//SPDX-License-Identifier:MIT
pragma solidity >=0.7.0 <0.9.0;

import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/utils/Counters.sol';
import '@openzeppelin/contracts/security/ReentrancyGuard.sol';

contract AnswerToEarn is ReentrancyGuard, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _totalQuestions;
    Counters.Counter private _totalAnswers;

    struct QuestionStruct {
        uint id;
        string title;
        string description;
        address owner;
        address winner;
        bool paidout;
        bool deleted;
        uint updated;
        uint created;
        uint answers;
        string tags;
        uint256 prize;
    }

    struct AnswerStruct {
        uint id;
        uint qid;
        string comment;
        address owner;
        bool deleted;
        uint created;
        uint updated;
    }

    event Action(
        uint id, 
        string actionType, 
        address indexed executor, 
        uint256 timestamp
    );

    uint256 public serviceFee;
    mapping(uint => bool) questionExists;
    mapping(uint => QuestionStruct) questions;
    mapping(uint => mapping(uint => AnswerStruct)) answersOf;

     constructor(uint _serviceFee) {
        serviceFee = _serviceFee;
    }

    function createQuestion(
        string memory title,
        string memory description,
        string memory tags
    ) public payable {
        //the conditions that must be checked
        require(bytes(title).length > 0, "title must not be empty");
        require(bytes(description).length > 0, 'description must not be empty');
        require(bytes(tags).length > 0, 'tags must not be empty');
        require(msg.value > 0 ether, 'Insufficient amount');

        //initialize the question structure
        QuestionStruct memory question;
        _totalQuestions.increment();

        question.id = _totalQuestions.current(); //this will give the current number
        question.title = title;
        question.description = description;
        question.tags = tags;
        question.prize = msg.value;
        question.owner = msg.sender; //whoever is calling will be the owner of the questionn
        question.updated = currentTime();
        question.created = currentTime();

        //here we are going to populate the mappings
        questions[question.id] = question;
        questionExists[question.id] = true;

        //you create an event with the keyword:EVENT,
        //you implement an event with the keyword:EMIT
        emit Action(question.id, 'Question created', msg.sender, currentTime());
    }

     function updateQuestion(
        uint qid, //the question Id we want to update
        string memory title,
        string memory description,
        string memory tags
    ) public {
        //checking the mappings to know if the question exist
        require(questionExists[qid], 'Question not found');
        require(questions[qid].answers < 1, 'Question already with answer(s)');
        //other conditions just the create question
        require(bytes(title).length > 0, 'title must not be empty');
        require(bytes(description).length > 0, 'description must not be empty');
        require(bytes(tags).length > 0, 'tags must not be empty');
        require(msg.sender == questions[qid].owner, 'Unauthorized entity!');

        questions[qid].title = title;
        questions[qid].tags = tags;
        questions[qid].description = description;
        questions[qid].updated = currentTime();

        emit Action(qid, 'Question updated', msg.sender, currentTime());
    }

     function deleteQuestion(uint qid) public {
        require(questionExists[qid], 'Question not found');
        require(questions[qid].answers < 1, 'Question already with answer(s)');
        //this conditio ensures that the person that wants to delete the question must be the owner
        require(msg.sender == questions[qid].owner, 'Unauthorized entity!');

        _totalQuestions.decrement();
        questions[qid].deleted = true;
        questionExists[qid] = false;
        questions[qid].updated = currentTime();

        emit Action(qid, 'Question deleted', msg.sender, currentTime());
    }

    function currentTime() internal view returns (uint) {
        return (block.timestamp * 1000) + 1000;
    }
}
