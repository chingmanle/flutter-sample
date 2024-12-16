import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';

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

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  // Initialize speech recognition
  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize(
      onStatus: (status) => print('Status: $status'),
      onError: (error) => print('Error: $error'),
    );
    setState(() {});
  }

  // Start listening
  void _startListening() {
    _speechToText.listen(onResult: _onSpeechResult);
    setState(() {});
  }

  // Stop listening
  void _stopListening() {
    _speechToText.stop();
    setState(() {});
  }

  // Handle the speech recognition result
  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _recognizedText = result.recognizedWords;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Speech to Text'),
      ),
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
            FloatingActionButton(
              onPressed: _speechToText.isNotListening
                  ? _startListening
                  : _stopListening,
              child: Icon(
                _speechToText.isNotListening ? Icons.mic_off : Icons.mic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
