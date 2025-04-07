import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class StatsScreen extends StatefulWidget {
  @override
  _StatsScreenState createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _selectedTimeframe = 'Month';
  String _selectedChartType = 'Bar'; // 'Bar', 'Line', 'Pie'

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Financial Insights"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildTimeframeSelector(),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    _firestore
                        .collection('transactions')
                        .where('userId', isEqualTo: _auth.currentUser?.uid)
                        .orderBy('date', descending: true)
                        .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return _buildEmptyState();
                  }

                  var transactions = snapshot.data!.docs;
                  var groupedData = _groupTransactions(transactions);
                  var sortedKeys = groupedData.keys.toList()..sort();

                  if (sortedKeys.isEmpty) {
                    return _buildEmptyState();
                  }

                  return Column(
                    children: [
                      _buildSummaryCards(groupedData),
                      const SizedBox(height: 16),
                      Expanded(
                        child:
                            _selectedChartType == 'Bar'
                                ? _buildBarChart(groupedData, sortedKeys)
                                : _selectedChartType == 'Line'
                                ? _buildLineChart(groupedData, sortedKeys)
                                : _buildPieChart(groupedData),
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

  Widget _buildTimeframeSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildTimeframeButton('Week'),
        _buildTimeframeButton('Month'),
        _buildTimeframeButton('Year'),
      ],
    );
  }

  Widget _buildTimeframeButton(String timeframe) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        foregroundColor:
            _selectedTimeframe == timeframe ? Colors.white : Colors.black,
        backgroundColor:
            _selectedTimeframe == timeframe
                ? Theme.of(context).colorScheme.primary
                : Colors.grey[200],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      onPressed: () => setState(() => _selectedTimeframe = timeframe),
      child: Text(timeframe),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.analytics_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            "No transaction data available",
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            "Add transactions to see insights",
            style: TextStyle(color: Colors.grey[400], fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(Map<DateTime, Map<String, double>> groupedData) {
    double totalSpent = groupedData.values.fold(
      0,
      (sum, dayData) =>
          sum + dayData.values.fold(0, (daySum, amount) => daySum + amount),
    );

    String topCategory = '';
    double topCategoryAmount = 0;

    Map<String, double> categoryTotals = {};
    groupedData.values.forEach((dayData) {
      dayData.forEach((category, amount) {
        categoryTotals.update(
          category,
          (value) => value + amount,
          ifAbsent: () => amount,
        );
      });
    });

    if (categoryTotals.isNotEmpty) {
      var sortedCategories =
          categoryTotals.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));
      topCategory = sortedCategories.first.key;
      topCategoryAmount = sortedCategories.first.value;
    }

    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            "Total",
            "\$${totalSpent.toStringAsFixed(2)}",
            Icons.attach_money,
            Colors.blue[100]!,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildSummaryCard(
            "Top Category",
            topCategory.isNotEmpty
                ? "$topCategory\n\$${topCategoryAmount.toStringAsFixed(2)}"
                : "N/A",
            Icons.category,
            Colors.green[100]!,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 16),
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChart(
    Map<DateTime, Map<String, double>> groupedData,
    List<DateTime> sortedKeys,
  ) {
    double maxY = _getMaxYValue(groupedData);

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY + (maxY * 0.2), // Add 20% padding
        barGroups: _getBarGroups(groupedData, sortedKeys),
        titlesData: _getTitles(sortedKeys),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine:
              (value) => FlLine(color: Colors.grey[200], strokeWidth: 1),
        ),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            tooltipRoundedRadius: 8,
            tooltipPadding: const EdgeInsets.all(8),
            tooltipMargin: 8,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final date = sortedKeys[group.x.toInt()];
              final category = groupedData[date]!.keys.elementAt(rodIndex);
              final amount = rod.toY - rod.fromY;

              return BarTooltipItem(
                "$category\n\$${amount.toStringAsFixed(2)}",
                TextStyle(
                  color: rod.color ?? Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLineChart(
    Map<DateTime, Map<String, double>> groupedData,
    List<DateTime> sortedKeys,
  ) {
    double maxY = _getMaxYValue(groupedData);
    List<Color> colors = [
      Colors.orange,
      Colors.green,
      Colors.purple,
      Colors.blue,
    ];

    Map<String, List<FlSpot>> categorySpots = {};

    // Prepare data for line chart
    for (int i = 0; i < sortedKeys.length; i++) {
      DateTime date = sortedKeys[i];
      groupedData[date]!.forEach((category, amount) {
        categorySpots.putIfAbsent(category, () => []);
        categorySpots[category]!.add(FlSpot(i.toDouble(), amount));
      });
    }

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: sortedKeys.length > 1 ? (sortedKeys.length - 1).toDouble() : 1,
        minY: 0,
        maxY: maxY + (maxY * 0.2),
        titlesData: _getTitles(sortedKeys),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine:
              (value) => FlLine(color: Colors.grey[200], strokeWidth: 1),
        ),
        lineBarsData:
            categorySpots.entries.map((entry) {
              int colorIndex =
                  categorySpots.keys.toList().indexOf(entry.key) %
                  colors.length;
              return LineChartBarData(
                spots: entry.value,
                isCurved: true,
                color: colors[colorIndex],
                barWidth: 2,
                isStrokeCapRound: true,
                dotData: FlDotData(show: false),
                belowBarData: BarAreaData(show: false),
              );
            }).toList(),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (List<LineBarSpot> touchedSpots) {
              return touchedSpots.map((spot) {
                final date = sortedKeys[spot.x.toInt()];
                final category = categorySpots.keys.elementAt(spot.barIndex);
                return LineTooltipItem(
                  "${_formatDate(date)}\n$category: \$${spot.y.toStringAsFixed(2)}",
                  TextStyle(color: spot.bar.color, fontWeight: FontWeight.bold),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPieChart(Map<DateTime, Map<String, double>> groupedData) {
    Map<String, double> categoryTotals = {};
    groupedData.values.forEach((dayData) {
      dayData.forEach((category, amount) {
        categoryTotals.update(
          category,
          (value) => value + amount,
          ifAbsent: () => amount,
        );
      });
    });

    if (categoryTotals.isEmpty) {
      return const Center(child: Text("No data available for pie chart"));
    }

    List<Color> colors = [
      Colors.orange,
      Colors.green,
      Colors.purple,
      Colors.blue,
      Colors.red,
      Colors.amber,
      Colors.cyan,
      Colors.deepOrange,
    ];

    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 40,
        sections:
            categoryTotals.entries.map((entry) {
              int index = categoryTotals.keys.toList().indexOf(entry.key);
              return PieChartSectionData(
                color: colors[index % colors.length],
                value: entry.value,
                title: "${entry.key}\n\$${entry.value.toStringAsFixed(2)}",
                radius: 20,
                titleStyle: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              );
            }).toList(),
      ),
    );
  }

  Map<DateTime, Map<String, double>> _groupTransactions(
    List<QueryDocumentSnapshot> transactions,
  ) {
    Map<DateTime, Map<String, double>> groupedData = {};

    for (var transaction in transactions) {
      var data = transaction.data() as Map<String, dynamic>;

      DateTime date =
          (data['date'] is Timestamp)
              ? (data['date'] as Timestamp).toDate()
              : DateTime.parse(data['date']);

      // Group by day, week or month based on selection
      DateTime groupKey;
      if (_selectedTimeframe == 'Week') {
        groupKey = DateTime(date.year, date.month, date.day - date.weekday + 1);
      } else if (_selectedTimeframe == 'Month') {
        groupKey = DateTime(date.year, date.month);
      } else {
        // Year
        groupKey = DateTime(date.year);
      }

      String category = data['category'] ?? "Other";
      double amount = (data['amount'] ?? 0).toDouble();

      groupedData.putIfAbsent(groupKey, () => {});
      groupedData[groupKey]!.update(
        category,
        (value) => value + amount,
        ifAbsent: () => amount,
      );
    }

    return groupedData;
  }

  double _getMaxYValue(Map<DateTime, Map<String, double>> groupedData) {
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
    Map<DateTime, Map<String, double>> groupedData,
    List<DateTime> sortedKeys,
  ) {
    List<Color> colors = [
      Colors.orange,
      Colors.green,
      Colors.purple,
      Colors.blue,
      Colors.red,
      Colors.amber,
    ];

    return List.generate(sortedKeys.length, (index) {
      DateTime date = sortedKeys[index];
      final dayData = groupedData[date]!;
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
            width: 16,
            borderRadius: BorderRadius.zero,
          );
        }),
      );
    });
  }

  FlTitlesData _getTitles(List<DateTime> sortedKeys) {
    return FlTitlesData(
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 40,
          getTitlesWidget: (value, _) {
            if (value % 500 == 0) {
              return Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Text(
                  "\$${value.toInt()}",
                  style: const TextStyle(color: Colors.grey, fontSize: 10),
                ),
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
            if (index >= 0 && index < sortedKeys.length) {
              DateTime date = sortedKeys[index];
              return Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  _formatDate(date),
                  style: const TextStyle(color: Colors.grey, fontSize: 10),
                ),
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

  String _formatDate(DateTime date) {
    if (_selectedTimeframe == 'Week') {
      return "Week ${date.day ~/ 7 + 1}";
    } else if (_selectedTimeframe == 'Month') {
      return "${_getMonthAbbreviation(date.month)} ${date.day}";
    } else {
      return _getMonthAbbreviation(date.month);
    }
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

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Chart Options"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Chart Type"),
              RadioListTile(
                title: const Text("Bar Chart"),
                value: 'Bar',
                groupValue: _selectedChartType,
                onChanged: (value) {
                  setState(() => _selectedChartType = value.toString());
                  Navigator.pop(context);
                },
              ),
              RadioListTile(
                title: const Text("Line Chart"),
                value: 'Line',
                groupValue: _selectedChartType,
                onChanged: (value) {
                  setState(() => _selectedChartType = value.toString());
                  Navigator.pop(context);
                },
              ),
              RadioListTile(
                title: const Text("Pie Chart"),
                value: 'Pie',
                groupValue: _selectedChartType,
                onChanged: (value) {
                  setState(() => _selectedChartType = value.toString());
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
