import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:sqflite_database_example/db/notes_database.dart';
import 'package:sqflite_database_example/model/note.dart';
import 'package:sqflite_database_example/page/edit_note_page.dart';
import 'package:sqflite_database_example/page/search_note_page.dart';
import 'package:sqflite_database_example/page/settings_page.dart';
import 'package:sqflite_database_example/widget/note_card_widget.dart';

class NotesPage extends StatefulWidget {
  @override
  _NotesPageState createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  late List<Note> notes;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    refreshNotes();
  }

  @override
  void dispose() {

    NotesDatabase.instance.close();

    super.dispose();
  }

  void setStateIfMounted(f) {
    if (mounted) setState(f);
  }

  Future refreshNotes() async {
    setStateIfMounted(() => isLoading = true);
    this.notes = await NotesDatabase.instance.readAllNotes();
    if (!mounted) return;
    setStateIfMounted(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        drawer: SafeArea(
          child: Drawer(
            backgroundColor: Color.fromARGB(255, 28, 22, 1),
            elevation: 5,
            child: Column(
              children: <Widget>[
                SizedBox(height: 30),
                ListTile(
                  title: new Text(
                    "Settings",
                    style: TextStyle(color: Colors.white),
                  ),
                  leading: new Icon(
                    Icons.settings,
                    color: Colors.white,
                  ),
                  onTap: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => SettingsPage()),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        appBar: AppBar(
          // leading: TextButton(onPressed: () {}, child: Icon(Icons.segment)),
          title: Text(
            'Notes',
            style: TextStyle(fontSize: 24),
          ),
          actions: [
            TextButton(
                onPressed: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => SearchNotePage()),
                  );

                  refreshNotes();
                },
                child: Icon(Icons.search)),
            SizedBox(width: 12)
          ],
        ),
        body: SafeArea(
          child: Center(
            child: isLoading
                ? CircularProgressIndicator()
                : notes.isEmpty
                    ? Text(
                        'No Notes',
                        style: TextStyle(color: Colors.white, fontSize: 24),
                      )
                    : buildNotes(),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.black,
          child: Icon(Icons.add),
          onPressed: () async {
            await Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => AddEditNotePage()),
            );

            refreshNotes();
          },
        ),
      );

  Widget buildNotes() => StaggeredGridView.countBuilder(
        padding: EdgeInsets.all(8),
        itemCount: notes.length,
        staggeredTileBuilder: (index) => StaggeredTile.fit(2),
        crossAxisCount: 4,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
        itemBuilder: (context, index) {
          final note = notes[index];

          return GestureDetector(
            onTap: () async {
              await Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => AddEditNotePage(note: note),
              ));

              refreshNotes();
            },
            child: NoteCardWidget(note: note, index: index),
          );
        },
      );
}
