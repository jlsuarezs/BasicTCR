pragma solidity 0.4.24;

import "contracts/zeppelin/ERC20/StandardToken.sol";

contract TCRToken is StandardToken {

    address public owner;

    string public constant name = "TCRToken";
    string public constant symbol = "TCR";

    // Base variables

    uint256 public totalSupply;
    uint8 public constant decimals = 0;
    uint256 public constant initialSupply = 21000000;

    constructor() public {

        owner = msg.sender;

        totalSupply = initialSupply;

        balances[msg.sender] = initialSupply;

    }

}
