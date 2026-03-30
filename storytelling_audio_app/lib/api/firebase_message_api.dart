import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseMessageApi {
  // instance of Firebase Messaging
  final firebaseMessaging = FirebaseMessaging.instance;
  static const String notificationTopic = 'new_stories';

  // initialize notifications
  Future<void> initNotifications() async {
    // request permission from user (will prompt user)
    await firebaseMessaging.requestPermission();
    // fetch the FCM token for this device
    final fcmToken = await firebaseMessaging.getToken();
    // print the token (normally you would send this to your server)
    print('Token: $fcmToken');
    // Enable this device to receive notifications from the topic 'new_stories'
    await firebaseMessaging.subscribeToTopic(notificationTopic);
    // initialize further settings for push notification
    initPushNotifications();
  }

  // handle received messages
  void handleMessage(RemoteMessage? message) {
    // if the message is null, do nothing
    if (message == null) {
      return;
    }
    // navigate to new screen when message is received and user taps notification
    
  }

  // initialize foreground and background settings
  Future initPushNotifications() async {
    // handle notification if the app was terminated and now opened
    FirebaseMessaging.instance.getInitialMessage().then(handleMessage);
    // attach event listeners for when a notification opens the app
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
  }

  // enable notifications request permission and subscribe to topic
  // return true if allow or false if block permission
  Future<bool> enableNotifications() async {
    // request permission
    NotificationSettings settings = await firebaseMessaging.requestPermission();
    // check result
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User accepted permission');
      await firebaseMessaging.subscribeToTopic(notificationTopic);
      print('Subscribed to $notificationTopic topic');
      return true;
    } else {
      print('User declined permission');
      return false;
    }
  }

  // disable notifications, unsubscribe topic
  Future<void> disableNotifications() async {
    await firebaseMessaging.unsubscribeFromTopic(notificationTopic);
    print('Unsubscribed from $notificationTopic topic');
  }
}