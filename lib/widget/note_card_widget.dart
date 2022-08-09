import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '/model/note.dart';

final _lightColors = [
  Colors.amber.shade300,
  Colors.lightGreen.shade300,
  Colors.lightBlue.shade300,
  Colors.orange.shade300,
  Colors.pinkAccent.shade100,
  Colors.tealAccent.shade100
];

class NoteCardWidget extends StatelessWidget {
  NoteCardWidget({
    Key? key,
    required this.note,
    required this.index,
    this.isTransparent = false,
  }) : super(key: key);

  final Note note;
  final int index;
  bool? isTransparent = false;

  String? removeWhitespace(String? str) {
    return str?.replaceAll(' ', '');
  }

  @override
  Widget build(BuildContext context) {
    /// Pick colors from the accent colors based on index
    final color = (note.isSelected == false) ? _lightColors[index % _lightColors.length] : _lightColors[index % _lightColors.length].withOpacity(0.6);
    final time = DateFormat.yMMMd().format(note.createdTime);
    final minHeight = getMinHeight(index);

    // if (removeWhitespace(note.title) != '' ||
    //     removeWhitespace(note.description) != '') {
      return Card(
        color: color,
        child: Container(
          constraints: BoxConstraints(minHeight: minHeight),
          padding: EdgeInsets.all(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                time,
                style: TextStyle(color: Colors.grey.shade700),
              ),
              SizedBox(height: 4),
              if (removeWhitespace(note.title) != '')
                Text(
                  note.title?.trim() ?? '',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              if (removeWhitespace(note.description)  != '')
                Text(
                  note.description?.trim().replaceAll('\n', ' ') ?? '',
                  maxLines: 8,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                  ),
                ),
            ],
          ),
        ),
      );
    } 
  //   else 
  //     return Container(
  //       width: 0,
  //       height: 0,
  //     );
  // }

  /// To return different height for different widgets
  double getMinHeight(int index) {
    switch (index % 4) {
      case 0:
        return 100;
      case 1:
        return 150;
      case 2:
        return 150;
      case 3:
        return 100;
      default:
        return 100;
    }
  }
}
