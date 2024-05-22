import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          scaffoldBackgroundColor: Colors.grey[800],
          appBarTheme: const AppBarTheme(
              color: Colors.black, foregroundColor: Colors.white)),
      home: Scaffold(
        appBar: AppBar(title: const Text('44-R0N-GPT')),
        body: const MessengerProgram(),
      ),
    );
  }
}

class MessengerProgram extends StatefulWidget {
  const MessengerProgram({super.key});

  @override
  State<MessengerProgram> createState() => _MessengerProgram();
}

class _MessengerProgram extends State<MessengerProgram> {
  late IO.Socket socket;
  List<Widget> messageList = [];
  final fieldText = TextEditingController();

  @override
  void initState() {
    // initSocket();
    super.initState();
  }

  initSocket() {
    /* connect to a websocket to send and recieve messages */
    socket = IO.io("http://127.0.0.1:5000", <String, dynamic>{
      'autoConnect': true,
      'transports': ['websocket'],
    });
    socket.connect();
    socket.onConnect((_) => print('connection Established'));
    socket.onDisconnect((_) => print("connection Disconnection"));
    socket.onConnectError((err) => print(err));
    socket.onError((err) => print(err));
    socket.on('overlordMessage', (data) {
      setState(() {
        recieveMessage(data);
      });
    });
  }

  void sendMessage() {
    /* Send Message through a websocket */
    String message = fieldText.text.trim();
    
    if (message.isNotEmpty) {
      // socket.emit('message', message);
      fieldText.clear();
      messageList.add(Align(
          alignment: Alignment.centerRight,
          child: Container(
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.8),
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.fromLTRB(0, 0, 5, 10),
              decoration: BoxDecoration(
                  border: Border.all(),
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  color: Colors.blue[300]),
              child: Text(
                message,
                textAlign: TextAlign.right,
              ))));
    }
  }

  void recieveMessage(data) {
    messageList.add(Align(
        alignment: Alignment.centerRight,
        child: Container(
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.8),
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.fromLTRB(0, 0, 5, 10),
            decoration: BoxDecoration(
                border: Border.all(),
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                color: Colors.purpleAccent[100]),
            child: Text(
              data,
              textAlign: TextAlign.left,
            ))));
  }

  @override
  void dispose() {
    socket.disconnect();
    fieldText.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Expanded(
          child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: messageList.length,
              itemBuilder: (BuildContext context, int index) {
                return messageList[index];
              })),
      Row(children: [
        Expanded(
            flex: 8,
            child: Container(
                padding: const EdgeInsets.fromLTRB(10, 10, 0, 10),
                child: TextField(
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    hintText: 'Enter a message',
                  ),
                  controller: fieldText,
                ))),
        Expanded(
          flex: 2,
          child: FilledButton(
              onPressed: () {
                setState(() {
                  sendMessage();
                });
              },
              style: TextButton.styleFrom(
                minimumSize: const Size(60, 60),
                padding: const EdgeInsets.symmetric(horizontal: 0),
                shape: const CircleBorder(),
              ),
              child: const Icon(Icons.send, size: 30)),
        )
      ])
    ]);
  }
}
