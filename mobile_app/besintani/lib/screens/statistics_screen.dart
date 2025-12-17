import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../repositories/intake_repository.dart';
import '../models/daily_intake_list.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  String _selectedPeriod = '7 Gün';
  // Grafiklerde kullanılacak işlenmiş veri listesi
  List<_ChartData> _chartRecords = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStatistics('7 Gün');
  }

  Future<void> _loadStatistics(String period) async {
    setState(() => _isLoading = true);
    final repo = Provider.of<IntakeRepository>(context, listen: false);

    DateTime endDate = DateTime.now();
    DateTime startDate;

    if (period == '7 Gün') {
      startDate = endDate.subtract(const Duration(days: 6));
    } else if (period == '28 Gün') {
      startDate = endDate.subtract(const Duration(days: 27));
    } else {
      startDate = endDate.subtract(const Duration(days: 364));
    }

    final rawResults = await repo.getDailyIntakeRecords(
      DateFormat('yyyy-MM-dd').format(startDate),
      DateFormat('yyyy-MM-dd').format(endDate),
    );

    _processData(rawResults, period, startDate, endDate);
  }

  // Verileri grafik periyoduna göre gruplar
  void _processData(List<DailyIntakeList> raw, String period, DateTime start, DateTime end) {
    List<_ChartData> processed = [];

    if (period == '7 Gün') {
      // 7 Günlük: Günlük bazda gösterim
      for (int i = 0; i <= 6; i++) {
        DateTime date = start.add(Duration(days: i));
        String dateStr = DateFormat('yyyy-MM-dd').format(date);
        var record = raw.firstWhere((r) => r.date == dateStr, 
            orElse: () => DailyIntakeList(date: dateStr));
        
        processed.add(_ChartData(
          label: DateFormat('EEE', 'tr_TR').format(date), // Pzt, Sal...
          data: record,
        ));
      }
    } else if (period == '28 Gün') {
      // 28 Günlük: 4 Haftaya bölerek gösterim
      for (int i = 0; i < 4; i++) {
        double cal = 0, prot = 0, carb = 0, fat = 0, sug = 0, fib = 0;
        DateTime weekStart = start.add(Duration(days: i * 7));
        DateTime weekEnd = weekStart.add(const Duration(days: 6));

        for (var r in raw) {
          DateTime rDate = DateTime.parse(r.date);
          if (rDate.isAfter(weekStart.subtract(const Duration(seconds: 1))) && 
              rDate.isBefore(weekEnd.add(const Duration(seconds: 1)))) {
            cal += r.totalCalorie; prot += r.totalProtein; carb += r.totalCarb;
            fat += r.totalFat; sug += r.totalSugar; fib += r.totalFiber;
          }
        }
        processed.add(_ChartData(
          label: '${i + 1}. Hafta',
          data: DailyIntakeList(date: '', totalCalorie: cal, totalProtein: prot, 
              totalCarb: carb, totalFat: fat, totalSugar: sug, totalFiber: fib),
        ));
      }
    } else {
      for (int i = 11; i >= 0; i--) {
        // Bugünün tarihinden i kadar ay çıkarıyoruz (11 ay öncesinden başlayıp bugüne geliyoruz)
        DateTime targetMonthDate = DateTime(end.year, end.month - i, 1);
        int monthNum = targetMonthDate.month;
        int yearNum = targetMonthDate.year;

        double cal = 0, prot = 0, carb = 0, fat = 0, sug = 0, fib = 0;
      
        for (var r in raw) {
          DateTime rDate = DateTime.parse(r.date);
          if (rDate.month == monthNum && rDate.year == yearNum) {
            cal += r.totalCalorie; 
            prot += r.totalProtein; 
            carb += r.totalCarb;
            fat += r.totalFat; 
            sug += r.totalSugar; 
            fib += r.totalFiber;
          }
        }

        processed.add(_ChartData(
          label: _getMonthName(monthNum), // Oca, Şub vb.
          data: DailyIntakeList(
            date: '', 
            totalCalorie: cal, 
            totalProtein: prot, 
            totalCarb: carb, 
            totalFat: fat, 
            totalSugar: sug, 
            totalFiber: fib
          ),
        ));
      }
    }

    setState(() {
      _chartRecords = processed;
      _isLoading = false;
      _selectedPeriod = period;
    });
  }

  String _getMonthName(int month) {
    const months = ['Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz', 'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara'];
    return months[month - 1];
  }

  // Üstteki Özet Tablo
  Widget _buildSummaryTable() {
    double tCal = 0, tProt = 0, tCarb = 0, tFat = 0, tSug = 0, tFib = 0;
    for (var r in _chartRecords) {
      tCal += r.data.totalCalorie; tProt += r.data.totalProtein;
      tCarb += r.data.totalCarb; tFat += r.data.totalFat;
      tSug += r.data.totalSugar; tFib += r.data.totalFiber;
    }

    return Card(
      color: Colors.white.withOpacity(0.05),
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Table(
          columnWidths: const {0: FlexColumnWidth(2), 1: FlexColumnWidth(1)},
          children: [
            _tableRow("Dönemlik Kalori", "${tCal.toStringAsFixed(0)} kcal", isHead: true),
            _tableRow("Dönemlik Protein", "${tProt.toStringAsFixed(1)} g"),
            _tableRow("Dönemlik Karbonhidrat", "${tCarb.toStringAsFixed(1)} g"),
            _tableRow("Dönemlik Yağ", "${tFat.toStringAsFixed(1)} g"),
            _tableRow("Dönemlik Şeker", "${tSug.toStringAsFixed(1)} g"),
            _tableRow("Dönemlik Lif", "${tFib.toStringAsFixed(1)} g"),
          ],
        ),
      ),
    );
  }

  TableRow _tableRow(String label, String value, {bool isHead = false}) {
    return TableRow(children: [
      Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Text(label, style: TextStyle(color: isHead ? Colors.deepOrange : Colors.white70, fontWeight: isHead ? FontWeight.bold : FontWeight.normal))),
      Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Text(value, textAlign: TextAlign.right, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
    ]);
  }

  // Çubuk Grafiği Şablonu
  Widget _buildBarChart(String title, Color color, double Function(DailyIntakeList) getValue) {
    return Container(
      height: 250,
      margin: const EdgeInsets.only(bottom: 30),
      padding: const EdgeInsets.fromLTRB(10, 20, 20, 10),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: _getMaxY(getValue),
                barTouchData: BarTouchData(enabled: true),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        int index = value.toInt();
                        if (index >= 0 && index < _chartRecords.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(_chartRecords[index].label, style: const TextStyle(color: Colors.white54, fontSize: 10)),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) => Text(value.toInt().toString(), style: const TextStyle(color: Colors.white38, fontSize: 10)),
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                gridData: const FlGridData(show: true, drawVerticalLine: false, horizontalInterval: null),
                barGroups: _chartRecords.asMap().entries.map((e) {
                  return BarChartGroupData(
                    x: e.key,
                    barRods: [BarChartRodData(toY: getValue(e.value.data), color: color, width: 16, borderRadius: const BorderRadius.vertical(top: Radius.circular(4)))],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _getMaxY(double Function(DailyIntakeList) getValue) {
    double max = 0;
    for (var r in _chartRecords) {
      if (getValue(r.data) > max) max = getValue(r.data);
    }
    return max == 0 ? 100 : max * 1.2;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.deepOrange))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(value: '7 Gün', label: Text('7G')),
                        ButtonSegment(value: '28 Gün', label: Text('28G')),
                        ButtonSegment(value: '1 Yıl', label: Text('1Y')),
                      ],
                      selected: {_selectedPeriod},
                      onSelectionChanged: (val) => _loadStatistics(val.first),
                      style: ButtonStyle(backgroundColor: WidgetStateProperty.all(Colors.deepPurple.shade700)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildSummaryTable(),
                  const SizedBox(height: 20),
                  _buildBarChart("Kalori (kcal)", Colors.deepOrange, (r) => r.totalCalorie),
                  _buildBarChart("Protein (g)", Colors.blue, (r) => r.totalProtein),
                  _buildBarChart("Karbonhidrat (g)", Colors.green, (r) => r.totalCarb),
                  _buildBarChart("Yağ (g)", Colors.yellow, (r) => r.totalFat),
                  _buildBarChart("Şeker (g)", Colors.pink, (r) => r.totalSugar),
                  _buildBarChart("Lif (g)", Colors.teal, (r) => r.totalFiber),
                ],
              ),
            ),
    );
  }
}

// Grafik için yardımcı model
class _ChartData {
  final String label;
  final DailyIntakeList data;
  _ChartData({required this.label, required this.data});
}