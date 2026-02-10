// lib/main.dart

import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'screens/tts_test_screen.dart';
import 'screens/auto_read_sessions_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/conversation_list_screen.dart';
import 'screens/conversation_detail_screen.dart';

void main() {
  runApp(const AffinityVoiceApp());
}

class AffinityVoiceApp extends StatelessWidget {
  const AffinityVoiceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AffinityVoice: Personal Voice Reader',
      theme: ThemeData(
        colorScheme:
            ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),

      // Start on Home Screen
      initialRoute: '/',

      // Define all routes/screens
      routes: {
        '/': (context) => const HomeScreen(),
        '/tts-test': (context) => const TTSTestScreen(),
        '/auto-read-sessions': (context) =>
            const AutoReadSessionsScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/conversations': (context) =>
            const ConversationListScreen(),

        // Conversation detail reads its ID from route arguments
        '/conversation-detail': (context) =>
            const ConversationDetailScreen(),
      },
    );
  }
}
