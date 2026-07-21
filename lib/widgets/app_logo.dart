import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double size;
  
  const AppLogo({Key? key, this.size = 1.0}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // The Z Logo: Black background, green border
        Container(
          width: 40 * size,
          height: 40 * size,
          decoration: BoxDecoration(
            color: Colors.black,
            border: Border.all(color: Colors.greenAccent, width: 2 * size),
            borderRadius: BorderRadius.circular(8 * size),
          ),
          child: Center(
            child: Text(
              'Z',
              style: TextStyle(
                fontSize: 24 * size,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        SizedBox(width: 10 * size),
        // The Text: Life \n watch
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Life',
              style: TextStyle(
                fontSize: 22 * size,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                height: 1.0,
              ),
            ),
            Text(
              'watch',
              style: TextStyle(
                fontSize: 14 * size,
                fontWeight: FontWeight.w600,
                color: Colors.greenAccent,
                height: 1.0,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
