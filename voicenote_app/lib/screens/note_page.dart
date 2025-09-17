import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:io';

Future<void> saveNoteToFirestore(String content) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  await FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('notes')
      .add({
    'content': content,
    'timestamp': FieldValue.serverTimestamp(),
  });
}

class NotePage extends StatefulWidget {
  const NotePage({super.key});

  @override
  State<NotePage> createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {
  final TextEditingController _controller = TextEditingController();
  late stt.SpeechToText _speech;
  bool isRecording = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  void _toggleRecording() async {
    if (!isRecording) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => isRecording = true);
        _speech.listen(onResult: (result) {
          setState(() {
            _controller.text = result.recognizedWords;
          });
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Microphone could not be initialized.")),
        );
      }
    } else {
      setState(() => isRecording = false);
      _speech.stop();
    }
  }

  void _playNote() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    try {
      final uri = Uri.parse("http://10.0.2.2:8000/speak"); //emülatör için
      final request = http.MultipartRequest("POST", uri)..fields['text'] = text;
      final response = await request.send();

      if (response.statusCode == 200) {
        final bytes = await response.stream.toBytes();
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/tts_note.wav');
        await file.writeAsBytes(bytes);

        final player = AudioPlayer();
        await player.play(DeviceFileSource(file.path));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Audio playback failed.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  void _saveNote() async {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      await saveNoteToFirestore(text);
      Navigator.pop(context, text);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cannot save an empty note.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Note')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                maxLines: null,
                decoration: const InputDecoration(
                  hintText: 'Type or speak your note',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                FloatingActionButton(
                  onPressed: _toggleRecording,
                  backgroundColor: isRecording
                      ? Colors.redAccent
                      : const Color.fromARGB(255, 215, 199, 224),
                  child: Icon(isRecording ? Icons.stop : Icons.mic),
                  tooltip: "Convert speech to text",
                ),
                FloatingActionButton(
                  onPressed: _playNote,
                  child: const Icon(Icons.volume_up),
                  tooltip: "Play note aloud",
                ),
                FloatingActionButton(
                  onPressed: _saveNote,
                  child: const Icon(Icons.check),
                  tooltip: "Save",
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
