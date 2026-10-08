import \'package:flutter/material.dart\';
import \'package:flutter/services.dart\';
import \'package:google_generative_ai/google_generative_ai.dart\';

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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("API Key aur Prompt dono likho")),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      final model = GenerativeModel(
        model: \'gemini-1.5-flash\',
        apiKey: _apiController.text.trim(),
        systemInstruction: Content.system(
          \'You are an expert App and Website builder. Give complete code.\',
        ),
      );
      final result = await model.generateContent([Content.text(_promptController.text)]);
      setState(() => _response = result.text ?? "Koi jawab nahi mila");
    } catch (e) {
      setState(() => _response = "Error: $e");
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("AI MASTER"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              controller: _apiController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Gemini API Key", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _promptController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: "Prompt likho", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : askGemini,
                child: _loading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text("GENERATE KARO"),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(10)),
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: SelectableText(_response),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: _response));
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Copy Ho Gaya")));
                      },
                      icon: const Icon(Icons.copy),
                      label: const Text("Copy Code"),
                    ),
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
