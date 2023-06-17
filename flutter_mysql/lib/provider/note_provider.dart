import 'package:flutter/foundation.dart';
import 'package:flutter_mysql/models/note.dart';

class NoteProvider with ChangeNotifier {
  List<Note> _notes = [];

  List<Note> get notes => [..._notes];
  
  void setNotes(List<Note> newNotes) {
    _notes = newNotes;
    notifyListeners();
  }

  void addNote(Note note) {
    _notes.add(note);
    notifyListeners();
  }

  void updateNote(Note updatedNote) {
    final index = _notes.indexWhere((note) => note.id == updatedNote.id);
    if (index != -1) {
      _notes[index] = updatedNote;
      notifyListeners();
    }
  }

  void deleteNote(String noteId) {
    _notes.removeWhere((note) => note.id == noteId);
    notifyListeners();
  }
}
