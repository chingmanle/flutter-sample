import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'dart:js' as js; // For detecting browser type in web

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Speech to Text',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: SpeechToTextPage(),
    );
  }
}

class SpeechToTextPage extends StatefulWidget {
  @override
  _SpeechToTextPageState createState() => _SpeechToTextPageState();
}

class _SpeechToTextPageState extends State<SpeechToTextPage> {
  SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _recognizedText = "Press the microphone button to start speaking...";
  List<LocaleName> _availableLanguages = [];
  String _selectedLanguage = 'en_US'; // Default to English
  bool _isChrome = false;
  bool _isSupportedBrowser = true;

  @override
  void initState() {
    super.initState();
    _detectBrowser();
    _initSpeech();
  }

  // Detect browser type
  void _detectBrowser() {
    if (kIsWeb) {
      String userAgent = js.context['navigator']['userAgent'].toString();
      _isChrome = userAgent.contains("Chrome"); // Check if it's Chrome

      if (!_isChrome) {
        _isSupportedBrowser = false; // Disable speech recognition
      }
    }
  }

  // Initialize speech recognition and get available languages
  void _initSpeech() async {
    if (!_isSupportedBrowser) return; // Skip initialization for unsupported browsers

    _speechEnabled = await _speechToText.initialize(
      onStatus: (status) => print('Status: $status'),
      onError: (error) => print('Error: $error'),
    );

    if (_speechEnabled) {
      if (!kIsWeb) {
        // Fetch available languages for Android/iOS
        _availableLanguages = await _speechToText.locales();
      } else {
        // Manually define supported languages for Chrome
        _availableLanguages = [
          LocaleName("en-US", "English (US)"),
          LocaleName("es-ES", "Spanish (Spain)"),
          LocaleName("fr-FR", "French (France)"),
          LocaleName("de-DE", "German (Germany)"),
          LocaleName("zh-CN", "Chinese (Simplified)"),
          LocaleName("zh-TW", "Chinese (Traditional)"),
          LocaleName("yue-HK", "Cantonese (Hong Kong)"),
        ];
      }
      setState(() {});
    }
  }

  // Start listening with the selected language
  void _startListening() {
    if (!_isSupportedBrowser) return;
    _speechToText.listen(
      onResult: _onSpeechResult,
      localeId: _selectedLanguage,
    );
    setState(() {});
  }

  // Stop listening
  void _stopListening() {
    if (!_isSupportedBrowser) return;
    _speechToText.stop();
    setState(() {});
  }

  // Handle speech recognition result
  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _recognizedText = result.recognizedWords;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Speech to Text')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _recognizedText,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20.0),
            ),
            SizedBox(height: 20),

            // Show language selector only if supported
            if (_isSupportedBrowser && _availableLanguages.isNotEmpty)
              DropdownButton<String>(
                value: _selectedLanguage,
                items: _availableLanguages.map((locale) {
                  return DropdownMenuItem<String>(
                    value: locale.localeId,
                    child: Text(locale.name), // Show language name
                  );
                }).toList(),
                onChanged: (newLanguage) {
                  setState(() {
                    _selectedLanguage = newLanguage!;
                  });
                },
              ),

            SizedBox(height: 20),

            // Show microphone only if supported
            if (_isSupportedBrowser)
              FloatingActionButton(
                onPressed: _speechToText.isNotListening
                    ? _startListening
                    : _stopListening,
                child: Icon(
                  _speechToText.isNotListening ? Icons.mic_off : Icons.mic,
                ),
              )
            else
              Text(
                "Speech recognition is not supported in this browser.",
                style: TextStyle(color: Colors.red, fontSize: 16),
              ),
          ],
        ),
      ),
    );
  }
}
