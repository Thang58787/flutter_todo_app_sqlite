import 'package:animated_search_bar/animated_search_bar.dart';
import 'package:flutter/material.dart';

class SearchNotePage extends StatefulWidget {
  SearchNotePage({Key? key}) : super(key: key);

  @override
  State<SearchNotePage> createState() => _SearchNotePageState();
}



class _SearchNotePageState extends State<SearchNotePage> {
  String searchText = "";
  
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
              print("value on Change");
              setState(() {
                searchText = value;
              });
            },
          ),
        ),
        
      );
    // return new Scaffold(
    //   appBar: searchBar.build(context)
    // );
  }
}