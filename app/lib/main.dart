import 'dart:ui';

import 'package:app/src/app.dart';
import 'package:app/src/screens/home/index.dart';
import 'package:app/src/utils/app_state_notifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:background_fetch/background_fetch.dart';

// This "Headless Task" is run when app is terminated.

void main() {

  runApp(
    ChangeNotifierProvider<AppStateNotifier>(
      create: (_) => AppStateNotifier(),
      child: App(),
    ),
  );
}
