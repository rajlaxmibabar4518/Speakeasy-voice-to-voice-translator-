import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

/// 🟣 APP ROOT
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/home': (context) => const VoiceTranslator(),
      },
    );
  }
}

/// 🟣 SPLASH SCREEN
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 3));
    _scale = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
    _controller.forward();

    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, '/home');
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: ScaleTransition(
          scale: _scale,
          child: Image.asset(
            'assests/images/voice translator.png',
            width: 220,
          ),
        ),
      ),
    );
  }
}

/// 🟣 MAIN APP SCREEN
class VoiceTranslator extends StatefulWidget {
  const VoiceTranslator({super.key});

  @override
  State<VoiceTranslator> createState() => _VoiceTranslatorState();
}

class _VoiceTranslatorState extends State<VoiceTranslator>
    with SingleTickerProviderStateMixin {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  final TextEditingController _textController = TextEditingController();

  String _recognizedText = "";
  String _translatedText = "";
  bool _isListening = false;
  bool _isTranslating = false;
  String? _errorMessage;
  double _ttsVolume = 0.7;

  String _fromLang = "en-US";
  String _toLang = "hi-IN";

  final Map<String, String> languages = {
    "English": "en-US",
    "Hindi": "hi-IN",
    "Gujarati": "gu-IN",
    "Marathi": "mr-IN",
    "Tamil": "ta-IN",
    "Telugu": "te-IN",
    "Kannada": "kn-IN",
    "Malayalam": "ml-IN",
    "Bengali": "bn-IN",
    "Punjabi": "pa-IN",
    "Oriya": "or-IN",
    "Assamese": "as-IN",
    "Nepali": "ne-IN",
    "Sanskrit": "sa-IN",
    "Urdu": "ur-IN",
  };

  Future<String?> _translateText(String text, String from, String to) async {
    try {
      final memoryUrl =
          "https://api.mymemory.translated.net/get?q=$text&langpair=$from|$to";
      final res1 = await http.get(Uri.parse(memoryUrl));
      if (res1.statusCode == 200) {
        final data = json.decode(res1.body);
        if (data["responseData"]?["translatedText"] != null) {
          return data["responseData"]["translatedText"];
        }
      }

      final libreUrl = Uri.parse("https://libretranslate.de/translate");
      final res2 = await http.post(
        libreUrl,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "q": text,
          "source": from,
          "target": to,
          "format": "text",
        }),
      );
      if (res2.statusCode == 200) {
        final data = json.decode(res2.body);
        return data["translatedText"];
      }
    } catch (e) {
      debugPrint("Translation error: $e");
    }
    return null;
  }

  Future<void> _startListening() async {
    FocusScope.of(context).unfocus(); // 👈 auto close keyboard when using mic

    if (_fromLang == _toLang) {
      setState(() => _errorMessage = "⚠️ Please choose different languages.");
      return;
    }

    bool available = await _speech.initialize(
      onError: (val) => setState(() => _errorMessage = "Speech error: $val"),
      onStatus: (val) => debugPrint("Status: $val"),
    );

    if (available) {
      setState(() {
        _isListening = true;
        _recognizedText = "";
        _translatedText = "";
        _errorMessage = null;
      });

      _speech.listen(
        localeId: _fromLang,
        onResult: (val) async {
          if (val.recognizedWords.isNotEmpty) {
            setState(() => _recognizedText = val.recognizedWords);
            await _handleTranslation(val.recognizedWords, _fromLang, _toLang);
          }
        },
      );
    } else {
      setState(() => _errorMessage = "Microphone not available");
    }
  }

  void _stopListening() {
    _speech.stop();
    setState(() => _isListening = false);
  }

  Future<void> _handleTranslation(
      String input, String fromLang, String toLang) async {
    setState(() {
      _isTranslating = true;
      _errorMessage = null;
    });

    final fromCode = fromLang.split("-").first;
    final toCode = toLang.split("-").first;
    final translated = await _translateText(input, fromCode, toCode);

    if (translated != null && translated.isNotEmpty) {
      setState(() => _translatedText = translated);
      await _flutterTts.setVolume(_ttsVolume);
      await _flutterTts.setLanguage(toLang);
      await _flutterTts.speak(translated);
    } else {
      setState(() => _errorMessage = "Translation failed. Please try again.");
    }

    setState(() => _isTranslating = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // ✅ fixes keyboard overflow
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xff8A2BE2), Color(0xffFF1493)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                const SizedBox(height: 20),
                const Text(
                  "Voice Translator",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 20),

                /// 🎤 Mic button
                GestureDetector(
                  onTap: _isListening ? _stopListening : _startListening,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 130,
                    width: 130,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: _isListening
                              ? Colors.redAccent.withOpacity(0.6)
                              : Colors.white24,
                          blurRadius: 30,
                          spreadRadius: 8,
                        ),
                      ],
                      gradient: LinearGradient(
                        colors: _isListening
                            ? [Colors.redAccent, Colors.pinkAccent]
                            : [Colors.purpleAccent, Colors.blueAccent],
                      ),
                    ),
                    child: Icon(
                      _isListening ? Icons.stop : Icons.mic,
                      size: 55,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 25),

                /// 🌐 Dropdowns
                Row(
                  children: [
                    Expanded(
                      child: _buildDropdown(
                        "From",
                        _fromLang,
                        Colors.lightBlueAccent,
                        (val) => setState(() => _fromLang = val!),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildDropdown(
                        "To",
                        _toLang,
                        Colors.orangeAccent,
                        (val) => setState(() => _toLang = val!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                /// ✍️ Input field + send button
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: "Type text here...",
                          hintStyle: const TextStyle(color: Colors.white54),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.1),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        if (_textController.text.trim().isNotEmpty) {
                          setState(() =>
                              _recognizedText = _textController.text.trim());
                          _handleTranslation(
                              _recognizedText, _fromLang, _toLang);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurpleAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Icon(Icons.send, color: Colors.white),
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                /// Recognized text
                _buildTextBox(
                  icon: Icons.record_voice_over,
                  color: Colors.blueAccent,
                  text: _recognizedText,
                  label: "Recognized Speech / Typed Text",
                ),
                const SizedBox(height: 20),

                /// Translation
                _buildTextBox(
                  icon: Icons.translate,
                  color: Colors.greenAccent,
                  text: _errorMessage ?? _translatedText,
                  label: "Translation",
                  isError: _errorMessage != null,
                ),

                const SizedBox(height: 20),

                /// 🔊 Volume slider
                Column(
                  children: [
                    const Icon(Icons.volume_up, color: Colors.white),
                    Slider(
                      value: _ttsVolume,
                      onChanged: (val) =>
                          setState(() => _ttsVolume = val),
                      activeColor: Colors.white,
                      inactiveColor: Colors.white30,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(
      String title, String value, Color color, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(color: color, fontSize: 16)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.5)),
          ),
          child: DropdownButton<String>(
            isExpanded: true,
            dropdownColor: Colors.black,
            value: value,
            iconEnabledColor: color,
            style: TextStyle(color: color),
            items: languages.entries
                .map(
                  (e) => DropdownMenuItem(
                    value: e.value,
                    child: Text(e.key,
                        style: const TextStyle(color: Colors.white)),
                  ),
                )
                .toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildTextBox({
    required IconData icon,
    required Color color,
    required String text,
    required String label,
    bool isError = false,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 10),
              Text(label,
                  style: TextStyle(
                      color: color, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            text.isEmpty ? "—" : text,
            style: TextStyle(
              color: isError ? Colors.redAccent : Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}