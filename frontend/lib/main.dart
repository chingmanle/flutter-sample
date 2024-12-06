import 'dart:html';
import 'dart:js_util'; // For JavaScript interop
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Speech to Text',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SpeechToTextPage(),
    );
  }
}

class SpeechToTextPage extends StatefulWidget {
  @override
  _SpeechToTextPageState createState() => _SpeechToTextPageState();
}

class _SpeechToTextPageState extends State<SpeechToTextPage> {
  dynamic _recognition; // JS interop object for speech recognition
  String _recognizedText = "Press the button and start speaking...";
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _initializeSpeechRecognition();
  }

  void _initializeSpeechRecognition() {
    try {
      // Check if 'webkitSpeechRecognition' exists
      if (getProperty(window, 'webkitSpeechRecognition') != null) {
        final recognition = callConstructor(
          getProperty(window, 'webkitSpeechRecognition'),
          [],
        );
        _recognition = recognition;

        print("SpeechRecognition initialized: $_recognition");

        setProperty(_recognition, 'lang', 'en-US');
        setProperty(_recognition, 'interimResults', true);

        setProperty(
          _recognition,
          'onresult',
          allowInterop((event) {
            final transcript = getProperty(
                getProperty(event, 'results')[event['resultIndex']], '0')['transcript'];
            setState(() {
              _recognizedText = transcript;
            });
          }),
        );

        setProperty(
          _recognition,
          'onerror',
          allowInterop((event) {
            setState(() {
              _recognizedText = "Error: ${getProperty(event, 'error')}";
            });
          }),
        );

        setProperty(
          _recognition,
          'onspeechend',
          allowInterop((_) {
            setState(() {
              _isListening = false;
              _recognizedText = "Speech recognition stopped.";
            });
          }),
        );
      } else {
        setState(() {
          _recognizedText =
              "Speech Recognition is not supported in this browser.";
        });
        print("SpeechRecognition is not supported in this browser.");
      }
    } catch (e) {
      print("Error initializing SpeechRecognition: $e");
      setState(() {
        _recognizedText = "Error initializing SpeechRecognition: $e";
      });
    }
  }

  void _startListening() {
    if (_recognition != null && hasProperty(_recognition, 'start')) {
      try {
        print("Starting speech recognition...");
        setState(() {
          _isListening = true;
          _recognizedText = "Listening...";
        });
        callMethod(_recognition, 'start', []);
      } catch (e) {
        print("Error starting recognition: $e");
        setState(() {
          _recognizedText = "Error starting speech recognition: $e";
        });
      }
    } else {
      print("SpeechRecognition object is invalid or 'start' method not found.");
      setState(() {
        _recognizedText = "Speech Recognition is not initialized properly.";
      });
    }
  }

  void _stopListening() {
    if (_recognition != null && hasProperty(_recognition, 'stop')) {
      try {
        print("Stopping speech recognition...");
        callMethod(_recognition, 'stop', []);
        setState(() {
          _isListening = false;
          _recognizedText = "Speech recognition stopped.";
        });
      } catch (e) {
        print("Error stopping recognition: $e");
        setState(() {
          _recognizedText = "Error stopping recognition: $e";
        });
      }
    } else {
      print("SpeechRecognition object is invalid or 'stop' method not found.");
      setState(() {
        _recognizedText = "Speech Recognition is not initialized properly.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Speech to Text'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _recognizedText,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              color: _isListening ? Colors.green : Colors.black,
              fontWeight: _isListening ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _startListening,
            child: Text('Start Speaking'),
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: _stopListening,
            child: Text('Stop Speaking'),
          ),
        ],
      ),
    );
  }
}
