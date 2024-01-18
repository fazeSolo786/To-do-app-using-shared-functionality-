import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Note {
  final String id;
  final String title;
  final String content;

  Note({
    required this.id,
    required this.title,
    required this.content,
  });
}

class NotesApp extends StatefulWidget {
  @override
  _NotesAppState createState() => _NotesAppState();
}

class _NotesAppState extends State<NotesApp> {
  List<Note> notes = [];
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    loadNotes();
  }

  Future<void> loadNotes() async {
    _prefs = await SharedPreferences.getInstance();
    final notesString = _prefs.getStringList('notes') ?? [];

    setState(() {
      notes = notesString.map((noteString) {
        final noteData = noteString.split(',');
        return Note(
          id: noteData[0],
          title: noteData[1],
          content: noteData[2],
        );
      }).toList();
    });
  }

  Future<void> saveNotes() async {
    final notesString = notes.map((note) => '${note.id},${note.title},${note.content}').toList();
    await _prefs.setStringList('notes', notesString);
  }

  Future<void> addNote(Note newNote) async {
    setState(() {
      notes.add(newNote);
    });
    await saveNotes();
  }

  Future<void> updateNote(Note updatedNote) async {
    final noteIndex = notes.indexWhere((note) => note.id == updatedNote.id);
    setState(() {
      notes[noteIndex] = updatedNote;
    });
    await saveNotes();
  }

  Future<void> deleteNote(String noteId) async {
    setState(() {
      notes.removeWhere((note) => note.id == noteId);
    });
    await saveNotes();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notes App',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Notes'),
        ),
        body: ListView.builder(
          itemCount: notes.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(notes[index].title),
              subtitle: Text(notes[index].content),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () {
                      // Navigate to the screen for updating the note
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UpdateNoteScreen(
                            note: notes[index],
                            onUpdate: updateNote,
                          ),
                        ),
                      );
                    },
                    icon: Icon(Icons.edit),
                  ),
                  IconButton(
                    onPressed: () {
                      // Delete the note
                      deleteNote(notes[index].id);
                    },
                    icon: Icon(Icons.delete),
                  ),
                ],
              ),
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // Navigate to the screen for creating a new note
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CreateNoteScreen(
                  onAdd: addNote,
                ),
              ),
            );
          },
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}

class CreateNoteScreen extends StatefulWidget {
  final Function(Note) onAdd;

  CreateNoteScreen({required this.onAdd});

  @override
  _CreateNoteScreenState createState() => _CreateNoteScreenState();
}

class _CreateNoteScreenState extends State<CreateNoteScreen> {
  TextEditingController titleController = TextEditingController();
  TextEditingController contentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Note'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'Title',
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: contentController,
              decoration: InputDecoration(
                labelText: 'Content',
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                // Create a new note object
                Note newNote = Note(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  title: titleController.text,
                  content: contentController.text,
                );

                // Pass the new note back to the previous screen
                widget.onAdd(newNote);

                // Close the current screen
                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}

class UpdateNoteScreen extends StatefulWidget {
  final Note note;
  final Function(Note) onUpdate;

  UpdateNoteScreen({required this.note, required this.onUpdate});

  @override
  _UpdateNoteScreenState createState() => _UpdateNoteScreenState();
}

class _UpdateNoteScreenState extends State<UpdateNoteScreen> {
  TextEditingController titleController = TextEditingController();
  TextEditingController contentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    titleController.text = widget.note.title;
    contentController.text = widget.note.content;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Note'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'Title',
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: contentController,
              decoration: InputDecoration(
                labelText: 'Content',
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                // Create an updated note object
                Note updatedNote = Note(
                  id: widget.note.id,
                  title: titleController.text,
                  content: contentController.text,
                );

                // Pass the updated note back to the previous screen
                widget.onUpdate(updatedNote);

                // Close the current screen
                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(home: NotesApp()));
}
