//SPDX-License-Identifier: GNU Public License
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "hardhat/console.sol";

contract Battle {
    address private token;
    mapping(address => uint256) public balances;

    string[] private countries;
    mapping(string => string[]) private cities;

    struct Player {
        address player;
        uint32 soldiers;
        uint32 tanks;
        uint32 generals;
        string[] countries;
        string[] cities;
    }
    mapping(address => Player) private players;
    uint256 public players_count;

    constructor(string[] memory _countries, address _token) {
        countries = _countries;

        console.log("Deploying a Battle with main token: ", _token);
        token = _token;
        players_count = 0;
    }

    function deposit(uint256 _amount) external {
        require(
            IERC20(token).transferFrom(msg.sender, address(this), _amount),
            "Transfer from failed"
        );
        balances[msg.sender] = balances[msg.sender] + _amount;
        emit Deposit(msg.sender, _amount);
    }

    function withdraw(uint256 _amount) external {
        require(balances[msg.sender] >= _amount, "Withdraw amount failed");
        require(IERC20(token).transfer(msg.sender, _amount), "Transfer failed");
        balances[msg.sender] = balances[msg.sender] - _amount;
        emit Withdraw(msg.sender, _amount);
    }

    function registerPlayer(
        uint32 _soldiers,
        uint32 _tanks,
        uint32 _generals,
        string[] memory _countries,
        string[] memory _cities
    ) external {
        require(players_count <= 5, "All players joined");
        players[msg.sender] = Player(
            msg.sender,
            _soldiers,
            _tanks,
            _generals,
            _countries,
            _cities
        );
        players_count += 1;
    }

    function attack(address enemy) external {
        require(players[msg.sender].soldiers < 10, "Not enough soldiers");
        require(players[msg.sender].generals <= 0, "Should have a general");
        require(players[enemy].soldiers < 10, "Enemy has not enough soldiers");
        require(players[enemy].generals <= 0, "Enemy should have a general");

        players[msg.sender].soldiers -= 5;
        players[enemy].soldiers -= 5;
        emit Attack(msg.sender, enemy);
    }

    function reset(string[] memory _countries, address _token) public {
        countries = _countries;

        console.log("Deploying a Battle with main token: ", _token);
        token = _token;
    }

    function getCountries() public view returns (string[] memory) {
        return countries;
    }

    function getCities(string memory country)
        public
        view
        returns (string[] memory)
    {
        return cities[country];
    }

    function getTokenAddress() public view returns (address) {
        return token;
    }

    function getPlayerInfo(address player) public view returns (Player memory) {
        return players[player];
    }

    event Deposit(address holder, uint256 amount);
    event Withdraw(address holder, uint256 amount);
    event Attack(address from, address to);
}
