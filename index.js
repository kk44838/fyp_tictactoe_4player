
//HTML page environement variables
var game1 = document.querySelector('#game1');
var boxes1 = game1.querySelectorAll('li');

var game2 = document.querySelector('#game2');
var boxes2 = game2.querySelectorAll('li');

var game3 = document.querySelector('#game3');
var boxes3 = game3.querySelectorAll('li');

var game4 = document.querySelector('#game4');
var boxes4 = game4.querySelectorAll('li');

const games = [boxes1, boxes2, boxes3, boxes4]

var timerDisplay = document.getElementById('timer');
var turnDisplay = document.getElementById('whos-turn');
var statusDisplay = document.getElementById('game-status');
var gameMessages = document.getElementById('game-messages');
var newGame = document.getElementById('new-game');
var joinGame = document.getElementById('join-game');
// var startGame;
var player;
var team;
var gameOver = false;
var accounts;
var betAmount;

var timerStarted = false;
var startTime;

if (typeof web3 !== 'undefined') {
    web3 = new Web3(web3.currentProvider);
} else {
    //this Dapp requires the use of metamask
    alert('please install metamask')
}
const eth = new Eth(web3.currentProvider);

var TicTacToeContract;
var TicTacToe;

//Play functions
var init = async function() {
    let response = await fetch('/artifacts/contracts/TicTacToe.sol/TicTacToe.json');
    const data = await response.json()
    const abi = data.abi
    const byteCode = data.bytecode

    accounts = await ethereum.request({ method: 'eth_requestAccounts' });
    console.log("The account is " + accounts[0])
    TicTacToeContract = eth.contract(abi, byteCode, { from: accounts[0], gas: '3000000' });

    ethereum.on('accountsChanged', async function (accounts) {
        accounts = await ethereum.request({ method: 'eth_requestAccounts' });
        TicTacToeContract = eth.contract(abi, byteCode, { from: accounts[0], gas: '3000000' });
    });
    
    //the user can first create or join a game
    newGame.addEventListener('click',newGameHandler,false);
    joinGame.addEventListener('click',joinGameHandler, false);
    
    //events listeners for user to click on the board
    for(var i = 0; i < 4; i++) {
        for(var j = 0; j < 4*4; j++) {
            games[i][j].addEventListener('click', clickHandler, false);
        }
    }
    renderInterval = setInterval(render, 1000);
    render();
}

var checkWin = function(){

    //checks the contract on the blockchain to verify if there is a winner or not
    if (typeof TicTacToe != 'undefined'){
        var win;
        TicTacToe.status().then(function(res){
            win = res[0].words[0];
            console.log(win)
            var displayResult;
            // statusDisplay.innerHTML = "Status: " + win
            if (win>0 && win<4){
                if (win==3){
                    displayResult = "Draw ! game is over";
                } else if (win == 2){
                    displayResult = "Team 2 wins ! game is over";
                } else if (win == 1) {
                    displayResult = "Team 1 wins ! game is over";
                }
                gameOver = true;
                document.querySelector('#game-messages').innerHTML = displayResult;

                for(var i = 0; i < 4; i++) {
                    for(var j = 0; j < 4*4; j++) {
                        games[i][j].removeEventListener('click', clickHandler);
                    }
                }

                return true;
            } else if (win == 0){
                document.querySelector('#game-messages').innerHTML = "Waiting for players...";
            } else if (win == 4) {
                document.querySelector('#game-messages').innerHTML = "Game in progress..."
                if (!timerStarted) {
                    start = Date.now();
                    timerStarted = true;
                    // document.querySelector('#timeout').innerHTML = "<button class=\"buttons\" id=\"timeoutOn\" onclick=\"timeoutHandler()\">Claim Opponent Timeout</button>"
                }
            }
        });
    }

    return false;
}


var render = function(){

    //renders the board byt fetching the state of the board from the blockchain
    if (typeof TicTacToe != 'undefined'){
        TicTacToe.showBoard().then(function(res){
            for (var i = 0; i < 4; i++){
                for (var j = 0; j < 4; j++){
                    for (var k = 0; k < 4; k++){
                        var state = res[0][i][j][k].words[0];
                        if (state>0){
                            var box_i = 4 * i + j;
                            if (state==1){
                                games[k][box_i].className = 'x';
                                games[k][box_i].innerHTML = 'x';
                            } else{
                                games[k][box_i].className = 'o';
                                games[k][box_i].innerHTML = 'o';
                            }
                        }
                    }
                }   
            }
        });
        checkWin();

        if (!gameOver){
            turnMessageHandler();
            if (timerStarted) {
                timerHandler();
            }
        } else {
            endGameHandler();
        }
    }
}

var timerHandler = function(){
    timerDisplay.innerHTML = Math.floor((Date.now() - start)/ 1000);
}

