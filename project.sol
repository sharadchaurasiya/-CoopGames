// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CoopGames {
    struct Challenge {
        uint id;
        string name;
        string description;
        uint reward;
        address creator;
        bool isCompleted;
        address solver;
    }

    uint public nextChallengeId;
    mapping(uint => Challenge) public challenges;
    mapping(address => uint) public balances;

    event ChallengeCreated(uint id, string name, string description, uint reward, address creator);
    event ChallengeSolved(uint id, address solver);
    event RewardClaimed(uint id, address solver, uint reward);

    // Create a new challenge
    function createChallenge(string memory _name, string memory _description, uint _reward) public payable {
        require(msg.value == _reward, "Reward must match the sent value.");

        challenges[nextChallengeId] = Challenge({
            id: nextChallengeId,
            name: _name,
            description: _description,
            reward: _reward,
            creator: msg.sender,
            isCompleted: false,
            solver: address(0)
        });

        emit ChallengeCreated(nextChallengeId, _name, _description, _reward, msg.sender);
        nextChallengeId++;
    }

    // Mark a challenge as solved
    function solveChallenge(uint _challengeId) public {
        Challenge storage challenge = challenges[_challengeId];
        require(!challenge.isCompleted, "Challenge is already completed.");
        require(challenge.creator != msg.sender, "Creator cannot solve their own challenge.");

        challenge.isCompleted = true;
        challenge.solver = msg.sender;
        balances[msg.sender] += challenge.reward;

        emit ChallengeSolved(_challengeId, msg.sender);
    }

    // Claim reward for a solved challenge
    function claimReward(uint _challengeId) public {
        Challenge storage challenge = challenges[_challengeId];
        require(challenge.isCompleted, "Challenge is not completed yet.");
        require(challenge.solver == msg.sender, "Only the solver can claim the reward.");

        uint reward = challenge.reward;
        challenge.reward = 0;
        balances[msg.sender] -= reward;
        payable(msg.sender).transfer(reward);

        emit RewardClaimed(_challengeId, msg.sender, reward);
    }

    // Get the details of a challenge
    function getChallenge(uint _challengeId) public view returns (
        uint id,
        string memory name,
        string memory description,
        uint reward,
        address creator,
        bool isCompleted,
        address solver
    ) {
        Challenge storage challenge = challenges[_challengeId];
        return (
            challenge.id,
            challenge.name,
            challenge.description,
            challenge.reward,
            challenge.creator,
            challenge.isCompleted,
            challenge.solver
        );
    }

    // Fallback function to accept ETH
    receive() external payable {}
}
