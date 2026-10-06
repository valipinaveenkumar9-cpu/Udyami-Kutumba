const fs = require('fs');
let text = fs.readFileSync('lib/features/dashboard/presentation/dashboard_screen.dart', 'utf-8');

const regex = /if \(source != null\) \{[\s\S]*?\} catch \(\_\) \{\}/;

const replacement = `if (source != null) {
                // Try to extract from nested objects first
                if (wardId == null) {
                  wardId = source['ward']?['_id']?.toString() ?? source['ward']?['wardId']?.toString();
                }
                if (_wardName.isEmpty) {
                  _wardName = source['ward']?['wardName']?.toString() ?? source['wardName']?.toString() ?? '';
                }
                
                if (talukaId == null) {
                  talukaId = source['taluka']?['_id']?.toString() ?? source['taluka']?['talukaId']?.toString() ?? source['ward']?['talukaId']?.toString();
                }
                if (_talukaName.isEmpty) {
                  _talukaName = source['taluka']?['talukaName']?.toString() ?? source['ward']?['talukaName']?.toString() ?? source['talukaName']?.toString() ?? '';
                }
                
                if (districtId == null) {
                  districtId = source['district']?['_id']?.toString() ?? source['district']?['districtId']?.toString() ?? source['ward']?['districtId']?.toString();
                }
                if (_districtName.isEmpty) {
                  _districtName = source['district']?['districtName']?.toString() ?? source['ward']?['districtName']?.toString() ?? source['districtName']?.toString() ?? '';
                }
              }
            }
          } catch (_) {}`;

text = text.replace(regex, replacement);

// Also remove the escaped variables in the debug print so they actually interpolate
text = text.replace(/DEBUG: Resolved Location -> Ward: \\\$_wardName \(\\\$wardId\), Taluka: \\\$_talukaName \(\\\$talukaId\), District: \\\$_districtName \(\\\$districtId\)/g, 
  "DEBUG: Resolved Location -> Ward: $_wardName ($wardId), Taluka: $_talukaName ($talukaId), District: $_districtName ($districtId)");

text = text.replace(/DEBUG: \[Taluka Head\] Triggering APIs for Taluka: \\\$_talukaName \(ID: \\\$talukaId\)/g, 
  "DEBUG: [Taluka Head] Triggering APIs for Taluka: ${_talukaName} (ID: ${talukaId})");

text = text.replace(/DEBUG: \[Ward Chairman\] Triggering APIs for Ward: \\\$_wardName \(ID: \\\$wardId\)/g, 
  "DEBUG: [Ward Chairman] Triggering APIs for Ward: ${_wardName} (ID: ${wardId})");

text = text.replace(/DEBUG: \[District Head\] Triggering APIs for District: \\\$_districtName \(ID: \\\$districtId\)/g, 
  "DEBUG: [District Head] Triggering APIs for District: ${_districtName} (ID: ${districtId})");


fs.writeFileSync('lib/features/dashboard/presentation/dashboard_screen.dart', text, 'utf-8');
