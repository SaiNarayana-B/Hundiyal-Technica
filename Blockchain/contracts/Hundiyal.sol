// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Hundiyal {
    uint private Id;
    uint private lendersId;

    struct Lender {
        address payable lenderAddress;
        string name;
        uint userId;
        bool created;
        string addr;
        string contactNumber;
        uint poolCapacity;
    }

    struct Request {
        address payable requesterAddress;
        string name;
        string mobile;
        string permanentAddress;
        uint loanId;
        address payable lender;
        uint loanAmount;
        uint repaymentPeriod;
        uint settledAmount;
    }

    struct UserLoan {
        uint loanId;
        address lender;
        uint loanAmount;
        uint repaymentPeriod;
    }

    struct LoanRequest {
        uint loanId;
        address requester;
        uint loanAmount;
        string contactAddress;
    }

    struct RequestStatus {
        uint loanId;
        bool isApproved;
        bool isExists;
        bool isEnded;
        uint dateApproved;
    }

    mapping(address => LoanRequest[]) private lenderRequests;
    mapping(address => UserLoan[]) private userLoans;
    mapping(address => Lender) public lenders;
    mapping(address => mapping(uint => Request)) private loanRequests;
    mapping(address => mapping(uint => RequestStatus)) private loanRequestsStatus;

    Lender[] public allLenders;

    // Events
    event LenderRegistered(address lenderAddress, string name, uint userId);
    event LoanRequested(uint loanId, address requester, uint amount);
    event LoanStatusUpdated(uint loanId, bool isApproved, bool isEnded);

    // Constructor
    constructor() {
        Id = 0; // Initialize the global ID
        lendersId = 0; // Initialize the lenders ID
    }

    // Function to register a new lender
    function registerLender(string memory _name, string memory _addr, string memory _contactNumber, uint _poolCapacity) public {
        require(!lenders[msg.sender].created, "Account is Already Created");

        Lender memory newLender = Lender({
            lenderAddress: payable(msg.sender),
            name: _name,
            userId: lendersId,
            created: true,
            addr: _addr,
            contactNumber: _contactNumber,
            poolCapacity: _poolCapacity
        });

        allLenders.push(newLender);
        
        lenders[msg.sender] = newLender;

        emit LenderRegistered(msg.sender, _name, lendersId);
        
        lendersId++; // Increment the lenders ID for the next registration
    }

    // Function to request a new loan (incomplete)
    function requestLoan(string memory _name, string memory _contactNumber, string memory _addr) public {
       // The rest of your function logic goes here...
       // Emit an event when a loan is requested
       emit LoanRequested(Id, msg.sender, 0); // Replace '0' with actual loan amount

       Id++; // Increment the global ID for the next request
   }


}

