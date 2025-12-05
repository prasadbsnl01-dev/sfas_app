import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../ctopup/models/child_pos.dart';
import '../../ctopup/screens/ctopup_list_screen.dart' show baseApiUrl;

class VisitStartScreen extends StatefulWidget {
  final ChildPos childPos;

  const VisitStartScreen({super.key, required this.childPos});

  @override
  State<VisitStartScreen> createState() => _VisitStartScreenState();
}

class _VisitStartScreenState extends State<VisitStartScreen> {
  // Controllers
  String _visitType = 'Regular Visit';
  String _retailerStatus = 'Met Retailer';

  final TextEditingController _todaySalesController = TextEditingController();
  final TextEditingController _salesFocusController = TextEditingController();
  final TextEditingController _remarksController = TextEditingController();
  final TextEditingController _nextActionController = TextEditingController();

  bool _isSubmitting = false;
  String? _error;

  Future<void> _submitVisit() async {
    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    final uri = Uri.parse('$baseApiUrl/visit/save_visit.php');

    try {
      final response = await http.post(
        uri,
        body: {
          'child_ctopup': widget.childPos.childCtop,
          'parent_ctop': widget.childPos.parentCtop,
          'pos_name': widget.childPos.posName,
          'visit_type': _visitType,
          'retailer_status': _retailerStatus,
          'today_sales': _todaySalesController.text.trim(),
          'sales_focus': _salesFocusController.text.trim(),
          'remarks': _remarksController.text.trim(),
          'next_action': _nextActionController.text.trim(),
        },
      );

      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}');
      }

      final body = json.decode(response.body);

      if (body['status'] != 'success') {
        throw Exception(body['message'] ?? 'Failed to save visit');
      }

      // Success
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Visit saved successfully')));

      // Pop back to POS detail or list
      Navigator.pop(context); // back to detail screen
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _todaySalesController.dispose();
    _salesFocusController.dispose();
    _remarksController.dispose();
    _nextActionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final child = widget.childPos;

    return Scaffold(
      appBar: AppBar(title: const Text('Start POS Visit')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // POS header card
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      child.posName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text('Child CTOPUP: ${child.childCtop}'),
                    Text('Parent CTOPUP: ${child.parentCtop}'),
                    const SizedBox(height: 4),
                    Text('CSC: ${child.cscCode}'),
                    Text('Circle: ${child.circle} • SSA: ${child.ssa}'),
                    const SizedBox(height: 4),
                    Text(
                      child.dealerAddress,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            const Text(
              'Visit Details',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),

            // Visit type
            DropdownButtonFormField<String>(
              initialValue: _visitType, // 👈 changed
              decoration: const InputDecoration(
                labelText: 'Visit Type',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'Regular Visit',
                  child: Text('Regular Visit'),
                ),
                DropdownMenuItem(
                  value: 'Issue Resolution',
                  child: Text('Issue Resolution'),
                ),
                DropdownMenuItem(
                  value: 'Sales Push',
                  child: Text('Sales Push'),
                ),
                DropdownMenuItem(
                  value: 'Stock Check',
                  child: Text('Stock Check'),
                ),
                DropdownMenuItem(
                  value: 'Scheme Communication',
                  child: Text('Scheme Communication'),
                ),
              ],
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _visitType = val;
                  });
                }
              },
            ),

            const SizedBox(height: 12),

            // Retailer status
            DropdownButtonFormField<String>(
              initialValue: _retailerStatus, // 👈 changed
              decoration: const InputDecoration(
                labelText: 'Retailer Status',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'Met Retailer',
                  child: Text('Met Retailer'),
                ),
                DropdownMenuItem(
                  value: 'Shop Closed',
                  child: Text('Shop Closed'),
                ),
                DropdownMenuItem(
                  value: 'Retailer Not Available',
                  child: Text('Retailer Not Available'),
                ),
                DropdownMenuItem(
                  value: 'Wrong Address / Shifted',
                  child: Text('Wrong Address / Shifted'),
                ),
              ],
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _retailerStatus = val;
                  });
                }
              },
            ),

            const SizedBox(height: 12),

            // Today sales
            TextField(
              controller: _todaySalesController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Today\'s Recharge Value (₹)',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            // Sales focus
            TextField(
              controller: _salesFocusController,
              decoration: const InputDecoration(
                labelText: 'Sales Focus (e.g., FTTH, Prepaid)',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            // Remarks
            TextField(
              controller: _remarksController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Remarks / Discussion',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            // Next action
            TextField(
              controller: _nextActionController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Next Action / Follow-up',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check),
                label: Text(_isSubmitting ? 'Submitting...' : 'Submit Visit'),
                onPressed: _isSubmitting ? null : _submitVisit,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
