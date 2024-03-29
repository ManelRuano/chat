import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_cupertino_desktop_kit/cdk.dart';
import 'package:flutter_postget/chat_message.dart';
import 'package:provider/provider.dart';
import 'package:velocity_x/velocity_x.dart';

import 'app_data.dart';

class LayoutDesktop extends StatefulWidget {
  const LayoutDesktop({super.key});

  @override
  State<LayoutDesktop> createState() => _LayoutDesktopState();
}

class _LayoutDesktopState extends State<LayoutDesktop> {
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [];

  void _sendMessage(
      AppData appData, String messageSender, String messageText) async {
    // Create a message object

    ChatMessage _message =
        ChatMessage(text: messageText, sender: messageSender);

    // Update UI with the new message
    setState(() {
      if (messageText.isNotEmpty) {
        _messages.insert(0, _message);
      }
    });

    try {
      if (messageText.isNotEmpty) {
        // If the message is text, send it as 'conversa' type
        print("aaaaa");
        appData.load('POST',
            selectedFile: null,
            messageType: 'conversa',
            messageText: messageText);
      } else {
        // If the message is a file, send it as 'imatge' type
        File selectedFile = await pickFile();
        appData.load('POST',
            selectedFile: selectedFile, messageType: 'imatge', messageText: '');
      }
    } catch (e) {
      if (kDebugMode) {
        print("Excepción (sendMessage): $e");
      }
    }
    // Clear the text input
    _controller.clear();
  }

  // Return a custom button

  // Función para seleccionar un archivo
  Future<File> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      File file = File(result.files.single.path!);
      return file;
    } else {
      throw Exception("No se ha seleccionado ningún archivo.");
    }
  }

  // Función para cargar el archivo seleccionado con una solicitud POST
  Future<void> uploadFile(AppData appData) async {
    try {
      appData.load("POST",
          selectedFile: await pickFile(), messageType: '', messageText: '');
    } catch (e) {
      if (kDebugMode) {
        print("Excepción (uploadFile): $e");
      }
    }
  }

  Widget _builderTextComposer(AppData appData) {
    return Container(
      margin: const EdgeInsets.symmetric(
          horizontal: 8.0), // Adjust the horizontal margin as needed
      decoration: BoxDecoration(
        borderRadius:
            BorderRadius.circular(20.0), // Set your desired border radius
        border: Border.all(
            color: const Color.fromARGB(
                255, 204, 204, 204)), // Add a border for better visibility
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              onSubmitted: (value) {
                _sendMessage(appData, "User", _controller.text);
              },
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0), // Adjust padding as needed
                hintText: "Send a message",
                border: InputBorder.none, // Remove the default border
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.stop),
            onPressed: () {
              // Enviar un GET para parar la respuesta
              appData.load("GET",
                  selectedFile: null, messageType: '', messageText: '');
            },
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () {
              _sendMessage(appData, "User", _controller.text);
            },
          ),
          IconButton(
            icon: const Icon(Icons.upload_file),
            onPressed: () {
              uploadFile(appData);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    AppData appData = Provider.of<AppData>(context);

    String stringGet = "";
    if (appData.loadingGet && appData.dataGet == "") {
      stringGet = "Loading ...";
    } else if (appData.dataGet != null) {
      stringGet = "GET: ${appData.dataGet.toString()}";
    }

    String stringPost = "";
    if (appData.loadingPost) {
      stringPost = "Loading ...";
    } else if (appData.dataPost != null) {
      stringPost = "GET: ${appData.dataPost.toString()}";
    }

    String stringFile = "";
    if (appData.loadingFile) {
      stringFile = "Loading ...";
    } else if (appData.dataFile != null) {
      stringFile = "File: ${appData.dataFile}";
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("IetiChat"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Flexible(
              child: Container(
                margin: const EdgeInsets.only(
                    left: 20, top: 20, right: 20, bottom: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  color: Colors.blueGrey[200],
                ),
                child: ListView.builder(
                  reverse: true,
                  padding: Vx.m8,
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    return _messages[index];
                  },
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(color: context.cardColor),
              child: Padding(
                padding: const EdgeInsetsDirectional.only(
                    start: 20, end: 20, bottom: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: _builderTextComposer(appData),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
