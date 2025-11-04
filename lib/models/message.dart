import 'package:cloud_firestore/cloud_firestore.dart';

class Message implements Comparable {
  final String uid;
  final String content;
  final DateTime dateTime;

  Message({required this.uid, required this.content, required this.dateTime});

  factory Message.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return Message(
      uid: data?['uid'] ?? "",
      content: data?['content'] ?? "",
      dateTime: DateTime.fromMillisecondsSinceEpoch(data?['dateTime'] ?? 0),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      "uid": uid,
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
