import 'package:animated_search_bar/animated_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:sqflite_database_example/db/notes_database.dart';
import 'package:sqflite_database_example/model/note.dart';
import 'package:sqflite_database_example/page/edit_note_page.dart';
import 'package:sqflite_database_example/widget/note_card_widget.dart';

class SearchNotePage extends StatefulWidget {
  SearchNotePage({Key? key}) : super(key: key);


  
  @override
  State<SearchNotePage> createState() => _SearchNotePageState();
}

  
class _SearchNotePageState extends State<SearchNotePage> {
  late List<Note> notes;
  String searchText = "";
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    refreshNotes();
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AnimatedSearchBar(
          label: "Search Something Here",
          labelStyle: TextStyle(fontSize: 16),
          searchStyle: TextStyle(color: Colors.white),
          cursorColor: Colors.white,
          searchDecoration: InputDecoration(
            hintText: "Search",
            alignLabelWithHint: true,
            fillColor: Colors.white,
            focusColor: Colors.white,
            hintStyle: TextStyle(color: Colors.white70),
            border: InputBorder.none,
          ),
          onChanged: (value) {
            searchNote(value);
          },
        ),
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
    );
    // return new Scaffold(
    //   appBar: searchBar.build(context)
    // );
  }

  void searchNote(String value) {
    List<Note> filtedNotes = notes.where((note) => note.title != '').toList();
    final suggestions = filtedNotes.where((note) {
      final noteTitle = note.title!.toLowerCase();
      final input = value.toLowerCase();

      return noteTitle.contains(input);
      
      
    }).toList();

    setState(() => notes = suggestions);
  }
  
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
