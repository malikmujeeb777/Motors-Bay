import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = []; // Stores chat messages
  final Dio _dio = Dio();
  bool isLoading = false; // Loading state

  // Replace with your actual API Key
  final String _apiKey = "YOUR_GEMINI_API_KEY_HERE";

  Future<void> sendMessage() async {
    String userMessage = _messageController.text.trim();
    if (userMessage.isEmpty || isLoading) return;

    setState(() {
      isLoading = true; // Start loading
      _messages.add({"text": userMessage, "isUser": true});
    });

    _messageController.clear();

    if (!isCarRelated(userMessage)) {
      setState(() {
        _messages.add({"text": "Sorry, I can only answer car-related questions.", "isUser": false});
        isLoading = false; // Stop loading
      });
      return;
    }

    try {
      String response = await getAiResponse(userMessage);
      setState(() {
        _messages.add({"text": response, "isUser": false});
      });
    } catch (e) {
      setState(() {
        _messages.add({"text": "Error fetching response. Try again later.", "isUser": false});
      });
    } finally {
      setState(() {
        isLoading = false; // Stop loading
      });
    }
  }

  bool isCarRelated(String query) {
    String lowerQuery = query.toLowerCase();

    // Expanded keyword list
    List<String> keywords = [
      "car", "engine", "transmission", "mileage", "fuel", "vehicle", "automobile",
      "horsepower", "torque", "speed", "acceleration", "brake", "suspension",
      "Toyota", "Honda", "BMW", "Tesla", "Ford", "Mercedes", "Audi", "Volkswagen",
      "Suzuki", "Nissan", "Chevrolet", "Kia", "Hyundai", "Lexus", "Jeep", "Mazda", "Porsche"
    ];

    // Check if any keyword is found in the query
    return keywords.any((keyword) => lowerQuery.contains(keyword.toLowerCase()));
  }


  Future<String> getAiResponse(String message) async {
    try {
      final response = await _dio.post(
        "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$_apiKey",
        options: Options(headers: {"Content-Type": "application/json"}),
        data: {
          "contents": [{
            "parts": [{"text": message}]
          }]
        },
      );

      print("API Response: ${response.data}");

      return response.data["candidates"][0]["content"]["parts"][0]["text"];
    } catch (e) {
      print("API Error: $e");
      return "Error fetching response. Try again later.";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("AI Chat Bot")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[_messages.length - 1 - index];
                return Align(
                  alignment: message["isUser"] ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    decoration: BoxDecoration(
                      color: message["isUser"] ? Colors.blue : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      message["text"],
                      style: TextStyle(color: message["isUser"] ? Colors.white : Colors.black),
                    ),
                  ),
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: "Ask about cars...",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                IconButton(
                  icon: isLoading
                      ? const CircularProgressIndicator() // Show loading spinner on button
                      : const Icon(Icons.send, color: Colors.blue),
                  onPressed: isLoading ? null : sendMessage, // Disable button while loading
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

