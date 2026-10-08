import \'package:flutter/material.dart\';
import \'package:google_generative_ai/google_generative_ai.dart\';
import \'package:flutter_markdown/flutter_markdown.dart\';
import \'package:clipboard/clipboard.dart\';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: \'AI MASTER\',
      theme: ThemeData.dark(useMaterial3: true),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _apiController = TextEditingController();
  final TextEditingController _promptController = TextEditingController();
  String _response = "Jawab yahan aayega...";
  bool _loading = false;

  Future<void> askGemini() async {
    if (_apiController.text.isEmpty || _promptController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("API Key aur Prompt dono likho")));
      return;
    }
    setState(() { _loading = true; });

    try {
      final model = GenerativeModel(
        model: \'gemini-1.5-flash\',
        apiKey: _apiController.text.trim(),
        systemInstruction: Content.system(
          \'Tum ek Expert AI App & Website Builder ho. User jo bhi bole uska pura clean code do. Agar app bole to Flutter code, agar website bole to single HTML file me HTML,CSS,JS do. Code hamesha complete aur ready-to-use dena.\'
        ),
      );
      final content = [Content.text(_promptController.text)];
      final result = await model.generateContent(content);
      setState(() { _response = result.text ?? "Koi jawab nahi mila"; });
    } catch (e) {
      setState(() { _response = "Error: $e"; });
    }
    setState(() { _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("AI MASTER - Gemini"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              controller: _apiController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Yahan Gemini API Key Paste Karo", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _promptController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: "Likhdo jaise: Ek calculator app banao", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : askGemini,
                child: _loading ? const CircularProgressIndicator() : const Text("GENERATE KARO"),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(10)),
                child: Column(
                  children: [
                    Expanded(child: Markdown(data: _response, selectable: true)),
                    ElevatedButton.icon(onPressed: () { FlutterClipboard.copy(_response); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Copy Ho Gaya"))); }, icon: const Icon(Icons.copy), label: const Text("Copy Code"))
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
