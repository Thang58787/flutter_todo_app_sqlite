import 'package:flutter/material.dart';
import 'package:sqflite_database_example/page/edit_note_page.dart';

class AddNewNoteButtonWidget extends StatelessWidget {
  const AddNewNoteButtonWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: Colors.black,
      child: Icon(Icons.add),
      onPressed: () async {
        await Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => AddEditNotePage()),
        );
      },
    );
  }
}