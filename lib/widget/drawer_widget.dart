import 'package:flutter/material.dart';
import 'package:sqflite_database_example/page/important_notes_page.dart';
import 'package:sqflite_database_example/page/notes_page.dart';
import 'package:sqflite_database_example/page/recycle_bin_page.dart';

class DrawerWidget extends StatelessWidget {
  const DrawerWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Drawer(
        backgroundColor: Color.fromARGB(255, 28, 22, 1),
        elevation: 5,
        child: Column(
          children: <Widget>[
            SizedBox(height: 30),
            ListTile(
              title: new Text(
                "Home",
                style: TextStyle(color: Colors.white),
              ),
              leading: new Icon(
                Icons.home,
                color: Colors.white,
              ),
              onTap: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => NotesPage()),
                );
              },
            ),
            ListTile(
              title: new Text(
                "Important",
                style: TextStyle(color: Colors.white),
              ),
              leading: new Icon(
                Icons.star,
                color: Colors.white,
              ),
              onTap: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => ImportantNotesPage()),
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
            
            // ListTile(
            //   title: new Text(
            //     "Settings",
            //     style: TextStyle(color: Colors.white),
            //   ),
            //   leading: new Icon(
            //     Icons.settings,
            //     color: Colors.white,
            //   ),
            //   onTap: () async {
            //     await Navigator.of(context).push(
            //       MaterialPageRoute(builder: (context) => SettingsPage()),
            //     );
            //   },
            // ),
          ],
        ),
      ),
    );
  }
}