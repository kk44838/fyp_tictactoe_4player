//SPDX-License-Identifier: Unlicense
pragma solidity ^0.4.24;

/**
 * @title TicTacToe contract
 **/
contract TicTacToe {
    uint constant GAME_NOT_STARTED = 0;
    uint constant GAME_TEAM_1_WON = 1;
    uint constant GAME_TEAM_2_WON = 2;
    uint constant GAME_DRAW = 3;
    uint constant GAME_STARTED = 4;
    uint constant GAME_CANCELLED = 5;


    /**
      Players in the game
     */
    address[4] public players;

    
    /**
      Bet amounts of players that have joined the game
     */
    uint[4] public playersJoined;

    /**
      Maps player address to the player number
     */
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
     5 - Failed to Start
     */

    uint public status = GAME_NOT_STARTED;

    /**
      Winner has been paid
     */
    bool public paidWinner = false;
    /**
      A 4x4x4 board
     */
    uint[4][4][4] private board;

    /**
      Join Game Timeout
     */
    uint256 joinTimeout = 5 minutes;
    uint256 joinDeadline;

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

        joinDeadline = (now + joinTimeout);
    }

    /**
      * @dev Checks all players have joined the game
      * @return true if all players joined otherwise false
      **/
    function allJoined() public view returns (bool) {
      for (uint i=0; i < players.length; i++) {
        if (playersJoined[i] == 0) {
          return false;
        }
      }
      return true;
    }


    /**
      * @dev Join the game
      * The game starts upon all players joining
      **/
    function join() external payable {
      uint playerI = walletToPlayer[msg.sender] - 1;
      require(playerI > 0, "You are not an opponent.");
      require(playersJoined[playerI] == 0, "Opponent already joined.");
      require(msg.value == betAmount, "Wrong bet amount.");
      require(joinDeadline > now, "Game join timeout.");
      
      playersJoined[playerI] = betAmount;

      if (allJoined()) {
        nextTimeoutPhase = (now + timeout);
        status = GAME_STARTED;
      }
    }


    /**
      * @dev Check a, b, c, d in a line are the same
      * _fourInALine doesn't check if a, b, c, d are in a line
      * @param a position a
      * @param b position b
      * @param c position c
      * @param d position d
      */    
    function _fourInALine(uint a, uint b, uint c, uint d) private pure returns (bool){
        
        return (a != 0 && a == b && a == c && a == d);

    }

    /**
      * @dev Checks if there are four in a line in one of the rows
      * @return player number of winner four in a line, otherwise return game status
      */  
    function winnerInRow() private view returns (uint){
      for (uint i = 0; i < board.length; i++) {
        for (uint j = 0; j < board.length; j++) {
          if (_fourInALine(board[j][0][i], board[j][1][i], board[j][2][i], board[j][3][i])) {
            return board[j][0][i];
          }
        } 
      }
      
      return GAME_STARTED;
    }

    /**
      * @dev Checks if there are four in a line in one of the columns
      * @return player number of winner four in a line, otherwise return game status
      */  
    function winnerInColumn() private view returns (uint){
      for (uint i = 0; i < board.length; i++) {
        for (uint j = 0; j < board.length; j++) {
          if (_fourInALine(board[0][j][i], board[1][j][i], board[2][j][i], board[3][j][i])) {
            return board[0][j][i];
          }
        }
      }
      return GAME_STARTED;
    }

    /**
      * @dev Checks if there are four in a line in one of the diagonals
      * @return player number of winner four in a line, otherwise return game status
      */  
    function winnerInDiagonal() private view returns (uint){
      
      for (uint i = 0; i < board.length; i++) {
        if (_fourInALine(board[0][0][i], board[1][1][i], board[2][2][i], board[3][3][i])) {
          return board[0][0][i];
        }
        
        if (_fourInALine(board[0][3][i], board[1][2][i], board[2][1][i], board[3][0][i])) {
          return board[0][3][i];
        }
      }
      return GAME_STARTED;
    }

    /**
      * @dev Checks if there are four in a line in one of the vertical lines
      * @return player number of winner four in a line, otherwise return game status
      */  
    function winnerInVertical() private view returns (uint){
      for (uint i = 0; i < board.length; i++) {
        for (uint j = 0; j < board.length; j++) {
          if (_fourInALine(board[i][j][0], board[i][j][1], board[i][j][2], board[i][j][3])) {
            return board[i][j][0];
          
          }
        } 
      }
      
      return GAME_STARTED;
    }

    /**
      * @dev Checks if there are four in a line in one of the vertical rows
      * @return player number of winner four in a line, otherwise return game status
      */  
    function winnerInVerticalRow() private view returns (uint){
      for (uint i = 0; i < board.length; i++) {
          if (_fourInALine(board[i][0][0], board[i][1][1], board[i][2][2], board[i][3][3])) {
            return board[i][0][0];
          }

          if (_fourInALine(board[i][3][0], board[i][2][1], board[i][1][2], board[i][0][3])) {
            return board[i][3][0];
          }
      }
      
      return GAME_STARTED;
    }

    /**
      * @dev Checks if there are four in a line in one of the vertical columns
      * @return player number of winner four in a line, otherwise return game status
      */  
    function winnerInVerticalColumn() private view returns (uint){
      for (uint i = 0; i < board.length; i++) {
          if (_fourInALine(board[0][i][0], board[1][i][1], board[2][i][2], board[3][i][3])) {
            return board[i][0][0];
          }

          if (_fourInALine(board[3][i][0], board[2][i][1], board[1][i][2], board[0][i][3])) {
            return board[3][i][0];
          }
      }
      
      return GAME_STARTED;
    }

    /**
      * @dev Checks if there are four in a line in one of the vertical diagonals
      * @return player number of winner four in a line, otherwise return game status
      */  
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
      
      return GAME_STARTED;
    }

    /**
      * @dev Checks if the board is full
      * @return true if the board is full otherwise false
      */  
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
        

        uint cur_status = winnerInRow();

        if (cur_status < GAME_STARTED) {
          return cur_status;
        }

        cur_status = winnerInColumn();

        if (cur_status < GAME_STARTED) {
          return cur_status;
        }

        cur_status = winnerInDiagonal();

        if (cur_status < GAME_STARTED) {
          return cur_status;
        }

        cur_status = winnerInVertical();

        if (cur_status < GAME_STARTED) {
          return cur_status;
        }

        cur_status = winnerInVerticalRow();

        if (cur_status < GAME_STARTED) {
          return cur_status;
        }

        cur_status = winnerInVerticalColumn();

        if (cur_status < GAME_STARTED) {
          return cur_status;
        }

        cur_status = winnerInVerticalDiagonal();

        if (cur_status < GAME_STARTED) {
          return cur_status;
        }

        if (fullBoard()) {
          return GAME_DRAW;
        }

        return GAME_STARTED;

    }

    

    /**
     * @dev ensure the game is still ongoing before a player move
     * update game status after a player move
     */
    modifier _checkStatus {
        
        require(status == GAME_STARTED, "Game is not in progess.");
        _;
        status = _getStatus();

        if (status == GAME_DRAW) {
          draw();
        } else if (status > GAME_NOT_STARTED && status < GAME_DRAW && !paidWinner) {
          paidWinner = true;
          payWinner(status);
        } 

    }

    /**
     * @dev check if it's msg.sender's turn
     * @return true if it's msg.sender's turn otherwise false
     */
    function myTurn() public view returns (bool) {
       
       return msg.sender == players[turn-1];
    }

    /**
     * @dev ensure it's a msg.sender's turn
     * update the turn after a move
     */
    modifier _myTurn {
      
      require(myTurn(), "Not your turn!");
      _;
      turn = (turn % 4) + 1;

    }

    /**
     * @dev check player move is valid
     * @param pos_x the x position the player places at
     * @param pos_y the y position the player places at
     * @param pos_z the z position the player places at
     * @return true if valid player move otherwise false
     */
    function validMove(uint pos_x, uint pos_y, uint pos_z) public view returns (bool) {
      
      return pos_x >= 0 && pos_x < 4 && pos_y >= 0 && pos_y < 4 && pos_z >= 0 && pos_z < 4 && board[pos_x][pos_y][pos_z] == 0;

    }

    /**
     * @dev ensure player move is valid before move is made
     * @param pos_x the x position the player places at
     * @param pos_y the y position the player places at
     * @param pos_z the z position the player places at
     */
    modifier _validMove(uint pos_x, uint pos_y, uint pos_z) {
      
      require(validMove(pos_x, pos_y, pos_z), "Invalid Move.");
      _;
    }    

    /**
     * @dev ensure a move is made before the timeout
     * update move timeout after move is made
     */

    modifier _checkTimeout {
      
      require(nextTimeoutPhase > now, "Took too long to make move.");
      _;
      nextTimeoutPhase = (now + timeout);
    }    

    /**
     * @dev a player makes a move
     * @param pos_x the x position the player places at
     * @param pos_y the y position the player places at
     * @param pos_z the z position the player places at
     */
    function move(uint pos_x, uint pos_y, uint pos_z) public _validMove(pos_x, pos_y, pos_z) _checkTimeout _checkStatus _myTurn {
      board[pos_x][pos_y][pos_z] = (turn - 1) % 2 + 1;
    }

    /**
     * @dev show the current board state
     * @return board
     */
    function showBoard() public view returns (uint[4][4][4]) {
      return board;
    }


    /**
     * @dev returns bets to respective players if not all players join before the timeout
     */
    function unlockFundsAfterJoinTimeout() public {
        //Game must be timed out & still active
        require(joinDeadline < now, "Game has not yet timed out");
        require(status == 0, "Game has Started.");
        require(!paidWinner, "Winner already paid.");
        // require(, "Must be called by winner.");

        status = GAME_CANCELLED;
        paidWinner = true;
        returnFunds();
    }

    /**
     * @dev awards bets to opposing team of a player that has timed out
     */
    function unlockFundsAfterTimeout() public {
        //Game must be timed out & still active
        require(nextTimeoutPhase < now, "Game has not yet timed out");
        require(status == GAME_STARTED, "Game has already been rendered inactive.");
        require(!paidWinner, "Winner already paid.");
        require(players[(turn % 2)] == msg.sender || players[(turn % 2) + 2] == msg.sender, "Must be called by winner.");

        status = (turn % 2) + 1;
        paidWinner = true;
        payWinner(status);
    }

    /**
     * @dev return funds to respective owners
     */
    function draw() private {
      players[0].transfer(betAmount);
      players[1].transfer(betAmount);
      players[2].transfer(betAmount);
      players[3].transfer(betAmount);
    }

    /**
     * @dev award winners with winnings
     */
    function payWinner(uint team) private {
      if (team == 1) {
        players[0].transfer(betAmount + betAmount);
        players[2].transfer(betAmount + betAmount);
      } else {
        players[1].transfer(betAmount + betAmount);
        players[3].transfer(betAmount + betAmount);
      }
    }

    /**
     * @dev returns funds to players that have joined
     */
    function returnFunds() private {
      for (uint i=0; i < playersJoined.length; i++) {
        if (playersJoined[i] > 0) {
          uint bet = playersJoined[i];
          playersJoined[i] = 0;

          players[i].transfer(bet);
        }
      }

    }
}

