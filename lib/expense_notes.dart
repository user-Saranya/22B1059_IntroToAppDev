import 'package:flutter/material.dart';
import 'expenses.dart';

class ExpenseNotesPage extends StatelessWidget {
  final List<Expenses> expenses;

  const ExpenseNotesPage({super.key, required this.expenses});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Notes'),
      ),
      body: ListView.builder(
        itemCount: expenses.length,
        itemBuilder: (context, index) {
          if (expenses[index].notes.isNotEmpty) {
            return ListTile(
              title: Text(expenses[index].name),
              subtitle: Text(expenses[index].notes),
            );
          } else {
            return Container();
          }
        },
      ),
    );
  }
}
