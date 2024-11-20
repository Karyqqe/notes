import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Заметки',
      theme: ThemeData(
        primarySwatch: Colors.amber,
        scaffoldBackgroundColor: Colors.amber[50],
      ),
      home: const NotesScreen(),
    );
  }
}

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  _NotesScreenState createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  List<Map<String, String>> _notes = [];

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? notesJson = prefs.getString('notes');
    if (notesJson != null) {
      setState(() {
        _notes = List<Map<String, String>>.from(
          json.decode(notesJson).map<Map<String, String>>(
            (item) => Map<String, String>.from(item),
          ),
        );
      });
    }
  }

  Future<void> _saveNotes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('notes', json.encode(_notes));
  }

  void _addOrEditNote([Map<String, String>? note, int? index]) {
    TextEditingController titleController = TextEditingController(text: note?['title'] ?? '');
    TextEditingController contentController = TextEditingController(text: note?['content'] ?? '');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.amber[100],
          title: Text(
            note == null ? 'Новая заметка' : 'Редактировать заметку',
            style: const TextStyle(color: Colors.black87),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  hintText: "Заголовок",
                  hintStyle: TextStyle(color: Colors.black45),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: contentController,
                decoration: const InputDecoration(
                  hintText: "Содержание",
                  hintStyle: TextStyle(color: Colors.black45),
                ),
                maxLines: 5,
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Отмена',
                style: TextStyle(color: Colors.black54),
              ),
            ),
            TextButton(
              onPressed: () {
                if (titleController.text.isNotEmpty || contentController.text.isNotEmpty) {
                  setState(() {
                    if (index == null) {
                      _notes.add({
                        'title': titleController.text,
                        'content': contentController.text,
                      });
                    } else {
                      _notes[index] = {
                        'title': titleController.text,
                        'content': contentController.text,
                      };
                    }
                  });
                  _saveNotes();
                }
                Navigator.of(context).pop();
              },
              child: Text(
                note == null ? 'Добавить' : 'Сохранить',
                style: const TextStyle(color: Colors.black),
              ),
            ),
          ],
        );
      },
    );
  }

  void _viewNote(Map<String, String> note) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.amber[100],
          title: Text(
            note['title'] ?? 'Без названия',
            style: const TextStyle(color: Colors.black87),
          ),
          content: Text(
            note['content'] ?? '',
            style: const TextStyle(color: Colors.black54),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Закрыть',
                style: TextStyle(color: Colors.black54),
              ),
            ),
          ],
        );
      },
    );
  }

  void _deleteNote(int index) {
    setState(() {
      _notes.removeAt(index);
    });
    _saveNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Заметки'),
        backgroundColor: Colors.amber,
      ),
      body: Stack(
        children: [
          Center(
            child: Icon(
              Icons.note_alt,
              size: 200,
              color: Colors.amber.withOpacity(0.1),
            ),
          ),
          ListView.builder(
            itemCount: _notes.length,
            itemBuilder: (context, index) {
              return Card(
                color: Colors.amber[100],
                margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                child: ListTile(
                  title: Text(
                    _notes[index]['title'] ?? 'Без названия',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(_notes[index]['content'] ?? ''),
                  onTap: () => _viewNote(_notes[index]),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.grey),
                        onPressed: () => _addOrEditNote(_notes[index], index),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteNote(index),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEditNote(),
        backgroundColor: Colors.amber,
        child: const Icon(Icons.add),
      ),
    );
  }
}
