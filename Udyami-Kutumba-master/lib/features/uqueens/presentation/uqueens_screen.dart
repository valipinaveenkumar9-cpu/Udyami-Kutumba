import 'package:flutter/material.dart';

class UQueensScreen extends StatefulWidget {
  const UQueensScreen({super.key});

  @override
  State<UQueensScreen> createState() => _UQueensScreenState();
}

class _UQueensScreenState extends State<UQueensScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.black : Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: OrientationBuilder(
          builder: (context, orientation) {
            final isLandscape = orientation == Orientation.landscape;

            final iconWidget = Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.teal.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.account_balance_wallet_rounded, 
                size: 80, 
                color: Colors.teal,
              ),
            );

            final textContent = Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: isLandscape ? CrossAxisAlignment.start : CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'uQueens Dashboard',
                  style: TextStyle(
                    fontSize: 26, 
                    fontWeight: FontWeight.bold, 
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xff0D1B4C),
                  ),
                  textAlign: isLandscape ? TextAlign.left : TextAlign.center,
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? Colors.transparent : Colors.grey.shade100, width: 1.5),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.rocket_launch, color: Colors.orange, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'COMING SOON',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'New financial features are on the way!',
                  style: TextStyle(
                    fontSize: 16, 
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                  textAlign: isLandscape ? TextAlign.left : TextAlign.center,
                ),
              ],
            );

            return Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: isLandscape
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            iconWidget,
                            const SizedBox(width: 48),
                            Expanded(child: textContent),
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            iconWidget,
                            const SizedBox(height: 32),
                            textContent,
                          ],
                        ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
