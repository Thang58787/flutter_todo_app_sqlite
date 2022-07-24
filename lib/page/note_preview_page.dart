import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sqflite_database_example/db/notes_database.dart';
import 'package:sqflite_database_example/model/note.dart';

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

  @override
  void initState() {
    super.initState();
    refreshNote();
  }

  Future refreshNote() async {
    setState(() => isLoading = true);
    this.note = await NotesDatabase.instance.readNote(widget.noteId);
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        // appBar: AppBar(
        //   actions: [
        //     buildDeleteButton();
        //   ],
        // ),
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
      
    //   Widget buildDeleteButton() {
    // if (widget.note != null) {
    //   return IconButton(
    //     icon: Icon(Icons.delete),
    //     onPressed: () async {
    //       await showDeleteNoteDialog();
    //     },
    //   );
    // } else {
    //   return Container(
    //     width: 0,
    //     height: 0,
    //   );}
      

      
  }



  

