import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/gemini_service.dart'; // <-- Update import as needed

class KnowledgeCampScreen extends StatefulWidget {
  @override
  _KnowledgeCampScreenState createState() => _KnowledgeCampScreenState();
}

class _KnowledgeCampScreenState extends State<KnowledgeCampScreen> {
  final TextEditingController _controller = TextEditingController();
  String? _response;
  bool _loading = false;

  final List<String> _presetQuestions = [
    "How can we reduce plastic pollution?",
    "What are the effects of climate change?",
    "How does deforestation impact biodiversity?",
    "What is carbon footprint?",
  ];

  void _askGemini() async {
    setState(() => _loading = true);
    final prompt = _controller.text.trim();
    final gemini = GeminiService();
    final result = await gemini.getResponse(prompt);
    setState(() {
      _response = result;
      _loading = false;
    });
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Copied to clipboard')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('🌍 Knowledge Camp')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Ask a question about the environment...',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _askGemini(),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loading ? null : _askGemini,
              child:
                  _loading
                      ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : Text('Get Answer'),
            ),
            SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children:
                  _presetQuestions.map((q) {
                    return ActionChip(
                      label: Text(q, style: TextStyle(fontSize: 13)),
                      onPressed: () {
                        _controller.text = q;
                        _askGemini();
                      },
                    );
                  }).toList(),
            ),
            SizedBox(height: 20),
            Expanded(
              child:
                  _response == null
                      ? Center(child: Text('Your answer will appear here.'))
                      : Stack(
                        alignment: Alignment.topRight,
                        children: [
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: SingleChildScrollView(
                              child: Text(
                                _response!,
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.copy_rounded),
                            onPressed: () => _copyToClipboard(_response!),
                            tooltip: "Copy Answer",
                          ),
                        ],
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
