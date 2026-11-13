// Project-owned worker. Keep real Firebase configuration in the ignored local file.
importScripts('https://www.gstatic.com/firebasejs/12.19.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/12.19.0/firebase-messaging-compat.js');

importScripts('firebase-config.local.js');
firebase.initializeApp(self.PAYPULSE_FIREBASE_CONFIG);

const messaging = firebase.messaging();

// Your own code goes below this line. FlutterFire CLI does not touch it.
