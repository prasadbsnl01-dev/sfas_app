import 'package:flutter/material.dart';

import '../models/child_pos.dart';
import '../../visit/visit_start_screen.dart';

class CtopupDetailScreen extends StatelessWidget {
  final ChildPos childPos;

  const CtopupDetailScreen({super.key, required this.childPos});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('POS Detail')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // POS Header
            Text(
              childPos.posName,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Child CTOPUP: ${childPos.childCtop}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 2),
            Text(
              'Parent CTOPUP: ${childPos.parentCtop}',
              style: const TextStyle(fontSize: 14),
            ),

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),

            // Basic Info Section
            const Text(
              'Basic Info',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            _infoRow('Dealer Type', childPos.dealerType),
            _infoRow('Dealer ID', childPos.dealerId),
            _infoRow('CSC Code', childPos.cscCode),

            const SizedBox(height: 16),

            // Location Section
            const Text(
              'Location',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            _infoRow('Circle', childPos.circle),
            _infoRow('SSA', childPos.ssa),
            _infoRow('City', childPos.cityName),

            const SizedBox(height: 16),

            // Address
            const Text(
              'Address',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(childPos.dealerAddress),

            const SizedBox(height: 24),

            // Go to POS Visit button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.directions_walk),
                label: const Text('Go to POS Visit'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => VisitStartScreen(childPos: childPos),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
