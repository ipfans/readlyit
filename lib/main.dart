import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:readlyit/app/app_widget.dart';

void main() {
  // For Riverpod, we need to wrap the entire application in a ProviderScope
  runApp(const ProviderScope(child: AppWidget()));
}
