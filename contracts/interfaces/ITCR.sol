pragma solidity 0.4.24;

contract ITCR {

  //Events

  event _Application(bytes32 indexed listingHash, uint deposit, string data, address indexed applicant);
  event _Challenge(bytes32 indexed listingHash, uint challengeId, address indexed challenger);
  event _Vote(bytes32 indexed listingHash, uint challengeId, address indexed voter);
  event _ResolveChallenge(bytes32 indexed listingHash, uint challengeId, address indexed resolver);
  event _RewardClaimed(uint indexed challengeId, uint reward, address indexed voter);


}
