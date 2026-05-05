import 'dart:io';
import 'package:flutter/material.dart';

class LowConfidenceResultScreen extends StatefulWidget {
  final String imagePath;

  const LowConfidenceResultScreen({
    super.key,
    required this.imagePath,
  });

  @override
  State<LowConfidenceResultScreen> createState() =>
      _LowConfidenceResultScreenState();
}

class _LowConfidenceResultScreenState
    extends State<LowConfidenceResultScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _sent = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [

              // IMAGE
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  height: 200,
                  width: double.infinity,
                  child: Image.file(
                    File(widget.imagePath),
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: const Color(0xFF2A3A2A),
                      child: const Center(
                        child: Icon(Icons.image, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // MESSAGE
              const Text(
                "Not sure yet",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                "Send this to an expert and get a confirmed answer.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 25),

              // INPUT
              TextField(
                controller: _controller,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Phone or email",
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: const Color(0xFF2A2A2A),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const Spacer(),

              // BUTTON / SUCCESS
              _sent
                  ? const Text(
                      "Sent! We'll notify you.",
                      style: TextStyle(color: Colors.green),
                    )
                  : GestureDetector(
                      onTap: () {
                        if (_controller.text.isEmpty) return;
                        setState(() => _sent = true);
                      },
                      child: Container(
                        height: 55,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE53935),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Center(
                          child: Text(
                            "Send to Expert",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}