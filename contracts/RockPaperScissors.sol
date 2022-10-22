// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract RockPaperScissors {
    enum Choice {
        None, Rock, Paper, Scissors
    }

    event commit(address _player, bytes32 _hashedChoice);
    event reveal(address _player, Choice choice);
    event sendWinner(address _winner);

    address[] playerKeys;
    address public winner;
    bool public isChooseStage;
    mapping(address => bytes32) choices;
    uint peopleRevealed;
    mapping(address => Choice) revealedChoice;

    constructor() {
        isChooseStage = true;
    }

    modifier chooseStage() {
        require(isChooseStage, "Choose stage already finished!");
        _;
        if (playerKeys.length == 2) {
            isChooseStage = false;
        }
    }

    modifier revealStage() {
        require(!isChooseStage, "Choose stage haven't finished yet!");
        _;
        peopleRevealed++;
        if (peopleRevealed == 2) {
            defineWinner();
            emit sendWinner(winner);
        }
    }

    function getEnumValueByIndex(uint _choice) private pure returns (Choice) {
        if (_choice == 1) {
            return Choice.Rock;
        } else if (_choice == 2) {
            return Choice.Paper;
        } else if (_choice == 3) {
            return Choice.Scissors;
        }
        revert("Incorrect choice number!");
    }

    function makeChoice(bytes32 _hashedChoice) external chooseStage {
        require(choices[msg.sender] == bytes32(0), "You already made a choice!");

        playerKeys.push(msg.sender);
        choices[msg.sender] = _hashedChoice;
        emit commit(msg.sender, _hashedChoice);
    }

    function revealChoices(uint _choice, bytes32 _secret) external revealStage {
        require(revealedChoice[msg.sender] == Choice.None, "You already revealed your choice!");
        require(keccak256(abi.encodePacked(_choice, _secret, msg.sender)) == choices[msg.sender], "Choice is deffers from what you choosed!");

        revealedChoice[msg.sender] = getEnumValueByIndex(_choice);
        emit reveal(msg.sender, getEnumValueByIndex(_choice));
    }

    function defineWinner() private {
        Choice first = revealedChoice[playerKeys[0]];
        Choice second = revealedChoice[playerKeys[1]];

        if (first != second) {
            if ((first == Choice.Rock && second == Choice.Paper) || (first == Choice.Paper && second == Choice.Scissors) || (first == Choice.Scissors && second == Choice.Rock)) {
                winner = playerKeys[1];
            } else {
                winner = playerKeys[0];
            }
        }
    }

    // Example:
    // ethers.utils.formatBytes32String('MySecret')
    // ethers.utils.solidityKeccak256(['uint', 'bytes32', 'address'], ['1', '0x6d79536563726574000000000000000000000000000000000000000000000000', '0x5B38Da6a701c568545dCfcB03FcB875f56beddC4'])
    // 0x3be51856ff09f01d0f199bf1271c43b89a7e9758b1ea1eba2993868599c27e7a
    // ethers.utils.formatBytes32String('MySecretTwo')
    // ethers.utils.solidityKeccak256(['uint', 'bytes32', 'address'], ['2', '0x4d7953656372657454776f000000000000000000000000000000000000000000', '0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2'])
    // 0x6568b4705b8a74a22d4757e29aebc491fb9074c062e7145680533f0f2ea834a1
}