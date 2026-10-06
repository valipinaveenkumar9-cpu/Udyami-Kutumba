const fs = require('fs');
let text = fs.readFileSync('lib/features/ward/presentation/member_map_screen.dart', 'utf-8');

text = text.replace(/GeofenceScreen/g, 'MemberMapScreen');
text = text.replace(/_GeofenceScreenState/g, '_MemberMapScreenState');
text = text.replace("import 'package:udyamikutumba/core/widgets/theme_toggle_button.dart';", "import 'package:udyamikutumba/core/widgets/theme_toggle_button.dart';\nimport '../../../core/api/dashboard_api.dart';");

// Add state variables
const stateVars = `
  final DashboardAPI _dashboardAPI = DashboardAPI();
  
  String _filterType = 'ucn'; // 'ucn', 'members', 'heads'

  List<dynamic> _districtsList = [];
  List<dynamic> _talukasList = [];
  List<dynamic> _wardsList = [];

  String? _selectedDistrictId;
  String? _selectedDistrictName;
  
  String? _selectedTalukaId;
  String? _selectedTalukaName;
  
  String? _selectedWardId;
  String? _selectedWardName;
`;
text = text.replace('bool _isSheetVisible = true;', 'bool _isSheetVisible = true;\n' + stateVars);

fs.writeFileSync('lib/features/ward/presentation/member_map_screen.dart', text, 'utf-8');