var timeoutHandler = function(){
    if (typeof TicTacToe != 'undefined'){
        if (checkWin()){
            return;
        }

        TicTacToe.unlockFundsAfterTimeout().then(function(res){
            document.querySelector('#timeout-messages').innerHTML = "Opponent exceeded timeout."
        }).catch(function(err) {
            document.querySelector('#timeout-messages').innerHTML = "Opponent has not exceeded timeout."
        });
    }
}

var turnMessageHandler = function(){
    TicTacToe.turn().then(function(res){
        if (res[0].words[0] == player){
            turnDisplay.innerHTML = "Your turn Player " + res[0].words[0] + "!";
            document.querySelector('#timeout').innerHTML = "<button class=\"buttons\" id=\"timeout\" onclick=\"timeoutHandler()\" disabled>Claim Opponent Timeout</button>"
        } else {
            turnDisplay.innerHTML = "Not your turn! It's Player " + res[0].words[0] + "'s turn!";
            document.querySelector('#timeout').innerHTML = "<button class=\"buttons\" id=\"timeout\" onclick=\"timeoutHandler()\">Claim Opponent Timeout</button>"
        }
    });
}

var newGameHandler = function(){

    //creates a new contract based on the user input of their opponent's address
    if (typeof TicTacToe != 'undefined'){
        console.log("There seems to be an existing game going on already");
    } else{
        var teammateAddress = document.getElementById('teammate-address').value
        var opponentAddress1 = document.getElementById('opponent-address-1').value
        var opponentAddress2 = document.getElementById('opponent-address-2').value
        betAmount = document.getElementById('bet-amount').value;

        console.log(teammateAddress, opponentAddress1, opponentAddress2)
        TicTacToeContract.new(teammateAddress, opponentAddress1, opponentAddress2, { from: accounts[0], gas: '3000000',  value: web3.utils.toWei(betAmount.toString(), "ether")})
        .then(function(txHash) {
            var waitForTransaction = setInterval(function(){
                eth.getTransactionReceipt(txHash, function(err, receipt){
                    if (receipt) {
                        clearInterval(waitForTransaction);
                        TicTacToe = TicTacToeContract.at(receipt.contractAddress);
                        //display the contract address to share with the opponent
                        
                        document.querySelector('#new-game-address').innerHTML = "BET AMOUNT OF " + betAmount + " PLACED <br><br>" 
                        + "Share the contract address with your opponnent: " + String(TicTacToe.address) + "<br><br>";
                        player = 1;
                        team = 1;
                        document.querySelector('#player').innerHTML = "Player 1 (TEAM 1)";
                    }
                })
            }, 300);
        
        })
        
    }
}

var joinGameHandler = function(){
    //idem for joining a game
    var contractAddress = document.getElementById('contract-ID-tojoin').value.trim();
    TicTacToe = TicTacToeContract.at(contractAddress);

    TicTacToe.betAmount().then(function(res) {
        console.log(res)
        betAmount = web3.utils.fromWei(res[0].toString(), 'ether');
        if (betAmount == 0) {
            document.querySelector('#bet-amount-field-join').innerHTML = "Try Again..."
        } else {
            document.querySelector('#bet-amount-field-join').innerHTML = 
            "Bet Amount of " + betAmount + " requried to join game. <button class=\"buttons\" id=\"start-game\" onclick=\"joinGameConfirmHandler()\">Confirm</button> <br><br>"
        }
        
    });
    
}

var joinGameConfirmHandler = function(){
    TicTacToe.join({ from: accounts[0], gas: '3000000',  value: web3.utils.toWei(betAmount.toString(), "ether")}).then(function(res) {
        TicTacToe.walletToPlayer(accounts[0]).then(function(res) {
            player = res[0]
            team = (player + 1) % 2 + 1
            document.querySelector('#player').innerHTML = "Player " + player + " (TEAM " + team + ")";
        });
        document.querySelector('#bet-amount-field-join').innerHTML = "Game of " + betAmount + " ETH stakes joined."

        startTime = Date.now()
    });
    
}

var endGameHandler = function(){
    document.querySelector('#timeout').innerHTML = ""
    turnDisplay.innerHTML = ""
    // TicTacToe.paidWinner().then(function(res){
    //     document.querySelector('#winner-paid').innerHTML = "Winner paid: " + res[0];
    // });
}

var clickHandler = function() {

    //called when the user clicks a cell on the board

    if (typeof TicTacToe != 'undefined'){
        if (checkWin()){
            return;
        }
        var target_x = this.getAttribute('data-pos-x');
        var target_y = this.getAttribute('data-pos-y');
        var target_z = this.getAttribute('data-pos-z');
        TicTacToe.validMove(target_x, target_y, target_z).then(function(res){
            if (res[0]) {
                TicTacToe.turn().then(function(res) {
                    if (res[0].words[0] == player) {
                        TicTacToe.move(target_x, target_y, target_z).catch(function(err){
                            console.log('something went wrong ' + String(err));
                        }).then(function(res){
                            this.removeEventListener('click', clickHandler);
                            render();
                        });
                    }
                });
            }
        });
    }
}

init();
