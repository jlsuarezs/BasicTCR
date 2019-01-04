pragma solidity 0.5.0;
pragma experimental ABIEncoderV2;

contract ITCR {

  function _apply(bytes32 listingHash, uint256 amount, string memory _data) public;

  function challenge(bytes32 _listingHash, uint _amount)
      external returns (uint challengeId);

  function vote(bytes32 _listingHash, uint _amount, bool _choice) public;

  function updateStatus(bytes32 _listingHash) public;

  function endPoll(uint challengeId) private returns (bool didPass);

  function resolveChallenge(bytes32 _listingHash) private;

  function claimRewards(uint challengeId) public;


  function isWhitelisted(bytes32 listingHash) public view returns (bool whitelisted);

  function appWasMade(bytes32 listingHash) public view returns (bool exists);

  function getAllListings() public view returns (string[] memory);

  function getDetails() public view returns (string memory, address, uint256, uint256, uint256);

  function getListingDetails(bytes32 listingHash) public view returns (bool, address, uint256, uint256, string memory);

  function canBeWhitelisted(bytes32 listingHash) public view returns (bool);

}
