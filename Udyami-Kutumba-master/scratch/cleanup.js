const fs = require('fs');
let text = fs.readFileSync('lib/features/ward/presentation/area_chart_screen.dart', 'utf-8');
text = text.replace("import 'package:printing/printing.dart';", "");
text = text.replace("import '../../../core/utils/ward_chart_pdf_generator.dart';", "");
text = text.replace("final WardAPI _wardAPI = WardAPI();", "");
fs.writeFileSync('lib/features/ward/presentation/area_chart_screen.dart', text, 'utf-8');
