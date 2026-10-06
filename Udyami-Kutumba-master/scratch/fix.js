const fs = require('fs');
let text = fs.readFileSync('lib/features/dashboard/presentation/dashboard_screen.dart', 'utf-8');

text = text.replace(/'.*?Prime.*?Basic.*?Free'/g, "' Prime ·  Basic ·  Free'");
text = text.replace(/'.*?Prime.*?Basic'/g, "' Prime ·  Basic'");
text = text.replace(/'.*?\/\s*Active'/g, "' /  Active'");
text = text.replace(/'.*?active chairmen'/g, "' active chairmen'");
text = text.replace(/'.*?active CPs across wards'/g, "' active CPs across wards'");
text = text.replace(/'.*?Active.*?0 Chairmen Vacant'/g, "' Active · 0 Chairmen Vacant'");

// Clean up any accidentally prepended primeCount from earlier powershell errors
text = text.replace(/primeCount Prime · import/g, 'import');

fs.writeFileSync('lib/features/dashboard/presentation/dashboard_screen.dart', text, 'utf-8');
