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

  function apply(bytes32 listingHash, uint256 amount, string data) external {

    require(!IsWhitelisted(listingHash), "Listing is already whitelisted");
    require(!appWasMade(listingHash), "Listing is already in apply mode");
    require(amount >= minDeposit, "Not enough stake for app");

    Listing storage listing = listings[listingHash];

    listing.owner = msg.sender;
    listing.data = data;
    listingNames.push(listing.data);
    listing.arrIndex = listingNames.length - 1;

    listing.applicationExpiry = now.add(applyStageLen);

    listing.deposit = amount;

    require(token.transferFrom(listing.owner, this, amount), "Token transfer failed");

    emit Application(listingHash, amount, data, msg.sender);

  }

  function challenge(bytes32 _listingHash, uint _amount)
      external returns (uint challengeId) {

    Listing storage listing = listings[_listingHash];

    require(appWasMade(_listingHash) || listing.whitelisted, "Listing does not exist.");

    require(listing.challengeId == 0 || challenges[listing.challengeId].resolved, "Listing is already challenged.");

    require(listing.applicationExpiry > now, "Apply stage has passed.");

    require(_amount >= listing.deposit, "Not enough stake passed for challenge.");

    pollNonce = pollNonce.add(1);

    challenges[pollNonce] = Challenge({

      challenger: msg.sender,
      stake: _amount,
      resolved: false,
      totalTokens: 0,
      rewardPool: 0

    });

    polls[pollNonce] = Poll({

      votesFor: 0,
      votesAgainst: 0,
      passed: false,
      commitEndDate: now.add(commitStageLen)

    });

    listing.challengeId = pollNonce;

    require(token.transferFrom(msg.sender, this, _amount), "Token transfer failed.");

    emit Challenge(_listingHash, pollNonce, msg.sender);

    return pollNonce;

  }

  function vote(bytes32 _listingHash, uint _amount, bool _choice) public {

    Listing storage listing = listings[_listingHash];

    require(appWasMade(_listingHash) || listing.whitelisted, "Listing does not exist.");

    require(listing.challengeId > 0 && !challenges[listing.challengeId].resolved, "Listing is not challenged.");

    Poll storage poll = polls[listing.challengeId];

    require(poll.commitEndDate > now, "Commit period has passed.");

    require(token.transferFrom(msg.sender, this, _amount), "Token transfer failed.");

    if(_choice) {

      poll.votesFor = poll.votesFor.add(_amount);

    } else {

      poll.votesAgainst = poll.votesAgainst.add(_amount);

    }

    poll.votes[msg.sender] = Vote({
      value: _choice,
      stake: _amount,
      claimed: false
    });

    emit Vote(_listingHash, listing.challengeId, msg.sender);

  }

  function updateStatus(bytes32 _listingHash) public {

    if (canBeWhitelisted(_listingHash)) {

      listings[_listingHash].whitelisted = true;

    } else {

      resolveChallenge(_listingHash);

    }
    
  }

  function endPoll(uint challengeId) private returns (bool didPass) {

    require(polls[challengeId].commitEndDate > 0, "Poll does not exist.");
    Poll storage poll = polls[challengeId];

    /* solium-disable-next-line security/no-block-members */
    require(poll.commitEndDate < now, "Commit period is active.");

    if (poll.votesFor >= poll.votesAgainst) {

        poll.passed = true;

      } else {

        poll.passed = false;

    }

    return poll.passed;

  }

  function resolveChallenge(bytes32 _listingHash) private {

    Listing memory listing = listings[_listingHash];

    require(listing.challengeId > 0 && !challenges[listing.challengeId].resolved,
        "Listing is not challenged.");

    uint challengeId = listing.challengeId;

    bool pollPassed = endPoll(challengeId);

    challenges[challengeId].resolved = true;

    address challenger = challenges[challengeId].challenger;

    if (pollPassed) {

      challenges[challengeId].totalTokens = polls[challengeId].votesFor;
      challenges[challengeId].rewardPool = challenges[challengeId].stake + polls[challengeId].votesAgainst;
      listings[_listingHash].whitelisted = true;

    } else {

      require(token.transfer(challenger, challenges[challengeId].stake), "Challenge stake return failed.");

      challenges[challengeId].totalTokens = polls[challengeId].votesAgainst;
      challenges[challengeId].rewardPool = listing.deposit + polls[challengeId].votesFor;

      delete listings[_listingHash];
      delete listingNames[listing.arrIndex];

    }

    emit _ResolveChallenge(_listingHash, challengeId, msg.sender);

  }

  function claimRewards(uint challengeId) public {

    require(challenges[challengeId].resolved == true, "Challenge is not resolved.");

    Poll storage poll = polls[challengeId];
    Vote storage voteInstance = poll.votes[msg.sender];

    require(voteInstance.claimed == false, "Vote reward is already claimed.");

    if((poll.passed && voteInstance.value) || (!poll.passed && !voteInstance.value)) {

      uint reward = (challenges[challengeId].rewardPool.div(challenges[challengeId].totalTokens)).mul(voteInstance.stake);
      uint total = voteInstance.stake.add(reward);

      require(token.transfer(msg.sender, total), "Voting reward transfer failed.");

      emit _RewardClaimed(challengeId, total, msg.sender);

    }

    voteInstance.claimed = true;

  }

  //GETTERS

  function isWhitelisted(bytes32 listingHash) public view returns (bool whitelisted) {

    return listings[listingHash].whitelisted;

  }

  function appWasMade(bytes32 listingHash) public view returns (bool exists) {

    return listings[listingHash].applicationExpiry > 0;

  }

  function getAllListings() public view returns (string[]) {

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
