document.addEventListener("DOMContentLoaded", event => {
  // Initialize Firebase
  var config = {
    apiKey: "AIzaSyCIl8WekYktjVdqgbU2FQ7cU2yYCbu8sPI",
    authDomain: "sample-737f0.firebaseapp.com",
    databaseURL: "https://sample-737f0.firebaseio.com",
    projectId: "sample-737f0",
    storageBucket: "sample-737f0.appspot.com",
    messagingSenderId: "826522134738"
  };
  firebase.initializeApp(config);

  // html reference
  const chatroom = document.querySelector("#chatroom-chat");
  console.log(chatroom);

  var firestore = firebase.firestore();
  var chatroomRef = firestore.collection("chatroom");

  chatroomRef.orderBy("time", "asc").onSnapshot(querySnapshot => {
    const changes = querySnapshot.docChanges();
    console.log(changes[0]);

    changes.forEach(change => {
      if (change.type === "added") {
        addMessage(chatroom, change.doc.data().name, change.doc.data().message);
      }
    });
  });
});

function addMessage(container, name, message) {
  var messageLine = document.createElement("p");
  messageLine.className = "message-line";

  var text = document.createTextNode(`${name}: ${message}`); // Create a text node
  messageLine.appendChild(text); // Append the text to <p>

  container.appendChild(messageLine);
}

function sendMessage() {
  var firestore = firebase.firestore();
  var chatroomRef = firestore.collection("chatroom");

  // html reference
  const name = document.querySelector("#user-name");
  const message = document.querySelector("#message");

  var newMessage = {
    name: name.value,
    message: message.value,
    time: firebase.firestore.Timestamp.fromDate(new Date())
  };

  chatroomRef.add(newMessage).then(() => {
    console.log("send succesfully");
  });
  name.value = "";
  message.value = "";
}
