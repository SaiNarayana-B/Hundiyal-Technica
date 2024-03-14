// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Hundiyal {
    
    uint256 public Id;
    uint256 public lendersId;
  
    struct lender {
        address payable lenderAddress;
        string name;
        uint256 userId;
        bool created;
        string addr;
        string contactNumber;
        uint256 poolCapacity;
    }
    
    struct request {
        address payable requesterAddress;
        string name;
        string mobile;
        string permanentAddress;
        uint256 loanId;
        address payable lender;
        uint256 loanAmount;
        uint256 repaymentPeriod;
        uint256 settledAmount;
    }
    
    struct userLoan {
        uint256 loanId;
        address lender;
        uint256 loanAmount;
        uint256 repaymentPeriod;
    }
    
    struct loanRequest {
        uint256 loanId;
        address requester;
        uint256 loanAmount;
        string contactAddress;
    }
    
    struct requestStatus {
        uint256 loanId;
        bool isApproved;
        bool isExists;
        bool isEnded;
        uint256 dateApproved;
    }
    
    mapping(address => loanRequest[]) private lenderRequests;
    mapping(address => userLoan[]) private userLoans;
    mapping(address => lender) public lenders;
    mapping(address => mapping(uint256 => request)) private loanRequests;
    mapping(address => mapping(uint256 => requestStatus)) private loanRequestsStatus;
    lender[] public allLenders;

    constructor() {
        Id = 0;
        lendersId = 0;
    }

    function registerLender(string memory _name, string memory _address, string memory _contactNumber, uint256 _poolCapacity) public {
        require(!lenders[msg.sender].created, "Account is Already Created");
    
        lender memory newLender = lender(payable(msg.sender), _name, lendersId++, true, _address, _contactNumber, _poolCapacity);
        allLenders.push(newLender);
        
        lenders[msg.sender] = newLender;
    }

    function requestLoan(string memory _name, string memory _contactNumber, string memory _address, address _lender, uint256 _amount, uint256 _repaymentPeriod) public {
        require(lenders[_lender].created, "Lender is not Existed");
          
        uint256 _loanId = Id++;
        loanRequest memory req = loanRequest(_loanId, msg.sender, _amount, _address);
        userLoan memory loan = userLoan(_loanId, _lender, _amount, _repaymentPeriod);
        userLoans[msg.sender].push(loan);
        lenderRequests[_lender].push(req);
        loanRequests[_lender][_loanId] = request(payable(msg.sender), _name, _contactNumber, _address, _loanId, payable(_lender), _amount, _repaymentPeriod, 0);
        loanRequestsStatus[_lender][_loanId] = requestStatus(_loanId, false, true, false, 0);
        loanRequests[msg.sender][_loanId] = loanRequests[_lender][_loanId];
        loanRequestsStatus[msg.sender][_loanId] = loanRequestsStatus[_lender][_loanId];
    }

    function approveLoan(uint256 _loanId) public payable {
        require(loanRequestsStatus[msg.sender][_loanId].isExists, "Loan with this Id does not exist");
        require(!loanRequestsStatus[msg.sender][_loanId].isApproved, "Loan with this Id is already approved");
        require(msg.value == loanRequests[msg.sender][_loanId].loanAmount, "Amount is less than LoanAmount");
           
        payable(loanRequests[msg.sender][_loanId].requesterAddress).transfer(msg.value);
        loanRequestsStatus[msg.sender][_loanId].isApproved = true;
        loanRequestsStatus[msg.sender][_loanId].dateApproved = block.timestamp;

        loanRequestsStatus[loanRequests[msg.sender][_loanId].requesterAddress][_loanId].isApproved = true;
        loanRequestsStatus[loanRequests[msg.sender][_loanId].requesterAddress][_loanId].dateApproved = block.timestamp;
    }

    function repayAmount(uint256 _loanId, uint256 _amount) public payable {
        require(loanRequestsStatus[msg.sender][_loanId].isExists, "LoanId is not Existed");
        require(!loanRequestsStatus[msg.sender][_loanId].isEnded, "LoanId is Ended");
        require(loanRequestsStatus[msg.sender][_loanId].isApproved, "Loan with this Id is not Approved Yet");
        require(loanRequests[msg.sender][_loanId].settledAmount < loanRequests[msg.sender][_loanId].loanAmount, "Amount is already settled");
        require(loanRequests[msg.sender][_loanId].settledAmount + _amount <= loanRequests[msg.sender][_loanId].loanAmount, "Settling amount is greater than loan Amount");
        require(_amount <= loanRequests[msg.sender][_loanId].loanAmount, "Amount is Greater than LoanAmount");
        require(msg.value == _amount);
         
        loanRequests[msg.sender][_loanId].lender.transfer(msg.value);
        loanRequests[msg.sender][_loanId].settledAmount += _amount;
        loanRequests[loanRequests[msg.sender][_loanId].lender][_loanId].settledAmount += _amount;
    }

    function endLoan(uint256 _loanId) public {
        require(loanRequestsStatus[msg.sender][_loanId].isExists, "Loan with this Id not Exists");
        require(loanRequestsStatus[msg.sender][_loanId].isApproved, "Loan with this Id is not Approved Yet");
        require(!loanRequestsStatus[msg.sender][_loanId].isEnded, "Loan with this Id is already Ended");
        require(loanRequests[msg.sender][_loanId].settledAmount == loanRequests[msg.sender][_loanId].loanAmount, "Loan amount is not Fully Settled Yet");
    
        loanRequestsStatus[loanRequests[msg.sender][_loanId].lender][_loanId].isEnded = true;
        loanRequestsStatus[msg.sender][_loanId].isEnded = true;
    }

    function loanDetails(uint256 _loanId) public view returns(uint256, address, string memory, string memory, string memory, address, uint256) {
        return (
            loanRequests[msg.sender][_loanId].loanId,
            loanRequests[msg.sender][_loanId].requesterAddress,
            loanRequests[msg.sender][_loanId].name,
            loanRequests[msg.sender][_loanId].mobile, 
            loanRequests[msg.sender][_loanId].permanentAddress,
            loanRequests[msg.sender][_loanId].lender,
            loanRequests[msg.sender][_loanId].loanAmount
        );
    }
   
    function loanStatus(uint256 _loanId) public view returns(uint256, uint256, bool, bool, bool, uint256) {
        return (
            loanRequests[msg.sender][_loanId].repaymentPeriod,
            loanRequests[msg.sender][_loanId].settledAmount,
            loanRequestsStatus[msg.sender][_loanId].isApproved,
            loanRequestsStatus[msg.sender][_loanId].isExists,
            loanRequestsStatus[msg.sender][_loanId].isEnded,
            loanRequestsStatus[msg.sender][_loanId].dateApproved
        );
    }

    function getMyLoans(uint256 _index) public view returns(uint256, address, uint256, uint256) {
        return (
            userLoans[msg.sender][_index].loanId,
            userLoans[msg.sender][_index].lender,
            userLoans[msg.sender][_index].loanAmount,
            userLoans[msg.sender][_index].repaymentPeriod
        );
    }

    function getRequests(uint256 _index) public view returns(uint256, address, uint256, string memory) {
        return (
            lenderRequests[msg.sender][_index].loanId,
            lenderRequests[msg.sender][_index].requester,
            lenderRequests[msg.sender][_index].loanAmount,
            lenderRequests[msg.sender][_index].contactAddress
        );
    }

    function getMyLoansLength() public view returns(uint256) {
        return userLoans[msg.sender].length;
    }

    function getRequestsLength() public view returns(uint256) {
        return lenderRequests[msg.sender].length;
    }

    function getAllLendersLength() public view returns(uint256) {
        return allLenders.length;
    }
}
