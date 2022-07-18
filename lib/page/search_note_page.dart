
import 'package:flutter/material.dart';

class SearchNotePage extends StatefulWidget {
  SearchNotePage({Key? key}) : super(key: key);

  @override
  State<SearchNotePage> createState() => _SearchNotePageState();
}



class _SearchNotePageState extends State<SearchNotePage> {

  // late SearchBar searchBar;
  
  // AppBar buildAppBar(BuildContext context) {
  //   return new AppBar(
  //     title: new Text('My Home Page'),
  //     actions: [searchBar.getSearchAction(context)]
  //   );
  // }  
  
  // _MyHomePageState() {
  //   searchBar = new SearchBar(
  //     inBar: false,
  //     setState: setState,
  //     onSubmitted: print,
  //     buildDefaultAppBar: buildAppBar,
  //   );
  // }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Hello'),
      ),
    );
    // return new Scaffold(
    //   appBar: searchBar.build(context)
    // );
  }
}