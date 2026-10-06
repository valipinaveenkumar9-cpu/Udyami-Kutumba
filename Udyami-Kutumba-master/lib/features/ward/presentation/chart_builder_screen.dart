import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/models/ward_model.dart';
import '../../../core/utils/session_manager.dart';
import '../../../core/utils/layout_calculator.dart';

class ChartBuilderScreen extends StatefulWidget {
  final WardModel ward;
  final List<dynamic> layoutSectors;
  final List<dynamic> layoutUmsRoles;
  final List<dynamic> layoutBrandTiles;
  final Map<String, dynamic> slotCounts;
  final String wardHeadId;
  final int talukaWardsCount;

  const ChartBuilderScreen({
    super.key,
    required this.ward,
    required this.layoutSectors,
    required this.layoutUmsRoles,
    required this.layoutBrandTiles,
    required this.slotCounts,
    required this.wardHeadId,
    required this.talukaWardsCount,
  });

  @override
  State<ChartBuilderScreen> createState() => _ChartBuilderScreenState();
}

class _ChartBuilderScreenState extends State<ChartBuilderScreen> {
  List<Map<String, dynamic>> _sectors = [];
  List<Map<String, dynamic>> _umsRoles = [];
  List<Map<String, dynamic>> _brandTiles = [];
  Map<String, dynamic> _slotCounts = {};
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Deep copy the incoming lists so we can edit locally
    _sectors = widget.layoutSectors.map((e) => Map<String, dynamic>.from(e)).toList();
    _umsRoles = widget.layoutUmsRoles.map((e) => Map<String, dynamic>.from(e)).toList();
    _slotCounts = Map<String, dynamic>.from(widget.slotCounts);
    
