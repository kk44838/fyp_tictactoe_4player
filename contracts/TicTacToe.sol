//SPDX-License-Identifier: Unlicense
pragma solidity ^0.4.24;

/**
 * @title TicTacToe contract
 **/
contract TicTacToe {
    address[4] public players;
    uint[4] public playersJoined;
    mapping(address => uint) public walletToPlayer;
    /**
      Amount to bet
     */
    uint public betAmount;

    /**
     turn
     1 - players[0]'s turn
     2 - players[1]'s turn
     3 - players[2]'s turn
     4 - players[3]'s turn     
     */
    uint public turn = 1;

    /**
     status
     0 - Not started
     1 - players[0] and players[2] won
     2 - players[1] and players[3] won
     3 - draw
     4 - Ongoing
     */
    uint public status = 0;
    bool public paidWinner = false;
    /**
    board status
     0    1    2
     3    4    5
     6    7    8
     */
    uint[4][4][4] private board;

    /**
      Timeout
     */
    uint256 timeout = 1.5 minutes;
    uint256 nextTimeoutPhase;

    /**
      * @dev Deploy the contract to create a new game
      * @param teammate The address of player3
      * @param opponent1 The address of player2
      * @param opponent2 The address of player4
      **/
    constructor(address teammate, address opponent1, address opponent2) public payable {
        require(msg.sender != opponent1 && msg.sender != opponent2, "No self play.");
        require(teammate != opponent1 && teammate != opponent2 , "No self play.");
        require(msg.value > 0, "Bet too small");
        // require(msg.value <= msg.sender.balance, "Player 1 insufficient balance.");
        // require(msg.value <= opponent.balance, "Player 2 insufficient balance.");

        betAmount = msg.value;

        players[0] = msg.sender;
        players[1] = opponent1;
        players[2] = teammate;
        players[3] = opponent2;

        walletToPlayer[msg.sender] = 1;
        walletToPlayer[opponent1] = 2;
        walletToPlayer[teammate] = 3;
        walletToPlayer[opponent2] = 4;

        playersJoined[0] = betAmount;
    }

    function allJoined() public view returns (bool) {
      for (uint i=0; i < players.length; i++) {
        if (playersJoined[i] == 0) {
          return false;
        }
      }
      return true;
    }

    function join() external payable {
      uint playerI = walletToPlayer[msg.sender] - 1;
      require(playerI > 0, "You are not an opponent.");
      require(playersJoined[playerI] == 0, "Opponent already joined.");
      require(msg.value == betAmount, "Wrong bet amount.");
      
      playersJoined[playerI] = betAmount;

      if (allJoined()) {
        nextTimeoutPhase = (now + timeout);
        status = 4;
      }
    }


    /**
      * @dev Check a, b, c in a line are the same
      * _threeInALine doesn't check if a, b, c are in a line
      * @param a position a
      * @param b position b
      * @param c position c
      */    
    function _fourInALine(uint a, uint b, uint c, uint d) private pure returns (bool){
        /*Please complete the code here.*/
        return (a != 0 && a == b && a == c && a == d);

    }


    function winnerInRow() private view returns (uint){
      for (uint8 i = 0; i < board.length; i++) {
        for (uint8 j = 0; j < board.length; j++) {
          if (_fourInALine(board[j][0][i], board[j][1][i], board[j][2][i], board[j][3][i])) {
            return board[j][0][i];
          }
        } 
      }
      
      return 4;
    }

    function winnerInColumn() private view returns (uint){
      for (uint8 i = 0; i < board.length; i++) {
        for (uint8 j = 0; j < board.length; j++) {
          if (_fourInALine(board[0][j][i], board[1][j][i], board[2][j][i], board[3][j][i])) {
            return board[0][j][i];
          }
        }
      }
      return 4;
    }

    function winnerInDiagonal() private view returns (uint){
      
      for (uint8 i = 0; i < board.length; i++) {
        if (_fourInALine(board[0][0][i], board[1][1][i], board[2][2][i], board[3][3][i])) {
          return board[0][0][i];
        }
        
        if (_fourInALine(board[0][3][i], board[1][2][i], board[2][1][i], board[3][0][i])) {
          return board[0][3][i];
        }
      }
      return 4;
    }

    function winnerInVertical() private view returns (uint){
      for (uint8 i = 0; i < board.length; i++) {
        for (uint8 j = 0; j < board.length; j++) {
          if (_fourInALine(board[i][j][0], board[i][j][1], board[i][j][2], board[i][j][3])) {
            return board[i][j][0];
          
          }
        } 
      }
      
      return 4;
    }

    function winnerInVerticalRow() private view returns (uint){
      for (uint8 i = 0; i < board.length; i++) {
          if (_fourInALine(board[i][0][0], board[i][1][1], board[i][2][2], board[i][3][3])) {
            return board[i][0][0];
          }

          if (_fourInALine(board[i][3][0], board[i][2][1], board[i][1][2], board[i][0][3])) {
            return board[i][3][0];
          }
      }
      
      return 4;
    }

    function winnerInVerticalColumn() private view returns (uint){
      for (uint8 i = 0; i < board.length; i++) {
          if (_fourInALine(board[0][i][0], board[1][i][1], board[2][i][2], board[3][i][3])) {
            return board[i][0][0];
          }

          if (_fourInALine(board[3][i][0], board[2][i][1], board[1][i][2], board[0][i][3])) {
            return board[3][i][0];
          }
      }
      
      return 4;
    }

    function winnerInVerticalDiagonal() private view returns (uint){
      if (_fourInALine(board[0][0][0], board[1][1][1], board[2][2][2], board[3][3][3])) {
        return board[0][0][0];
      }

      if (_fourInALine(board[0][0][3], board[1][1][2], board[2][2][1], board[3][3][0])) {
        return board[0][0][3];
      }
      
      if (_fourInALine(board[0][3][0], board[1][2][1], board[2][1][2], board[3][0][3])) {
        return board[0][3][0];
      }

      if (_fourInALine(board[0][3][3], board[1][2][2], board[2][1][1], board[3][0][0])) {
        return board[0][3][3];
      }
      
      return 4;
    }

    function fullBoard() private view returns (bool){
      
      for (uint i=0; i < board.length; i++) {
        for (uint j=0; j < board.length; j++) {
          for (uint k=0; k < board.length; k++) {
            if (board[i][j][k] == 0) {
              return false;
            }
          }
        }
      }

      return true;
    }

    /**
     * @dev get the status of the game
     * @return the status of the game
     */
    function _getStatus() private view returns (uint) {
        /*Please complete the code here.*/

        uint cur_status = winnerInRow();

        if (cur_status < 4) {
          return cur_status;
        }

        cur_status = winnerInColumn();

        if (cur_status < 4) {
          return cur_status;
        }

        cur_status = winnerInDiagonal();

        if (cur_status < 4) {
          return cur_status;
        }

        cur_status = winnerInVertical();

        if (cur_status < 4) {
          return cur_status;
        }

        cur_status = winnerInVerticalRow();

        if (cur_status < 4) {
          return cur_status;
        }

        cur_status = winnerInVerticalColumn();

        if (cur_status < 4) {
          return cur_status;
        }

        cur_status = winnerInVerticalDiagonal();

        if (cur_status < 4) {
          return cur_status;
        }

        if (fullBoard()) {
          return 3;
        }

        return 4;

    }

    

    /**
     * @dev ensure the game is still ongoing before a player moving
     * update the status of the game after a player moving
     */
    modifier _checkStatus {
        /*Please complete the code here.*/
        require(status == 4, "Game is not in progess.");
        _;
        status = _getStatus();

        if (status == 3) {
          draw();
        } else if (status > 0 && status < 3 && !paidWinner) {
          paidWinner = true;
          payWinner(status);
        } 

    }

    /**
     * @dev check if it's msg.sender's turn
     * @return true if it's msg.sender's turn otherwise false
     */
    function myTurn() public view returns (bool) {
       /*Please complete the code here.*/
       return msg.sender == players[turn-1];
    }

    /**
     * @dev ensure it's a msg.sender's turn
     * update the turn after a move
     */
    modifier _myTurn {
      /*Please complete the code here.*/
      require(myTurn(), "Not your turn!");
      _;
      turn = (turn % 4) + 1;

    }

    /**
     * @dev check a move is valid
     * @param pos_x the position the player places at
     * @param pos_y the position the player places at
     * @return true if valid otherwise false
     */
    function validMove(uint pos_x, uint pos_y, uint pos_z) public view returns (bool) {
      /*Please complete the code here.*/
      return pos_x >= 0 && pos_x < 4 && pos_y >= 0 && pos_y < 4 && pos_z >= 0 && pos_z < 4 && board[pos_x][pos_y][pos_z] == 0;

    }

    /**
     * @dev ensure a move is made is valid before it is made
     */

    modifier _validMove(uint pos_x, uint pos_y, uint pos_z) {
      /*Please complete the code here.*/
      require(validMove(pos_x, pos_y, pos_z), "Invalid Move.");
      _;
    }    

    /**
     * @dev ensure a move is made before the timeout
     */

    modifier _checkTimeout {
      /*Please complete the code here.*/
      require(nextTimeoutPhase > now, "Took too long to make move.");
      _;
      nextTimeoutPhase = (now + timeout);
    }    

    /**
     * @dev a player makes a move
     * @param pos_x the position the player places at
     * @param pos_y the position the player places at
     */
    function move(uint pos_x, uint pos_y, uint pos_z) public _validMove(pos_x, pos_y, pos_z) _checkTimeout _checkStatus _myTurn {
      board[pos_x][pos_y][pos_z] = (turn - 1) % 2 + 1;
    }

    /**
     * @dev show the current board
     * @return board
     */
    function showBoard() public view returns (uint[4][4][4]) {
      return board;
    }

    function unlockFundsAfterTimeout() public {
        //Game must be timed out & still active
        require(nextTimeoutPhase < now, "Game has not yet timed out");
        require(status == 4, "Game has already been rendered inactive.");
        require(!paidWinner, "Winner already paid.");
        require(players[(turn % 2)] == msg.sender || players[(turn % 2) + 2] == msg.sender, "Must be called by winner.");

        status = (turn % 2) + 1;
        paidWinner = true;
        payWinner(status);
    }

    function draw() private {
      players[0].transfer(betAmount);
      players[1].transfer(betAmount);
      players[2].transfer(betAmount);
      players[3].transfer(betAmount);
    }

    function payWinner(uint team) private {
      if (team == 1) {
        players[0].transfer(betAmount + betAmount);
        players[2].transfer(betAmount + betAmount);
      } else {
        players[1].transfer(betAmount + betAmount);
        players[3].transfer(betAmount + betAmount);
      }
      
    }
}

