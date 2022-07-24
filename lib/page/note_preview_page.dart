import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sqflite_database_example/db/notes_database.dart';
import 'package:sqflite_database_example/model/note.dart';
import 'package:sqflite_database_example/page/recycle_bin_page.dart';

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
        appBar: AppBar(
          actions: [
            buidRecycleButton(),
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
        icon: Icon(Icons.delete, color: Colors.white,),
        onPressed: () async {
          await showDeleteNoteDialog();
        },
      );
      }

      showDeleteNoteDialog() async {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              backgroundColor: Color.fromARGB(133, 191, 189, 189),
              title: Text('Do you want to delete this note pernamently?',
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
                      await NotesDatabase.instance.delete(note.id!);
                      
                      NotesDatabase.instance.update(note);
                      await Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => RecycleBinPage(),
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
  
  buidRecycleButton() {
    return TextButton(
      onPressed: () async {
          note.isInRecycleBin = false;
          await NotesDatabase.instance.update(note);
          await Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => RecycleBinPage(),
                      ));
          setState(() {});
        },
      child: Icon(Icons.recycling, color: Colors.white,)
    );
  }
}



  

