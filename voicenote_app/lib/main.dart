import 'package:flutter/material.dart';
import 'screens/note_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const VoiceNoteApp());
}

class VoiceNoteApp extends StatelessWidget {
  const VoiceNoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Voice Note',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: const LoginPage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<String> notes = []; // notlar burada tutuluyor

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Notlarım")),
      body: notes.isEmpty
          ? const Center(child: Text("Henüz hiç not alınmadı."))
          : ListView.builder(
              itemCount: notes.length,
              itemBuilder: (context, index) => ListTile(
                title: Text(notes[index]),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newNote = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NotePage()),
          );

          if (newNote != null && newNote is String) {
            setState(() {
              notes.add(newNote);
            });
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
