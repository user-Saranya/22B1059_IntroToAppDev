import 'package:flutter/material.dart';
import 'expenses.dart';

class ExpenseHistoryPage extends StatefulWidget {
  final List<Expenses> expenses;

  ExpenseHistoryPage({required this.expenses});

  @override
  _ExpenseHistoryPageState createState() => _ExpenseHistoryPageState();
}

class _ExpenseHistoryPageState extends State<ExpenseHistoryPage> {
@override
Widget build(BuildContext context) {
  widget.expenses.sort((a, b) => a.date.compareTo(b.date));

  Map<String, List<ExpenseRecord>> expensesByDate = {};
  for (var expense in widget.expenses) {
    for (var record in expense.history) {
      final dateString = "${record.date.year}-${record.date.month}-${record.date.day}";
      expensesByDate[dateString] ??= [];
      expensesByDate[dateString]!.add(record);
    }
  }

  return Scaffold(
    appBar: AppBar(
      title: Text('Expense History'),
    ),
    body: ListView.builder(
      itemCount: expensesByDate.length,
      itemBuilder: (context, index) {
        final dateString = expensesByDate.keys.elementAt(index);
        final recordsOnDate = expensesByDate[dateString]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(dateString,
              style: TextStyle(
                fontSize: 15
              ),),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: recordsOnDate.length,
              itemBuilder: (context, index) {
                final record = recordsOnDate[index];
                final expense = widget.expenses.firstWhere((e) => e.id == record.expenseId);

                return ListTile(
                  title: Text(expense.name), // Display expense name instead of 'Expense ${index + 1}'
                  subtitle: Text('Price: ${record.price}'),
                );
              },
            ),
            Divider(),
          ],
        );
      },
    ),
  );
}
}

