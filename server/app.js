const express = require('express')
const shadowsObj = require('./utilsShadows.js')
const webSockets = require('./utilsWebSockets.js')
const debug = true

/*
    WebSockets server, example of messages:

    From client to server:
        - Client name           { "type": "name", "value": "clientName" }
        - Player movement       { "type": "move", "x": 0, "y": 0 }

    From server to client:
        - Welcome message       { "type": "welcome", "value": "Welcome to the server", "id", "clientId" }
        
    From server to everybody (broadcast):
        - New Client            { "type": "newClient", "id": "clientId" }
*/

var ws = new webSockets()

// Start HTTP server
const app = express()
const port = process.env.PORT || 8888

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
  let obj = JSON.parse(msg)
  if (debug) console.log(`New message:  ${JSON.stringify(obj.type)}`)
  switch (obj.type) {
    case "name":
      socket.clientName = obj.value
      break;
    case "move":
      socket.clientX = obj.x
      socket.clientY = obj.y
      break
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
