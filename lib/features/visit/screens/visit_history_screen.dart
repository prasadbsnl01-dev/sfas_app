import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../ctopup/models/child_pos.dart';
import '../../ctopup/screens/ctopup_list_screen.dart' show baseApiUrl;

// ⚠️ IMPORTANT:
// Emulator -> 'http://10.0.2.2/SFAS/'
// Physical phone (hotspot/LAN) -> 'http://<YOUR_PC_IP>/SFAS/'
const String _imageBaseUrl = 'http://10.29.102.159/SFAS/';

class VisitRecord {
  final int id;
  final String visitType;
  final String retailerStatus;
  final String visitedAt;
  final String remarks;
  final String todaySales;
  final String salesFocus;
  final String nextAction;
  final double? latitude;
  final double? longitude;
  final double? gpsAccuracy;
  final String? photoPath;

  VisitRecord({
    required this.id,
    required this.visitType,
    required this.retailerStatus,
    required this.visitedAt,
    required this.remarks,
    required this.todaySales,
    required this.salesFocus,
    required this.nextAction,
    this.latitude,
    this.longitude,
    this.gpsAccuracy,
    this.photoPath,
  });

  factory VisitRecord.fromJson(Map<String, dynamic> json) {
    String s(dynamic v) => v?.toString() ?? '';
    int i(dynamic v) => int.tryParse(v.toString()) ?? 0;

    double? d(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      if (v is String && v.trim().isNotEmpty) {
        return double.tryParse(v);
      }
      return null;
    }

    return VisitRecord(
      id: i(json['id']),
      visitType: s(json['visit_type']),
      retailerStatus: s(json['retailer_status']),
      visitedAt: s(json['visited_at']),
      remarks: s(json['remarks']),
      todaySales: s(json['today_sales']),
      salesFocus: s(json['sales_focus']),
      nextAction: s(json['next_action']),
      latitude: d(json['latitude']),
      longitude: d(json['longitude']),
      gpsAccuracy: d(json['gps_accuracy']),
      photoPath: json['photo_path']?.toString(),
    );
  }
}

class VisitHistoryScreen extends StatefulWidget {
  final ChildPos childPos;

  const VisitHistoryScreen({super.key, required this.childPos});

  @override
  State<VisitHistoryScreen> createState() => _VisitHistoryScreenState();
}

class _VisitHistoryScreenState extends State<VisitHistoryScreen> {
  late Future<List<VisitRecord>> _futureVisits;

  @override
  void initState() {
    super.initState();
    _futureVisits = _fetchVisits();
  }

  Future<List<VisitRecord>> _fetchVisits() async {
    final uri = Uri.parse(
      '$baseApiUrl/visit/get_visits_by_child.php?child_ctopup=${widget.childPos.childCtop}',
    );

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}');
    }

    final body = json.decode(response.body);

    if (body['status'] != 'success') {
      throw Exception(body['message'] ?? 'API error');
    }

    final List data = body['data'] ?? [];
    return data.map((e) => VisitRecord.fromJson(e)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final child = widget.childPos;

    return Scaffold(
      appBar: AppBar(title: Text('Visits – ${child.childCtop}')),
      body: FutureBuilder<List<VisitRecord>>(
        future: _futureVisits,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Failed to load visits:\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final visits = snapshot.data ?? [];
          if (visits.isEmpty) {
            return const Center(child: Text('No visits found for this POS.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: visits.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final v = visits[index];

              final hasPhoto =
                  v.photoPath != null && v.photoPath!.trim().isNotEmpty;
              final photoUrl = hasPhoto
                  ? _imageBaseUrl + v.photoPath!.trim()
                  : null;

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // First row: date/time + type
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              v.visitType,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            v.visitedAt,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 4),

                      // Status
                      Text(
                        'Status: ${v.retailerStatus}',
                        style: const TextStyle(fontSize: 13),
                      ),

                      const SizedBox(height: 4),

                      if (v.todaySales.isNotEmpty)
                        Text(
                          'Today Sales: ₹${v.todaySales}',
                          style: const TextStyle(fontSize: 13),
                        ),

                      if (v.salesFocus.isNotEmpty)
                        Text(
                          'Focus: ${v.salesFocus}',
                          style: const TextStyle(fontSize: 13),
                        ),

                      const SizedBox(height: 6),

                      if (v.remarks.isNotEmpty)
                        Text(
                          'Remarks: ${v.remarks}',
                          style: const TextStyle(fontSize: 13),
                        ),

                      if (v.nextAction.isNotEmpty)
                        Text(
                          'Next: ${v.nextAction}',
                          style: const TextStyle(fontSize: 13),
                        ),

                      // GPS line
                      if (v.latitude != null && v.longitude != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          'Location: '
                          '${v.latitude!.toStringAsFixed(5)}, '
                          '${v.longitude!.toStringAsFixed(5)}'
                          '${v.gpsAccuracy != null ? " (±${v.gpsAccuracy!.toStringAsFixed(1)} m)" : ""}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],

                      // Photo preview
                      if (hasPhoto && photoUrl != null) ...[
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: SizedBox(
                            height: 160,
                            width: double.infinity,
                            child: Image.network(
                              photoUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                    color: Colors.grey.shade300,
                                    alignment: Alignment.center,
                                    child: const Text(
                                      'Photo not available',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ),
                            ),
                          ),
                        ),
                      ],
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
