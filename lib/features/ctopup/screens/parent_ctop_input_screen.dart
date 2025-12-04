import 'package:flutter/material.dart';

import 'ctopup_list_screen.dart';

class ParentCtopInputScreen extends StatefulWidget {
  const ParentCtopInputScreen({super.key});

  @override
  State<ParentCtopInputScreen> createState() => _ParentCtopInputScreenState();
}

class _ParentCtopInputScreenState extends State<ParentCtopInputScreen> {
  final TextEditingController _parentCtopController = TextEditingController();
  String? _error;

  void _proceed() {
    final parent = _parentCtopController.text.trim();

    if (parent.isEmpty) {
      setState(() {
        _error = 'Please enter Parent CTOPUP number';
      });
      return;
    }

    if (parent.length < 10) {
      setState(() {
        _error = 'Parent CTOPUP looks too short';
      });
      return;
    }

    setState(() {
      _error = null;
    });

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CtopupListScreen(parentCtop: parent)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('POS View – Parent CTOPUP')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _parentCtopController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Parent CTOPUP Number',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _proceed,
                child: const Text('Show My POS'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
