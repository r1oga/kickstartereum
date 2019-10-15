struct Request:
  description: bytes32
  amount: uint256
  recipient: address
  complete: bool
  approvals: map(address, bool)
  approvalsCount: uint256

contract Campaign():
  def contribute(): modifying
  def createRequest(): modifying
  def approveRequest(): modifying
  def finalizeRequest(): modifying
  def getSummary(): constant

MAX_APPROVALS: constant(uint256) = 1000


founder: public(address)
minContribution: public(wei_value)
backers: address[1000] # limit backers to 1000
backersCount: public(uint256)

requests: public(map(uint256, Request))
requestsCount: public(uint256)

@public
def __init__(_minContribution: uint256, _founder: address):
    self.founder = _founder
    self.minContribution = _minContribution

@public
@payable
def contribute():
    assert msg.value > self.minContribution, 'Contribution smaller than minimum'
    self.backers[self.backersCount] = msg.sender
    self.backersCount = self.backersCount + 1

@public
def createRequest(_description: bytes32,
                  _amount: uint256,
                  _recipient: address):
    assert msg.sender == self.founder, 'Only founder can create requests'
    self.requests[self.requestsCount].description = _description
    self.requests[self.requestsCount].amount = _amount
    self.requests[self.requestsCount].recipient = _recipient
    self.requestsCount = self.requestsCount + 1



@public
def approveRequest(index: uint256):
    assert not self.requests[index].approvals[msg.sender], 'You can only prove a request once'
    self.requests[index].approvals[msg.sender] = True
    self.requests[index].approvalsCount += 1

@public
def finalizeRequest(index: uint256):
    assert not self.requests[index].complete, 'This request has already been finalized'
    assert self.requests[index].approvalsCount > self.backersCount/2, 'Not enough backers have approved this request yet'
    self.requests[index].complete = True
    send(self.requests[index].recipient, self.requests[index].amount)

@public
@constant
def getSummary() -> (wei_value,
                     wei_value,
                     uint256,
                     uint256,
                     address):
    return (self.minContribution,
            self.balance,
            self.requestsCount,
            self.backersCount,
            self.founder)
