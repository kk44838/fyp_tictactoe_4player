//SPDX-License-Identifier: Unlicense
pragma solidity ^0.4.24;

/**
 * @title TicTacToe contract
 **/
contract TicTacToe {
    address[2] public players;

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
     */
    uint public status;

    /**
    board status
     0    1    2
     3    4    5
     6    7    8
     */
    uint[9] private board;

    /**
      Mapping
     */
    mapping(uint => uint[][]) public lines;

    /**
      * @dev Deploy the contract to create a new game
      * @param opponent The address of player2
      **/
    constructor(address opponent) public {
        require(msg.sender != opponent, "No self play.");
        players = [msg.sender, opponent];


        /**
          Fill up lines mapping
        */

        lines[0] = [[0,1,2],[0,3,6],[0,4,8]];
        lines[1] = [[0,1,2],[1,4,7]];
        lines[2] = [[0,1,2],[2,5,8],[2,4,6]];
        lines[3] = [[3,4,5],[0,3,6]];
        lines[4] = [[3,4,5],[1,4,7],[0,4,8],[2,4,6]];
        lines[5] = [[3,4,5],[2,5,8]];
        lines[6] = [[6,7,8],[0,3,6],[2,4,6]];
        lines[7] = [[6,7,8],[1,4,7]];
        lines[8] = [[6,7,8],[2,5,8],[0,4,8]];

    }

    /**
      * @dev Check a, b, c in a line are the same
      * _threeInALine doesn't check if a, b, c are in a line
      * @param a position a
      * @param b position b
      * @param c position c
      */    
    function _threeInALine(uint a, uint b, uint c) private view returns (bool){
        /*Please complete the code here.*/
        return (board[a] != 0 && board[a] == board[b] && board[a] == board[c]);

    }

    /**
     * @dev get the status of the game
     * @param pos the position the player places at
     * @return the status of the game
     */
    function _getStatus(uint pos) private view returns (uint) {
        /*Please complete the code here.*/

        for (uint i=0; i < lines[pos].length; i++) {
          if (_threeInALine(lines[pos][i][0], lines[pos][i][1], lines[pos][i][2])){
             return board[pos];
          }
        }


        for (uint j=0; j < board.length; j++) {
          if (board[j] == 0) {
            return 0;
          }
        }

        return 3;
    }

    /**
     * @dev ensure the game is still ongoing before a player moving
     * update the status of the game after a player moving
     * @param pos the position the player places at
     */
    modifier _checkStatus(uint pos) {
        /*Please complete the code here.*/
        require(status == 0, "Game is Complete.");
        _;
        status = _getStatus(pos);
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
     * @param pos the position the player places at
     * @return true if valid otherwise false
     */
    function validMove(uint pos) public view returns (bool) {
      /*Please complete the code here.*/
      return pos >= 0 && pos < 9 && board[pos] == 0;

    }

    /**
     * @dev ensure a move is valid
     * @param pos the position the player places at
     */
    modifier _validMove(uint pos) {
      /*Please complete the code here.*/
      require (validMove(pos), "Move is invalid.");
      _;
    }

    /**
     * @dev a player makes a move
     * @param pos the position the player places at
     */
    function move(uint pos) public _validMove(pos) _checkStatus(pos) _myTurn {
        board[pos] = turn;
    }

    /**
     * @dev show the current board
     * @return board
     */
    function showBoard() public view returns (uint[9]) {
      return board;
    }
}
