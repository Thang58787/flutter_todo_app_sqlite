import 'package:flutter/material.dart';
import 'package:sqflite_database_example/db/notes_database.dart';
import 'package:sqflite_database_example/model/note.dart';
import 'package:sqflite_database_example/page/notes_page.dart';
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
  late String description;
  bool? isImportant;


  @override
  void initState() {
    super.initState();

    title = widget.note?.title ?? '';
    description = widget.note?.description ?? '';
    isImportant = widget.note?.isImportant ?? false;
  }

  @override
  Widget build(BuildContext context) => WillPopScope(
        onWillPop: () async {
          addOrUpdateNote();
          Navigator.of(context).pop();
          return true;
        },
        child: Scaffold(
          appBar: AppBar(
            actions: [
              buildToggleImportanrButton(),
              buildDeleteButton(),
              buildSaveButton()
            ],
          ),
          body: Form(
            key: _formKey,
            child: NoteFormWidget(
              title: title,
              description: description,
              onChangedTitle: (title) => setState(() => this.title = title),
              onChangedDescription: (description) =>
                  setState(() => this.description = description),
            ),
          ),
        ),
      );

  Widget buildSaveButton() {
    // final isFormValid = title.isNotEmpty && description.isNotEmpty;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          onPrimary: Colors.white,
        ),
        onPressed: () {
          addOrUpdateNote();
          Navigator.of(context).pop();
        },
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

      // Navigator.of(context).pop();
    }
  }

  Future updateNote() async {
    final note = widget.note!.copy(
      title: title,
      description: description,
      isImportant: widget.note?.isImportant ?? false,
    );
    await NotesDatabase.instance.update(note);
  }

  Future addNote() async {
    final note = Note(
      title: title,
      description: description,
      createdTime: DateTime.now(),
      isImportant: widget.note?.isImportant ?? false,
    );
    await NotesDatabase.instance.create(note);
  }

  Widget buildDeleteButton() {
    if (widget.note != null) {
      return IconButton(
        icon: Icon(Icons.delete),
        onPressed: () async {
          await showDeleteNoteDialog();
        },
      );
    } else
      return Container(
        width: 0,
        height: 0,
      );
  }

  showDeleteNoteDialog() async {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              backgroundColor: Color.fromARGB(133, 191, 189, 189),
              title: Text('Do you want to move this note to recycle bin?',
                  style: TextStyle(color: Colors.white)),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      'NO',
                      style: TextStyle(color: Colors.green),
                    )),
                TextButton(
                    onPressed: () async {
                      // await NotesDatabase.instance.delete(widget.note!.id!);
                      widget.note!.isInRecycleBin = true;
                      NotesDatabase.instance.update(widget.note!);
                      await Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => NotesPage(),
                      ));
                      // Navigator.pop(context);
                      setState(() {
                        
                      });
                      
                    },
                    child: Text(
                      'YES',
                      style: TextStyle(color: Colors.red),
                    )),
              ],
            ));
  }
  
  buildToggleImportanrButton() {
    
    return TextButton(
      child: widget.note?.isImportant == true
      ? Icon(Icons.star, color: Colors.white,)
      : Icon(Icons.star_border, color: Colors.white),
      onPressed: () {
        widget.note!.isImportant = !widget.note!.isImportant!;
        setState(() {
          
        });
      }, 
    );
  }
  
  

  
}
