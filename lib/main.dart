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
      home: SplashView(),
    );
  }
}

class SplashView extends StatelessWidget {
  String value = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
            onChanged: (v) => value = v,
          ),
          ElevatedButton(
            child: Text("Connect!"),
            onPressed: () => Navigator.push(context, MaterialPageRoute(
              builder: (context) => HomeView(value),
            )),
          ),
        ],
      ),
    );
  }
}


class HomeView extends StatefulWidget {
  final String url;
  HomeView(this.url);
  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  List<Map<String, bool>> messages = [];
  TextEditingController textEditingController = TextEditingController();

  late IO.Socket socket;

  void connect() async {

    socket = IO.io(widget.url.isNotEmpty ? widget.url : 'https://appio-chat.herokuapp.com/clients',<String, dynamic>{
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
          itemBuilder: (context, index) {
            final isMe = messages[index].values.first;
            return Padding(
              padding: EdgeInsets.only(right: isMe ? 100 : 0, left: isMe ? 0 : 100),
              child: ListTile(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)
                ),
                title: Text(messages[index].keys.first, style: TextStyle(color: Colors.white),),
                tileColor: isMe ? Colors.blue : Colors.red,
              ),
            );
          },
          itemCount: messages.length,
        ),
      );

  Widget _sendField() => Container(
    color: Colors.white,
    child: Row(
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
        ),
  );
}
