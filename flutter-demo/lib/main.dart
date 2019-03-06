import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

void main() => runApp(FirebaseChatroom());

class FirebaseChatroom extends StatefulWidget {
  const FirebaseChatroom({Key key}) : super(key: key);

  @override
  FirebaseChatroomState createState() => FirebaseChatroomState();
}

class FirebaseChatroomState extends State<FirebaseChatroom> {
  TextEditingController _messageControler = TextEditingController();

  CollectionReference _chatroomRef = Firestore.instance.collection("chatroom");
  String userName = "Firebase User";

  _signInWithGoogle() async {
    GoogleSignIn _googleSignIn = GoogleSignIn();

    try {
      GoogleSignInAccount account = await _googleSignIn.signIn();
      if (account != null) {
        userName = account.displayName;
        print(account);
      }
    } catch (error) {
      print(error);
      userName = "Firebase user";
    }
  }

  Widget _buildMessage(String name, String message) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, top: 10, bottom: 10),
      child: Container(
          child: Row(
        children: <Widget>[
          Text(
            "$name: ",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text(message, style: TextStyle(fontSize: 16))
        ],
      )),
    );
  }

  _sendMessage() {
    print(_messageControler.text);

    var message = {
      "name": userName,
      "message": _messageControler.text,
      "time": DateTime.now()
    };
    _chatroomRef.add(message);

    _messageControler.text = "";
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
            appBar: AppBar(
              title: Text("Firebase Chatroom"),
              actions: <Widget>[
                IconButton(
                  onPressed: _signInWithGoogle,
                  icon: Icon(Icons.person),
                ),
              ],
            ),
            body: Column(
              children: <Widget>[
                StreamBuilder<QuerySnapshot>(
                  stream: _chatroomRef.snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.data.documents.isEmpty) {
                      return Expanded(
                          child: Center(child: Text("No one said anything")));
                    } else if (snapshot.hasError) {
                      print(snapshot.error);
                      return Expanded(
                          child: Center(child: Text(snapshot.error)));
                    } else {
                      List<DocumentSnapshot> sorted = snapshot.data.documents;
                      sorted.sort((a, b) {
                        DateTime aTime = a.data["time"];
                        DateTime bTime = b.data["time"];
                        return aTime.compareTo(bTime);
                      });

                      return Expanded(
                        child: ListView.builder(
                          itemCount: sorted.length,
                          itemBuilder: (context, index) {
                            return _buildMessage(sorted[index].data["name"],
                                sorted[index].data["message"]);
                          },
                        ),
                      );
                    }
                  },
                ),
                Divider(height: 1.0),
                Material(
                  child: Container(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: TextFormField(
                              decoration:
                                  InputDecoration(hintText: "Your message..."),
                              controller: _messageControler,
                            ),
                          ),
                          IconButton(
                            splashColor: Colors.red,
                            onPressed: _sendMessage,
                            icon: Icon(Icons.send, color: Colors.blue),
                          )
                        ],
                      ),
                    ),
                  ),
                )
              ],
            )));
  }
}
