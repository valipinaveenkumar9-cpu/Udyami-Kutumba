import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../core/api/profile/profile_api.dart';
import '../../../core/api/area/ward_api.dart';
import '../../../core/api/area/dashboard_api.dart';
import '../../../core/utils/session_manager.dart';
import '../../../core/models/user_model.dart';
import '../../profile/presentation/profile_screen.dart';
import 'package:udyamikutumba/core/widgets/theme_toggle_button.dart';

class MemberMapScreen extends StatefulWidget {
  const MemberMapScreen({super.key});

  @override
  State<MemberMapScreen> createState() => _MemberMapScreenState();
}

class _MemberMapScreenState extends State<MemberMapScreen> {
  bool _isLoadingProfile = true;
  bool _isWardUpdated = false;
  bool _hasPrivilegedRole = false;
  String? _assignedAreaName;

  final MapController _mapController = MapController();
  Position? _currentPosition;
  String _mapType = 'm'; // 'm': roadmap, 's': satellite, 'y': hybrid, 'p': terrain
  bool _showTraffic = false;

  // Roles
  bool _isSuperAdmin = false;
  bool _isHeadRole = false;

  // Map Tools
  bool _isMeasurementMode = false;
  bool _isDrawMode = false;
  List<LatLng> _toolPoints = [];
  double _totalDistance = 0.0;
  double _currentZoom = 15.0;

  // Routing State
  List<LatLng> _routePoints = [];
  bool _isFetchingRoute = false;
  double _routeDistance = 0.0;
  String _routeDuration = "";

  // Search and GeoJSON State
  final WardAPI _wardAPI = WardAPI();
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String? _searchError;

  final List<Map<String, dynamic>> _districtPolygons = [];
  final List<Map<String, dynamic>> _talukaPolygons = [];
  final List<Map<String, dynamic>> _wardPolygons = [];
  Map<String, dynamic>? _wardProperties;
  final List<Map<String, dynamic>> _businesses = [];
  LatLng? _wardCentroid;
  Map<String, dynamic>? _selectedBusiness;
  bool _isSheetVisible = true;

  final DashboardAPI _dashboardAPI = DashboardAPI();
  List<dynamic> _districtsList = [];
  List<dynamic> _talukasList = [];
  List<dynamic> _wardsList = [];
  String? _selectedDistrictId;
  String? _selectedTalukaId;
  String? _selectedWardId;
  String? _selectedDistrictName;
  String? _selectedTalukaName;
  String? _selectedWardName;
  
  bool _showDistrictLayer = true;
  bool _showTalukaLayer = true;
  bool _showWardLayer = true;
  bool _showBusinessMarkers = true;
  bool _isFiltersExpanded = true;


  @override
  void initState() {
    super.initState();
    _checkProfileAndInit();
  }

  Future<void> _checkProfileAndInit() async {
    try {
      final user = SessionManager.user;
      if (user != null && user['userId'] != null) {
        final roleType = _getRoleType();
        _isSuperAdmin = (roleType == 'superadmin' || roleType == 'super_admin');
        _isHeadRole = (roleType == 'district' || roleType == 'taluka' || roleType == 'state' || roleType.contains('head') || roleType.contains('chairman'));
        _hasPrivilegedRole = (_isSuperAdmin || _isHeadRole);
        
        final profileAPI = ProfileAPI();
        final response = await profileAPI.getUserProfileById(
          user['userId'].toString(),
        );
        if (response != null && response['success'] == true) {
          final profile = response['data']?['profile'] ?? response['data'];
          String? areaName;
          if (roleType == 'superadmin' || roleType == 'state') {
            _fetchDistricts();
          }
          print(
            "DEV DEBUG - Geofence: roleType = $roleType, _hasPrivilegedRole = $_hasPrivilegedRole",
          );
          print("DEV DEBUG - Geofence: user['position'] = ${user['position']}");

          String? districtId;
          String? talukaId;

          if (profile != null) {
            // Extract District safely
            dynamic dData = profile['district'] ?? user['district'];
            if (dData is Map) {
               districtId = dData['_id']?.toString() ?? dData['districtId']?.toString();
               if (roleType == 'district') areaName = dData['districtName']?.toString();
            } else {
               if (roleType == 'district') areaName = dData?.toString() ?? profile['districtName']?.toString() ?? user['districtName']?.toString();
            }

            // Extract Taluka safely
            dynamic tData = profile['taluka'] ?? profile['assembly'] ?? user['taluka'];
            if (tData is Map) {
               talukaId = tData['_id']?.toString() ?? tData['talukaId']?.toString();
               if (roleType == 'taluka' && areaName == null) areaName = tData['talukaName']?.toString();
            } else {
               if (roleType == 'taluka' && areaName == null) areaName = tData?.toString() ?? profile['talukaName']?.toString() ?? user['talukaName']?.toString();
            }

            // Fallback using location chart if missing
            try {
              final locRes = await _dashboardAPI.getLocationByWardHeadId(user['userId'].toString());
              if (locRes != null) {
                 final locData = locRes['data'] ?? locRes;
                 List wardsArray = [];
                 if (locData is Map && locData['wards'] is List) wardsArray = locData['wards'];
                 else if (locData is List) wardsArray = locData;
                 else if (locData is Map && locData['areaChart'] != null && locData['areaChart']['wards'] is List) wardsArray = locData['areaChart']['wards'];
                 
                 if (wardsArray.isNotEmpty) {
                    final source = wardsArray.first as Map<String, dynamic>;
                    if (talukaId == null) talukaId = source['taluka']?['_id']?.toString() ?? source['taluka']?['talukaId']?.toString() ?? source['ward']?['talukaId']?.toString();
                    if (roleType == 'taluka' && (areaName == null || areaName!.isEmpty)) {
                       areaName = source['taluka']?['talukaName']?.toString() ?? source['ward']?['talukaName']?.toString() ?? source['talukaName']?.toString();
                    }
                 }
              }
            } catch (e) {
              print("DEV DEBUG - Map: Error fallback fetching location: $e");
            }

            print("DEV DEBUG - Map: Extracted districtId: $districtId, talukaId: $talukaId, areaName: $areaName");

            if (roleType == 'superadmin' || roleType == 'state') {
              // Super admin and State should not be locked to their personal ward profile.
              // They get full access to select from dropdowns.
            } else if (roleType == 'district') {
              if (districtId != null) _fetchTalukasForDistrict(districtId);
            } else if (roleType == 'taluka') {
              if (talukaId != null) _fetchWardsForTaluka(talukaId);
            } else if (profile['ward'] != null) {
              final wardIdOrName = profile['ward'] is Map ? (profile['ward']['wardName'] ?? profile['ward']['_id']).toString() : profile['ward'].toString();
              areaName = wardIdOrName;
            }
          }

          if ((roleType != 'superadmin' && roleType != 'state') && (areaName == null || areaName.isEmpty) &&
              user['position'] != null) {
            final positionName = user['position']['positionName']?.toString();
            print(
              "DEV DEBUG - Geofence: Attempting to extract from positionName = $positionName",
            );
            if (positionName != null) {
              if (roleType == 'district' &&
                  positionName.endsWith(' District Head')) {
                areaName = positionName.replaceAll(' District Head', '').trim();
              } else if (roleType == 'taluka') {
                if (positionName.endsWith(' Taluka Head')) {
                  areaName = positionName.replaceAll(' Taluka Head', '').trim();
                } else if (positionName.endsWith(' Assembly Head')) {
                  areaName = positionName
                      .replaceAll(' Assembly Head', '')
                      .trim();
                } else if (positionName.endsWith(' President')) {
                  areaName = positionName.replaceAll(' President', '').trim();
                }
              } else if (positionName.endsWith(' Ward Chairman')) {
                areaName = positionName.replaceAll(' Ward Chairman', '').trim();
              } else if (positionName.endsWith(' Ward Head')) {
                areaName = positionName.replaceAll(' Ward Head', '').trim();
              }
              print(
                "DEV DEBUG - Geofence: Extracted areaName from positionName = $areaName",
              );
            }
          }

          if (areaName != null && areaName.isNotEmpty) {
            _assignedAreaName = areaName;
            _isWardUpdated = true;
            print(
              "DEV DEBUG - Geofence: Final assignedAreaName = $_assignedAreaName, _isWardUpdated = true",
            );
          } else {
            print(
              "DEV DEBUG - Geofence: No assignedAreaName could be found. User must use search bar or update profile.",
            );
          }
        }
      }
    } catch (e) {
      debugPrint("Error checking profile for geofence: $e");
    }

    if (mounted) {
      setState(() {
        _isLoadingProfile = false;
      });
      if (_isWardUpdated || _hasPrivilegedRole) {
        _fetchLiveLocation();
        if (_isWardUpdated) _loadAssignedMap();
      }
    }
  }

