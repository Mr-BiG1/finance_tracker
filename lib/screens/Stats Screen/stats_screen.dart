import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class StatsScreen extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Transaction Stats"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    _firestore
                        .collection('transactions')
                        .where('userId', isEqualTo: _auth.currentUser?.uid)
                        .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  var transactions = snapshot.data!.docs;
                  var groupedData = _groupTransactionsByDay(transactions);
                  var sortedDays = groupedData.keys.toList()..sort();

                  if (sortedDays.isEmpty) {
                    return const Center(child: Text("No transaction data."));
                  }

                  double maxTransactionAmount = _getMaxYValue(groupedData);

                  final dateRangeText = _getDateRangeText(sortedDays);

                  return Column(
                    children: [
                      Text(
                        dateRangeText,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            maxY: maxTransactionAmount + 500,
                            barGroups: _getBarGroups(groupedData, sortedDays),
                            titlesData: _getTitles(sortedDays),
                            borderData: FlBorderData(show: false),
                            gridData: FlGridData(show: false),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<int, Map<String, double>> _groupTransactionsByDay(
    List<QueryDocumentSnapshot> transactions,
  ) {
    Map<int, Map<String, double>> groupedData = {};

    for (var transaction in transactions) {
      var data = transaction.data() as Map<String, dynamic>;

      DateTime date =
          (data['date'] is Timestamp)
              ? (data['date'] as Timestamp).toDate()
              : DateTime.parse(data['date']);

      int day = date.day;
      String category = data['category'] ?? "Other";
      double amount = (data['amount'] ?? 0).toDouble();

      groupedData.putIfAbsent(day, () => {});
      groupedData[day]!.update(
        category,
        (value) => value + amount,
        ifAbsent: () => amount,
      );
    }

    return groupedData;
  }

  double _getMaxYValue(Map<int, Map<String, double>> groupedData) {
    double maxValue = 0;
    for (var dayData in groupedData.values) {
      double total = dayData.values.fold(0, (sum, val) => sum + val);
      if (total > maxValue) {
        maxValue = total;
      }
    }
    return maxValue;
  }

  List<BarChartGroupData> _getBarGroups(
    Map<int, Map<String, double>> groupedData,
    List<int> sortedDays,
  ) {
    List<Color> colors = [
      Colors.orange,
      Colors.green,
      Colors.purple,
      Colors.blueGrey,
    ];

    return List.generate(sortedDays.length, (index) {
      int day = sortedDays[index];
      final dayData = groupedData[day]!;
      double previousHeight = 0;

      return BarChartGroupData(
        x: index,
        barRods: List.generate(dayData.length, (i) {
          double current = dayData.values.elementAt(i);
          double start = previousHeight;
          previousHeight += current;

          return BarChartRodData(
            fromY: start,
            toY: previousHeight,
            color: colors[i % colors.length],
            width: 12,
          );
        }),
      );
    });
  }

  FlTitlesData _getTitles(List<int> sortedDays) {
    return FlTitlesData(
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 40,
          getTitlesWidget: (value, _) {
            if (value % 1000 == 0) {
              return Text(
                "\$ ${(value / 1000).toInt()}K",
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (value, _) {
            int index = value.toInt();
            if (index >= 0 && index < sortedDays.length) {
              final now = DateTime.now();
              final date = DateTime(now.year, now.month, sortedDays[index]);
              return Text(
                "${_getMonthAbbreviation(date.month)} ${date.day}",
                style: const TextStyle(color: Colors.grey, fontSize: 11),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );
  }

  String _getDateRangeText(List<int> sortedDays) {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, sortedDays.first);
    final end = DateTime(now.year, now.month, sortedDays.last);

    return "Transactions from ${_getMonthAbbreviation(start.month)} ${start.day} to ${_getMonthAbbreviation(end.month)} ${end.day}";
  }

  String _getMonthAbbreviation(int month) {
    const months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];
    return months[month - 1];
  }
}
