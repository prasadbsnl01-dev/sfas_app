import 'dart:convert';
import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../ctopup/models/child_pos.dart';

// 🔴 CHANGE THIS URL depending on where you run:
// Emulator:   'http://10.0.2.2/SFAS/api/visit/save_visit.php'
// Phone (Wi-Fi / hotspot): 'http://10.29.102.159/SFAS/api/visit/save_visit.php'
//                           ^ use your PC's IP here.
const String _visitApiUrl =
    'http://10.29.102.159/SFAS/api/visit/save_visit.php';

class VisitStartScreen extends StatefulWidget {
  final ChildPos childPos;

  const VisitStartScreen({super.key, required this.childPos});

  @override
  State<VisitStartScreen> createState() => _VisitStartScreenState();
}

class _VisitStartScreenState extends State<VisitStartScreen> {
  // Controllers / state
  String _visitType = 'Regular Visit';
  String _retailerStatus = 'Met Retailer';

  final TextEditingController _todaySalesController = TextEditingController();
  final TextEditingController _salesFocusController = TextEditingController();
  final TextEditingController _remarksController = TextEditingController();
  final TextEditingController _nextActionController = TextEditingController();

  bool _isSubmitting = false;
  String? _error;

  // photo + GPS
  File? _photoFile;
  Position? _position;
  bool _isCapturing = false;

  // ---------------- CAPTURE PHOTO + LOCATION ----------------

  Future<void> _capturePhotoAndLocation() async {
    try {
      setState(() {
        _isCapturing = true;
        _error = null;
      });

      // 1) Check GPS enabled
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enable Location (GPS) on your device.'),
          ),
        );
        return;
      }

      // 2) Request permission if needed
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location permission denied. Cannot capture GPS.'),
          ),
        );
        return;
      }

      // 3) Get position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // 4) Capture photo
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
        maxWidth: 1024,
      );

      if (picked == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Photo not captured.')));
        return;
      }

      setState(() {
        _position = position;
        _photoFile = File(picked.path);
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to capture photo/location: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isCapturing = false;
        });
      }
    }
  }

  // ---------------- SUBMIT VISIT (WITH PHOTO + GPS) ----------------

  Future<void> _submitVisit() async {
    if (_isSubmitting) return;

    // optional: enforce capture before submit
    if (_photoFile == null || _position == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please capture Photo & Location before submitting.'),
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    try {
      // 👇 NO baseApiUrl here, use clean constant URL
      final Uri uri = Uri.parse(_visitApiUrl.trim());

      final request = http.MultipartRequest('POST', uri);

      // Text fields
      request.fields.addAll({
        'child_ctopup': widget.childPos.childCtop,
        'parent_ctop': widget.childPos.parentCtop,
        'pos_name': widget.childPos.posName,
        'visit_type': _visitType,
        'retailer_status': _retailerStatus,
        'today_sales': _todaySalesController.text.trim(),
        'sales_focus': _salesFocusController.text.trim(),
        'remarks': _remarksController.text.trim(),
        'next_action': _nextActionController.text.trim(),
        'latitude': _position!.latitude.toString(),
        'longitude': _position!.longitude.toString(),
        'gps_accuracy': _position!.accuracy.toString(),
      });

      // Photo file
      request.files.add(
        await http.MultipartFile.fromPath('photo', _photoFile!.path),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}');
      }

      final body = json.decode(response.body);

      if (body['status'] != 'success') {
        throw Exception(body['message'] ?? 'Failed to save visit');
      }

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Visit saved successfully')));

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

  // ---------------- LIFECYCLE ----------------

  @override
  void dispose() {
    _todaySalesController.dispose();
    _salesFocusController.dispose();
    _remarksController.dispose();
    _nextActionController.dispose();
    super.dispose();
  }

  // ---------------- UI ----------------

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
              initialValue: _visitType,
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
              initialValue: _retailerStatus,
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

            const SizedBox(height: 16),

            // Capture photo + location button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: _isCapturing
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.camera_alt),
                label: Text(
                  _isCapturing ? 'Capturing...' : 'Capture Photo & Location',
                ),
                onPressed: _isCapturing ? null : _capturePhotoAndLocation,
              ),
            ),

            if (_photoFile != null) ...[
              const SizedBox(height: 8),
              SizedBox(
                height: 150,
                child: Image.file(_photoFile!, fit: BoxFit.cover),
              ),
            ],

            if (_position != null) ...[
              const SizedBox(height: 4),
              Text(
                'Location: '
                '${_position!.latitude.toStringAsFixed(5)}, '
                '${_position!.longitude.toStringAsFixed(5)}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],

            const SizedBox(height: 12),

            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),

            const SizedBox(height: 16),

            // Submit button
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
