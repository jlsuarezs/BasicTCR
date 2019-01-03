pragma solidity 0.4.24;
pragma experimental ABIEncoderV2;

import "contracts/zeppelin/ERC20/ERC20.sol";
import "contracts/zeppelin/SafeMath.sol";

contract TCR {

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

}
