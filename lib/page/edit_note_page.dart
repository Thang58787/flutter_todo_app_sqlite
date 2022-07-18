import 'package:flutter/material.dart';
import 'package:sqflite_database_example/db/notes_database.dart';
import 'package:sqflite_database_example/model/note.dart';
import 'package:sqflite_database_example/widget/note_form_widget.dart';

class AddEditNotePage extends StatefulWidget {
  final Note? note;

  const AddEditNotePage({
    Key? key,
    this.note,
  }) : super(key: key);
  @override
  _AddEditNotePageState createState() => _AddEditNotePageState();
}

class _AddEditNotePageState extends State<AddEditNotePage> {
  final _formKey = GlobalKey<FormState>();
  late String title;
  late String content;

  @override
  void initState() {
    super.initState();

    title = widget.note?.title ?? '';
    content = widget.note?.content ?? '';
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          actions: [buildButton(), deleteButton()],
        ),
        body: Form(
          key: _formKey,
          child: NoteFormWidget(
            title: title,
            content: content,
            onChangedTitle: (title) => setState(() => this.title = title),
            onChangedDescription: (content) =>
                setState(() => this.content = content),
          ),
        ),
      );

  Widget buildButton() {
    final isFormValid = title.isNotEmpty && content.isNotEmpty;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          onPrimary: Colors.white,
          primary: isFormValid ? null : Colors.grey.shade700,
        ),
        onPressed: addOrUpdateNote,
        child: Text('Save'),
      ),
    );
  }

  void addOrUpdateNote() async {
    final isValid = _formKey.currentState!.validate();

    if (isValid) {
      final isUpdating = widget.note != null;

      if (isUpdating) {
        await updateNote();
      } else {
        await addNote();
      }

      Navigator.of(context).pop();
    }
  }

  Future updateNote() async {
    final note = widget.note!.copy(
      title: title,
      content: content,
    );
    await NotesDatabase.instance.update(note);
  }

  Future addNote() async {
    final note = Note(
      title: title,
      content: content,
      createdTime: DateTime.now(),
    );
    await NotesDatabase.instance.create(note);
  }

  Widget deleteButton() => IconButton(
        icon: Icon(Icons.delete),
        onPressed: () async {
          

          await NotesDatabase.instance.delete(widget.note!.id!);

          Navigator.of(context).pop();
        },
      );
}
