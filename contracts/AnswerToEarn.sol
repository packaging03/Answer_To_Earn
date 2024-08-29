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
        //this condition ensures that the person that wants to delete the question must be the owner
        require(msg.sender == questions[qid].owner, 'Unauthorized entity!');

        _totalQuestions.decrement();
        questions[qid].deleted = true;
        questionExists[qid] = false;
        questions[qid].updated = currentTime();

        payTo(questions[qid].owner, questions[qid].prize);

        emit Action(qid, 'Question deleted', msg.sender, currentTime());
    }

    function getQuestions() public view returns (QuestionStruct[] memory Questions) {
        uint available = 0;
        for (uint i = 0; i < _totalQuestions.current(); i++) {
            if (!questions[i + 1].deleted) available++; //i+1 because we started the count on 1
        }

        Questions = new QuestionStruct[](available);

        uint index = 0;
        for (uint i = 0; i < _totalQuestions.current(); i++) {
            if (!questions[i + 1].deleted) {
                Questions[index++] = questions[i + 1]; //first assign before increment
            }
        }
    }

    function getQuestion(uint qid) public view returns (QuestionStruct memory) {
        return questions[qid];
    }

    function addAnswer(uint qid, string memory comment) public {
        require(questionExists[qid], 'Question not found');
        require(!questions[qid].paidout, 'Question already paidout');
        require(bytes(comment).length > 0, 'Answer must not be empty');

        _totalAnswers.increment();
        AnswerStruct memory answer;

        answer.id = _totalAnswers.current();
        answer.qid = qid;
        answer.comment = comment;
        answer.owner = msg.sender;
        answer.created = currentTime();
        questions[qid].answers++;
        answersOf[qid][answer.id] = answer;

        emit Action(answer.id, 'Answer created', msg.sender, currentTime());
    }

    function privateAnswers(uint qid) internal view returns (AnswerStruct[] memory Answers) {
        uint available = 0;
        for (uint i = 0; i < _totalAnswers.current(); i++) {
            if (answersOf[qid][i + 1].qid == qid) available++; //i+1 because we started the count on 1
        }

        Answers = new AnswerStruct[](available);

        uint index = 0;
        for (uint i = 0; i < _totalAnswers.current(); i++) {
            if (answersOf[qid][i + 1].qid == qid) {
                Answers[index++] = answersOf[qid][i + 1]; //first assign before increment
            }
        }
    }

     function publicAnswers(uint qid) internal view returns (AnswerStruct[] memory Answers) {
        uint available = 0;
        for (uint i = 0; i < _totalAnswers.current(); i++) {
            if (answersOf[qid][i + 1].qid == qid) available++; //i+1 because we started the count on 1
        }

        Answers = new AnswerStruct[](available);

        uint index = 0;
        for (uint i = 0; i < _totalAnswers.current(); i++) {
            if (answersOf[qid][i + 1].qid == qid) {
                
                if(questions[qid].paidout)
                {
                    Answers[index++] = answersOf[qid][i + 1]; //first assign before increment
                } else {
                    AnswerStruct memory answer = answersOf[qid][i+1];
                    answer.comment = 'Hidden >> ****** ***** ** **';
                    Answers[index++] = answer;
                }
            }
        }
    }

    function getAnswers(uint qid) public view returns (AnswerStruct[] memory Answers) {
        if(msg.sender == questions[qid].owner || msg.sender == owner()) {
            return privateAnswers(qid);
        } else {
            return publicAnswers(qid);
        }
    }

    function getAnswer(uint qid, uint id) public view returns (AnswerStruct memory) {
        return answersOf[qid][id];
    }
    function payWinner(uint qid, uint id) public nonReentrant {
        require(questionExists[qid], 'Question not found');
        require(answersOf[qid][id].id == id, 'Answer not found');
        require(!questions[qid].paidout, 'Question already paid out');
        require(msg.sender == questions[qid].owner || msg.sender == owner(), 'Unauthorized entity');

        uint256 reward = questions[qid].prize;
        uint256 tax = (reward * serviceFee) / 100;
        address winner = answersOf[qid][id].owner;

        questions[qid].paidout = true;
        questions[qid].winner = winner;
        answersOf[qid][id].updated = currentTime();

        payTo(winner, reward - tax);
        payTo(owner(), tax);
        emit Action(qid, 'Question paidout', msg.sender, currentTime());
    }
    
    function changeFee(uint256 _serviceFee) public onlyOwner {
        require(_serviceFee > 0 && _serviceFee <= 100, 'Fee must be between 1 - 100');
        serviceFee = _serviceFee;
    }
    

    function payTo(address to, uint amount) internal {
        (bool success, ) = payable(to).call{ value: amount }('');
        if (!success) revert('Payment failed');
    }

    function currentTime() internal view returns (uint) {
        return (block.timestamp * 1000) + 1000;
    }
}
