import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '/db/notes_database.dart';
import '/model/note.dart';
import '/page/edit_note_page.dart';
import '/widget/note_card_widget.dart';

class SearchNotePage extends StatefulWidget {
  SearchNotePage({Key? key}) : super(key: key);

  @override
  State<SearchNotePage> createState() => _SearchNotePageState();
}

class _SearchNotePageState extends State<SearchNotePage> {
  late List<Note> notes;
  late List<Note> allNotes = notes;
  String searchText = "";
  bool isLoading = false;
  final controller = TextEditingController();

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
    this.allNotes = this.notes;
    if (!mounted) return;
    setStateIfMounted(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          autofocus: true,
          style: TextStyle(color: Colors.white),
          controller: controller,
          decoration: InputDecoration(
            border: InputBorder.none,
            focusColor: Color.fromARGB(57, 255, 255, 255),
            hintText: 'Search Notes',
            hintStyle: TextStyle(color: Color.fromARGB(106, 255, 255, 255)),
            suffixIcon: IconButton(
              onPressed: controller.clear,
              icon: Icon(
                Icons.clear,
                color: Color.fromARGB(175, 255, 255, 255),
                size: 18,
              ),
            ),
          ),
          onChanged: searchNote,
        ),
      ),
      body: SafeArea(
        child: Center(
            child: isLoading
                ? CircularProgressIndicator()
                : notes.isEmpty
                    ? Container()
                    : controller.text != ''
                        ? buildNotes()
                        : buildEmptySearch()),
      ),
    );
    // return new Scaffold(
    //   appBar: searchBar.build(context)
    // );
  }

  void searchNote(String value) {
    final suggestions = allNotes.where((note) {
      final noteTitle = note.title?.toLowerCase();
      final noteDescription = note.description?.toLowerCase();
      String? noteContent = '$noteTitle $noteDescription';
      final input = value.toLowerCase();

      return noteContent.contains(input);
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

  Widget buildEmptySearch() {
    return Container();
  }
}
