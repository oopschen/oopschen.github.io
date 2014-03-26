var guessGame = {};

(function($){
  $.GuessResult = function() {
    this.A = 0;
    this.B = 0;
  };


  // Guess
  $.Guess = function(num) {
    this.num = num; // store data user input
    this.answer = this.getRandomAnswer();
    this.result = new $.GuessResult();
  };

  $.Guess.INPUT_LEN = 4;

  $.Guess.prototype.getRandomAnswer = function() {
    var answer = [];

    for (var i=0; i<$.Guess.INPUT_LEN; i++) {
      var num = parseInt(Math.random() * 10),
        isIn = false;
      for (var j=0; j<i; j++) {
        if (num == answer[j]) {
          isIn = true;
          break;
        }

      }
      if (isIn) {
        i --;
      } else {
        answer[answer.length] = num + "";
      }

    }

    return answer;
  };


  // Game master
  $.GM = function() {};

  /**
   * check user inputs
   * 1. no duplicate number is allowed
   * 2. must be number
   * 3. check number length == 4
   */
  $.GM.ERR_LEN = 0;
  $.GM.ERR_DUP_NUMBER = 1;
  $.GM.ERR_NOT_NUMBER = 2;
  $.GM.SUCCESS = 3;
  $.GM.HIT = 4;
  $.GM.TRY_AGAIN = 5;

  var checkInput = function(guess) {
    var input = guess.num;
    if (!input || $.Guess.INPUT_LEN != input.length) {
      return $.GM.ERR_LEN;
    }

    var inputNumList = [];
    for (var i=0; i<$.Guess.INPUT_LEN; i++) {
      if (input[i] < '0' || input[i] > '9') {
        return $.GM.ERR_NOT_NUMBER;
      }

      var iNum = parseInt(input[i]);

      for (var j=0; j<i; j++) {
        if (inputNumList[j] == iNum) {
          return $.GM.ERR_DUP_NUMBER;
        }

      }

      inputNumList[inputNumList.length] = iNum;

    }

    return $.GM.SUCCESS;

  };

  $.GM.prototype.play = function(guess) {
    var checkRet = checkInput(guess);
    if ($.GM.SUCCESS != checkRet) {
      return checkRet;
    }

    var input = guess.num;
    guess.result.B = guess.result.A = 0;
    for (var i=0; i<$.Guess.INPUT_LEN; i++) {
      for (var j=0; j<$.Guess.INPUT_LEN; j++) {
        if (input[i] == guess.answer[j]) {
          if (i == j) {
            guess.result.A ++;
          } else {
            guess.result.B ++;
          }
          break;
        }

      }

    }

    return $.Guess.INPUT_LEN == guess.result.A ? $.GM.HIT : $.GM.TRY_AGAIN;

  };

})(guessGame);
