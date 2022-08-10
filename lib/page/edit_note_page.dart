import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '/db/notes_database.dart';
import '/model/note.dart';
import '/widget/note_form_widget.dart';

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

  FToast? fToast;

  @override
  void initState() {
    super.initState();

    title = widget.note?.title ?? '';
    description = widget.note?.description ?? '';
    isImportant = widget.note?.isImportant ?? false;

    fToast = FToast();
    fToast?.init(context);
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
      isImportant: isImportant ?? false,
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
              backgroundColor: Color.fromARGB(255, 46, 46, 46),
              title: Text('Do you want to move this note to recycle bin?',
                  style: TextStyle(color: Colors.white)),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      'NO',
                      style: TextStyle(color: Colors.blue),
                    )),
                TextButton(
                    onPressed: () async {
                      // await NotesDatabase.instance.delete(widget.note!.id!);
                      widget.note!.isInRecycleBin = true;
                      NotesDatabase.instance.update(widget.note!);
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                      _showToast('Moved to Recycle Bin');
                    },
                    child: Text(
                      'YES',
                      style: TextStyle(color: Colors.blue),
                    )),
              ],
            ));
  }

  buildToggleImportanrButton() {
    return TextButton(
      child: isImportant == true
          ? Icon(
              Icons.star,
              color: Colors.white,
            )
          : Icon(Icons.star_border, color: Colors.white),
      onPressed: () {
        //TODO: fix here
        setState(() {
          isImportant = !isImportant!;
        });
        widget.note?.isImportant = isImportant;
        
      },
    );
  }

  _showToast(String message) {
    String thisMessage = message;
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: const Color.fromARGB(171, 0, 0, 0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 12.0,
          ),
          Text(
            message,
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );

    // Custom Toast Position
    fToast?.showToast(
        child: toast,
        toastDuration: const Duration(seconds: 2),
        positionedToastBuilder: (context, child) {
          return Positioned(
            bottom: 100,
            left: 16,
            right: 16,
            child: child,
          );
        });
  }
}
