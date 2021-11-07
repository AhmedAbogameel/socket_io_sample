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
  List<Map<String, bool>> messages = [];
  TextEditingController textEditingController = TextEditingController();

  IO.Socket socket;

  void connect() async {

    socket = IO.io('',<String, dynamic>{
      'transports': ['websocket'],
      'forceNew': true
    });

    socket.onConnectError((data) => print("ConnectionError $data"));

    socket.onConnectTimeout((data) => print("Timeout:  $data"));

    socket.onError((data) => print("Error $data"));

    socket.onConnect((_) {
      socket.emit('joinRoom', 'clients-chat');
    });
    socket.on('client chat message', (d) {
      messages.insert(0, {d: false});
      setState(() {});
    });
  }

  @override
  void initState() {
    connect();
    super.initState();
  }

  void sendMessage() {
    messages.insert(0, {textEditingController.text: true});
    setState(() {});
    socket.emit('client chat message', textEditingController.text);
    textEditingController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
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
            title: Text(messages[index].keys.first, ),
            tileColor: messages[index].values.first ? Colors.blue : Colors.red,
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
