'use strict';
// For Firebase SDK to create Cloud Functions and setup triggers.
const functions = require('firebase-functions');
// The Firebase Admin SDK to access Cloud Firestore.
const admin = require('firebase-admin');
// Initialize the app.
admin.initializeApp();

// A reference to Cloud Firestore.
const db = admin.firestore();

// Refresh time. When the queue has more than 4 players, a game group will be spawned
// after 10 seconds.
// const REFRESH_TIME = 10 * 1000; // 10 seconds in milliseconds.

/*
  Listens for new players added to /Queues/:documentId/twoPlayersQueue or
  fourPlayersQueue and creates a game group to /GameGroups.
*/
exports.makeGameGroup = functions.firestore.document('/Queues/{gameName}/{queueName}/{userID}').onWrite(async (change, context) => {
  // Reference to the parent.
  const ref = db.collection(['Queues', context.params.gameName, context.params.queueName].join('/'));
  
  // Sort the players by their jigsawValue.
  const jigsawValueQuery = await ref.orderBy('jigsawValue').get();

  // An array to keep track of the IDs for all players in the queue.
  const playerIDs = [];
  jigsawValueQuery.forEach(doc => {
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
  // Get the game name.
  const gameName = context.params.gameName;
  // Create an anonymous chatroom.
  const chatroom = await db.collection('Chatrooms').add({
    "name": gameName,
    "playerIDs": [].concat(group1, group2)
  });
  // Get the chatroom ID.
  const chatroomID = chatroom.id;
  // Generate 2 game groups.
  const groups = [group1, group2];
  // Assign group randomly with questionnaires.
  const seed = Math.round(Math.random());

  const gameGroup = {
    "gameName": gameName,
    "chatroomID": chatroomID,
    "chatroomReadyUserIDs": [],
    "roomAttemptedUserIDs": [],
    "roomFinishedUserIDs": [],
    "allRoomsFinishedUserScores": [],
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

/*
  Listens for deletes in /GameGroups/:groupID,
  creates a team ranking to /TeamRankings and remove the game group.
*/
exports.addTeamRankingAndRemoveMatchGroup = functions.firestore.document('/GameGroups/{groupID}').onDelete(async (snap, context) => {
  // Get deleted value.
  const deletedValue = snap.data();
  
  const allScores = deletedValue.allRoomsFinishedUserScores;

  // Some/All players have finished the game.
  if (allScores.length > 0) {
    functions.logger.log('Finished count = ', allScores.length);
    // Create a TeamRanking object.
    const averageScore = allScores.reduce((a,b) => (a+b)) / allScores.length;
    const group1 = deletedValue.group1;
    const group2 = deletedValue.group2;
    const teamRanking = {
      "teamName": "Jigsaw Team",
      "playerIDs": [].concat(group1, group2),
      "gameName": deletedValue.gameName,
      "score": averageScore,
      "playedDate": deletedValue.createdDate
    };
    // Delete the game group.
    // const res1 = await db.collection('GameGroups').doc(context.params.groupID).delete();
    // Add the team ranking in collection "TeamRankings" with generated ID.
    const res2 = await db.collection('TeamRankings').add(teamRanking);
  }
});

/*
  Take the text parameter "groupID" passed to this HTTP endpoint
  and purge the game group in Firestore under /GameGroups/:groupID
*/
exports.removeGameGroup = functions.https.onRequest(async (req, res) => {
  // Grab the text parameter.
  const groupID = req.query.groupID;
  // Push the new message into Cloud Firestore using the Firebase Admin SDK.
  const deleteResult = await db.collection('GameGroups').doc(groupID).delete();
  // Send back an empty 200 status.
  res.status(200).send();
});

// https://firebase.google.com/docs/firestore/manage-data/delete-data
// To add:
// - Delete messages
