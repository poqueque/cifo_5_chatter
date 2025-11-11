import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Message implements Comparable {
  final String uid;
  final String name;
  final String content;
  final DateTime dateTime;

  bool get isMine => uid == FirebaseAuth.instance.currentUser?.uid;

  Message({
    required this.uid,
    required this.name,
    required this.content,
    required this.dateTime,
  });

  factory Message.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return Message(
      uid: data?['uid'] ?? "",
      name: data?['name'] ?? "Anònim",
      content: data?['content'] ?? "",
      dateTime: DateTime.fromMillisecondsSinceEpoch(data?['dateTime'] ?? 0),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      "uid": uid,
      "name": name,
      "content": content,
      "dateTime": dateTime.millisecondsSinceEpoch,
    };
  }

  @override
  int compareTo(dynamic other) {
    if (other is Message) return other.dateTime.compareTo(dateTime);
    return 0;
  }
}
