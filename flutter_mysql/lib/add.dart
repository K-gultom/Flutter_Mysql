import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_mysql/models/note.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:flutter_mysql/provider/note_provider.dart';

class Add extends StatefulWidget {
  const Add({Key? key}) : super(key: key);

  @override
  State<Add> createState() => _AddState();
}

class _AddState extends State<Add> {
  final _formKey = GlobalKey<FormState>();

  // Inisialisasi controller
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  Future<void> _onSubmit() async {
    if (_formKey.currentState!.validate()) {
      try {
        final noteProvider = Provider.of<NoteProvider>(context, listen: false);

        final newNote = Note(
          id: '',
          title: _titleController.text,
          content: _contentController.text,
          date: '',
        );

        // Mengirim permintaan POST ke server
        final response = await http.post(
          Uri.parse("http://192.168.1.17/note_app/create.php"),
          body: {
            "title": newNote.title,
            "content": newNote.content,
          },
        );

        final data = jsonDecode(response.body);
        print(data["message"]);

        // Menambahkan catatan ke dalam provider setelah berhasil dikirim
        noteProvider.addNote(newNote);

        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      } catch (e) {
        print(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create New Note"),
      ),
      body: Form(
        key: _formKey,
        child: Container(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Title',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: "Type Note Title",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  fillColor: Colors.white,
                  filled: true,
                ),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Note Title is Required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              const Text(
                'Content',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              TextFormField(
                controller: _contentController,
                keyboardType: TextInputType.multiline,
                minLines: 5,
                maxLines: null,
                decoration: InputDecoration(
                  hintText: "Type Note Content",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  fillColor: Colors.white,
                  filled: true,
                ),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Note Content is Required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Text(
                  "Submit",
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: _onSubmit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
