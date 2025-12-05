import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/child_pos.dart';
import 'ctopup_detail_screen.dart';

const String baseApiUrl = 'http://10.29.102.103/SFAS/api';
// For physical phone, change to: 'http://YOUR_PC_IP/SFAS/api';

class CtopupListScreen extends StatefulWidget {
  final String parentCtop;

  const CtopupListScreen({super.key, required this.parentCtop});

  @override
  State<CtopupListScreen> createState() => _CtopupListScreenState();
}

class _CtopupListScreenState extends State<CtopupListScreen> {
  late Future<List<ChildPos>> _futureList;

  @override
  void initState() {
    super.initState();
    _futureList = _fetchChildren();
  }

  Future<List<ChildPos>> _fetchChildren() async {
    final uri = Uri.parse(
      '$baseApiUrl/get_children_by_parent.php?parent_ctop=${widget.parentCtop}',
    );

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('HTTP error: ${response.statusCode}');
    }

    final body = json.decode(response.body);

    if (body['status'] != 'success') {
      throw Exception(body['message'] ?? 'API error');
    }

    final List data = body['data'] ?? [];
    return data.map((e) => ChildPos.fromJson(e)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Parent CTOPUP: ${widget.parentCtop}')),
      body: FutureBuilder<List<ChildPos>>(
        future: _futureList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Failed to load data:\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final list = snapshot.data ?? [];
          if (list.isEmpty) {
            return const Center(child: Text('No child CTOPUPs found.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: list.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final item = list[index];

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Child CTOPUP (first line)
                      Text(
                        item.childCtop,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // POS name (second line)
                      Text(item.posName, style: const TextStyle(fontSize: 14)),
                      const SizedBox(height: 8),
                      // Details button
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    CtopupDetailScreen(childPos: item),
                              ),
                            );
                          },
                          child: const Text('Details'),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