    // Deep copy brand tiles including nested products
    _brandTiles = widget.layoutBrandTiles.map((e) {
      final map = Map<String, dynamic>.from(e);
      if (map['products'] != null) {
        map['products'] = (map['products'] as List).map((p) => Map<String, dynamic>.from(p)).toList();
      }
      return map;
    }).toList();
  }

  Future<void> _saveLayout() async {
    setState(() => _isSaving = true);
    try {
      int totalSlots = LayoutCalculator.calculateTotalLayoutCards(
        {
          'sectors': _sectors,
          'umsRoles': _umsRoles,
          'brandTiles': _brandTiles,
          'slotCounts': _slotCounts,
        },
        wardLength: widget.talukaWardsCount,
      );

      final layoutConfig = {
        'layoutCount': totalSlots.toString(),
        'sectors': _sectors,
        'umsRoles': _umsRoles,
        'brandTiles': _brandTiles,
        'slotCounts': _slotCounts,
      };

      final payload = {
        'wardHeadId': widget.wardHeadId,
        'wardId': widget.ward.wardId,
        'ward': widget.ward.wardName,
        'layoutCount': totalSlots.toString(),
        'applyToAllWards': true,
        'isCommonPage': true,
        'members': [],
        'layoutConfig': layoutConfig,
      };

      print('DEV DEBUG - _saveLayout - Saving Layout Configuration to Backend');
      print('DEV DEBUG - _saveLayout - Calculated Total Slots: $totalSlots (Dynamic based on Ward Count: ${widget.talukaWardsCount})');
      print('DEV DEBUG - _saveLayout - Payload Sent to Web API: ${jsonEncode(payload)}');

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('https://backend.udyamikutumba.com/ward-chart/createWardChartData'),
      );
      if (SessionManager.token != null) {
        request.headers['Authorization'] = 'Bearer ${SessionManager.token}';
      }
      
      request.fields['data'] = jsonEncode(payload);
      
      final res = await request.send();

      print('DEV DEBUG - _saveLayout - Response Status Code: ${res.statusCode}');

      if (res.statusCode == 200 || res.statusCode == 201) {
        print('DEV DEBUG - _saveLayout - Successfully Synced Custom Layout with Web Backend!');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Layout saved successfully!')));
          Navigator.pop(context, true); // Return true to refresh
        }
      } else {
        print('DEV DEBUG - _saveLayout - Failed to sync custom layout.');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to save layout.')));
        }
      }
    } catch (e) {
      print('DEV DEBUG - _saveLayout - Error during sync: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving layout: $e')));
      }
    }
    if (mounted) setState(() => _isSaving = false);
  }

  Widget _buildSlotDropdown(String label, String key, List<int> options) {
    int currentValue = _slotCounts[key] is int ? _slotCounts[key] : (options.isNotEmpty ? options.first : 0);
    if (!options.contains(currentValue)) currentValue = options.first;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          DropdownButton<int>(
            value: currentValue,
            items: options.map((e) => DropdownMenuItem(value: e, child: Text('$e'))).toList(),
            onChanged: (val) {
              if (val != null) {
                setState(() => _slotCounts[key] = val);
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Customize Chart Layout')),
      body: _isSaving 
        ? const Center(child: CircularProgressIndicator())
        : ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text('Enable or disable sections for this Area Chart.', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 24),
              const Text('Slot Counts', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _buildSlotDropdown('Officials', 'officials', [4, 8]),
              _buildSlotDropdown('Patrons', 'patrons', [5, 10, 15]),
              _buildSlotDropdown('Advisories', 'advisories', [3, 6]),
              _buildSlotDropdown('Mentors', 'mentors', [2, 4]),
              const Divider(height: 32),
              const Text('Brand Tiles Slots', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              _buildSlotDropdown("UB Queen's", 'udyamiQueens', [1, 2, 3, 4, 5, 10, 15, 20]),
              _buildSlotDropdown("UB Realty", 'ubRealtyConstruction', [1, 2, 3, 4, 5, 10, 15, 20]),
              _buildSlotDropdown("Yuva Udyami", 'yuvaUdyami', [1, 2, 3, 4, 5, 10, 15, 20]),
              _buildSlotDropdown("E3", 'ec', [1, 2, 3, 4, 5, 10, 15, 20]),
              _buildSlotDropdown("UB Finance & IT", 'ubFinanceIT', [1, 2, 3, 4, 5, 10, 15, 20]),
              _buildSlotDropdown("UB Social & Brand", 'ubSocialBrand', [1, 2, 3, 4, 5, 10, 15, 20]),
              const SizedBox(height: 24),
              const Divider(height: 32),
              if (_sectors.isNotEmpty) ...[
                const Text('Sectors', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ..._sectors.map((e) => SwitchListTile(
                  title: Text(e['label'] ?? e['key']),
                  value: e['enabled'] == true,
                  onChanged: (val) {
                    setState(() => e['enabled'] = val);
                  },
                )),
                const SizedBox(height: 24),
              ],
              if (_umsRoles.isNotEmpty) ...[
                const Text('UMS Management', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ..._umsRoles.map((e) => SwitchListTile(
                  title: Text(e['label'] ?? e['key']),
                  value: e['enabled'] == true,
                  onChanged: (val) {
                    setState(() => e['enabled'] = val);
                  },
                )),
                const SizedBox(height: 24),
              ],
              if (_brandTiles.isNotEmpty) ...[
                const Text('Brand Tiles & Products', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ..._brandTiles.expand((cat) {
                  final catLabel = cat['label'] ?? cat['key'];
                  final products = cat['products'] as List<dynamic>? ?? [];
                  return [
                    Padding(
                      padding: const EdgeInsets.only(top: 16, bottom: 8, left: 16),
                      child: Text(catLabel, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                    ),
                    ...products.map((p) => SwitchListTile(
                      title: Text(p['name'] ?? p['key']),
                      subtitle: Text(p['sub'] ?? '', style: const TextStyle(fontSize: 12)),
                      value: p['enabled'] == true,
                      onChanged: (val) {
                        setState(() => p['enabled'] = val);
                      },
                    ))
                  ];
                }),
                const SizedBox(height: 32),
              ],
              ElevatedButton(
                onPressed: _saveLayout,
                child: const Text('Save Layout'),
              )
            ],
          ),
    );
  }
}
