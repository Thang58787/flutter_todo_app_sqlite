import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import '/db/notes_database.dart';
import '/model/note.dart';

class NotePreviewPage extends StatefulWidget {
  final int noteId;

  const NotePreviewPage({
    Key? key,
    required this.noteId,
  }) : super(key: key);

  @override
  _NoteDetailPageState createState() => _NoteDetailPageState();
}

class _NoteDetailPageState extends State<NotePreviewPage> {
  late Note note;
  bool isLoading = false;
  FToast? fToast;

  @override
  void initState() {
    super.initState();
    refreshNote();

    fToast = FToast();
    fToast?.init(context);
  }

  Future refreshNote() async {
    setState(() => isLoading = true);
    this.note = await NotesDatabase.instance.readNote(widget.noteId);
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          actions: [
            buidRestoreButton(),
            buildDeleteButton(),
          ],
        ),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : Padding(
                padding: EdgeInsets.all(12),
                child: ListView(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  children: [
                    Text(
                      note.title ?? '',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      DateFormat.yMMMd().format(note.createdTime),
                      style: TextStyle(color: Colors.white38),
                    ),
                    SizedBox(height: 8),
                    Text(
                      note.description ?? '',
                      style: TextStyle(color: Colors.white70, fontSize: 18),
                    )
                  ],
                ),
              ),
      );

  Widget buildDeleteButton() {
    return IconButton(
      icon: Icon(
        Icons.delete,
        color: Colors.white,
      ),
      onPressed: () async {
        await showDeleteNoteDialog();
      },
    );
  }

  showDeleteNoteDialog() async {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              backgroundColor: Color.fromARGB(255, 46, 46, 46),
              title: Text('Do you want to delete this note pernamently?',
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
                      NotesDatabase.instance.delete(note.id!);
                      NotesDatabase.instance.update(note);
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                      showToast('Deleted');
                    },
                    child: Text(
                      'YES',
                      style: TextStyle(color: Colors.blue),
                    )),
              ],
            ));
  }

  buidRestoreButton() {
    return TextButton(
        onPressed: () async {
          showRestoreDialog();
        },
        child: Icon(
          Icons.recycling,
          color: Colors.white,
        ));
  }

  showRestoreDialog() async {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              backgroundColor: Color.fromARGB(255, 46, 46, 46),
              title: Text('Do you want to restore selected notes?',
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
                      setState(() {
                        note.isInRecycleBin = false;
                        NotesDatabase.instance.update(note);
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                        showToast('Restored');
                      });
                    },
                    child: Text(
                      'YES',
                      style: TextStyle(color: Colors.blue),
                    )),
              ],
            ));
  }

  showToast(String message) {
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
