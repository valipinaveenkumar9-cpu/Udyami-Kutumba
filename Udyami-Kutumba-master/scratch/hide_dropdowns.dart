import 'dart:io';

void main() {
  final file = File('d:/DigiNik/Apps/udyamikutumba/lib/features/ucn/ucnsubscreens/assembly_roles_screen.dart');
  var content = file.readAsStringSync();

  // If taluka is auto-loaded, hide the dropdowns and show a clear message with a "Change" button if they want to see others.
  final buildRegex = RegExp(r'                  // District Dropdown.*?                  if \(_talukas\.isEmpty && _selectedDistrictId != null\).*?,\s+\),', dotAll: true);
  
  final newDropdowns = '''
                  if (_talukaId.isNotEmpty && _selectedDistrictId == null) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              "Auto-loaded based on your assigned Assembly",
                              style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _talukaId = '';
                                _selectedDistrictId = null;
                                _selectedTalukaId = null;
                                _assemblyLeadership = [];
                              });
                            },
                            child: const Text("Change"),
                          )
                        ],
                      ),
                    ),
                  ] else ...[
                    // District Dropdown
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: theme.brightness == Brightness.dark ? Colors.grey.shade900 : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          hint: const Text("Select District"),
                          value: _selectedDistrictId,
                          items: _districts.map((d) {
                            return DropdownMenuItem<String>(
                              value: d['districtId']?.toString(),
                              child: Text(d['districtName']?.toString() ?? 'Unknown'),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _selectedDistrictId = val;
                                _selectedDistrictName = _districts.firstWhere((d) => d['districtId']?.toString() == val)['districtName'];
                              });
                              _loadTalukas(val);
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Taluka Dropdown
                    if (_talukas.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: theme.brightness == Brightness.dark ? Colors.grey.shade900 : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            hint: const Text("Select Assembly / Taluka"),
                            value: _selectedTalukaId,
                            items: _talukas.map((t) {
                              return DropdownMenuItem<String>(
                                value: t['talukaId']?.toString(),
                                child: Text(t['talukaName']?.toString() ?? 'Unknown'),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  _selectedTalukaId = val;
                                  _talukaId = val;
                                  _selectedTalukaName = _talukas.firstWhere((t) => t['talukaId']?.toString() == val)['talukaName'];
                                });
                                _loadLeadership(val);
                              }
                            },
                          ),
                        ),
                      ),
                    
                    if (_talukas.isEmpty && _selectedDistrictId != null)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Text("No assemblies found for this district.", style: TextStyle(color: Colors.redAccent)),
                      ),
                  ],
''';

  content = content.replaceFirst(buildRegex, newDropdowns);
  file.writeAsStringSync(content);
}
