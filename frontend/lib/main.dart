import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:js' as js; // For detecting browser type in web

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Speech to Text & Translate via FastAPI',
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
  String _recognizedText =
      "Press the microphone button to start speaking...";
  List<LocaleName> _availableLanguages = [];
  String _selectedLanguage = 'en_US'; // Default to English
  bool _isChrome = false;
  bool _isSupportedBrowser = true;

  // Flutter TTS instance for text-to-speech
  FlutterTts _flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _detectBrowser();
    _initSpeech();
  }

  // Detect browser type (for web)
  void _detectBrowser() {
    if (kIsWeb) {
      String userAgent = js.context['navigator']['userAgent'].toString();
      _isChrome = userAgent.contains("Chrome");
      if (!_isChrome) {
        _isSupportedBrowser = false;
      }
    }
  }

  // Initialize speech recognition and available languages
  void _initSpeech() async {
    if (!_isSupportedBrowser) return;
    _speechEnabled = await _speechToText.initialize(
      onStatus: (status) => print('Status: $status'),
      onError: (error) => print('Error: $error'),
    );

    if (_speechEnabled) {
      if (!kIsWeb) {
        // On mobile, fetch available languages
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

  // Start listening using the selected language
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

  // Update recognized text as speech is processed
  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _recognizedText = result.recognizedWords;
    });
  }

  // Call the FastAPI endpoint to translate and then speak the translated text
  void _translateAndSpeak() async {
    if (_recognizedText.isEmpty ||
        _recognizedText == "Press the microphone button to start speaking...") {
      return;
    }

    // Define your FastAPI endpoint URL (adjust this URL accordingly)
    final url = Uri.parse('http://localhost:5000/translate');

    // Define the target language (e.g., Spanish 'es')
    String targetLanguage = 'en';

    // Prepare the JSON payload
    final payload = {
      'text': _recognizedText,
      'target_lang': targetLanguage,
      'source': "auto",
    };

    try {
      // Send a POST request to the FastAPI endpoint
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String translatedText = data['translated_text'];

        // Use Flutter TTS to voice out the translated text
        await _flutterTts.setLanguage("en");
        await _flutterTts.speak(translatedText);

        // Optionally update the UI with the translated text
        setState(() {
          _recognizedText = translatedText;
        });
      } else {
        print("Error: Failed to translate. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Exception during translation: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Speech to Text & Translate via FastAPI')),
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

            // Language selector
            if (_isSupportedBrowser && _availableLanguages.isNotEmpty)
              DropdownButton<String>(
                value: _selectedLanguage,
                items: _availableLanguages.map((locale) {
                  return DropdownMenuItem<String>(
                    value: locale.localeId,
                    child: Text(locale.name),
                  );
                }).toList(),
                onChanged: (newLanguage) {
                  setState(() {
                    _selectedLanguage = newLanguage!;
                  });
                },
              ),
            SizedBox(height: 20),

            // Two buttons: one for speech recognition and one for translating & speaking
            if (_isSupportedBrowser)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FloatingActionButton(
                    heroTag: 'speech',
                    onPressed: _speechToText.isNotListening
                        ? _startListening
                        : _stopListening,
                    child: Icon(
                      _speechToText.isNotListening ? Icons.mic_off : Icons.mic,
                    ),
                  ),
                  SizedBox(width: 20),
                  FloatingActionButton(
                    heroTag: 'translate',
                    onPressed: _translateAndSpeak,
                    child: Icon(Icons.translate),
                  ),
                ],
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
