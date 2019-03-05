import 'package:demo/message.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() => runApp(FirebaseChatroom());

class FirebaseChatroom extends StatefulWidget {
  const FirebaseChatroom({Key key}) : super(key: key);

  @override
  FirebaseChatroomState createState() => FirebaseChatroomState();
}

class FirebaseChatroomState extends State<FirebaseChatroom> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _messageControler = TextEditingController();

  CollectionReference _chatroomRef;

  void initState() {
    super.initState();

    _chatroomRef = Firestore.instance.collection("chatroom");
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
    print(_nameController.text);
    print(_messageControler.text);

    var message =
        Message(_nameController.text, _messageControler.text, DateTime.now());
    _chatroomRef.add(message.toJson());

    _messageControler.text = "";
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
            appBar: AppBar(
              title: Text("Firebase Chatroom"),
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
                            child: Column(
                              children: <Widget>[
                                TextFormField(
                                  decoration:
                                      InputDecoration(hintText: "Your name"),
                                  controller: _nameController,
                                ),
                                TextFormField(
                                  onEditingComplete: _sendMessage,
                                  decoration:
                                      InputDecoration(hintText: "Your message"),
                                  controller: _messageControler,
                                ),
                              ],
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
