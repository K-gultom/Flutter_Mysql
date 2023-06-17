import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_mysql/models/note.dart';
import 'package:provider/provider.dart';
import 'package:flutter_mysql/provider/note_provider.dart';

class Edit extends StatefulWidget {
  final String id;

  Edit({Key? key, required this.id}) : super(key: key);

  @override
  State<Edit> createState() => _EditState();
}

class _EditState extends State<Edit> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _contentController = TextEditingController();
    _getData();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _getData() async {
    try {
      final response = await http.get(Uri.parse(
          "http://192.168.1.17/note_app/detail.php?id=${widget.id}"));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          _titleController.text = data['title'];
          _contentController.text = data['content'];
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _onUpdate(context) async {
    try {
      final noteProvider = Provider.of<NoteProvider>(context, listen: false);

      final updatedNote = Note(
        id: widget.id,
        title: _titleController.text,
        content: _contentController.text,
        date: '',
      );

      final response = await http.post(
        Uri.parse("http://192.168.1.17/note_app/update.php"),
        body: {
          "id": updatedNote.id,
          "title": updatedNote.title,
          "content": updatedNote.content,
        },
      );

      final data = jsonDecode(response.body);
      print(data["message"]);

      noteProvider.updateNote(updatedNote);

      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    } catch (e) {
      print(e);
    }
  }

  Future<void> _onDelete(context) async {
    try {
      final noteProvider = Provider.of<NoteProvider>(context, listen: false);

      final response = await http.post(
        Uri.parse("http://192.168.1.17/note_app/delete.php"),
        body: {
          "id": widget.id,
        },
      );

      final data = jsonDecode(response.body);
      print(data["message"]);

      noteProvider.deleteNote(widget.id);

      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Note"),
        actions: [
          Container(
            padding: const EdgeInsets.only(right: 20),
            child: IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      content: const Text('Are you sure want to delete this?'),
                      actions: <Widget>[
                        ElevatedButton(
                          child: const Icon(Icons.cancel),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        ElevatedButton(
                          child: const Icon(Icons.check_circle),
                          onPressed: () => _onDelete(context),
                        ),
                      ],
                    );
                  },
                );
              },
              icon: const Icon(Icons.delete),
            ),
          )
        ],
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
              const SizedBox(
                height: 5,
              ),
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
                    return 'Note Title is required!';
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
              const SizedBox(
                height: 5,
              ),
              TextFormField(
                controller: _contentController,
                keyboardType: TextInputType.multiline,
                minLines: 5,
                maxLines: null,
                decoration: InputDecoration(
                  hintText: 'Type Note Content',
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
                    return 'Note Content is Required!';
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
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _onUpdate(context);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
