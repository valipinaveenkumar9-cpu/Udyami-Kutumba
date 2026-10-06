class LayoutCalculator {
  /// Calculates the total layout cards/slots based on the layout configuration.
  /// Mirrors the logic in calculateTotalLayoutCards from the web.
  static int calculateTotalLayoutCards(dynamic configObj, {int wardLength = 9}) {
    if (configObj == null || configObj is! Map) return 103;

    final config = configObj as Map<dynamic, dynamic>;
    final slotCounts = config['slotCounts'] is Map ? (config['slotCounts'] as Map<dynamic, dynamic>) : {};
    
    int mlaCount = 1;
    int patronsCount = _parseInt(slotCounts['patrons'], 10);
    int officialsCount = _parseInt(slotCounts['officials'], 4);
    int chairmanCount = 1;
    int totalChairmenCount = wardLength;
    int advisoriesCount = _parseInt(slotCounts['advisories'], 3);
    int mentorsCount = _parseInt(slotCounts['mentors'], 2);
    int coreRolesCount = 4;
    
    int sectorsCount = 0;
    if (config['sectors'] is List) {
      for (var s in (config['sectors'] as List)) {
        if (s is Map && s['enabled'] != false) {
          sectorsCount++;
        }
      }
    }
    
    int umsCount = 0;
    if (config['umsRoles'] is List) {
      for (var u in (config['umsRoles'] as List)) {
        if (u is Map && u['enabled'] != false) {
          umsCount++;
        }
      }
    }
    
    int totalBrandProductCards = 0;
    if (config['brandTiles'] is List && (config['brandTiles'] as List).isNotEmpty) {
      final categoryMap = {
        "ub-queens": "udyamiQueens",
        "ub-realty": "ubRealtyConstruction",
        "yuva-udyami": "yuvaUdyami",
        "ec": "ec",
        "ub-finance-it": "ubFinanceIT",
        "ub-social": "ubSocialBrand",
      };
      
      for (var cat in (config['brandTiles'] as List)) {
        if (cat is! Map) continue;
        
        final key = cat['key']?.toString();
        final countKey = categoryMap[key];
        
        int slotCount = 0;
        if (countKey != null) {
          slotCount = _parseInt(slotCounts[countKey], 0);
        }
        
        int enabledProducts = 0;
        if (cat['products'] is List) {
          for (var p in (cat['products'] as List)) {
            if (p is Map && p['enabled'] != false) {
              enabledProducts++;
            }
          }
        }
        
        totalBrandProductCards += (slotCount > enabledProducts ? slotCount : enabledProducts);
      }
    } else {
      totalBrandProductCards += _parseInt(slotCounts['udyamiQueens'], 20);
      totalBrandProductCards += _parseInt(slotCounts['ubRealtyConstruction'], 5);
      totalBrandProductCards += _parseInt(slotCounts['yuvaUdyami'], 5);
      totalBrandProductCards += _parseInt(slotCounts['ec'], 5);
      totalBrandProductCards += _parseInt(slotCounts['ubFinanceIT'], 5);
      totalBrandProductCards += _parseInt(slotCounts['ubSocialBrand'], 5);
    }
    
    return mlaCount + patronsCount + officialsCount + chairmanCount + totalChairmenCount + advisoriesCount + mentorsCount + coreRolesCount + sectorsCount + umsCount + totalBrandProductCards;
  }
  
  static int _parseInt(dynamic value, int defaultValue) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    final parsed = int.tryParse(value.toString());
    return parsed ?? defaultValue;
  }
}
