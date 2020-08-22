// The Cloud Functions for Firebase SDK to create Cloud Functions and setup triggers.
const functions = require('firebase-functions');

// The Firebase Admin SDK to access Cloud Firestore.
const admin = require('firebase-admin');
admin.initializeApp();

// Refresh time. When the queue has more than 4 players, a game group will be spawned
// after 10 seconds.
// const REFRESH_TIME = 10 * 1000; // 10 seconds in milliseconds.

const db = admin.firestore();

// Listens for new players added to /Queues/:documentId/twoPlayersQueue or fourPlayersQueue
// and creates a game group to /GameGroups.
exports.makePlayersGameGroup = functions.firestore.document('/Queues/{gameName}/{queueName}/{userID}').onWrite(async (change, context) => {
  // Reference to the parent.
  const ref = db.collection(['Queues', context.params.gameName, context.params.queueName].join('/'));
  
  // Sort the players by their jigsawValue.
  const jigsawValueQuery = await ref.orderBy('jigsawValue').get();

  // An array to keep track of the IDs for all players in the queue.
  const playerIDs = [];
  jigsawValueQuery.forEach((doc) => {
     playerIDs.push(doc.id)
  })

  // Get total players count in the queue.
  const playersCount = playerIDs.length;

  // Create 2 groups of players.
  const group1 = [];
  const group2 = [];

  // Decide if it is 2 or 4 players queue.
  if (context.params.queueName === 'twoPlayersQueue') {
    if (playersCount === undefined || playersCount < 2) {
      // Not enough players to create a game group.
      return null;
    }
    group1.push(playerIDs[0]);
    group2.push(playerIDs[playersCount-1]);
  } else if (context.params.queueName === 'fourPlayersQueue') {
    if (playersCount === undefined || playersCount < 4) {
      // Not enough players to create game group.
      return null;
    }
    group1.push(playerIDs[0], playerIDs[1]);
    group2.push(playerIDs[playersCount-2], playerIDs[playersCount-1]);
  } else {
    // Invalid case, abort.
    functions.logger.log('Error: Invalid name of queue.');
    return null;
  }

  functions.logger.log('Players count = ', playersCount);
  
  // Generate fields for a game group.
  const createdDate = admin.firestore.FieldValue.serverTimestamp();
  const chatroomID = "TestChatroom1";
  const gameName = context.params.gameName;
  // Generate 2 game groups.
  const groups = [group1, group2];
  // Assign group randomly with questionnaires.
  const seed = Math.round(Math.random());

  const gameGroup = {
    "gameName": gameName,
    "chatroomID": chatroomID,
    "chatroomReadyUserIDs": [],
    "createdDate": createdDate,
    "group1": groups[seed],
    "group2": groups[1-seed]
  };

  // Delete players added to a game group in a batch from the players queue.
  const batch = db.batch();
  [].concat(group1, group2).forEach((id) => {
    batch.delete(ref.doc(id));
  });
  await batch.commit();

  // Add a new document in collection "GameGroups" with generated ID.
  return db.collection('GameGroups').add(gameGroup);
});
