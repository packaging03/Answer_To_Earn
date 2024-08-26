//SPDX-License-Identifier:MIT
pragma solidity >=0.7.0 <0.9.0;

import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/utils/Counters.sol';
import '@openzeppelin/contracts/security/ReentrancyGuard.sol';

contract AnswerToEarn is ReentrancyGuard, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _totalQuestions;
    Counters.Counter private _totalAnswers;

    
}
