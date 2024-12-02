importScripts("https://www.gstatic.com/firebasejs/9.10.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/9.10.0/firebase-messaging-compat.js");

firebase.initializeApp({
    apiKey: "AIzaSyCO39iRJsfjx2Xt3VCb4MFEloG10fO2Gas",
    authDomain: "hanuman-4e9f4.firebaseapp.com",
    projectId: "hanuman-4e9f4",
    storageBucket: "hanuman-4e9f4.appspot.com",
    messagingSenderId: "390113074845",
    appId: "1:390113074845:web:393df32a7cf839ca69fe74",
    measurementId: 'G-5545S7G722',
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage(function(payload) {
    console.log('Received background message:', payload);
    
    // Opcional: Mostrar notificação
    const notificationTitle = payload.notification.title;
    const notificationOptions = {
        body: payload.notification.body,
        icon: '/icons/Icon-192.png' // Caminho para seu ícone
    };

    return self.registration.showNotification(notificationTitle, notificationOptions);
});