  Future<void> _fetchLiveLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        final pos = await Geolocator.getCurrentPosition();
        if (mounted) {
          setState(() => _currentPosition = pos);
        }
      }
    } catch (e) {
      debugPrint("Error getting location: $e");
    }
  }

  Future<void> _fetchRoute(LatLng destination) async {
    if (_currentPosition == null) return;
    setState(() => _isFetchingRoute = true);

    try {
      final start = LatLng(_currentPosition!.latitude, _currentPosition!.longitude);
      final url = Uri.parse(
        'https://router.project-osrm.org/route/v1/driving/${start.longitude},${start.latitude};${destination.longitude},${destination.latitude}?overview=full&geometries=geojson',
      );
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['routes'] != null && data['routes'].isNotEmpty) {
          final route = data['routes'][0];
          final geometry = route['geometry']['coordinates'] as List;
          
          List<LatLng> points = [];
          for (var coord in geometry) {
            points.add(LatLng(coord[1], coord[0]));
          }
          
          setState(() {
            _routePoints = points;
            _routeDistance = route['distance'] / 1000.0; // km
            _routeDuration = (route['duration'] / 60.0).toStringAsFixed(0); // mins
            _isFetchingRoute = false;
          });

          // Zoom to fit route
          final bounds = LatLngBounds.fromPoints(points);
          _mapController.fitCamera(
            CameraFit.bounds(
              bounds: bounds,
              padding: const EdgeInsets.all(50),
            ),
          );
        }
      } else {
        setState(() => _isFetchingRoute = false);
      }
    } catch (e) {
      setState(() => _isFetchingRoute = false);
    }
  }

  Future<void> _fetchLocationAndData(String query, String queryType) async {
    if (query.isEmpty) return;

    setState(() {
      _isSearching = true;
      _searchError = null;
      _districtPolygons.clear();
      _talukaPolygons.clear();
      _wardPolygons.clear();
      _businesses.clear();
      _wardProperties = null;
      _wardCentroid = null;
      _selectedBusiness = null;
      _isSheetVisible = false;
    });

    try {
      final response = await _wardAPI.getWardMap(query, type: queryType);
      if (mounted) {
        if (response != null && response['success'] == true && response['data'] != null && response['data']['type'] == 'FeatureCollection') {
          _parseGeoJson(response['data']);
        } else {
          setState(() {
            _searchError = 'No data found for the selected area.';
          });
        }
      }
    } catch (e) {
      if (mounted) setState(() => _searchError = 'Error fetching data.');
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  Future<void> _loadAssignedMap() async {
    if (_assignedAreaName == null) return;
    _searchController.text = _assignedAreaName!;
    await _searchWard();
  }

  String _getRoleType() {
    String highestRole = 'member';
    try {
      final user = SessionManager.user;
      if (user != null) {
        final userModel = UserModel.fromJson(user);
        if (userModel.roles.isNotEmpty) {
          highestRole = userModel.roles.first.roleName.toLowerCase();
          for (final r in userModel.roles) {
            final rl = r.roleName.toLowerCase();
            if (rl == 'super_admin') { highestRole = rl; break; }
            if (rl.contains('state')) { highestRole = rl; break; }
            if (rl.contains('district')) { highestRole = rl; }
            if (rl.contains('taluka') && !highestRole.contains('district') && !highestRole.contains('state') && highestRole != 'super_admin') { highestRole = rl; }
            if ((rl.contains('ward_chairman') || rl.contains('ward_head')) && !highestRole.contains('taluka') && !highestRole.contains('district') && !highestRole.contains('state') && highestRole != 'super_admin') { highestRole = rl; }
          }
        }
      }
    } catch (_) {}

    if (highestRole == 'super_admin') return 'superadmin';
    if (highestRole.contains('state')) return 'state';
    if (highestRole.contains('district')) return 'district';
    if (highestRole.contains('taluka') || highestRole.contains('taluk')) return 'taluka';
    return 'ward';
  }

  Future<void> _searchWard() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isSearching = true;
      _searchError = null;
      _districtPolygons.clear();
      _talukaPolygons.clear();
      _wardPolygons.clear();
      _businesses.clear();
      _wardProperties = null;
      _wardCentroid = null;
      _selectedBusiness = null;
      _isSheetVisible = true;
    });

    try {
      final roleType = _getRoleType();
      final response = await _wardAPI.getWardMap(query, type: roleType);
      if (mounted) {
        if (response != null &&
            response['success'] == true &&
            response['data'] != null &&
            response['data']['type'] == 'FeatureCollection') {
          _parseGeoJson(response['data']);

          if (_showWardLayer && _wardCentroid != null) {
            double zoomLevel = 14.5;
            if (roleType == 'district')
              zoomLevel = 9.0;
            else if (roleType == 'taluka')
              zoomLevel = 10.5;
            _mapController.move(_wardCentroid!, zoomLevel);
          } else {
            _searchError = "No valid boundaries found.";
          }
        } else {
          _searchError = response?['message'] ?? "Could not find map data.";
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _searchError = "Error fetching ward map data.";
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
      }
    }
  }

  void _parseGeoJson(Map<String, dynamic> data) {
    final features = data['features'];
    if (features == null || features is! List) return;

    double minLat = 90.0, maxLat = -90.0;
    double minLng = 180.0, maxLng = -180.0;
    bool foundPolygon = false;

    void processRing(List ring, String level, String? label) {
      final List<LatLng> polygonPoints = [];
      for (var pt in ring) {
        if (pt is List && pt.length >= 2) {
          double lng = (pt[0] as num).toDouble();
          double lat = (pt[1] as num).toDouble();
          polygonPoints.add(LatLng(lat, lng));

          if (lat < minLat) minLat = lat;
          if (lat > maxLat) maxLat = lat;
          if (lng < minLng) minLng = lng;
          if (lng > maxLng) maxLng = lng;
        }
      }
      if (polygonPoints.isNotEmpty) {
        final polyData = {'points': polygonPoints, 'label': label};
        if (level == 'district') {
          _districtPolygons.add(polyData);
        } else if (level == 'taluka') {
          _talukaPolygons.add(polyData);
        } else {
          _wardPolygons.add(polyData);
        }
        foundPolygon = true;
      }
    }

    for (var feature in features) {
      if (feature is Map<String, dynamic>) {
        final geom = feature['geometry'];
        final props = feature['properties'] ?? {};

        if (props['businesses'] is List) {
          for (var biz in props['businesses']) {
            if (biz is Map<String, dynamic> &&
                biz['latitude'] != null &&
                biz['longitude'] != null) {
              double lat = double.tryParse(biz['latitude'].toString()) ?? 0.0;
              double lng = double.tryParse(biz['longitude'].toString()) ?? 0.0;
              if (lat != 0.0 && lng != 0.0) {
                _businesses.add({'latLng': LatLng(lat, lng), ...biz});
              }
            }
          }
        }

        if (geom is Map<String, dynamic>) {
          final type = geom['type'];
          final coords = geom['coordinates'];

          if (type == 'Polygon' && coords is List && coords.isNotEmpty) {
            final ring = coords[0] as List;
            final label = props['name'] ?? props['wardName'] ?? props['ward_name'] ?? props['Ward_Name'] ?? props['talukaName'] ?? props['districtName'];
            processRing(ring, props['level']?.toString() ?? _getRoleType(), label?.toString());
            _wardProperties = props;
          } else if (type == 'MultiPolygon' && coords is List) {
            final label = props['name'] ?? props['wardName'] ?? props['ward_name'] ?? props['Ward_Name'] ?? props['talukaName'] ?? props['districtName'];
            for (var poly in coords) {
              if (poly is List && poly.isNotEmpty) {
                final ring = poly[0] as List;
                processRing(ring, props['level']?.toString() ?? _getRoleType(), label?.toString());
              }
            }
            _wardProperties = props;
          } else if (type == 'Point' && coords is List && coords.length >= 2) {
            double lng = (coords[0] as num).toDouble();
            double lat = (coords[1] as num).toDouble();
            _businesses.add({'latLng': LatLng(lat, lng), ...props});
          }
        }
      }
    }

    if (foundPolygon) {
      _wardCentroid = LatLng((minLat + maxLat) / 2, (minLng + maxLng) / 2);
    }
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.orange.withOpacity(0.2)
                      : Colors.orange.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.location_off_rounded,
                  size: 64,
                  color: Colors.orange.shade400,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Profile Update Required',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Geofence attendance and live location mapping are only available to members who have linked their profile to a specific ward.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProfileScreen(),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.person_pin_rounded,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'Update Profile Now',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLiveMap() {
    LatLng defaultCenter = const LatLng(15.3173, 75.7139); // Karnataka center
    if (_currentPosition != null) {
      defaultCenter = LatLng(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );
    }
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: _wardCentroid ?? defaultCenter,
        initialZoom: _wardCentroid == null ? 7.0 : 15.0,
        onPositionChanged: (position, hasGesture) {
          if (position.zoom != null && position.zoom != _currentZoom) {
            setState(() {
              _currentZoom = position.zoom!;
            });
          }
        },
        onTap: (tapPosition, point) {
          if (_isMeasurementMode || _isDrawMode) {
            setState(() {
              if (_toolPoints.isNotEmpty && _isMeasurementMode) {
                const Distance distance = Distance();
                _totalDistance += distance.as(LengthUnit.Meter, _toolPoints.last, point);
              }
              _toolPoints.add(point);
            });
          }
        },
      ),
      children: [
        TileLayer(
          urlTemplate: "https://mt1.google.com/vt/lyrs=${_mapType}${_showTraffic ? ',traffic' : ''}&x={x}&y={y}&z={z}",
          userAgentPackageName: 'com.ub.kutumba',
        ),
        if (_showWardLayer && _wardPolygons.isNotEmpty)
          PolygonLayer(
            polygons: _wardPolygons.map((polyData) {
              return Polygon(
                points: polyData['points'] as List<LatLng>,
                label: polyData['label']?.toString(),
                labelStyle: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold, backgroundColor: Colors.black54),
                color: const Color(0xFF16A34A).withOpacity(0.1),
                borderColor: const Color(0xFF16A34A),
                borderStrokeWidth: 2,
              );
            }).toList(),
          ),
        if (_routePoints.isNotEmpty)
          PolylineLayer(
            polylines: [
              Polyline(
                points: _routePoints,
                color: Colors.blueAccent,
                strokeWidth: 5.0,
              ),
            ],
          ),
        if (_showTalukaLayer && _talukaPolygons.isNotEmpty)
          PolygonLayer(
            polygons: _talukaPolygons.map((polyData) {
              return Polygon(
                points: polyData['points'] as List<LatLng>,
                label: polyData['label']?.toString(),
                labelStyle: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold, backgroundColor: Colors.black54),
                color: const Color(0xFFEA580C).withOpacity(0.1),
                borderColor: const Color(0xFFEA580C),
                borderStrokeWidth: 3,
              );
            }).toList(),
          ),
        if (_showDistrictLayer && _districtPolygons.isNotEmpty)
          PolygonLayer(
            polygons: _districtPolygons.map((polyData) {
              return Polygon(
                points: polyData['points'] as List<LatLng>,
                label: polyData['label']?.toString(),
                labelStyle: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold, backgroundColor: Colors.black54),
                color: const Color(0xFF1E40AF).withOpacity(0.08),
                borderColor: const Color(0xFF1E40AF),
                borderStrokeWidth: 4,
              );
            }).toList(),
          ),
        if (_showBusinessMarkers && _businesses.isNotEmpty && _currentZoom >= 12.0)
          MarkerLayer(
            markers: _businesses.map((b) {
              final isSelected = _selectedBusiness == b;
              final businessName = b['businessName']?.toString() ?? 'Business';
              return Marker(
                point: b['latLng'],
                width: 50,
                height: 50,
                alignment: Alignment.topCenter,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedBusiness = b;
                      _isSheetVisible = true;
                    });
                    _mapController.move(b['latLng'], 18.0);
                  },
                  child: Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      Icon(
                        Icons.location_on,
                        size: isSelected ? 48 : 36,
                        color: _getBusinessColor(b, isSelected),
                      ),
                      Positioned(
                        top: isSelected ? 8 : 6,
                        child: Icon(
                          _getBusinessIcon(b),
                          size: isSelected ? 18 : 14,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        if (_isMeasurementMode && _toolPoints.isNotEmpty)
          PolylineLayer(
            polylines: [
              Polyline(
                points: _toolPoints,
                color: Colors.blue,
                strokeWidth: 4.0,
              ),
            ],
          ),
        if (_isMeasurementMode && _toolPoints.isNotEmpty)
          MarkerLayer(
            markers: _toolPoints.map((p) => Marker(
              point: p,
              width: 12,
              height: 12,
              child: const CircleAvatar(backgroundColor: Colors.blue, radius: 6),
            )).toList(),
          ),
        if (_isDrawMode && _toolPoints.isNotEmpty)
          PolygonLayer(
            polygons: [
              Polygon(
                points: _toolPoints,
                color: Colors.green.withOpacity(0.3),
                borderColor: Colors.green,
                borderStrokeWidth: 3,
              ),
            ],
          ),
        if (_currentPosition != null)
          MarkerLayer(
            markers: [
              Marker(
                point: LatLng(
                  _currentPosition!.latitude,
                  _currentPosition!.longitude,
                ),
                width: 60,
                height: 60,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue.withOpacity(0.2),
                  ),
                  child: Center(
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blue,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: const [
                          BoxShadow(color: Colors.black26, blurRadius: 5),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildSearchBar() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Positioned(
      top: 50,
      left: 16,
      right: 16,
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black45 : Colors.black12,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          textInputAction: TextInputAction.search,
          onSubmitted: (_) => _searchWard(),
          style: TextStyle(fontSize: 15, color: theme.colorScheme.onSurface),
          decoration: InputDecoration(
            hintText: 'Type Area (e.g. Mathikere)',
            hintStyle: TextStyle(
              color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
              fontSize: 15,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 22),
            suffixIcon: _isSearching
                ? Padding(
                    padding: const EdgeInsets.all(12),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  )
                : _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.grey, size: 20),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {});
                    },
                  )
                : null,
          ),
          onChanged: (val) {
                   print("DEV DEBUG - Map: Dropdown changed to: " + val.toString());
            setState(() {});
          },
        ),
      ),
    );
  }

  Future<void> _fetchDistricts() async {
    print("DEV DEBUG - Map: _fetchDistricts called");
    try {
      final res = await _dashboardAPI.fetchAllDistricts();
      if (res != null && res['success'] == true)
        setState(() => _districtsList = res['data'] ?? []);
    } catch (_) {}
  }

  Future<void> _fetchTalukasForDistrict(String districtId) async {
    print("DEV DEBUG - Map: _fetchTalukasForDistrict called with ID: " + districtId);
    try {
      final res = await _dashboardAPI.fetchTalukasByDistrict(districtId);
      if (res != null && res['success'] == true) {
        setState(() => _talukasList = res['data'] ?? []);
      }
    } catch (_) {}
  }

  

  Future<void> _fetchWardsForTaluka(String talukaName) async {
    print("DEV DEBUG - Map: _fetchWardsForTaluka called with: " + talukaName);
    try {
      final res = await _dashboardAPI.fetchWardsByTaluka(
        talukaName,
      ); // might need talukaId
      if (res != null && res['success'] == true)
        setState(() {
          _wardsList = res['data'] ?? [];
          print("DEV DEBUG - Map: Wards fetched: " + _wardsList.length.toString());
        });
    } catch (_) {}
  }

  Widget _buildAreaFilters() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (!_hasPrivilegedRole && _getRoleType() != 'superadmin' && _getRoleType() != 'state') return const SizedBox();

    return Positioned(
      top: 110,
      left: 16,
      right: 16,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withOpacity(0.95),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isDark ? Colors.grey.shade700 : Colors.grey.shade300),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2))],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: () => setState(() => _isFiltersExpanded = !_isFiltersExpanded),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.filter_alt, size: 18, color: Colors.blue),
                      SizedBox(width: 8),
                      Text('Map Filters', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Icon(_isFiltersExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, size: 20),
                ],
              ),
            ),
            if (_isFiltersExpanded) ...[
              const Divider(),
              // Dropdowns
              if (_getRoleType() == 'superadmin' || _getRoleType() == 'state')
                 DropdownButton<String>(
                   isExpanded: true,
                   hint: const Text('Select District'),
                   value: _selectedDistrictId,
                   items: _districtsList.map((e) => DropdownMenuItem<String>(value: e['districtId'] ?? e['_id'] ?? e['id'] ?? e['districtName'], child: Text(e['districtName'] ?? ''))).toList(),
                   onChanged: (val) {
                   print("DEV DEBUG - Map: Dropdown changed to: " + val.toString());
                     if (val == null) return;
                     final selectedObj = _districtsList.firstWhere((e) => (e['districtId'] ?? e['_id'] ?? e['id'] ?? e['districtName']) == val, orElse: () => {});
                     final name = selectedObj['districtName'] ?? val;
                     _searchController.text = name;
                     setState(() {
                       _selectedDistrictId = val;
                       _selectedDistrictName = name;
                       _selectedTalukaId = null;
                       _selectedTalukaName = null;
                       _selectedWardId = null;
                       _selectedWardName = null;
                       _talukasList = [];
                       _wardsList = [];
                     });
                     _fetchTalukasForDistrict(val);
                     _fetchLocationAndData(name, 'district');
                   },
                 ),
              if (_getRoleType() == 'superadmin' || _getRoleType() == 'state' || _getRoleType() == 'district')
                 DropdownButton<String>(
                   isExpanded: true,
                   hint: const Text('Select Taluka'),
                   value: _selectedTalukaId,
                   items: _talukasList.map((e) => DropdownMenuItem<String>(value: e['talukaId'] ?? e['_id'] ?? e['id'] ?? e['talukaName'], child: Text(e['talukaName'] ?? ''))).toList(),
                   onChanged: (val) {
                   print("DEV DEBUG - Map: Dropdown changed to: " + val.toString());
                     if (val == null) return;
                     final selectedObj = _talukasList.firstWhere((e) => (e['talukaId'] ?? e['_id'] ?? e['id'] ?? e['talukaName']) == val, orElse: () => {});
                     final name = selectedObj['talukaName'] ?? val;
                     _searchController.text = name;
                     setState(() {
                       _selectedTalukaId = val;
                       _selectedTalukaName = name;
                       _selectedWardId = null;
                       _selectedWardName = null;
                       _wardsList = [];
                     });
                     _fetchWardsForTaluka(val);
                     _fetchLocationAndData(name, 'taluka');
                   },
                 ),
              DropdownButton<String>(
                isExpanded: true,
                hint: const Text('Select Ward'),
                value: _selectedWardId,
                items: _wardsList.map((e) => DropdownMenuItem<String>(value: e['wardId'] ?? e['_id'] ?? e['id'] ?? e['wardName'], child: Text(e['wardName'] ?? ''))).toList(),
                onChanged: (val) {
                   print("DEV DEBUG - Map: Dropdown changed to: " + val.toString());
                  if (val == null) return;
                  final selectedObj = _wardsList.firstWhere((e) => (e['wardId'] ?? e['_id'] ?? e['id'] ?? e['wardName']) == val, orElse: () => {});
                  final name = selectedObj['wardName'] ?? val;
                  _searchController.text = name;
                  setState(() {
                    _selectedWardId = val;
                    _selectedWardName = name;
                  });
                  _fetchLocationAndData(name, 'ward');
                },
              ),
              const Divider(),
              // Map Layer Toggles
              _buildToggleRow('District Boundary', _showDistrictLayer, (v) => setState(() => _showDistrictLayer = v)),
              _buildToggleRow('Taluka Boundary', _showTalukaLayer, (v) => setState(() => _showTalukaLayer = v)),
              _buildToggleRow('Ward Boundary', _showWardLayer, (v) => setState(() => _showWardLayer = v)),
              _buildToggleRow('Markers (Members/UCN)', _showBusinessMarkers, (v) => setState(() => _showBusinessMarkers = v)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildToggleRow(String title, bool value, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 13)),
          SizedBox(
            height: 24,
            child: Switch(
              value: value,
              onChanged: onChanged,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSheet() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: GestureDetector(
        onVerticalDragUpdate: (details) {
          if (details.delta.dy > 5 && _isSheetVisible) {
            setState(() => _isSheetVisible = false);
          } else if (details.delta.dy < -5 && !_isSheetVisible) {
            setState(() => _isSheetVisible = true);
          }
        },
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            boxShadow: [
              BoxShadow(
                color: isDark ? Colors.black54 : Colors.black12,
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 50,
                    height: 5,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.grey.shade700
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOutBack,
                  child: _isSheetVisible
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (_searchError != null)
                              Container(
                                padding: const EdgeInsets.all(12),
                                margin: const EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Colors.red.withOpacity(0.2)
                                      : Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  _searchError!,
                                  style: TextStyle(
                                    color: isDark
                                        ? Colors.red.shade300
                                        : Colors.red.shade700,
                                    fontSize: 13,
                                  ),
                                ),
                              ),

                            // SHOW SELECTED BUSINESS DETAILS
                            if (_selectedBusiness != null) ...[
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Colors.amber.withOpacity(0.1)
                                      : Colors.amber.shade50,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isDark
                                        ? Colors.amber.withOpacity(0.3)
                                        : Colors.amber.shade200,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                _selectedBusiness!['businessName']
                                                            ?.toString()
                                                            .isNotEmpty ==
                                                        true
                                                    ? _selectedBusiness!['businessName']
                                                    : 'Unnamed Business',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18,
                                                  color: theme
                                                      .colorScheme
                                                      .onSurface,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              if (_wardProperties != null)
                                                Text(
                                                  _wardProperties!['ward_name'] ??
                                                      _wardProperties!['Ward_Name'] ??
                                                      _wardProperties!['ward'] ??
                                                      'Ward ${_wardProperties!['ward_id'] ?? 'Unknown'}',
                                                  style: TextStyle(
                                                    color: isDark
                                                        ? Colors.grey.shade400
                                                        : Colors.grey.shade700,
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () => setState(
                                            () => _selectedBusiness = null,
                                          ),
                                          child: Icon(
                                            Icons.close_rounded,
                                            size: 24,
                                            color: isDark
                                                ? Colors.grey.shade400
                                                : Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    if (_selectedBusiness!['businessType'] !=
                                        null)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        margin: const EdgeInsets.only(
                                          bottom: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.amber.shade100,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Text(
                                          _selectedBusiness!['businessType'],
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.amber.shade900,
                                          ),
                                        ),
                                      ),
                                    if (_selectedBusiness!['sector'] != null)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 12,
                                        ),
                                        child: Text(
                                          _selectedBusiness!['sector'],
                                          style: TextStyle(
                                            color: isDark
                                                ? Colors.grey.shade400
                                                : Colors.grey.shade600,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    _buildDetailRow(
                                      Icons.person_rounded,
                                      'Owner',
                                      _selectedBusiness!['ownerName'] ?? 'N/A',
                                    ),
                                    _buildDetailRow(
                                      Icons.phone_rounded,
                                      'Mobile',
                                      _selectedBusiness!['businessMobile'] ??
                                          _selectedBusiness!['mobile'] ??
                                          'N/A',
                                    ),
                                    if (_selectedBusiness!['email'] != null)
                                      _buildDetailRow(
                                        Icons.email_rounded,
                                        'Email',
                                        _selectedBusiness!['email'],
                                      ),
                                    if (_selectedBusiness!['address'] != null)
                                      _buildDetailRow(
                                        Icons.location_on_rounded,
                                        'Address',
                                        '${_selectedBusiness!['address']}${_selectedBusiness!['city'] != null ? ', ${_selectedBusiness!['city']}' : ''}',
                                      ),
                                    if (_selectedBusiness!['employees'] != null)
                                      _buildDetailRow(
                                        Icons.people_rounded,
                                        'Employees',
                                        '${_selectedBusiness!['employees']} · Est. ${_selectedBusiness!['establishedYear'] ?? 'N/A'}',
                                      ),
                                    _buildDetailRow(
                                      Icons.tag_rounded,
                                      'Membership',
                                      _selectedBusiness!['membershipNumber'] ??
                                          'N/A',
                                    ),

                                    // Business Images (if any)
                                    Builder(
                                      builder: (context) {
                                        final List<String> b64Images = [];
                                        // Check for businessImage1, businessImage2, etc.
                                        for (int i = 1; i <= 5; i++) {
                                          final imgData =
                                              _selectedBusiness!['businessImage$i'];
                                          if (imgData != null &&
                                              imgData is Map &&
                                              imgData['image'] != null) {
                                            b64Images.add(
                                              imgData['image'].toString(),
                                            );
                                          } else if (imgData != null &&
                                              imgData is String) {
                                            b64Images.add(imgData);
                                          }
                                        }

                                        // Fallback to businessImages array if it exists
                                        if (_selectedBusiness!['businessImages'] !=
                                                null &&
                                            _selectedBusiness!['businessImages']
                                                is List) {
                                          for (var img
                                              in _selectedBusiness!['businessImages']) {
                                            if (img is String)
                                              b64Images.add(img);
                                          }
                                        }

                                        final List<ImageProvider>
                                        imageProviders = [];
                                        for (var imgStr in b64Images) {
                                          final isBase64 =
                                              imgStr.startsWith('data:image') ||
                                              !imgStr.startsWith('http');
                                          if (isBase64) {
                                            final base64Data =
                                                imgStr.contains(',')
                                                ? imgStr.split(',').last
                                                : imgStr;
                                            try {
                                              final cleanBase64 = base64Data
                                                  .replaceAll(
                                                    RegExp(r'\s+'),
                                                    '',
                                                  );
                                              imageProviders.add(
                                                MemoryImage(
                                                  base64Decode(cleanBase64),
                                                ),
                                              );
                                            } catch (e) {
                                              // Ignore
                                            }
                                          } else {
                                            imageProviders.add(
                                              NetworkImage(imgStr),
                                            );
                                          }
                                        }

                                        if (imageProviders.isEmpty)
                                          return const SizedBox();

                                        return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(height: 16),
                                            const Text(
                                              'Business Photos',
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            SizedBox(
                                              height: 80,
                                              child: ListView.builder(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                itemCount:
                                                    imageProviders.length,
                                                itemBuilder: (context, idx) {
                                                  final imageProvider =
                                                      imageProviders[idx];
                                                  return GestureDetector(
                                                    onTap: () => _showGallery(
                                                      context,
                                                      imageProviders,
                                                      idx,
                                                    ),
                                                    child: Container(
                                                      margin:
                                                          const EdgeInsets.only(
                                                            right: 8,
                                                          ),
                                                      width: 80,
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12,
                                                            ),
                                                        color: isDark
                                                            ? Colors
                                                                  .grey
                                                                  .shade800
                                                            : Colors
                                                                  .grey
                                                                  .shade200,
                                                        image: DecorationImage(
                                                          image: imageProvider,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                    if ((_isSuperAdmin || _isHeadRole) && _selectedBusiness!['latLng'] != null)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 16),
                                        child: SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton.icon(
                                            onPressed: () async {
                                              final LatLng pos = _selectedBusiness!['latLng'];
                                              final url = Uri.parse("https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=${pos.latitude},${pos.longitude}");
                                              if (await canLaunchUrl(url)) {
                                                await launchUrl(url, mode: LaunchMode.externalApplication);
                                              }
                                            },
                                            icon: const Icon(Icons.streetview),
                                            label: const Text("Open in Street View"),
                                            style: ElevatedButton.styleFrom(
                                              padding: const EdgeInsets.symmetric(vertical: 12),
                                              backgroundColor: Colors.blue.shade800,
                                              foregroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                            ),
                                          ),
                                        ),
                                      ),
                                    if ((_isSuperAdmin || _isHeadRole) && _selectedBusiness!['latLng'] != null)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 8),
                                        child: SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton.icon(
                                            onPressed: _isFetchingRoute ? null : () {
                                              _fetchRoute(_selectedBusiness!['latLng']);
                                              setState(() => _isSheetVisible = false); // Hide sheet to see route
                                            },
                                            icon: _isFetchingRoute ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.directions),
                                            label: Text(_isFetchingRoute ? "Calculating..." : "Get Directions"),
                                            style: ElevatedButton.styleFrom(
                                              padding: const EdgeInsets.symmetric(vertical: 12),
                                              backgroundColor: Colors.green.shade700,
                                              foregroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ]
                            // ELSE SHOW WARD OVERVIEW & BUSINESS LIST
                            else if (_wardProperties != null) ...[
                              Text(
                                _wardProperties!['ward_name'] ??
                                    _wardProperties!['Ward_Name'] ??
                                    _wardProperties!['ward'] ??
                                    'Ward ${_wardProperties!['ward_id'] ?? 'Unknown'}',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Area: ${((_wardProperties!['area_sqm'] ?? 0) / 1000000).toStringAsFixed(2)} km² · LGD: ${_wardProperties!['lgd_code'] ?? 'N/A'}',
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.grey.shade400
                                      : Colors.grey.shade600,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: isDark
                                              ? Colors.grey.shade800
                                              : Colors.grey.shade200,
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Column(
                                        children: [
                                          Text(
                                            '${_businesses.length}',
                                            style: TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                              color:
                                                  theme.colorScheme.onSurface,
                                            ),
                                          ),
                                          Text(
                                            'Businesses',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: isDark
                                                  ? Colors.grey.shade400
                                                  : Colors.grey.shade600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              if (_businesses.isNotEmpty) ...[
                                Text(
                                  'Businesses in Ward',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? Colors.grey.shade400
                                        : Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  height: 160,
                                  child: ListView.builder(
                                    itemCount: _businesses.length,
                                    padding: EdgeInsets.zero,
                                    itemBuilder: (context, index) {
                                      final b = _businesses[index];
                                      return ListTile(
                                        contentPadding: EdgeInsets.zero,
                                        dense: true,
                                        leading: CircleAvatar(
                                          backgroundColor: isDark
                                              ? Colors.blue.withOpacity(0.2)
                                              : Colors.blue.shade50,
                                          child: Icon(
                                            Icons.storefront_rounded,
                                            size: 18,
                                            color: isDark
                                                ? Colors.blue.shade300
                                                : Colors.blue.shade700,
                                          ),
                                        ),
                                        title: Text(
                                          b['businessName']
                                                      ?.toString()
                                                      .isNotEmpty ==
                                                  true
                                              ? b['businessName']
                                              : 'Unnamed Business',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                            color: theme.colorScheme.onSurface,
                                          ),
                                        ),
                                        subtitle: Text(
                                          '${b['ownerName'] ?? 'Unknown'} · ${b['mobile'] ?? ''}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: isDark
                                                ? Colors.grey.shade400
                                                : Colors.grey.shade600,
                                          ),
                                        ),
                                        onTap: () {
                                          setState(() => _selectedBusiness = b);
                                          _mapController.move(
                                            b['latLng'],
                                            18.0,
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ],

                            // DEFAULT EMPTY STATE
                            if (_wardProperties == null &&
                                _businesses.isEmpty &&
                                _searchError == null)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 32,
                                ),
                                child: Center(
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.search_rounded,
                                        size: 48,
                                        color: isDark
                                            ? Colors.grey.shade700
                                            : Colors.grey.shade300,
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        'Search for a ward to view map data.',
                                        style: TextStyle(
                                          color: isDark
                                              ? Colors.grey.shade400
                                              : Colors.grey.shade500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(
            icon,
            size: 14,
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
          ),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getBusinessIcon(Map<String, dynamic> b) {
    final raw = (b['user']?['position']?['assignmentType'] ?? b['role'] ?? b['type'] ?? 'member').toString().toLowerCase().replaceAll(' ', '_');
    if (raw.contains('super_admin')) return Icons.admin_panel_settings;
    if (raw.contains('district') || raw.contains('state')) return Icons.account_balance;
    if (raw.contains('taluk')) return Icons.location_city;
    if (raw.contains('ward')) return Icons.local_police;
    if (raw.contains('circle') || raw.contains('president')) return Icons.groups;
    if (raw.contains('assembly')) return Icons.how_to_reg;
    if (raw.contains('business')) return Icons.storefront;
    return Icons.person;
  }

  Color _getBusinessColor(Map<String, dynamic> b, bool isSelected) {
    if (isSelected) return const Color(0xFF2563EB); // Blue for selected
    final raw = (b['user']?['position']?['assignmentType'] ?? b['role'] ?? b['type'] ?? 'member').toString().toLowerCase().replaceAll(' ', '_');
    if (raw.contains('super_admin')) return const Color(0xFF7B3FA0);
    if (raw.contains('district') || raw.contains('state') || raw.contains('taluk')) return const Color(0xFFC8962A);
    if (raw.contains('ward')) return const Color(0xFFA08828);
    if (raw.contains('circle') || raw.contains('president')) return const Color(0xFF1E7EC8);
    if (raw.contains('assembly')) return const Color(0xFF2E8B3A);
    return const Color(0xFFB5730B); // Default gold/amber
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        actions: const [ThemeToggleButton()],
        elevation: 0,
        backgroundColor: theme.colorScheme.surface,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Member Map",
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoadingProfile
          ? const Center(child: CircularProgressIndicator())
          : (!_isWardUpdated && !_hasPrivilegedRole)
          ? _buildEmptyState()
          : Stack(
              children: [
                Positioned.fill(child: _buildLiveMap()),
                _buildSearchBar(),
                _buildAreaFilters(),
                if (_isMeasurementMode && _totalDistance > 0)
                  Positioned(
                    top: 100,
                    left: 20,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade900.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "Total Distance: ${(_totalDistance / 1000).toStringAsFixed(2)} km",
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                if (_routePoints.isNotEmpty)
                  Positioned(
                    top: 100,
                    left: 20,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.shade900.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Route: ${_routeDistance.toStringAsFixed(1)} km",
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                              Text(
                                "Est. Time: $_routeDuration mins",
                                style: const TextStyle(color: Colors.white70, fontSize: 13),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () {
                              setState(() {
                                _routePoints.clear();
                                _routeDistance = 0.0;
                                _routeDuration = "";
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                Positioned(
                  top: 150, // Below area filters
                  right: 16,
                  child: Column(
                    children: [
                      FloatingActionButton(
                        heroTag: 'btn_map_type_map',
                        mini: true,
                        backgroundColor: Theme.of(context).colorScheme.surface,
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (ctx) {
                              return SafeArea(
                                child: Wrap(
                                  children: [
                                    ListTile(
                                      leading: const Icon(Icons.map),
                                      title: const Text('Default'),
                                      onTap: () {
                                        setState(() => _mapType = 'm');
                                        Navigator.pop(ctx);
                                      },
                                    ),
                                    ListTile(
                                      leading: const Icon(Icons.satellite),
                                      title: const Text('Satellite'),
                                      onTap: () {
                                        setState(() => _mapType = 's');
                                        Navigator.pop(ctx);
                                      },
                                    ),
                                    ListTile(
                                      leading: const Icon(Icons.terrain),
                                      title: const Text('Terrain'),
                                      onTap: () {
                                        setState(() => _mapType = 'p');
                                        Navigator.pop(ctx);
                                      },
                                    ),
                                    ListTile(
                                      leading: const Icon(Icons.traffic),
                                      title: const Text('Live Traffic'),
                                      trailing: Switch(
                                        value: _showTraffic,
                                        onChanged: (val) {
                                          setState(() => _showTraffic = val);
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                        child: Icon(Icons.layers, color: Theme.of(context).colorScheme.onSurface),
                      ),
                      const SizedBox(height: 16),
                      FloatingActionButton(
                        heroTag: 'btn_location_map',
                        mini: true,
                        backgroundColor: Theme.of(context).colorScheme.surface,
                        onPressed: () async {
                          if (_currentPosition != null) {
                            _mapController.move(
                              LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                              15.0,
                            );
                          } else {
                            await _fetchLiveLocation();
                            if (_currentPosition != null) {
                              _mapController.move(
                                LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                                15.0,
                              );
                            }
                          }
                        },
                        child: Icon(Icons.my_location, color: Theme.of(context).colorScheme.onSurface),
                      ),
                    ],
                  ),
                ),
                _buildBottomSheet(),
              ],
            ),
    );
  }

  Widget _buildMapToolsToolbar() {
    if (!_isSuperAdmin && !_isHeadRole) return const SizedBox.shrink();
    return Positioned(
      top: 270,
      right: 16,
      child: Column(
        children: [
          FloatingActionButton(
            heroTag: 'btn_measure_tool',
            mini: true,
            backgroundColor: _isMeasurementMode ? Colors.blue : Theme.of(context).colorScheme.surface,
            onPressed: () {
              setState(() {
                _isMeasurementMode = !_isMeasurementMode;
                if (_isMeasurementMode) {
                  _isDrawMode = false;
                  _toolPoints.clear();
                  _totalDistance = 0.0;
                } else {
                  _toolPoints.clear();
                }
              });
            },
            child: Icon(Icons.straighten, color: _isMeasurementMode ? Colors.white : Theme.of(context).colorScheme.onSurface),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'btn_draw_tool',
            mini: true,
            backgroundColor: _isDrawMode ? Colors.green : Theme.of(context).colorScheme.surface,
            onPressed: () {
              setState(() {
                _isDrawMode = !_isDrawMode;
                if (_isDrawMode) {
                  _isMeasurementMode = false;
                  _toolPoints.clear();
                } else {
                  _toolPoints.clear();
                }
              });
            },
            child: Icon(Icons.draw, color: _isDrawMode ? Colors.white : Theme.of(context).colorScheme.onSurface),
          ),
          if (_toolPoints.isNotEmpty && (_isMeasurementMode || _isDrawMode)) ...[
            const SizedBox(height: 16),
            FloatingActionButton(
              heroTag: 'btn_clear_tool',
              mini: true,
              backgroundColor: Colors.red,
              onPressed: () {
                setState(() {
                  _toolPoints.clear();
                  _totalDistance = 0.0;
                });
              },
              child: const Icon(Icons.clear, color: Colors.white),
            ),
          ]
        ],
      ),
    );
  }

  void _showGallery(
    BuildContext context,
    List<ImageProvider> images,
    int initialIndex,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.zero,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Container(color: Colors.black.withOpacity(0.9)),
              PageView.builder(
                itemCount: images.length,
                controller: PageController(initialPage: initialIndex),
                itemBuilder: (context, index) {
                  return InteractiveViewer(
                    minScale: 0.5,
                    maxScale: 4.0,
                    child: Image(image: images[index], fit: BoxFit.contain),
                  );
                },
              ),
              Positioned(
                top: 40,
                right: 20,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
