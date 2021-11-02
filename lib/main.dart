import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeView(),
    );
  }
}

class HomeView extends StatefulWidget {
  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  List<String> messages = [];
  TextEditingController textEditingController = TextEditingController();

  void connect() async {
    print("hello");

    IO.Socket socket = IO.io('https://appio-chat.herokuapp.com/clients');

    socket.onConnectError((data) => print("ConnectionError $data"));

    socket.onConnectTimeout((data) => print("Timeout:  $data"));

    socket.onError((data) => print("Error $data"));

    socket.onConnect((_) {
      print('connect');
      socket.emit('joinRoom', 'clients-chat');
    });
    socket.on('client chat message', (d) => print(d));

    Future.delayed(Duration(seconds: 3), () {
      print(socket.connected);
    });
  }

  @override
  void initState() {
    connect();
    super.initState();
  }

  void sendMessage() {
    messages.insert(0, textEditingController.text);
    textEditingController.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _messagesList(),
            _sendField(),
          ],
        ),
      ),
    );
  }

  Widget _messagesList() => Expanded(
        child: ListView.separated(
          separatorBuilder: (context, index) => Divider(thickness: 2),
          reverse: true,
          itemBuilder: (context, index) => ListTile(
            title: Text(messages[index]),
          ),
          itemCount: messages.length,
        ),
      );

  Widget _sendField() => Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: textEditingController,
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: sendMessage,
          ),
        ],
      );
}
