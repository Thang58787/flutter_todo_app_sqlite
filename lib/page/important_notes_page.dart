import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '/db/notes_database.dart';
import '/model/note.dart';
import '/page/edit_note_page.dart';
import '/page/search_note_page.dart';
import '/widget/drawer_widget.dart';
import '/widget/note_card_widget.dart';

class ImportantNotesPage extends StatefulWidget {
  @override
  _ImportantNotesPageState createState() => _ImportantNotesPageState();
}

class _ImportantNotesPageState extends State<ImportantNotesPage> {
  final key = GlobalKey<ScaffoldState>();
  late List<Note> notes;
  bool isLoading = false;

  List<int> selectedItemIndex = [];
  bool isMultiSelectionMode = false;
  bool? isVisible = true;

  FToast? fToast;

  @override
  void initState() {
    super.initState();
    refreshNotes();

    fToast = FToast();
    fToast?.init(context);
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
    this.notes = await NotesDatabase.instance.readAllImportantNotes();
    if (!mounted) return;
    setStateIfMounted(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) => WillPopScope(
        onWillPop: () async {
          SystemNavigator.pop();
          return true;
        },
        child: Scaffold(
          drawer: DrawerWidget(),
          appBar: buildAppBar(context),
          body: buildBody(),
          floatingActionButton: buildFloatingActionButton(context),
        ),
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
                refreshNotes();
                setState(() {});
              },
              icon: Icon(Icons.close))
          : null,
      title: Text(
        isMultiSelectionMode ? getSelectedItemCount() : 'Important Notes',
        style: TextStyle(fontSize: 24),
      ),
      actions: [
        Visibility(
          child: buildUnimportantButton(),
          visible: isMultiSelectionMode,
        ),
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
                    'No Important Notes',
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  )
                : buildNotes(),
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
        child: Icon(
          Icons.search,
          color: Colors.white,
        ));
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
        onPressed: () async {
          setState(() {
            for (int index in selectedItemIndex) {
              notes[index].isInRecycleBin = true;
              notes[index].isImportant = false;
              NotesDatabase.instance.update(notes[index]);
              refreshNotes();
              showToast('Moved to Recycle Bin');
            }
            isMultiSelectionMode = false;
          });
        },
        child: Icon(
          Icons.delete,
          color: Colors.white,
        ));
  }

  String getSelectedItemCount() {
    return selectedItemIndex.isNotEmpty
        ? selectedItemIndex.length.toString()
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

  Widget buildUnimportantButton() {
    return TextButton(
        onPressed: () async {
          for (int index in selectedItemIndex) {
            notes[index].isImportant = false;
            await NotesDatabase.instance.update(notes[index]);
          }
          isMultiSelectionMode = false;
          setState(() {});
          refreshNotes();
          showToast('Mark as unimportant');
        },
        child: Icon(
          Icons.star_border,
          color: Colors.white,
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
