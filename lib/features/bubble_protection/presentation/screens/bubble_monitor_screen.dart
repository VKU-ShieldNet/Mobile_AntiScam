import 'package:flutter/material.dart';
import '../../../../core/services/screenshot_processor_service.dart';

class BubbleMonitorScreen extends StatefulWidget {
  const BubbleMonitorScreen({super.key});

  @override
  State<BubbleMonitorScreen> createState() => _BubbleMonitorScreenState();
}

class _BubbleMonitorScreenState extends State<BubbleMonitorScreen> {
  final ScreenshotProcessorService _processorService = ScreenshotProcessorService();
  final List<String> _detectedTexts = [];
  bool _isMonitoring = false;

  @override
  void initState() {
    super.initState();
    _startMonitoring();
  }

  void _startMonitoring() {
    setState(() => _isMonitoring = true);
    
    _processorService.startListening(
      onTextExtracted: (extractedText, originalPath) {
        setState(() {
          _detectedTexts.insert(0, extractedText);
        });
        
        // TODO: Send to Backend API for scam detection
        _sendToBackend(extractedText);
        
        // Show notification if scam detected
        _showScamAlert(extractedText);
      },
      onError: (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $error')),
        );
      },
    );
  }

  void _stopMonitoring() {
    setState(() => _isMonitoring = false);
    _processorService.stopListening();
  }

  Future<void> _sendToBackend(String text) async {
    // TODO: Implement API call
    // Example:
    // final response = await http.post(
    //   Uri.parse('https://your-api.com/analyze'),
    //   body: {'text': text},
    // );
    
    print('📤 Would send to backend: ${text.substring(0, text.length > 50 ? 50 : text.length)}...');
  }

  void _showScamAlert(String text) {
    // TODO: Implement scam detection logic
    // For now, just a placeholder
    if (text.toLowerCase().contains('scam') || 
        text.toLowerCase().contains('urgent') ||
        text.toLowerCase().contains('click here')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Potential scam detected!'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  void dispose() {
    _processorService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bubble Monitor'),
        actions: [
          IconButton(
            icon: Icon(_isMonitoring ? Icons.stop : Icons.play_arrow),
            onPressed: _isMonitoring ? _stopMonitoring : _startMonitoring,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: _isMonitoring ? Colors.green.shade100 : Colors.grey.shade200,
            child: Row(
              children: [
                Icon(
                  _isMonitoring ? Icons.circle : Icons.circle_outlined,
                  color: _isMonitoring ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 8),
                Text(
                  _isMonitoring ? 'Monitoring Active' : 'Monitoring Stopped',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Expanded(
            child: _detectedTexts.isEmpty
                ? const Center(
                    child: Text('No screenshots captured yet.\nClick bubble to capture.'),
                  )
                : ListView.builder(
                    itemCount: _detectedTexts.length,
                    itemBuilder: (context, index) {
                      final text = _detectedTexts[index];
                      return Card(
                        margin: const EdgeInsets.all(8),
                        child: ExpansionTile(
                          title: Text(
                            'Capture ${index + 1}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            text.substring(0, text.length > 50 ? 50 : text.length) + '...',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: SelectableText(text),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
