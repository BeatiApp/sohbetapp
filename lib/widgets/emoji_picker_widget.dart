import 'package:emoji_picker/emoji_picker.dart';
import 'package:flutter/material.dart';

class EmojiPickerWidget extends StatelessWidget {
  final ValueChanged<String> onEmojiSelected;

  const EmojiPickerWidget({Key key, @required this.onEmojiSelected})
      : super(key: key);
  @override
  Widget build(BuildContext context) => EmojiPicker(
        onEmojiSelected: (emoji, category) {
          onEmojiSelected(emoji.emoji);
        },
        rows: 5,
        columns: 7,
      );
}
