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

  

}
