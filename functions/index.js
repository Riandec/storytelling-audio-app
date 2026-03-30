const functions = require('firebase-functions/v1'); 

// Firebase Admin SDK - for accessing other Firebase services
const admin = require('firebase-admin');

const { setGlobalOptions } = require('firebase-functions');
const { onRequest } = require('firebase-functions/https');
const logger = require('firebase-functions/logger');

admin.initializeApp();

functions.runWith({ maxInstances: 10 });

// Create a function that will run when a new document is created in the 'Stories' collection
exports.sendNewStoryNotification = functions.firestore
  .document('Stories/{storyId}')
  .onCreate(async (snapshot, context) => {
    
    // Fetch data from a newly created document
    const newStoryData = snapshot.data();
    const storyTitle = newStoryData.title; // Verify that your Firestore actually has a field named 'title'

    if (!storyTitle) {
      logger.warn('New story document is missing a title.', { storyId: context.params.storyId });
      return; // return if there is no title
    }

    logger.info(`New story added: ${storyTitle}. Preparing to send notification.`);

    // Create the message to send as a notification
    const message = {
      notification: {
        title: 'New Story Available!',
        body: `The '${storyTitle}' is ready for you. Come in and listen!`,
      },
      data: {
        // You can add more information for use in the app, such as the story's ID.
        'storyId': context.params.storyId,
      },
      topic: 'new_stories'
    };

    // Send a notification to the 'Topic' named 'new_stories'.
    try {
      const response = await admin.messaging().send(message);
      logger.info('Successfully sent notification:', response);
    } catch (error) {
      logger.error('Error sending notification:', error);
    }
  });

// You can add other functions from here
// exports.anotherFunction = ...
