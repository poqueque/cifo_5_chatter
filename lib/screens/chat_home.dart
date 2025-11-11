import 'dart:io';

import 'package:chat_bubbles/bubbles/bubble_special_one.dart';
import 'package:chatter/extensions/date_time_extension.dart';
import 'package:chatter/models/message.dart';
import 'package:chatter/screens/splash.dart';
import 'package:chatter/services/message_provider.dart';
import 'package:chatter/styles/app_styles.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class ChatHome extends StatefulWidget {
  const ChatHome({super.key});

  @override
  State<ChatHome> createState() => _ChatHomeState();
}

class _ChatHomeState extends State<ChatHome> {
  TextEditingController controller = TextEditingController();
  TextEditingController nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              currentAccountPicture: CircleAvatar(
                backgroundImage: NetworkImage(
                  FirebaseAuth.instance.currentUser?.photoURL ??
                      "https://static.thenounproject.com/png/5034901-200.png",
                ),
              ),
              accountName: Text(
                FirebaseAuth.instance.currentUser?.displayName ?? "---",
              ),
              accountEmail: Text(
                FirebaseAuth.instance.currentUser?.email ?? "---",
              ),
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text("Canviar nom d'usuari"),
              onTap: showInputDialog,
            ),
            ListTile(
              leading: Icon(Icons.camera),
              title: Text("Foto de perfil"),
              onTap: changeProfileImage,
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text("Sortir"),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                if (!context.mounted) return;
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => Splash()),
                );
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(title: Text("ChatHome")),
      body: SafeArea(
        child: Center(
          child: Consumer<MessageProvider>(
            builder: (context, messageProvider, child) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: ListView(
                      reverse: true,
                      children: [
                        for (Message message in messageProvider.messages)
                          Column(
                            children: [
                              if (!message.isMine)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 16,
                                    top: 8,
                                  ),
                                  child: Align(
                                    alignment: Alignment.bottomLeft,
                                    child: Text(message.name),
                                  ),
                                )
                              else
                                AppStyles.separator,
                              BubbleSpecialOne(
                                text: message.content,
                                isSender: message.isMine,
                              ),
                              Align(
                                alignment: message.isMine
                                    ? Alignment.centerRight
                                    : Alignment.centerLeft,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                  ),
                                  child: Text(message.dateTime.hhmm),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: controller,
                      decoration: InputDecoration(
                        hintText: "Escriu un missatge",
                        border: OutlineInputBorder(),
                        suffixIcon: IconButton(
                          onPressed: () => sendMessage(controller.text),
                          icon: Icon(Icons.send),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> sendMessage(String value) async {
    var messageProvider = context.read<MessageProvider>();
    await messageProvider.addMessage(value);
    controller.text = "";
  }

  void showInputDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text("Introdueix el teu nom"),
        content: TextField(
          controller: nameController,
          decoration: InputDecoration(hintText: "Nom d'usuari"),
        ),
        actions: [
          TextButton(onPressed: saveUserName, child: Text("GUARDAR")),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("CANCELAR"),
          ),
        ],
      ),
    );
  }

  Future<void> saveUserName() async {
    await FirebaseAuth.instance.currentUser?.updateDisplayName(
      nameController.text,
    );
    if (!mounted) return;
    Navigator.pop(context);
    setState(() {});
  }

  Future<void> changeProfileImage() async {
    ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final storageRef = FirebaseStorage.instance.ref();
      final imageRef = storageRef
          .child("users")
          .child(FirebaseAuth.instance.currentUser!.uid)
          .child("profile.png");
      File imageFile = File(image.path);
      try {
        await imageRef.putFile(imageFile);
        String downloadUrl = await imageRef.getDownloadURL();
        await FirebaseAuth.instance.currentUser?.updatePhotoURL(downloadUrl);
      } catch (e) {
        debugPrint("Error pujant fitxer: $e");
      }
      setState(() {});
    }
  }
}
