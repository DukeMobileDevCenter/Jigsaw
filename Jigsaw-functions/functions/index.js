// The Cloud Functions for Firebase SDK to create Cloud Functions and setup triggers.
const functions = require('firebase-functions');

// The Firebase Admin SDK to access Cloud Firestore.
const admin = require('firebase-admin');
admin.initializeApp();

// Refresh time. When the queue has more than 4 players, a game group will be spawned
// after 10 seconds.
// const REFRESH_TIME = 10 * 1000; // 10 seconds in milliseconds.

const db = admin.firestore();

// Listens for new players added to /Queues/:documentId/twoPlayersQueue and creates an
// game group to /GameGroups
exports.makeGameGroup = functions.firestore.document('/Queues/Immigration/twoPlayersQueue/{userID}').onWrite(async (change, context) => {
  // Reference to the parent.
  const ref = db.collection('/Queues/Immigration/twoPlayersQueue');
  
  // Sort the players by their jigsawValue.
  const jigsawValueQuery = await ref.orderBy('jigsawValue').get();
  const playerIDs = [];
  // create a map with all children that need to be removed
  const updates = {};
  jigsawValueQuery.forEach((doc) => {
     playerIDs.push(doc.id)
  })
  functions.logger.log(playerIDs);

  const playersCount = playerIDs.length;
  // Not enough players to create a game group.
  if (playersCount === undefined || playersCount < 2) {
    functions.logger.log('Not enough players to create game group.');
    return null;
  }

  functions.logger.log('Players count = ', playersCount);
  // Generate fields for a game group.
  const group1 = [playerIDs[0]];  //, jigsawValueQuery[1]];
  const group2 = [playerIDs[playersCount-1]];  // , jigsawValueQuery[playersCount-2]]
  const createdDate = admin.firestore.FieldValue.serverTimestamp();
  const chatroomID = "TestChatroom1";
  const chatroomUserCount = 0;
  const gameName = "USImmigration1";
  
  const gameGroup = {
    "gameName": gameName,
    "chatroomID": chatroomID,
    "chatroomUserCount": chatroomUserCount,
    "createdDate": createdDate,
    "group1": group1,
    "group2": group2
  };
  // Remove players added to a game group.
  [].concat(group1, group2).forEach(async (id) => {
      await ref.doc(id).delete();
  })
  // Add a new document in collection "GameGroups" with generated ID.
  return db.collection('GameGroups').add(gameGroup);
});
