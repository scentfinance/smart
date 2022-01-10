// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "hardhat/console.sol";

/// @author flashdebugger
/// @title battle contract for strategic game
contract Battle is Ownable {
    struct Player {
        address player;
        uint256 soldiers;
        uint256 tanks;
        uint256 generals;
        string country;
    }
    address public token;
    address[] public allPlayers;
    string[] public allCountries;
    mapping(address => mapping(string => uint256)) public balances;
    mapping(address => mapping(string => Player)) public players;
    mapping(address => string[]) public countriesOfPlayer;
    mapping(string => address) public ownerOfCountry;
    mapping(address => bool) public playersCheckin;
    uint256 public playersCount;
    uint256 public fee;
    uint256 public COUNTRY_SUPPORT = 100;
    uint256 public totalBalance;

    event Deposit(address holder, uint256 amount, string country);
    event Withdraw(address holder, uint256 amount, string country);
    event WithdrawAll(address holder, uint256 amount);
    event EmegencyWithdraw(address owner, uint256 amount);
    event RegisterPlayerPayable(
        address player,
        uint256 soldiers,
        uint256 tanks,
        uint256 generals,
        string country,
        uint256 amount,
        uint256 bonus
    );
    event Attack(
        address from,
        string countryFrom,
        address to,
        string countryTo,
        uint256 attackerPoint,
        uint256 defenderPoint
    );
    event Reset(address token, uint256 fee);

    constructor(string[] memory _countries, address _token) {
        allCountries = _countries;
        token = _token;
        fee = 10 ether;
        playersCount = 0;
    }

    function deposit(uint256 _amount, string memory _country) external {
        require(ownerOfCountry[_country] == msg.sender, "It's not your country");
        require(IERC20(token).transferFrom(msg.sender, address(this), _amount), "Transfer from failed");
        balances[msg.sender][_country] += _amount;
        emit Deposit(msg.sender, _amount, _country);
    }

    function withdraw(uint256 _amount, string memory _country) external {
        require(ownerOfCountry[_country] == msg.sender, "It's not your country");
        require(balances[msg.sender][_country] >= _amount, "Not enough withdraw amount");
        require(IERC20(token).transfer(msg.sender, _amount), "Transfer failed");
        balances[msg.sender][_country] -= _amount;
        emit Withdraw(msg.sender, _amount, _country);
    }

    function withdrawAll() external {
        uint256 total;
        for (uint256 i = 0; i < countriesOfPlayer[msg.sender].length; i++) {
            total += balances[msg.sender][countriesOfPlayer[msg.sender][i]];
            balances[msg.sender][countriesOfPlayer[msg.sender][i]] = 0;
        }
        require(total > fee, "Nothing to withdraw");
        require(IERC20(token).transfer(msg.sender, total - fee), "Transfer failed");
        require(IERC20(token).transfer(owner(), fee), "Transfer failed");
        emit WithdrawAll(msg.sender, total);
    }

    function emegencyWithdraw() public onlyOwner {
        require(totalBalance >= 10, "Not enough total balance");
        require(IERC20(token).transfer(msg.sender, totalBalance), "Transfer failed");
        totalBalance = 0;
        emit EmegencyWithdraw(msg.sender, totalBalance);
    }

    function registerPlayerPayable(
        uint256 _soldiers,
        uint256 _tanks,
        uint256 _generals,
        string memory _country,
        uint256 _amount,
        uint256 _bonus
    ) external {
        // TODO: check if _country is in the allCountries list
        require(playersCount <= 5, "All players joined");
        require(playersCheckin[msg.sender] == false, "Player already registered");
        require(_soldiers >= 100, "Not enough soldiers");
        require(_tanks >= 10, "Not enough tanks");
        require(_generals == 1, "Should only have 1 general");
        require(_amount >= getMinimumPayableAmount(_soldiers, _tanks, _generals), "Not enough amount for deposit");
        require(IERC20(token).transferFrom(msg.sender, address(this), _amount - fee), "Transfer from failed");
        require(IERC20(token).transfer(owner(), fee), "Transfer failed");
        balances[msg.sender][_country] += _amount;
        totalBalance += _amount;

        players[msg.sender][_country] = Player(msg.sender, _soldiers + _bonus, _tanks, _generals, _country);
        ownerOfCountry[_country] = msg.sender;
        countriesOfPlayer[msg.sender].push(_country);

        allPlayers.push(msg.sender);
        playersCheckin[msg.sender] = true;
        playersCount += 1;

        emit RegisterPlayerPayable(msg.sender, _soldiers, _tanks, _generals, _country, _amount, _bonus);
    }

    function attack(
        string memory _attackerCountry,
        address _enemy,
        string memory _enemyCountry,
        uint256 _attackerPoint,
        uint256 _defenderPoint
    ) external {
        // TODO: use encoding as anyone can call this
        require(players[msg.sender][_attackerCountry].soldiers >= 100, "Attacker has not enough soldiers");
        require(players[msg.sender][_attackerCountry].generals == 1, "Attacker should have a general");
        require(players[_enemy][_enemyCountry].soldiers >= 100, "Enemy has not enough soldiers");
        require(players[_enemy][_enemyCountry].generals == 1, "Enemy should have a general");
        // TODO: check if attacker and defender have enough amount of tokens

        require(IERC20(token).transfer(owner(), _attackerPoint / 10 + _defenderPoint / 10), "Transfer failed");
        players[msg.sender][_attackerCountry].soldiers -= _attackerPoint;
        players[_enemy][_enemyCountry].soldiers -= _defenderPoint;

        if (
            players[msg.sender][_attackerCountry].soldiers > players[_enemy][_enemyCountry].soldiers &&
            players[_enemy][_enemyCountry].soldiers < 12
        ) {
            _finish(msg.sender, _attackerCountry, _enemy, _enemyCountry);
        }

        if (
            players[msg.sender][_attackerCountry].soldiers < players[_enemy][_enemyCountry].soldiers &&
            players[msg.sender][_attackerCountry].soldiers < 12
        ) {
            _finish(_enemy, _enemyCountry, msg.sender, _attackerCountry);
        }

        emit Attack(msg.sender, _attackerCountry, _enemy, _enemyCountry, _attackerPoint, _defenderPoint);
    }

    function _finish(
        address _winner,
        string memory _winnerCountry,
        address _loser,
        string memory _loserCountry
    ) internal {
        // check balance
        require(IERC20(token).transfer(owner(), (balances[_loser][_loserCountry] * 2) / 10), "Transfer failed");
        balances[_winner][_winnerCountry] += (balances[_loser][_loserCountry] * 3) / 10;

        // check player soldiers
        players[_winner][_winnerCountry].soldiers += 100; // TODO: re calc
        players[_loser][_loserCountry].soldiers += 50; // TODO: re calc

        // check countries
        countriesOfPlayer[_winner].push(_loserCountry);
        // countriesOfPlayer[_loser] - _loserCountry <= TODO

        // init winner's new country
        players[_winner][_loserCountry].soldiers = 100;
        players[_winner][_loserCountry].generals = 1;
        players[_winner][_loserCountry].tanks = 10;
        players[_winner][_loserCountry].country = _loserCountry;
        players[_winner][_loserCountry].player = _winner;
    }

    function reset(address _token, uint256 _fee) public onlyOwner {
        // TODO: reset balances, players, countriesOfPlayer, ownerOfCountry, allCountries, and playersCheckin
        token = _token;
        fee = _fee;
        playersCount = 0;
        emit Reset(_token, _fee);
    }

    /// @dev retrieves the sum of each payable amount
    /// @return the minimum payable value for registered player info
    function getMinimumPayableAmount(
        uint256 _soldiers,
        uint256 _tanks,
        uint256 _generals
    ) public view returns (uint256) {
        return (_soldiers * 1 + _tanks * 10 + _generals * 100 + COUNTRY_SUPPORT) * 1 ether + fee;
    }

    /// @return all countries
    function getAllCountries() public view returns (string[] memory) {
        return allCountries;
    }

    /// @return all players list
    function getAllPlayers() public view returns (address[] memory) {
        return allPlayers;
    }

    /// @dev retrieves the value of the state variable `countriesOfPlayer`
    /// @return the countries that player has
    function getPlayerCountries(address _player) public view returns (string[] memory) {
        return countriesOfPlayer[_player];
    }

    /// @dev retrieves the value of the state variable `players`
    /// @return the player info for given country name
    function getPlayerCountryInfo(address _player, string memory _country) public view returns (Player memory) {
        return players[_player][_country];
    }
}
