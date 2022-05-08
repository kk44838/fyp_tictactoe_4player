//SPDX-License-Identifier: Unlicense
pragma solidity ^0.4.24;

/**
 * @title TicTacToe contract
 **/
contract TicTacToe {
    address[2] public players;
    address[2] public playersJoined;
    
    /**
      Amount to bet
     */
    uint public betAmount;

    /**
     turn
     1 - players[0]'s turn
     2 - players[1]'s turn
     */
    uint public turn = 1;

    /**
     status
     0 - ongoing
     1 - players[0] won
     2 - players[1] won
     3 - draw
     4 - Not started
     */
    uint public status = 4;
    bool public paidWinner = false;
    /**
    board status
     0    1    2
     3    4    5
     6    7    8
     */
    uint[4][4][4] private board;

    /**
      Mapping
     */
    // mapping(uint => uint[][]) public lines;
    // uint[][] private tests;

    /**
      * @dev Deploy the contract to create a new game
      * @param opponent The address of player2
      **/
    constructor(address opponent) public {
        require(msg.sender != opponent, "No self play.");
        // require(msg.value <= msg.sender.balance, "Player 1 insufficient balance.");
        // require(msg.value <= opponent.balance, "Player 2 insufficient balance.");

        players[0] = msg.sender;
        players[1] = opponent;
        
    }

    modifier _hasJoined(address sender) {
      require((sender == players[0] && playersJoined[0] == address(0)) || (sender == players[1] && playersJoined[1] == address(0)), "Already Joined");
      _;
    }

    function join() external payable _hasJoined(msg.sender) {
        
        if (msg.sender == players[0]){
          playersJoined[0] = msg.sender;
          betAmount = msg.value;
        }

        if (msg.sender == players[1]) {
          require(msg.value == betAmount, "Wrong bet amount.");
          playersJoined[1] = msg.sender;
          status = 0;
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

    modifier _allJoined() {
      for (uint i=0; i < playersJoined.length; i++) {
        require((players[0] != address(0) && playersJoined[0] == players[0]));
      }
      _;
    }


    function winnerInRow() private view returns (uint){
      for (uint8 x1 = 0; x1 < board.length; x1++) {
        for (uint8 x2 = 0; x2 < board.length; x2++) {
          if (_fourInALine(board[x2][0][x1], board[x2][1][x1], board[x2][2][x1], board[x2][3][x1])) {
            return board[x2][0][x1];
          }
        } 
      }
      
      return 0;
    }

    function winnerInColumn() private view returns (uint){
      for (uint8 y1 = 0; y1 < board.length; y1++) {
        for (uint8 y2 = 0; y2 < board.length; y2++) {
          if (_fourInALine(board[0][y2][y1], board[1][y2][y1], board[2][y2][y1], board[3][y2][y1])) {
            return board[0][y2][y1];
          }
        }
      }
      return 0;
    }

    function winnerInDiagonal() private view returns (uint){
      
      for (uint8 z1 = 0; z1 < board.length; z1++) {
        if (_fourInALine(board[0][0][z1], board[1][1][z1], board[2][2][z1], board[3][3][z1])) {
          return board[0][0][z1];
        }
        
        if (_fourInALine(board[0][3][z1], board[1][2][z1], board[2][1][z1], board[3][0][z1])) {
          return board[0][3][z1];
        }
      }
      return 0;
    }

    function winnerInVertical() private view returns (uint){
      for (uint8 a1 = 0; a1 < board.length; a1++) {
        for (uint8 a2 = 0; a2 < board.length; a2++) {
          if (_fourInALine(board[a1][a2][0], board[a1][a2][1], board[a1][a2][2], board[a1][a2][3])) {
            return board[a1][a2][0];
          
          }
        } 
      }
      
      return 0;
    }

    function winnerInVerticalRow() private view returns (uint){
      for (uint8 b1 = 0; b1 < board.length; b1++) {
          if (_fourInALine(board[b1][0][0], board[b1][1][1], board[b1][2][2], board[b1][3][3])) {
            return board[b1][0][0];
          }

          if (_fourInALine(board[b1][3][0], board[b1][2][1], board[b1][1][2], board[b1][0][3])) {
            return board[b1][3][0];
          }
      }
      
      return 0;
    }

    function winnerInVerticalColumn() private view returns (uint){
      for (uint8 c1 = 0; c1 < board.length; c1++) {
          if (_fourInALine(board[0][c1][0], board[1][c1][1], board[2][c1][2], board[3][c1][3])) {
            return board[c1][0][0];
          }

          if (_fourInALine(board[3][c1][0], board[2][c1][1], board[1][c1][2], board[0][c1][3])) {
            return board[3][c1][0];
          }
      }
      
      return 0;
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
      
      return 0;
    }

    function fullBoard() private view returns (bool){
      
      for (uint j=0; j < board.length; j++) {
        for (uint k=0; k < board.length; k++) {
          for (uint l=0; l < board.length; l++) {
            if (board[j][k][l] == 0) {
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

        if (cur_status > 0) {
          return cur_status;
        }

        cur_status = winnerInColumn();

        if (cur_status > 0) {
          return cur_status;
        }

        cur_status = winnerInDiagonal();

        if (cur_status > 0) {
          return cur_status;
        }

        cur_status = winnerInVertical();

        if (cur_status > 0) {
          return cur_status;
        }

        cur_status = winnerInVerticalRow();

        if (cur_status > 0) {
          return cur_status;
        }

        cur_status = winnerInVerticalColumn();

        if (cur_status > 0) {
          return cur_status;
        }

        cur_status = winnerInVerticalDiagonal();

        if (cur_status > 0) {
          return cur_status;
        }

        if (fullBoard()) {
          return 3;
        }

        return 0;

    }

    /**
     * @dev ensure the game is still ongoing before a player moving
     * update the status of the game after a player moving
     */
    modifier _checkStatus {
        /*Please complete the code here.*/
        require(status == 0, "Game is Complete.");
        _;
        status = _getStatus();
        if (status > 0 && status < 3 && !paidWinner) {
          paidWinner = true;
          payWinner();
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
    modifier _myTurn() {
      /*Please complete the code here.*/
      require(myTurn(), "Not your turn!");
      _;
      turn = (turn % 2) + 1;

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
     * @dev ensure a move is valid
     * @param pos_x the position the player places at
     * @param pos_y the position the player places at
     */
    modifier _validMove(uint pos_x, uint pos_y, uint pos_z) {
      /*Please complete the code here.*/
      require (validMove(pos_x, pos_y, pos_z), "Move is invalid.");
      _;
    }

    /**
     * @dev a player makes a move
     * @param pos_x the position the player places at
     * @param pos_y the position the player places at
     */
    function move(uint pos_x, uint pos_y, uint pos_z) public _allJoined _validMove(pos_x, pos_y, pos_z) _checkStatus _myTurn {
        board[pos_x][pos_y][pos_z] = turn;
    }

    /**
     * @dev show the current board
     * @return board
     */
    function showBoard() public view returns (uint[4][4][4]) {
      return board;
    }


    function payWinner() private {
      players[status - 1].transfer(betAmount + betAmount);
    }
}

