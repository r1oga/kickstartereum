pragma solidity ^0.5.1;

contract CampaignFactory {
    struct Project {
        address projectAddress;
        string title;
    }
    Project[] public projects;

    function createCampaign(uint minimum, string memory title) public {
        Project memory newProject = Project(address(new Campaign(minimum, msg.sender)), title);
        projects.push(newProject);
    }
    function getCampaignsCount() public view returns (uint) {
        return projects.length;
    }
}

contract Campaign {
    struct Request {
        string description;
        uint amount;
        address payable recipient;
        bool complete;
        mapping (address => bool) approvals;
        uint approvalsCount;
    }

    address public funder;
    uint public minimumContribution;
    mapping(address => bool) public backers;
    uint public backersCount;
    Request[] public requests;

    modifier mustPayMinimum() {
        require(msg.value > minimumContribution, "You must pay the minimum contribution");
        _;

    }
    modifier onlyFunder() {
        require(msg.sender == funder, "Only Funder can create Requests.");
        _;
    }
    modifier onlyBacker() {
        require(backers[msg.sender], 'Only backers can approve requests.');
        _;
    }

    constructor(uint minimum, address creator) public {
        funder = creator;
        minimumContribution = minimum;
    }


    function contribute() public payable mustPayMinimum {
        backers[msg.sender] = true;
        backersCount++;
    }

    function createRequest(
        string memory description,
        uint amount,
        address payable recipient
    )
        onlyFunder
        public
    {
        Request memory newRequest = Request({
            description: description,
            amount: amount,
            recipient: recipient,
            complete: false,
            approvalsCount: 0
        });
        requests.push(newRequest);
    }

    function approveRequest(uint index) public onlyBacker {
        Request storage request = requests[index];
        // check if hasn't voted yet
        require(!request.approvals[msg.sender], 'You can only approve a request once.');

        request.approvals[msg.sender] = true;
        request.approvalsCount++;
    }

    function finalizeRequest(uint index) public onlyFunder {
        Request storage request = requests[index];

        require(!request.complete, 'This request was already completed.');
        require(request.approvalsCount > backersCount/2, "Not enough backers have approved this request yet.");

        request.complete = true;
        request.recipient.transfer(request.amount);
    }

    function getSummary() public view returns (
      uint,
      uint,
      uint,
      uint,
      address
    )
    {
      return (
        minimumContribution,
        address(this).balance,
        requests.length,
        backersCount,
        funder
      );
    }

    function getRequestsCount() public view returns (uint) {
      return requests.length;
    }


}
