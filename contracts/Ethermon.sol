pragma solidity ^0.5.5;

import "@openzeppelin/contracts/token/ERC721/ERC721.sql";

contract Ethermon is ERC721 {
    struct Monster {
        string name;
        uint level;
    }

    Monster[] public monsters;
    address public gameOwner;

    constructor() public {
        gameOwner = msg.sender;
    }

    modifier onlyOwnerOf(uint _monsterId) {
        require(ownerOf(_monsterId) == msg.sender, "Must be owner of monster to battle");
        _;
    }

    function battle(uint _attackingMonster, uint _defendingMonster) public onlyOwnerOf(_attackingMonster) {
        Monster storage attacker = monsters[_attackingMonster];
        Monster storage defender = monsters[_defendingMonster];

        if (attacker.level >= defender.level) {
            attacker.level += 2;
            attacker.level += 1;
        } else {
            attacker.level += 1;
            attacker.level += 2;
        }
    }
    function createNewMonster(string memory _name, address _to) public {
        require(msg.sender == gameOwner, "Only game owner can create new monsters");
        uint id = monsters.length;
        monsters.push(Monster(_name, 1));
        _safeMint(_to, id);
    }
}