import 'package:flutter/material.dart';

class MediaButton extends StatefulWidget {
  const MediaButton({super.key, required this.onChange, required this.media});

  final String media;
  final Function(String) onChange;

  @override
  State<MediaButton> createState() => _MediaButton();
}

class _MediaButton extends State<MediaButton> {
  late String media;

  @override
  void initState() {
    super.initState();
    media = widget.media;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: SegmentedButton<String>(
        style: SegmentedButton.styleFrom(
          selectedForegroundColor: Colors.white,
          selectedBackgroundColor: Colors.blueAccent,
          side: BorderSide(color: Colors.blueAccent, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
        segments: [
          ButtonSegment<String>(
            value: 'TJ',
            label: Text('TJ'),
          ),
          ButtonSegment<String>(
            value: 'KY',
            label: Text('KY')
          )
        ],
        selected: {media},
        onSelectionChanged: (newMedia) {
          setState(() {
            media = newMedia.first;
          });

          widget.onChange(media);
        },
      ),
    );
  }
}