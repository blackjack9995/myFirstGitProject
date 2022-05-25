// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
//pragma solidity  >=0.4.21 <0.9.0;

contract Wallet {
    // an array of address needed to approve the transaction.
    // minimum number of addreses required to approve the transaction
    address[] public approvers;
    uint256 public quorum;

    // defining the data structure
    struct Transfer {
        uint256 id;
        uint256 amount;
        address payable to;
        uint256 approvals;
        bool sent;
    }

    // container to hold all the transactions.
    // this can also be in a different way......... solution 1
    // mapping(uint => Transfer) public transfers;
    // uint256 public nextId;

    // using an array.............................. solution 2
    Transfer[] public transfers;

    // who approved what
    // here inside the nested mapping - uint256 = id
    mapping(address => mapping(uint256 => bool)) public approvals;

    constructor(address[] memory _approvers, uint256 _quorum) {
        approvers = _approvers;
        quorum = _quorum;
    }

    // get the list of approvers addresses
    function getApprovers() external view returns(address[] memory) {
        return approvers;
    }

    // get the list of trasfers 
    function getTransfers() external view returns(Transfer[] memory) {
        return transfers;
    }

    // tranfering the ether ............................. solution 1
    // function createTransfer(uint256 amount, address payable to) external {
    //     transfers[nextId] = Transfer(
    //         nextId,
    //         amount,
    //         to,
    //         0,
    //         false
    //     );
    //     nextId++;
    // }
    
    // ............................... solution 2
    function createTransfer(uint256 amount, address payable to) external onlyApprover {
        transfers.push(Transfer(
            transfers.length,
            amount,
            to,
            0,
            false
        ));
    }

    // approve the transfers
    function approveTransfer(uint id) external onlyApprover {
        require(transfers[id].sent == false, 'transfer has already been sent');
        require(approvals[msg.sender][id] == false, 'cannot approve transfer twice');

        approvals[msg.sender][id] == true;
        transfers[id].approvals++;

        if(transfers[id].approvals >= quorum) {
            transfers[id].sent = true;
            address payable to = transfers[id].to;
            uint amount = transfers[id].amount;
            to.transfer(amount); 
        }
    }

    // recieve ether ....... not the best way to do it
    //function sendEther() external payable {}

    // most native way to receive Ether in solidity
    receive() external payable {}

    // access control using function modifiers
    modifier onlyApprover() {
        bool allowed = false;
        for(uint i = 0; i < approvers.length; i++) {
            if(approvers[i] == msg.sender) {
                allowed = true;
            }
        }
        require(allowed == true, 'only approver is allowed');
        _;
    }
}