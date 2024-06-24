const express = require('express');
const http = require('http');
const { Server } = require('socket.io');
const app = express();
const server = http.createServer(app);
const io = new Server(server);

let games = {};

app.use(express.static('frontend'));

io.on('connection', (socket) => {
  socket.on('joinGame', ({ username, gameId }) => {
    socket.join(gameId);
    if (!games[gameId]) {
      games[gameId] = { players: [], board: Array(9).fill(null), currentPlayer: 'X' };
    }
    games[gameId].players.push({ username, id: socket.id });
    io.to(gameId).emit('gameUpdate', games[gameId]);
  });

  socket.on('makeMove', ({ gameId, index }) => {
    let game = games[gameId];
    if (game && game.board[index] === null) {
      game.board[index] = game.currentPlayer;
      game.currentPlayer = game.currentPlayer === 'X' ? 'O' : 'X';
      io.to(gameId).emit('gameUpdate', game);
      checkWinner(gameId);
    }
  });

  const checkWinner = (gameId) => {
    let game = games[gameId];
    const winningCombinations = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8],
      [0, 3, 6], [1, 4, 7], [2, 5, 8],
      [0, 4, 8], [2, 4, 6]
    ];

    winningCombinations.forEach(combination => {
      const [a, b, c] = combination;
      if (game.board[a] && game.board[a] === game.board[b] && game.board[a] === game.board[c]) {
        io.to(gameId).emit('gameEnd', { winner: game.board[a] });
        games[gameId] = { players: game.players, board: Array(9).fill(null), currentPlayer: 'X' }; // Reset game
      }
    });

    if (!game.board.includes(null)) {
      io.to(gameId).emit('gameEnd', { winner: 'Draw' });
      games[gameId] = { players: game.players, board: Array(9).fill(null), currentPlayer: 'X' }; // Reset game
    }
  };

  socket.on('disconnect', () => {
    for (let gameId in games) {
      games[gameId].players = games[gameId].players.filter(player => player.id !== socket.id);
      if (games[gameId].players.length === 0) {
        delete games[gameId];
      }
    }
  });
});

server.listen(3000, () => {
  console.log('listening on *:3000');
});
