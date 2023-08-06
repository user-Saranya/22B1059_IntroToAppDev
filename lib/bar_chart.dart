import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'expenses.dart';

class BarChartPage extends StatelessWidget {
  final List<ExpenseCategory> categories;

  const BarChartPage({Key? key, required this.categories}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Expense Bar Chart'),
        ),
        body: const Center(
          child: Text('Not enough data points for bar chart.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Bar Chart'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: 100,
              titlesData: FlTitlesData(
                leftTitles: SideTitles(showTitles: true),
                bottomTitles: SideTitles(
                  showTitles: true,
                  getTextStyles: (context, value) {
                    return const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    );
                  },
                  getTitles: (value) {
                    if (value >= 0 && value < categories.length) {
                      return categories[value.toInt()].name;
                    }
                    return '';
                  },
                ),
              ),
              borderData: FlBorderData(
                show: true,
                border: const Border(
                  bottom: BorderSide(
                    color: Colors.black,
                    width: 2,
                  ),
                ),
              ),
              barGroups: categories.asMap().entries.map((entry) {
                final index = entry.key;
                final category = entry.value;
                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      y: category.percentage,
                      colors: [Colors.deepPurpleAccent[100]!],
                    ),
                  ],
                );
              }).toList(),
              groupsSpace: 20,
            ),
          ),
        ),
      ),
    );
  }
}



