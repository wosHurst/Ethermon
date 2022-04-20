## ERC-721 Ethermon 游戏

### 游戏逻辑描述：

- 每个Ethermon都归个人所有
- 从第一级开始
- 和其他口袋妖怪战斗
- 通过战斗升级

需要围绕战斗一些逻辑：假设如果一个Ethermon攻击另外一个，则级别更高的Ethermon获胜，吐过级别相同，则攻击者获胜。战斗的胜利者上升两级，失败者升一级。

### ERC721 有什么用呢 ?

[ERC-721标准](https://learnblockchain.cn/docs/eips/eip-721.html)描述了任何不可替代令牌都必须遵守的接口才能被视为ERC-721。

幸运的是，我们每次创建ERC-721时都不需要创建新代码来满足该标准。 使用社区维护如[OpenZeppelin对我们来说是一个捷径。

让我们看一下如何使用OpenZeppelin创建简单数字化模仿Pocket Monsters的游戏。 我们将其称为“Ethermon”游戏。

### 创建ERC721项目

使用[Truffle开发框架](https://learnblockchain.cn/docs/truffle/)创建基于[ERC721](https://learnblockchain.cn/docs/eips/eip-721.html)的Pokemon游戏项目

```shell 
mkdir ethermon
cd ethermon/
truffle init
```

### 使用OpenZeppe

为了使用OpenZepplin，我们需要利用npm导入这个库。让我们先初始化npm， 然后获取正确版本的OpenZeppelin。我们使用最新的稳定版，`2.5.0`版本的OpenZeppelin， 确保你需要使用的是 `0.5.5` 版本的Solidity编译器：

```shell 
npm init
npm install @openzeppelin/contracts@2.5.0 --save
```

### 扩展 ERC-721

在我们的`contracts/`文件夹，先创建一个新的名为`Ethermon.sol`文件。要使用 OpenZeppelin 代码，我们需要引入并扩展 [ERC721.sol](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/58a3368215581509d05bd3ec4d53cd381c9bb40e/contracts/token/ERC721/ERC721.sol)。

当前 Ethermon.sol 代码如下：

当前 Ethermon.sol 代码如下：

```solidity
pragma solidity ^0.5.5;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract Ethermon is ERC721 {
    
}
```

首先使用`truffle compile`检查确保我们的合约可以正确编译。 接下来，我们编写迁移脚本以便将合约部署到本地区块链。在`migrations/`目录下创建一个新的迁移文件`2_deploy_contracts.js`，代码如下：

```js
const Ethermon = artifacts.require("Ethermon");

module.exports = function(deployer) {
	deployer.deploy(Ethermon);
};
```

确保 `truffle-config.js` 配置可以正确连接本地区块链，你可以使用`truffle test` 先测试一下。

### 编写 Ethermon 逻辑

Ethermon合约需要实现如下功能：

1. 创建新的妖怪
2. 将妖怪分配给主人
3. 主人可以安排妖怪与其他妖怪的战斗

让我们先实现第一步。我们需要在`Ethermon`合约中用一个数组保存所有的妖怪。需要保存的妖怪相关的数据包括名字、级别等。因此我们使用一个结构体。

现在 Ethermon 合约的代码如下：

```solidity
pragma solidity ^0.5.5;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

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

    function createNewMonster(string memory _name, address _to) public {
        require(msg.sender == gameOwner, "Only game owner can create new monsters");
        uint id = monsters.length;
        monsters.push(Monster(_name, 1));
        _safeMint(_to, id);
    }
}
```

`Monster`结构体在第7行定义，数组在第12行定义。我们也添加了一个`gameOwner`变量来保存`Ethermon`合约的部署账户。第19行开始是`createNewMonster()`函数的实现， 该函数负责创建新的妖怪。

首先，它会检查这个函数是否是由合约的部署账号调用的。然后为新妖怪生成一个ID，并将新妖怪存入数组，最后使用`_safeMint()`函数将这个新创建的妖怪分配给其主人，这就完成了第一二步。

`_safeMint()` 是我们继承的ERC721合约中实现的函数。它可以安全地将一个 ID 分配给指定的账号，在分配之前会检查ID是否已经存在。

好了，现在我们已经可以创建新的妖怪并将其分配给指定的账号。该进行 第三步了：战斗逻辑。

## 战斗逻辑

正如之前所述，我们的战斗逻辑决定了一个妖怪可以升多少等级。较高等级的妖怪可以获胜并升两级，失败的妖怪升一级。如果两个妖怪处于同一等级，那么进攻者获胜。下面的代码展示了合约中战斗逻辑的实现：

```solidity
pragma solidity ^0.5.5;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

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

    function battle(uint _attackingMonster, uint _defendingMonster) public {
        Monster storage attacker = monsters[_attackingMonster];
        Monster storage defender = monsters[_defendingMonster];

        if (attacker.level >= defender.level) {
            attacker.level += 2;
            defender.level += 1;
        }
        else{
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
```

第19行开始展示了妖怪的战斗逻辑。目前任何账号都可以调用battle()方法。我们需要对此加以限制，只允许发起进攻的妖怪的主人调用该方法。为此，我们可以添加一个修饰器（参考[Solidity 文档 - 函数修饰器](https://learnblockchain.cn/docs/solidity/contracts.html#modifier)），该修饰器`onlyOwnerOf`利用`ERC721.sol`合约中的`ownerOf()`函数来检查调用者账号。

修改后的代码如下：

```solidity
pragma solidity ^0.5.5;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

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
            defender.level += 1;
        }
        else{
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
```

这样就完成了一个使用ERC721的妖怪战斗游戏：我们可以创建新的怪物并分配给某主人。 怪物的主人可以与其他人战斗以升级他们的怪物。