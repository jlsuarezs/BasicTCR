pragma solidity 0.4.24;
pragma experimental ABIEncoderV2;

import "contracts/zeppelin/ERC20/ERC20.sol";
import "contracts/zeppelin/SafeMath.sol";

import "contracts/interfaces/ITCR.sol";

contract TCR is ITCR {

  using SafeMath for uint256;

  struct Listing {

    uint256 applicationExpiry;
    bool whitelisted;
    address owner;
    uint256 deposit;
    uint256 challengeId;
    string data;
    uint256 arrIndex;

  }

  struct Vote {

    bool value;
    uint stake;
    bool claimed;

  }

  struct Poll {

    uint256 votedFor;
    uint256 votesAgainst;
    uint26 commitEndDate;
    bool passed;

    mapping(address => Vote) votes;

  }

  struct Challenge {

    address challenger;
    bool resolved;
    uint256 stake;
    uint256 rewardPool;
    uint256 totalTokens;

  }

  mapping(uint256 => Challenge) private challenges;

  mapping(bytes32 => Listing) private listings;

  mapping(uint256 => Poll) private polls;

  string[] public listingNames;

  ERC20 public token;

  string public name;

  uint256 public minDeposit;
  uint256 public applyStageLen;
  uint256 public commitStageLen;

  uint256 constant private INITIAL_POLL_NONCE = 0;
  uint256 public pollNonce;

  constructor(string _name, address _token, uint256[] parameters) {

    require(_token != address(0), "The token address shold not be zero");

    token = ERC20(_token);

    name = _name;

    minDeposit = parameters[0];

    applyStageLen = parameters[1];

    commitStageLen = parameters[2];

    pollNonce = INITIAL_POLL_NONCE;

  }

  //GETTERS

  function isWhitelisted(bytes32 listingHash) public view returns (bool whitelisted) {

    return listings[listingHash].whitelisted;

  }

  function appWasMade(bytes32 listingHash) public view returns (bool exists) {

    return listings[listingHash].applicationExpiry > 0;

  }

  function getALlListings() public view returns (string[]) {

    string[] memory listingArr = new string[](listingNames.length);

    for (uint256 i = 0; i < listingNames.length; i++) {

      listingArr[i] = listingNames[i];

    }

    return listingArr;

  }

  function getDetails() public view returns (string, address, uint256, uint256, uint256) {

    return (name, token, minDeposit, applyStageLen, commitStageLen);

  }

  function getListingDetails(bytes32 listingHash) public view returns (bool, address, uint256, uint256, string) {

    Listing memory listingIns = listings[listingHash];

    require(appWasMade(listingHash) || listingIns.whitelisted, "Listing does not exist");

    return (listingIns.whitelisted, listingIns.owner,
      listingIns.deposit, listingIns.challengeId, listingIns.data);

  }

  function canBeWhitelisted(bytes32 listingHash) public view returns (bool) {

    uint256 challengeId = listings[listingHash].challengeId;

    return (appWasMade(listingHash) &&
            listings[listingHash].applicationExpiry < now &&
            !isWhitelisted(listingHash) &&
            (challengeId == 0 || challenges[challengeId].resolved == true));

  }

}
