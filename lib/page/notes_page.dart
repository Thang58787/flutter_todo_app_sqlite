import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:sqflite_database_example/db/notes_database.dart';
import 'package:sqflite_database_example/model/note.dart';
import 'package:sqflite_database_example/page/edit_note_page.dart';
import 'package:sqflite_database_example/page/recycle_bin_page.dart';
import 'package:sqflite_database_example/page/search_note_page.dart';
import 'package:sqflite_database_example/page/settings_page.dart';
import 'package:sqflite_database_example/widget/note_card_widget.dart';

class NotesPage extends StatefulWidget {
  @override
  _NotesPageState createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final key = GlobalKey<ScaffoldState>();
  late List<Note> notes;
  bool isLoading = false;

  List<int> selectedItemIndex = [];
  bool isMultiSelectionMode = false;
  bool? isVisible = true;

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
    NotesDatabase.instance.deleteEmptyNotes();
    setStateIfMounted(() => isLoading = true);
    this.notes = await NotesDatabase.instance.readAllNotes();
    if (!mounted) return;
    setStateIfMounted(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        drawer: SafeArea(
          child: buildDrawer(context),
        ),
        appBar: buildAppBar(context),
        body: buildBody(),
        floatingActionButton: buildFloatingActionButton(context),
      );

  FloatingActionButton buildFloatingActionButton(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: Colors.black,
      child: Icon(Icons.add),
      onPressed: () async {
        await Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => AddEditNotePage()),
        );

        refreshNotes();
      },
    );
  }

AppBar buildAppBar(BuildContext context) {
    return AppBar(
      leading: isMultiSelectionMode
          ? IconButton(
              onPressed: () {
                selectedItemIndex.clear();
                isMultiSelectionMode = false;
                setState(() {});
              },
              icon: Icon(Icons.close))
          : null,
      title: Text(
        isMultiSelectionMode ? getSelectedItemCount() : 'Notes',
        style: TextStyle(fontSize: 24),
      ),
      actions: [
        Visibility(
          child: buildDeleteButton(),
          visible: isMultiSelectionMode,
        ),
        Visibility(
          child: buildSearchButton(context),
          visible: isMultiSelectionMode == false,
        ),
        SizedBox(width: 12)
      ],
    );
  }

  SafeArea buildBody() {
    return SafeArea(
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
    );
  }

  Drawer buildDrawer(BuildContext context) {
    return Drawer(
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
          ListTile(
            title: new Text(
              "Recycle Bin",
              style: TextStyle(color: Colors.white),
            ),
            leading: new Icon(
              Icons.delete_outline,
              color: Colors.white,
            ),
            onTap: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => RecycleBinPage()),
              );
            },
          ),
        ],
      ),
    );
  }

  TextButton buildSearchButton(BuildContext context) {
    return TextButton(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => SearchNotePage()),
          );
          refreshNotes();
        },
        child: Icon(Icons.search));
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
          if (isMultiSelectionMode) {
            return GestureDetector(
              onTap: () {
                doMultiSelection(index);
              },
              child: NoteCardWidget(note: note, index: index),
            );
          } else {
            return GestureDetector(
              onLongPress: () {
                isMultiSelectionMode = true;
                doMultiSelection(index);
              },
              onTap: () async {
                await Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => AddEditNotePage(note: note),
                ));

                refreshNotes();
              },
              child: NoteCardWidget(note: note, index: index),
            );
          }
        },
      );

  Widget buildDeleteButton() {
    return TextButton(
        onPressed: () {
          for (int index in selectedItemIndex) {
            NotesDatabase.instance.delete(notes[index].id!);
          }
          isMultiSelectionMode = false;
          refreshNotes();
          setState(() {});
        },
        child: Icon(Icons.delete));
  }

  String getSelectedItemCount() {
    return selectedItemIndex.isNotEmpty
        ? selectedItemIndex.length.toString() + " item selected"
        : "No item selected";
  }

  void doMultiSelection(int index) {
    final note = notes[index];
    if (isMultiSelectionMode) {
      if (selectedItemIndex.contains(index)) {
        selectedItemIndex.remove(index);
        note.isSelected = false;
      } else {
        selectedItemIndex.add(index);
        note.isSelected = true;
      }
      if (selectedItemIndex.isEmpty) {
        isMultiSelectionMode = false;
      }
      setState(() {});
    } else {}
  }
}
