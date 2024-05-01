let lobbies = {};
let playerLobby = {};
let availableLobby = "";

function createLobbyId() {
    const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    let result = '';
    for (let i = 0; i < 4; i++) {
        result += characters.charAt(Math.floor(Math.random() * characters.length));
    }

    if (lobbies[result]) {
        return createLobbyId();
    }
    return result;
}

// devuelve booleano si el lobby ya empieza partida
function addPlayer(id, name) {
    let newGame = false;
    let completedLobbyId;

    if (Object.keys(lobbies).length === 0) {
        availableLobby = createLobbyId();
        lobbies[availableLobby] = { "players_id": [], "in_game": 0, "players_name": [], "playerId_colorId": {} };
    }

    let lobby = lobbies[availableLobby];

    lobby.players_id.push(id);
    lobby.players_name.push(name);
    lobby.in_game += 1;
    lobby["playerId_colorId"][id] = lobby.in_game;
    playerLobby[id] = lobby;

    // Esto significa que el lobby esta lleno y se puede comenzar el game
    if (lobbies[availableLobby].in_game >= 2) {
        completedLobbyId = availableLobby;
        availableLobby = createLobbyId();
        lobbies[availableLobby] = { "players_id": [], "in_game": 0, "players_name": [], "playerId_colorId": {} };
        newGame = true;
    }

    return newGame;
}

function generateIntegerList(size, min, max) {
    let randomIntegers = [];
    for (var i = 0; i < size; i++) {
        randomIntegers.push(Math.floor(Math.random() * (max - min + 1)) + min);
    }

    return randomIntegers;
}

module.exports = {
    lobbies,
    playerLobby,
    addPlayer,
    generateIntegerList
};