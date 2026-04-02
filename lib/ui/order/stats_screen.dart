import 'package:ct484_project/ui/shared/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../manager/order_manager.dart';
import '../../model/stats_period.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  StatsPeriod _period = StatsPeriod.day;
  DateTime _selectedDate = DateTime.now();

  /// --- FORMAT DATE HIỂN THỊ ---
  String get displayDate {
    switch (_period) {
      case StatsPeriod.day:
        return DateFormat('dd/MM/yyyy').format(_selectedDate);
      case StatsPeriod.month:
        return DateFormat('MM/yyyy').format(_selectedDate);
      case StatsPeriod.year:
        return DateFormat('yyyy').format(_selectedDate);
    }
  }

  /// --- CHART ---
  Widget buildChart(Map<String, int> data) {
    final entries = data.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final topEntries = entries.take(3).toList(); //  TOP 3

    return SizedBox(
      height: 260,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceEvenly,

          barGroups: List.generate(topEntries.length, (index) {
            final e = topEntries[index];

            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: e.value.toDouble(),
                  borderRadius: BorderRadius.circular(6),
                ),
              ],
            );
          }),

          titlesData: FlTitlesData(
            /// ===== TRỤC Y =====
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),

            /// ===== TÊN SẢN PHẨM (DƯỚI) =====
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 50,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= topEntries.length) {
                    return const SizedBox();
                  }

                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: SizedBox(
                      width: 90,
                      child: Text(
                        topEntries[index].key,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 10),
                      ),
                    ),
                  );
                },
              ),
            ),

            /// ===== SỐ LƯỢNG (TRÊN CỘT) =====
            topTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= topEntries.length) {
                    return const SizedBox();
                  }

                  return Text(
                    "${topEntries[index].value}", //  số lượng bán
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
            ),

            ///  TẮT TRỤC PHẢI
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    /// đảm bảo có data
    Future.microtask(() {
      context.read<OrderManager>().fetchOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final manager = context.watch<OrderManager>();
    final result = manager.getStats(
      period: _period,
      selectedDate: _selectedDate,
    );

    final currencyFormat = NumberFormat("#,##0", "vi_VN");

    /// SORT sản phẩm
    final sorted = result.productQuantity.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      appBar: AppBar(title: const Text("Thống kê"), centerTitle: true),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// PERIOD
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ChoiceChip(
                  label: const Text("Ngày"),
                  selected: _period == StatsPeriod.day,
                  onSelected: (_) {
                    setState(() => _period = StatsPeriod.day);
                  },
                ),
                ChoiceChip(
                  label: const Text("Tháng"),
                  selected: _period == StatsPeriod.month,
                  onSelected: (_) {
                    setState(() => _period = StatsPeriod.month);
                  },
                ),
                ChoiceChip(
                  label: const Text("Năm"),
                  selected: _period == StatsPeriod.year,
                  onSelected: (_) {
                    setState(() => _period = StatsPeriod.year);
                  },
                ),
              ],
            ),

            const SizedBox(height: 16),

            /// DATE PICKER
            GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2100),
                );

                if (picked != null) {
                  setState(() => _selectedDate = picked);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.brown.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Thời gian"),
                    Row(
                      children: [
                        Text(
                          displayDate,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.calendar_today, size: 18),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// REVENUE
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: ListTile(
                title: const Text("Tổng doanh thu"),
                trailing: Text(
                  "${currencyFormat.format(result.totalRevenue)} VNĐ",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.green,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// CHART
            if (result.productQuantity.isNotEmpty)
              Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: buildChart(result.productQuantity),
                ),
              ),

            const SizedBox(height: 16),

            /// TITLE
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Sản phẩm bán chạy",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown.shade700,
                ),
              ),
            ),

            const SizedBox(height: 10),

            /// LIST
            ListView.builder(
              itemCount: sorted.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final entry = sorted[index];

                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.brown.shade100,
                      child: Text("${index + 1}"),
                    ),
                    title: Text(entry.key),
                    trailing: Text(
                      "${entry.value}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
