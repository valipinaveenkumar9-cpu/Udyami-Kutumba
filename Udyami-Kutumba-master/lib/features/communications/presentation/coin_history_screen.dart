import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../viewmodels/communications_viewmodel.dart';
import '../models/campaign.dart';
import 'package:udyamikutumba/core/widgets/theme_toggle_button.dart';

class CoinHistoryScreen extends StatelessWidget {
  final CommunicationsViewModel viewModel;

  const CoinHistoryScreen({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.brightness == Brightness.dark ? Colors.black : theme.colorScheme.surface,
      appBar: AppBar(
            actions: const [ThemeToggleButton()],
            backgroundColor: theme.brightness == Brightness.dark ? Colors.black : theme.colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
        titleSpacing: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Coin History",
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 2),
          ListenableBuilder(
            listenable: viewModel,
            builder: (context, _) {
              final balance = viewModel.wallet?.coins ?? 0;
              final formatter = NumberFormat('#,##0');
              return Text(
                "Balance ${formatter.format(balance)}",
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              );
            },
          ),
          ],
        ),
      ),
      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) {
          // 1. Get Campaign Deductions
          final campaignsWithDeductions = viewModel.campaignHistory
              .where((c) => c.coinsSpent > 0)
              .toList();

          // 2. Format them into a generic transaction object
          final List<Map<String, dynamic>> allTransactions = [];

          for (var c in campaignsWithDeductions) {
            DateTime? date;
            try {
              // Try to parse the submittedDate or fallback
              date = DateTime.tryParse(c.submittedDate);
            } catch (_) {}
            
            allTransactions.add({
              'title': "${c.title} · ${c.channel}",
              'subtitle': "${c.submittedDate.split('T').first} · Campaign",
              'amount': c.coinsSpent,
              'isCredit': false,
              'date': date ?? DateTime.now(), // fallback for sorting
            });
          }

          // 3. Add Recharges
          for (var r in viewModel.localRecharges) {
            DateTime? date;
            String dateString = 'Recently';
            try {
              date = DateTime.parse(r['date']);
              dateString = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
            } catch (_) {}
            
            allTransactions.add({
              'title': r['title'] ?? 'Coin pack — Recharge',
              'subtitle': "$dateString · Recharge",
              'amount': r['amount'] ?? 0,
              'isCredit': true,
              'date': date ?? DateTime.now(),
            });
          }

          // 4. Sort by date descending
          allTransactions.sort((a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));

          if (allTransactions.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Text(
                  "No transaction history found.\nHistory will appear here when you run campaigns or recharge.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: allTransactions.length,
            itemBuilder: (context, index) {
              final tx = allTransactions[index];
              final formatter = NumberFormat('#,##0');
              final amountStr = tx['isCredit'] 
                  ? "+${formatter.format(tx['amount'])}" 
                  : "-${formatter.format(tx['amount'])}";
              
              return CoinHistoryTile(
                title: tx['title'],
                subtitle: tx['subtitle'],
                amount: amountStr,
                isCredit: tx['isCredit'],
              );
            },
          );
        },
      ),
    );
  }
}

class CoinHistoryTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String amount;
  final bool isCredit;

  const CoinHistoryTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.isCredit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final MaterialColor color = isCredit ? Colors.green : Colors.red;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? Colors.transparent : Colors.grey.shade100),
        boxShadow: [
          BoxShadow(color: Theme.of(context).brightness == Brightness.dark ? Colors.transparent : Colors.grey.shade100,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.shade50,
            shape: BoxShape.circle,
          ),
          child: Icon(
            isCredit ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
            color: color.shade700,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            subtitle,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ),
        trailing: Text(
          amount,
          style: TextStyle(
            color: color.shade700,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
