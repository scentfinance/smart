//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";
import "hardhat/console.sol";

contract Battle {
    address private token;
    mapping(address => uint256) public balances;

    string[] private countries;
    mapping(string => string[]) private cities;

    struct Player {
        address player;
        uint32 soliders;
        uint32 tanks;
        uint32 generals;
        string[] countries;
        string[] cities;
    }
    mapping(address => Player) private players;

    constructor(string[] memory _countries, address _token) {
        console.log("Deploying a Battle with countries: ", _countries);
        countries = _countries;

        console.log("Deploying a Battle with main token: ", _token);
        token = _token;
    }

    function deposit(uint256 _amount) external {
        require(
            IERC20(token).transferFrom(msg.sender, address(this), _amount),
            "Transfer from failed"
        );
        balances[msg.sender] = balances[msg.sender].add(_amount);
        emit Deposit(msg.sender, _amount);
    }

    function withdraw(uint256 _amount) external {
        require(balances[msg.sender] >= _amount, "Withdraw amount failed");
        require(IERC20(token).transfer(msg.sender, _amount), "Transfer failed");
        balances[msg.sender] = balances[msg.sender].sub(_amount);
        emit Withdraw(msg.sender, _amount);
    }

    function registerPlayer(
        uint32 _soliders,
        uint32 _tanks,
        uint32 _generals,
        string[] _countries,
        string[] _cities
    ) external {
        require(players.length() <= 5, "All players joined");
        players[msg.sender] = Player(
            msg.sender,
            _soldiers,
            _tanks,
            _generals,
            _countries,
            _cities
        );
    }

    function reset(string[] memory _countries, address _token) {
        console.log("Deploying a Battle with countries: ", _countries);
        countries = _countries;

        console.log("Deploying a Battle with main token: ", _token);
        token = _token;

        players = [];
    }

    function greet() public view returns (string memory) {
        return greeting;
    }

    function setGreeting(string memory _greeting) public {
        console.log("Changing greeting from '%s' to '%s'", greeting, _greeting);
        greeting = _greeting;
    }
}
