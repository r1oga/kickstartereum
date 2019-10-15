from . import Campaign

struct Project:
  projectAddress: address
  title: bytes32

projects: public(Project[1000])
projectsCount: public(uint256)

@public
def createCampaign(minimum: uint256, title: bytes32):
  newProject: Project = Project(address(Campaign(minimum, msg.sender)), title)
  projects.push(newProject)
  projectsCount += 1


# TODO Check create_forwarder_to!!
# https://vyper.readthedocs.io/en/latest/built-in-functions.html#create_forwarder_to
