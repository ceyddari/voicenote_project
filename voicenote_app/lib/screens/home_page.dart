import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'note_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<String> notes = [];

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final storedNotes = prefs.getStringList('notes');
    if (storedNotes != null) {
      setState(() {
        notes = storedNotes;
      });
    }
  }

  Future<void> _saveNotes() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('notes', notes);
  }

  void _navigateToNotePage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NotePage()),
    );

    if (result != null && result is String && result.isNotEmpty) {
      setState(() {
        notes.add(result);
      });
      await _saveNotes();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notlarım')),
      body: notes.isEmpty
          ? const Center(child: Text("Henüz not yok."))
          : GridView.builder(
              padding: const EdgeInsets.all(16.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // aynı anda 2 not göster
                mainAxisSpacing: 12.0,
                crossAxisSpacing: 12.0,
                childAspectRatio: 1, // kare gibi görünmesi için
              ),
              itemCount: notes.length,
              itemBuilder: (context, index) {
                return Card(
                  color: const Color.fromARGB(255, 237, 229, 246),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      notes[index],
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToNotePage,
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
