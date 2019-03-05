import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  String name;
  String message;
  DateTime time;

  Message(this.name, this.message, this.time);

  Message.fromSnapshot(DocumentSnapshot snapshot) {
    name = snapshot.data["name"];
    message = snapshot.data["messasge"];
    time = snapshot.data["time"];
  }

  toJson() {
    return {"name": name, "message": message, "time": Timestamp.fromDate(time)};
  }
}
