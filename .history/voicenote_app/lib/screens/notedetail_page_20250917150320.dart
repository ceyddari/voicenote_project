import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';

class NoteDetailPage extends StatefulWidget {
  final String noteId;
  final String initialContent;

  const NoteDetailPage({
    super.key,
    required this.noteId,
    required this.initialContent,
  });

  @override
  State<NoteDetailPage> createState() => _NoteDetailPageState();
}

class _NoteDetailPageState extends State<NoteDetailPage> {
  final TextEditingController _controller = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _controller.text = widget.initialContent;
  }

  Future<void> _updateNote() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final updatedText = _controller.text.trim();
    if (updatedText.isEmpty) return;

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('notes')
        .doc(widget.noteId)
        .update({
      'content': updatedText,
      'timestamp': FieldValue.serverTimestamp(),
    });

    Navigator.pop(context);
  }

  Future<void> _deleteNote() async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('notes')
        .doc(widget.noteId)
        .delete();

    Navigator.pop(context);
  }

  void _playNote() async {
    final text = widget.initialContent.trim();
    if (text.isEmpty) return;

    try {
      final uri = Uri.parse("http://10.0.2.2:8000/speak");
      final request = http.MultipartRequest("POST", uri)..fields['text'] = text;
      final response = await request.send();

      if (!mounted) return;

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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Note Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.volume_up),
            onPressed: _playNote,
            tooltip: 'Listen',
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteNote,
            tooltip: 'Delete',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                maxLines: null,
                decoration: const InputDecoration(
                  hintText: 'Edit your note',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _updateNote,
              icon: const Icon(Icons.save),
              label: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }
}
