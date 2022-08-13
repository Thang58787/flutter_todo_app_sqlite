import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '/db/notes_database.dart';
import '/model/note.dart';
import '/page/note_preview_page.dart';
import '/page/recycle_bin_search_note_page.dart';
import '/widget/drawer_widget.dart';
import '/widget/note_card_widget.dart';

class RecycleBinPage extends StatefulWidget {
  const RecycleBinPage({Key? key}) : super(key: key);

  @override
  State<RecycleBinPage> createState() => _RecycleBinPageState();
}

class _RecycleBinPageState extends State<RecycleBinPage> {
  final key = GlobalKey<ScaffoldState>();
  List<Note> notesInRecycleBin = [];
  bool isLoading = false;

  bool isMultiSelectionMode = false;
  List<int> selectedItemIndex = [];
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
    this.notesInRecycleBin =
        await NotesDatabase.instance.readAllNotesInRecycleBin();
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
        ),
      );

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
              icon: Icon(
                Icons.close,
                color: Colors.white,
              ))
          : null,
      // : BackButton(
      //     onPressed: () async {
      //       await Navigator.of(context).push(MaterialPageRoute(
      //         builder: (context) => NotesPage(),
      //       ));
      //     },
      //   ),
      title: Text(
        isMultiSelectionMode ? getSelectedItemCount() : 'Recycle Bin',
        style: TextStyle(fontSize: 24),
      ),
      actions: [
        Visibility(
          child: buidRestoreButton(),
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
            : notesInRecycleBin.isEmpty
                ? Text(
                    'Recycle bin is empty',
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  )
                : buildNotes(),
      ),
    );
  }

  Widget buildNotes() => StaggeredGridView.countBuilder(
        padding: EdgeInsets.all(8),
        itemCount: notesInRecycleBin.length,
        staggeredTileBuilder: (index) => StaggeredTile.fit(2),
        crossAxisCount: 4,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
        itemBuilder: (context, index) {
          final note = notesInRecycleBin[index];
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
                  builder: (context) => NotePreviewPage(
                    noteId: note.id!,
                  ),
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
          showDeleteNoteDialog();
        },
        child: Icon(
          Icons.delete,
          color: Colors.white,
        ));
  }

  TextButton buildSearchButton(BuildContext context) {
    return TextButton(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => RecycleBinSearchNotePage()),
          );
          refreshNotes();
        },
        child: Icon(
          Icons.search,
          color: Colors.white,
        ));
  }

  String getSelectedItemCount() {
    return selectedItemIndex.isNotEmpty
        ? selectedItemIndex.length.toString()
        : "No item selected";
  }

  void doMultiSelection(int index) {
    final note = notesInRecycleBin[index];
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

  buidRestoreButton() {
    return TextButton(
        onPressed: () async {
          showRestoreNoteDialog();
        },
        child: Icon(
          Icons.recycling,
          color: Colors.white,
        ));
  }

  showDeleteNoteDialog() async {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              backgroundColor: Color.fromARGB(255, 46, 46, 46),
              title: Text(
                  'Do you really want to pernamently delete selected notes?',
                  style: TextStyle(color: Colors.white)),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      setState(() {
                        selectedItemIndex.clear();
                        isMultiSelectionMode = false;
                        refreshNotes();
                      });
                    },
                    child: Text(
                      'NO',
                      style: TextStyle(color: Colors.blue),
                    )),
                TextButton(
                    onPressed: () async {
                      for (int index in selectedItemIndex) {
                        NotesDatabase.instance.delete(notesInRecycleBin[index].id!);
                      }
                      Navigator.of(context).pop();
                      isMultiSelectionMode = false;
                      refreshNotes();
                      setState(() {});
                      showToast('Deleted');
                    },
                    child: Text(
                      'YES',
                      style: TextStyle(color: Colors.blue),
                    )),
              ],
            ));
  }

  showRestoreNoteDialog() async {
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
                      setState(() {
                        selectedItemIndex.clear();
                        isMultiSelectionMode = false;
                        refreshNotes();
                      });
                    },
                    child: Text(
                      'NO',
                      style: TextStyle(color: Colors.blue),
                    )),
                TextButton(
                    onPressed: () async {
                      setState(() {
                        Navigator.of(context).pop();
                        for (int index in selectedItemIndex) {
                          notesInRecycleBin[index].isInRecycleBin = false;
                          NotesDatabase.instance.update(notesInRecycleBin[index]);
                        }
                        isMultiSelectionMode = false;
                        refreshNotes();
                      });
                      showToast('Restored');
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

    // Custom Toast Position
    
}
