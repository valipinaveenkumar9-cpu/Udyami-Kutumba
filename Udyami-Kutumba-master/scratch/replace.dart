import 'dart:io';

void main() {
  final file = File('lib/features/auth/presentation/signup_screen.dart');
  final lines = file.readAsLinesSync();
  int startIdx = -1;
  int endIdx = -1;

  for (int i = 0; i < lines.length; i++) {
    if (lines[i].contains('] else if (_currentStep == 2) ...[')) {
      startIdx = i;
    }
    if (lines[i].contains('_buildLocationButton(') && 
        lines[i+1].contains('Business Location') && 
        lines[i+2].contains('_businessLocationController') && 
        lines[i+3].contains('false,')) {
      endIdx = i + 4;
      break;
    }
  }

  print('Start: $startIdx, End: $endIdx');

  final newBlock = '''
                                ] else if (_currentStep == 2) ...[
                                  Text(
                                    'BUSINESS DETAILS',
                                    style: TextStyle(
                                      color: theme.colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  _buildInputField(
                                    theme: theme,
                                    hintText: 'Business Name',
                                    icon: Icons.store,
                                    controller: _businessNameController,
                                  ),
                                  const SizedBox(height: 16),
                                  _isLoadingSectors
                                      ? const Center(
                                          child: CircularProgressIndicator(),
                                        )
                                      : Column(
                                          children: [
                                            Container(
                                              margin: const EdgeInsets.only(bottom: 16),
                                              child: DropdownButtonFormField<Map<String, dynamic>>(
                                                isExpanded: true,
                                                value: _selectedSector,
                                                decoration: InputDecoration(
                                                  labelText: "Business Category (Sector)",
                                                  filled: true,
                                                  fillColor: Colors.grey.shade50,
                                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                                                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                                                ),
                                                items: _sectors.map((s) => DropdownMenuItem<Map<String, dynamic>>(value: s, child: Text(s['sectorName'], overflow: TextOverflow.ellipsis))).toList(),
                                                onChanged: _onSectorChanged,
                                                validator: (v) => v == null ? 'Required' : null,
                                              ),
                                            ),
                                            Container(
                                              margin: const EdgeInsets.only(bottom: 16),
                                              child: DropdownButtonFormField<Map<String, dynamic>>(
                                                isExpanded: true,
                                                value: _selectedSubSector,
                                                decoration: InputDecoration(
                                                  labelText: "Business Sub-Category",
                                                  filled: true,
                                                  fillColor: Colors.grey.shade50,
                                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                                                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                                                ),
                                                items: _subSectors.map((s) => DropdownMenuItem<Map<String, dynamic>>(value: s, child: Text(s['subSectorName'], overflow: TextOverflow.ellipsis))).toList(),
                                                onChanged: _onSubSectorChanged,
                                                validator: (v) => v == null ? 'Required' : null,
                                              ),
                                            ),
                                            Container(
                                              margin: const EdgeInsets.only(bottom: 16),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    child: _isLoadingSubSubSectors ? const Center(child: CircularProgressIndicator()) : DropdownButtonFormField<Map<String, dynamic>>(
                                                      isExpanded: true,
                                                      value: _selectedSubSubSector,
                                                      decoration: InputDecoration(
                                                        labelText: "Business Sub-Sub-Category",
                                                        filled: true,
                                                        fillColor: Colors.grey.shade50,
                                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                                                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                                                      ),
                                                      items: _subSubSectors.map((s) => DropdownMenuItem<Map<String, dynamic>>(value: s, child: Text(s['productDescription'] ?? s['subSubSectorName'] ?? '', overflow: TextOverflow.ellipsis))).toList(),
                                                      onChanged: _onSubSubSectorChanged,
                                                      validator: (v) => v == null ? 'Required' : null,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Container(
                                                    decoration: BoxDecoration(color: Colors.teal.shade50, borderRadius: BorderRadius.circular(12)),
                                                    child: IconButton(
                                                      icon: const Icon(Icons.add, color: Colors.teal, size: 28),
                                                      onPressed: _showCreateAllSectorsDialog,
                                                      tooltip: 'Add new category',
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Checkbox(
                                        value: _sameAsPersonalArea,
                                        activeColor: theme.colorScheme.primary,
                                        onChanged: (value) {
                                          setState(() {
                                            _sameAsPersonalArea = value ?? false;
                                            if (_sameAsPersonalArea) {
                                              _selectedBusinessState = _selectedState;
                                              _businessDistricts = List.from(_districts);
                                              _selectedBusinessDistrict = _selectedDistrict;
                                              _businessTalukas = List.from(_talukas);
                                              _selectedBusinessTaluka = _selectedTaluka;
                                              _businessWards = List.from(_wards);
                                              _selectedBusinessWardId = _selectedWardId;
                                            } else {
                                              _selectedBusinessState = null;
                                              _selectedBusinessDistrict = null;
                                              _selectedBusinessTaluka = null;
                                              _selectedBusinessWardId = null;
                                              _businessDistricts = [];
                                              _businessTalukas = [];
                                              _businessWards = [];
                                            }
                                          });
                                        },
                                      ),
                                      const Expanded(
                                        child: Text(
                                          'Same as personal area',
                                          style: TextStyle(fontSize: 14),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  _buildRealDropdown(
                                    'State',
                                    Icons.location_on,
                                    _states,
                                    _selectedBusinessState,
                                    _onBusinessStateChanged,
                                    false,
                                  ),
                                  _buildRealDropdown(
                                    'District',
                                    Icons.map,
                                    _businessDistricts,
                                    _selectedBusinessDistrict,
                                    _onBusinessDistrictChanged,
                                    _selectedBusinessState == null,
                                  ),
                                  _buildRealDropdown(
                                    'Taluk',
                                    Icons.terrain,
                                    _businessTalukas,
                                    _selectedBusinessTaluka,
                                    _onBusinessTalukaChanged,
                                    _selectedBusinessDistrict == null,
                                  ),
                                  _buildBusinessWardDropdown(
                                    'Area / Village',
                                    Icons.map_outlined,
                                    _selectedBusinessTaluka == null,
                                  ),
                                  const SizedBox(height: 16),
                                  _buildLocationButton(
                                    'Business Location',
                                    _businessLocationController,
                                    false,
                                  ),
''';

  final newLines = <String>[];
  newLines.addAll(lines.sublist(0, startIdx));
  newLines.add(newBlock);
  newLines.addAll(lines.sublist(endIdx + 1));

  file.writeAsStringSync(newLines.join('\n'));
}
