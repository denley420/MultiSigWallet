// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

/*
##- Quorum should always be a majority
##- Only Contract owner can add signers
- Signers and contract owner can
##    * Submit transaction for approval
##    * View pending transactions
##    * Approve and revoke pending transactions
##    * If quorum is met, contract owner or any of the signers can execute the transactions
- Types of transactions
##    * Sending ETH
##    * Sending ERC20(create a basic ERC20)
*/

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract MultisigWallet is Ownable, AccessControl {
    bytes32 public constant SIGNERS_ROLE = keccak256("SIGNERS_ROLE");

    modifier onlySigners() {
        require(hasRole(SIGNERS_ROLE, _msgSender()));
        _;
    }
    
    using Strings for uint;
    address private ERC20Address;
    enum transferType { ETH, Token }
    uint public transactionId;
    address[] public signers;
    mapping(address => bool) public signersListed;

    Transactions[] public transactions;

    struct Transactions {
        string _description;
        address _receiver;
        uint _amount;
        uint _approve;
        uint _revoke;
        transferType _type;
        bool _complete;
        mapping(address => bool) _voter;
    }

    constructor() payable {
        _setupRole(SIGNERS_ROLE, _msgSender());
    }

    function addSigners(address _signers) public onlyOwner {
        require(!signersListed[_signers], "Signer Already Listed!");
        _grantRole(SIGNERS_ROLE, _signers);
        signers.push(_signers);
        signersListed[_signers] = true;
    }

    function createTransactionETH(string memory _description, address _receiver, uint _amount) public onlySigners {
        Transactions storage request = transactions.push();
        request._description = _description;
        request._amount = _amount;
        request._receiver = _receiver;
        request._type = transferType.ETH;
    }

    function createTransanctionERC20(string memory _description, address _receiver, uint _amount, address _tokenAddress) public onlySigners {
        ERC20Address = _tokenAddress;
        Transactions storage request = transactions.push();
        request._description = _description;
        request._amount = _amount;
        request._receiver = _receiver;
        request._type = transferType.Token;
    }

    function approveTransaction(uint _transactionId) public onlySigners {
        Transactions storage request = transactions[_transactionId];
        require(!request._voter[_msgSender()], "Already Voted!");
        request._approve += 1;
        request._voter[_msgSender()] = true;
    }

    function revokeTransaction(uint _transactionId) public onlySigners {
        Transactions storage request = transactions[_transactionId];
        require(request._voter[_msgSender()], "You haven't voted yet");
        request._approve -= 1;
        request._voter[_msgSender()] = true;
    }

    function viewTransactions(uint _transactionId) public view returns (string memory, address, uint, uint, uint, transferType, bool) {
        require(_transactionId <= transactionId, "Transaction ID does not exist!");
        Transactions storage request = transactions[_transactionId];
        return (request._description, request._receiver, request._amount, request._approve, request._revoke, request._type, request._complete);
    }

    function executeTransactions(uint _transactionId) public onlySigners {
        Transactions storage request = transactions[_transactionId];
        require(!request._complete, "Transaction already Complete!");
        require(request._approve / signers.length * 100 > 50, "Quorum did not met");
        if (request._type == transferType.ETH) {
            payable(request._receiver).transfer(request._amount);
        } else {
            IERC20(ERC20Address).transfer(request._receiver, request._amount);
        }
        request._complete = true;
    }

    function viewPendingTransactions() public view returns(string memory) {
        bytes memory pendingTransactions;
        for (uint i = 0; i < transactions.length; i++) {
            if (!transactions[i]._complete) {
                pendingTransactions = abi.encodePacked(pendingTransactions, '\n', 'Transaction ID:', i.toString(), 'Reason:', transactions[i]._description, '');
            }
        }
        return string(pendingTransactions);
    }

}