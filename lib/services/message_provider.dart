import 'package:chatter/models/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MessageProvider extends ChangeNotifier {
  List<Message> messages = [];

  final db = FirebaseFirestore.instance;

  MessageProvider() {
    loadMessages();
  }

  Future<void> addMessage(String content) async {
    if (FirebaseAuth.instance.currentUser == null) return;

    var message = Message(
      uid: FirebaseAuth.instance.currentUser!.uid,
      content: content,
      dateTime: DateTime.now(),
    );

    final docRef = db
        .collection("chatRooms")
        .doc("room1")
        .collection("messages")
        .withConverter(
          fromFirestore: Message.fromFirestore,
          toFirestore: (Message message, options) => message.toFirestore(),
        );
    await docRef.add(message);
  }

  void loadMessages() {
    final docRef = db
        .collection("chatRooms")
        .doc("room1")
        .collection("messages")
        .withConverter(
          fromFirestore: Message.fromFirestore,
          toFirestore: (Message message, options) => message.toFirestore(),
        );

    docRef.snapshots().listen((event) {
      messages = event.docs.map((e) => e.data()).toList().reversed.toList();
      messages.sort();
      notifyListeners();
    }, onError: (error) => debugPrint("Error escoltant Firebase: $error"));
  }
}
