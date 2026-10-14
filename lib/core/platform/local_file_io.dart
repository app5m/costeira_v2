import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/painting.dart';

Future<ImageProvider<Object>> imageProviderFromPath(String path) async {
  return FileImage(File(path));
}

Future<MultipartFile> multipartFileFromPath(String path) {
  return MultipartFile.fromFile(path);
}
