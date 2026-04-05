import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ChatScreen(),
    );
  }
}

class Message {
  final String text;
  final bool isUser;

  Message(this.text, this.isUser);
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  List<Message> messages = [];

  late stt.SpeechToText _speech;
  late FlutterTts tts;

  bool isListening = false;
  bool isTyping = false;
  bool animateWave = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    tts = FlutterTts();
  }

  // 🎤 Voice
  void startListening() async {
    bool available = await _speech.initialize();

    if (available) {
      setState(() {
        isListening = true;
        isTyping = false;
        animateWave = true;
        _controller.clear();
      });

      // 🔥 smooth animation loop
      Future.doWhile(() async {
        if (!isListening) return false;

        setState(() {
          animateWave = !animateWave;
        });

        await Future.delayed(const Duration(milliseconds: 200));
        return true;
      });

      _speech.listen(
        listenMode: stt.ListenMode.dictation,
        onResult: (result) {
          setState(() {
            _controller.text = result.recognizedWords;
          });
        },
      );
    }
  }

  void stopListening() {
    _speech.stop();
    setState(() {
      isListening = false;
      animateWave = false;
    });
  }

  // 🔊 Speak
  Future speak(String text) async {
    await tts.setLanguage("en-US");
    await tts.setPitch(1.0);
    await tts.speak(text);
  }

  // 🧠 AI
  String getFakeResponse(String input) {
    input = input.toLowerCase().trim();

    if (input.contains("hi") ||
        input.contains("hello") ||
        input.contains("hey")) {
      return "Hey! I'm Sara 👋 How can I help you?";
    }

    if (input.contains("how are you")) {
      return "I'm doing great! 😊 What about you?";
    }

    if (input.contains("fine") || input.contains("good")) {
      return "That's great to hear! 👍";
    }

    if (input.contains("name")) {
      return "I'm Sara, your voice assistant.";
    }

    return "That's interesting! Tell me more.";
  }

  // 💾 Save history
  Future<void> saveToHistory(Message msg) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList("history") ?? [];

    history.add(jsonEncode({
      "text": msg.text,
      "isUser": msg.isUser,
    }));

    await prefs.setStringList("history", history);
  }

  // 💬 Send
  void sendMessage() async {
    String userText = _controller.text.trim();
    if (userText.isEmpty) return;

    if (isListening) stopListening();

    _controller.clear();
    isTyping = false;

    Message userMsg = Message(userText, true);

    setState(() {
      messages.add(userMsg);
      messages.add(Message("Typing...", false));
    });

    await Future.delayed(const Duration(seconds: 1));

    String aiText = getFakeResponse(userText);
    Message aiMsg = Message(aiText, false);

    setState(() {
      messages.removeLast();
      messages.add(aiMsg);
    });

    saveToHistory(userMsg);
    saveToHistory(aiMsg);
  }

  // 🕒 History
  void showHistory() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList("history") ?? [];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black,
      builder: (_) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: history.isEmpty
              ? [
                  const Text("No history",
                      style: TextStyle(color: Colors.white))
                ]
              : history.map((e) {
                  final data = jsonDecode(e);
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      data["isUser"]
                          ? "You: ${data["text"]}"
                          : "Sara: ${data["text"]}",
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                }).toList(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "Sara AI",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.access_time, color: Colors.white),
            onPressed: showHistory,
          ),
        ],
      ),
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF0F051D),
                Color(0xFF1A0B2E),
                Color(0xFF2A0F4F),
              ],
            ),
          ),
          child: Column(
            children: [
              Expanded(
                child: messages.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.purple.withOpacity(0.8),
                                    blurRadius: 40,
                                  )
                                ],
                              ),
                              child: const Icon(
                                Icons.auto_awesome,
                                size: 40,
                                color: Colors.purpleAccent,
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              "How can I help you?",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final msg = messages[index];
                          return Align(
                            alignment: msg.isUser
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.all(10),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                gradient: msg.isUser
                                    ? const LinearGradient(
                                        colors: [
                                          Colors.purple,
                                          Colors.deepPurple
                                        ],
                                      )
                                    : null,
                                color: msg.isUser ? null : Colors.grey[900],
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    msg.text,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  if (!msg.isUser)
                                    IconButton(
                                      icon: const Icon(Icons.volume_up,
                                          color: Colors.white70, size: 18),
                                      onPressed: () {
                                        speak(msg.text);
                                      },
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),

              // 🌈 PREMIUM WAVEFORM
              if (isListening)
                SizedBox(
                  height: 70,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(6, (index) {
                      return AnimatedContainer(
                        duration: Duration(milliseconds: 250 + index * 80),
                        curve: Curves.easeInOut,
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        width: 6,
                        height: animateWave ? (18.0 + (index * 10)) : 10,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFFB026FF),
                              Color(0xFFFF4D9D),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.pinkAccent.withOpacity(0.5),
                              blurRadius: 12,
                              spreadRadius: 1,
                            )
                          ],
                        ),
                      );
                    }),
                  ),
                ),

              // 🔥 INPUT
              Container(
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        style: const TextStyle(color: Colors.white),
                        onTap: () {
                          if (!isTyping) _controller.clear();
                          isTyping = true;
                        },
                        onChanged: (_) => isTyping = true,
                        onSubmitted: (_) {
                          sendMessage();
                          isTyping = false;
                        },
                        decoration: const InputDecoration(
                          hintText: "Ask Sara...",
                          hintStyle: TextStyle(color: Colors.white54),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send, color: Colors.purpleAccent),
                      onPressed: sendMessage,
                    ),
                    GestureDetector(
                      onTap: () {
                        if (!isListening) {
                          startListening();
                        } else {
                          stopListening();
                        }
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: isListening
                                  ? Colors.redAccent.withOpacity(0.8)
                                  : Colors.purple.withOpacity(0.6),
                              blurRadius: isListening ? 25 : 10,
                              spreadRadius: isListening ? 4 : 1,
                            )
                          ],
                        ),
                        child: CircleAvatar(
                          radius: isListening ? 26 : 22,
                          backgroundColor: Colors.black,
                          child: Icon(
                            isListening ? Icons.mic : Icons.mic_none,
                            color: isListening
                                ? Colors.redAccent
                                : Colors.purpleAccent,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
