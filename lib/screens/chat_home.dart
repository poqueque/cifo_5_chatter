import 'package:chatter/screens/splash.dart';
import 'package:chatter/services/message_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatHome extends StatefulWidget {
  const ChatHome({super.key});

  @override
  State<ChatHome> createState() => _ChatHomeState();
}

class _ChatHomeState extends State<ChatHome> {
  TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ChatHome"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (!context.mounted) return;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => Splash()),
              );
            },
          ),
        ],
      ),
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
                        for (var message in messageProvider.messages)
                          ListTile(title: Text(message.content)),
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
}
