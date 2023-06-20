import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class CustomRatingBar extends StatefulWidget {
  const CustomRatingBar({super.key, required this.title, required this.defaultRating, required this.callback});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;
  final double defaultRating;
  final Function callback;

  @override
  State<CustomRatingBar> createState() => _CustomRatingBarState();
}

class _CustomRatingBarState extends State<CustomRatingBar> {

  @override
  void initState() {
    super.initState();
    widget.callback(widget.title, widget.defaultRating);
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.0),
        child: Column(
          children: [
            Expanded(
              child: Text('${widget.title}',
                style: const TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                    decoration: TextDecoration.underline
                ),
              ),
            ),
            Expanded(
              child: RatingBar.builder(
                initialRating: widget.defaultRating,
                minRating: 0,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                itemSize: 20.0,
                itemBuilder: (context, _) => Icon(
                  Icons.favorite,
                  color: Colors.blue,
                ),
                onRatingUpdate: (rating) {
                  widget.callback(widget.title, rating);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}