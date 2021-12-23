// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "hardhat/console.sol";

contract BattleV1 is Ownable{
    address public token;
    address public admin;
    mapping(address => uint256) public balances;

    string[] private countries;
    mapping(string => string[]) private cities;

    struct Player {
        address player;
        uint256 soldiers;
        uint256 tanks;
        uint256 generals;
        string[] countries;
        string[] cities;
    }
    mapping(address => Player) private players;
    mapping(address => bool) private playersCheckin;
    uint256 public players_count;

    constructor(
        string[] memory _countries,
        address _token,
        address _admin
    ) {
        countries = _countries;
        token = _token;
        admin = _admin;
        players_count = 0;
    }

    function deposit(uint256 _amount) external {
        require(IERC20(token).transferFrom(msg.sender, address(this), _amount), "Transfer from failed");
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
        uint256 _soldiers,
        uint256 _tanks,
        uint256 _generals,
        string[] memory _countries,
        string[] memory _cities
    ) external {
        require(players_count <= 5, "All players joined");
        require(playersCheckin[msg.sender] == false, "Player already registered");
        players[msg.sender] = Player(msg.sender, _soldiers, _tanks, _generals, _countries, _cities);
        playersCheckin[msg.sender] = true;
        players_count += 1;
        emit RegisterPlayer(msg.sender, _soldiers, _tanks, _generals, _countries, _cities);
    }

    function registerPlayerPayable(
        uint256 _soldiers,
        uint256 _tanks,
        uint256 _generals,
        string[] memory _countries,
        string[] memory _cities,
        uint256 _amount,
        uint256 _bonus
    ) external {
        require(players_count <= 5, "All players joined");
        require(playersCheckin[msg.sender] == false, "Player already registered");
        require(_soldiers >= 100, "Not enough soldiers");
        require(_tanks >= 5, "Not enough tanks");
        require(_generals == 1, "Should only have 1 general");
        require(_amount >= getMinimumPayableAmount(_soldiers, _generals, _tanks), "Not enough deposit");
        require(IERC20(token).transferFrom(msg.sender, address(this), _amount), "Transfer from failed");
        balances[msg.sender] = balances[msg.sender] + _amount;

        players[msg.sender] = Player(msg.sender, (_soldiers + _bonus), _tanks, _generals, _countries, _cities);
        playersCheckin[msg.sender] = true;
        players_count += 1;

        emit RegisterPlayerPayable(msg.sender, _soldiers, _tanks, _generals, _countries, _cities, _amount, _bonus);
    }

    function attack(
        address _enemy,
        uint256 _attacker,
        uint256 _defender
    ) external {
        require(players[msg.sender].soldiers >= 10, "Not enough soldiers");
        require(players[msg.sender].generals == 1, "Should have a general");
        require(players[_enemy].soldiers >= 10, "Enemy has not enough soldiers");
        require(players[_enemy].generals == 1, "Enemy should have a general");

        players[msg.sender].soldiers -= _attacker;
        players[_enemy].soldiers -= _defender;

        if (players[msg.sender].soldiers > players[_enemy].soldiers && players[_enemy].soldiers < 10) {
            _finish(msg.sender, _enemy);
        }

        if (players[msg.sender].soldiers < players[_enemy].soldiers && players[msg.sender].soldiers < 10) {
            _finish(_enemy, msg.sender);
        }

        emit Attack(msg.sender, _enemy);
    }

    function _finish(address _winner, address _loser) internal {
        balances[_winner] += (balances[_loser] * 5) / 10;
        balances[admin] += (balances[_loser] * 3) / 10;
    }

    function reset(string[] memory _countries, address _token) public {
        countries = _countries;
        token = _token;
        emit Reset(_countries, _token);
    }

    function getMinimumPayableAmount(
        uint256 _soldiers,
        uint256 _tanks,
        uint256 _generals
    ) private pure returns (uint256) {
        return _soldiers * 1 + _tanks * 5 + _generals * 1 + 100;
    }

    function getCountries() public view returns (string[] memory) {
        return countries;
    }

    function getCities(string memory country) public view returns (string[] memory) {
        return cities[country];
    }

    function getPlayerInfo(address player) public view returns (Player memory) {
        return players[player];
    }

    event Deposit(address holder, uint256 amount);
    event Withdraw(address holder, uint256 amount);
    event RegisterPlayer(
        address player,
        uint256 soldiers,
        uint256 tanks,
        uint256 generals,
        string[] countries,
        string[] cities
    );
    event RegisterPlayerPayable(
        address player,
        uint256 soldiers,
        uint256 tanks,
        uint256 generals,
        string[] countries,
        string[] cities,
        uint256 amount,
        uint256 bonus
    );
    event Attack(address from, address to);
    event Reset(string[] countries, address token);
}
