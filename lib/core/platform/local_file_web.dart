import 'package:dio/dio.dart';
import 'package:flutter/painting.dart';
import 'package:image_picker/image_picker.dart';

Future<ImageProvider<Object>> imageProviderFromPath(String path) async {
  final bytes = await XFile(path).readAsBytes();
  return MemoryImage(bytes);
}

Future<MultipartFile> multipartFileFromPath(String path) async {
  final file = XFile(path);
  final bytes = await file.readAsBytes();
  final name = file.name.trim().isEmpty ? 'avatar.jpg' : file.name;
  return MultipartFile.fromBytes(bytes, filename: name);
}
