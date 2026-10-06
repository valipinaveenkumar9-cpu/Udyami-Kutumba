const fs = require('fs');
let text = fs.readFileSync('lib/features/ward/presentation/ward_screen.dart', 'utf-8');

const regex = /if \(member\.companyName != null && member\.companyName!\.isNotEmpty\) \.\.\.\[[\s\S]*?\]\,/g;

text = text.replace(regex, `if (member.companyName != null && member.companyName!.isNotEmpty) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: member.companyName == 'Prime' ? Colors.orange.withValues(alpha: 0.1) : (member.companyName == 'Patron' ? Colors.purple.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1)),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                member.companyName!,
                                style: TextStyle(
                                  color: member.companyName == 'Prime' ? Colors.orange : (member.companyName == 'Patron' ? Colors.purple : Colors.grey),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],`);

fs.writeFileSync('lib/features/ward/presentation/ward_screen.dart', text, 'utf-8');
