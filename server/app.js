const express = require('express')
const gameLoop = require('./utilsGameLoop.js')
const webSockets = require('./utilsWebSockets.js')
const dataManager = require('./dataManager.js');
const debug = true

/*
    WebSockets server, example of messages:

    From client to server:
        - Client init                     { "type": "init", "name": "name", "color": "0x000000" }
        - Player movement                 { "type": "move", "x": 0, "y": 0 }

    From server to client:
        - Welcome message                 { "type": "welcome", "value": "Welcome to the server", "id", "clientId" }
        - Players names in lobby          { type: "players_names", value: [], id:id,}
        - start game when lobby is full   { type: "game_start", value: {random_numbers:[]}, id: id }
        
    From server to everybody (broadcast):
        - All clients data                { "type": "data", "data": "clientsData" }
*/

var ws = new webSockets()
var gLoop = new gameLoop()

// Start HTTP server
const app = express()
const port = process.env.PORT || 8889

// Publish static files from 'public' folder
app.use(express.static('public'))

// Activate HTTP server
const httpServer = app.listen(port, appListen)
async function appListen() {
  console.log(`Listening for HTTP queries on: http://localhost:${port}`)
}

// Close connections when process is killed
process.on('SIGTERM', shutDown);
process.on('SIGINT', shutDown);
function shutDown() {
  console.log('Received kill signal, shutting down gracefully');
  httpServer.close()
  ws.end()
  gLoop.stop()
  process.exit(0);
}

// WebSockets
ws.init(httpServer, port)

ws.onConnection = (socket, id) => {
  if (debug) console.log("WebSocket client connected: " + id)



  // Saludem personalment al nou client
  socket.send(JSON.stringify({
    type: "welcome",
    value: "Welcome to the server",
    id: id
  }))

  // Enviem el nou client a tothom
  ws.broadcast(JSON.stringify({
    type: "newClient",
    id: id
  }))
}

ws.onMessage = (socket, id, msg) => {
  //if (debug) console.log(`New message from ${id}:  ${msg.substring(0, 100)}...`)

  let clientData = ws.getClientData(id)
  if (clientData == null) return

  let obj = JSON.parse(msg)
  switch (obj.type) {
    case "init":
      // Manager de lobbies
      let startLobby = dataManager.addPlayer(id, obj["name"]);
      sendPlayersNames(id);

      if (startLobby == true) {
        sendStartGame(id)
      }
      clientData.name = obj.name
      clientData.alive = true
      break;
    case "move":
      clientData.x = obj.x
      clientData.y = obj.y
      break
    case "score":
      let lobby = dataManager.playerLobby[id];
      lobby.playerScore[obj.id].score = obj.score;
      console.log(JSON.stringify(obj))
      break
    case "died":
      clientData.x = obj.x
      clientData.y = obj.y
      clientData.alive = false;
      let lobby1 = dataManager.playerLobby[obj.id];
      lobby1.playerScore[obj.id].score = obj.score;
      checkGameStatus(obj.id);
      //if (debug) console.log(`New message from ${id}:  ${msg.substring(0, 100)}...`)
      break
  }
}

async function checkGameStatus(id) {
  let lobby = dataManager.playerLobby[id];
  const remaining = lobby.in_game;
  lobby.in_game = remaining - 1;
  if (lobby.in_game === 1) {
    console.log({
      type: "game_over",
      data: JSON.stringify(lobby)
    })
    ws.broadcast(JSON.stringify({
      type: "game_over",
      data: lobby
    }));
  }
}

ws.onClose = (socket, id) => {
  if (debug) console.log("WebSocket client disconnected: " + id)

  // Informem a tothom que el client s'ha desconnectat
  ws.broadcast(JSON.stringify({
    type: "disconnected",
    from: "server",
    id: id
  }))
}

function sendPlayersNames(id) {
  // Enviem array con nombre jugadores en el lobby
  let playersIdList = dataManager.playerLobby[id]["players_id"];

  playersIdList.forEach(idClient => {
    ws.sendMessageToClient(idClient, JSON.stringify({
      type: "players_names",
      value: { "names": dataManager.playerLobby[id]["players_name"], "colors": dataManager.playerLobby[id]["playerId_colorId"] },
      id: id,
    }));
  });

}

function sendStartGame(playerId) {
  console.log("empieza el gameee")
  let playersIdList = dataManager.playerLobby[playerId]["players_id"];
  let listaRandom = dataManager.generateIntegerList(500, 1, 100);
  playersIdList.forEach(idClient => {
    ws.sendMessageToClient(idClient, JSON.stringify({
      type: "game_start",
      value: { random_numbers: listaRandom },
      id: playerId,
    }));
  });
}

gLoop.init();
gLoop.run = (fps) => {
  // Aquest mètode s'intenta executar 30 cops per segon

  let clientsData = ws.getClientsData()
  //console.log(dataManager.lobbies);
  // Gestionar aquí la partida, estats i final
  //console.log(clientsData)

  // Send game status data to everyone
  ws.broadcast(JSON.stringify({ type: "data", value: clientsData }))

  // iteramos por lobbies para enviar los datos de los jugadores de los lobbies entre ellos
  //console.log(dataManager.lobbies)

  /*let clientsIds = ws.getClientsIds();
  for (const clientId in clientsIds) {
    let clientData = ws.getClientData(clientId);

    let lobbyId = dataManager.playerLobby[clientId];
    let lobby = dataManager.lobbies[lobbyId];

    if (lobby == null) {
      continue;
    }

    for (const playerInLobby in lobby["player_id"]) {
      let message = JSON.stringify({ type: "data", value: clientData });
      ws.sendMessageToClient(playerInLobby, message);
      console.log("se envio mensajes", message);
    }
  }*/
}
