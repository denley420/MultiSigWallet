// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

/*
##- Quorum should always be a majority
##- Only Contract owner can add signers
- Signers and contract owner can
##    * Submit transaction for approval
##   * View pending transactions
##   * Approve and revoke pending transactions
##    * If quorum is met, contract owner or any of the signers can execute the transactions
- Types of transactions
##    * Sending ETH
##    * Sending ERC20(create a basic ERC20)
*/

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract MultisigWallet is Ownable, AccessControl {
    bytes32 public constant SIGNERS_ROLE = keccak256("SIGNERS_ROLE");

    modifier onlySigners() {
        require(hasRole(SIGNERS_ROLE, _msgSender()));
        _;
    }
    
    address private ERC20Address;
    enum transferType { ETH, Token }
    uint public transactionId;
    address[] public signers;
    mapping(address => bool) public signersListed;
    mapping(uint => Transactions) public transact;

    struct Transactions {
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

    function createTransactionETH(address _receiver, uint _amount) public onlySigners {
        Transactions storage request = transact[transactionId];
        request._amount = _amount;
        request._receiver = _receiver;
        request._type = transferType.ETH;
        transactionId++;
    }

    function createTransanctionERC20(address _receiver, uint _amount, address _tokenAddress) public onlySigners {
        ERC20Address = _tokenAddress;
        Transactions storage request = transact[transactionId];
        request._amount = _amount;
        request._receiver = _receiver;
        request._type = transferType.Token;
        transactionId++;
    }

    function approveTransaction(uint _transactionId) public onlySigners {
        Transactions storage request = transact[_transactionId];
        require(!request._voter[_msgSender()], "Already Voted!");
        request._approve += 1;
        request._voter[_msgSender()] = true;
    }

    function revokeTransaction(uint _trasactionId) public onlySigners {
        Transactions storage request = transact[_trasactionId];
        require(!request._voter[_msgSender()], "Already Voted!");
        request._revoke += 1;
        request._voter[_msgSender()] = true;
    }

    function viewTransactions(uint _transactionId) public view returns (address, uint, uint, uint, transferType, bool) {
        require(_transactionId <= transactionId, "Transaction ID does not exist!");
        Transactions storage request = transact[_transactionId];
        return (request._receiver, request._amount, request._approve, request._revoke, request._type, request._complete);
    }

    function executeTransactions(uint _transactionId) public onlySigners {
        Transactions storage request = transact[_transactionId];
        require(!request._complete, "Transaction already Complete!");
        require(request._approve / signers.length * 100 > 50, "Quorum did not met");
        if (request._type == transferType.ETH) {
            payable(request._receiver).transfer(request._amount);
        } else {
            IERC20(ERC20Address).transfer(request._receiver, request._amount);
        }
    }

}