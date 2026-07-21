import 'dart:io';
import 'package:image/image.dart';

void main() {
  final file = File('assets/icon/logo.png');
  final bytes = file.readAsBytesSync();
  final image = decodeImage(bytes);
  if (image != null) {
    // Crop the left square
    final cropped = copyCrop(image, x: 0, y: 0, width: image.height, height: image.height);
    file.writeAsBytesSync(encodePng(cropped));
    print('Cropped successfully.');
  }
}
