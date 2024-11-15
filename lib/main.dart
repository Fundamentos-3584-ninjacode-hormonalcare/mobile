import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:trabajo_moviles_ninjacode/scr/features/iam/presentation/pages/sign_in.dart';
import 'package:trabajo_moviles_ninjacode/scr/shared/app.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase with the correct options for the current platform
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Activate App Check with a debug provider for Android
  FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug, // Use debug token
  );

  // Check if the user is signed in, if not, sign them in
  FirebaseAuth auth = FirebaseAuth.instance;

  // Optionally, use anonymous sign-in or your preferred sign-in method
  User? user = auth.currentUser;
  if (user == null) {
    await auth.signInAnonymously();
  }

  // Run the app after Firebase setup and user sign-in
  runApp(MyApp());
}