pragma solidity 0.4.24;
pragma experimental ABIEncoderV2;

contract ITCR {

  //Events

  event Application(bytes32 indexed listingHash, uint deposit, string data, address indexed applicant);
  event Challenge(bytes32 indexed listingHash, uint challengeId, address indexed challenger);
  event Vote(bytes32 indexed listingHash, uint challengeId, address indexed voter);
  event ResolveChallenge(bytes32 indexed listingHash, uint challengeId, address indexed resolver);
  event RewardClaimed(uint indexed challengeId, uint reward, address indexed voter);

  function isWhitelisted(bytes32 listingHash) public view returns (bool whitelisted);

  function appWasMade(bytes32 listingHash) public view returns (bool exists);

  function getAllListings() public view returns (string[]);

  function getDetails() public view returns (string, address, uint256, uint256, uint256);

  function getListingDetails(bytes32 listingHash) public view returns (bool, address, uint256, uint256, string);

  function canBeWhitelisted(bytes32 listingHash) public view returns (bool);

}
