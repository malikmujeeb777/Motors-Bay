import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:motorsbay1/SRC/Data/Resources/Colors/light_color_palate.dart';
import 'package:motorsbay1/SRC/Domain/Models/vehicle_maintenance_model.dart';
import 'package:motorsbay1/SRC/Domain/Services/maintenance_service.dart';

class ExpenseReportsScreen extends StatefulWidget {
  final String? vehicleId;

  const ExpenseReportsScreen({super.key, this.vehicleId});

  @override
  State<ExpenseReportsScreen> createState() => _ExpenseReportsScreenState();
}

class _ExpenseReportsScreenState extends State<ExpenseReportsScreen>
    with SingleTickerProviderStateMixin {
  final MaintenanceService _maintenanceService = MaintenanceService();
  late TabController _tabController;

  // Report timeframe
  String _selectedTimeframe = 'Last 3 Months';
  final List<String> _timeframeOptions = [
    'Last Month',
    'Last 3 Months',
    'Last 6 Months',
    'Last Year',
    'All Time'
  ];

  // Vehicle filter
  String? _selectedVehicleId;

  // Date range
  late DateTime _startDate;
  late DateTime _endDate;

  // Expense data
  Map<String, double> _expenseSummary = {};
  double _totalExpenses = 0;
  bool _isLoading = true;

  // Chart colors
  final List<Color> _expenseColors = [
    Colors.red,
    Colors.blue,
    Colors.orange,
    Colors.green,
    Colors.purple,
  ];

  @override
  void initState() {
    super.initState();
    _selectedVehicleId = widget.vehicleId;
    _updateDateRange();
    _loadExpenseData();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _updateDateRange() {
    _endDate = DateTime.now();

    switch (_selectedTimeframe) {
      case 'Last Month':
        _startDate = DateTime(_endDate.year, _endDate.month - 1, _endDate.day);
        break;
      case 'Last 3 Months':
        _startDate = DateTime(_endDate.year, _endDate.month - 3, _endDate.day);
        break;
      case 'Last 6 Months':
        _startDate = DateTime(_endDate.year, _endDate.month - 6, _endDate.day);
        break;
      case 'Last Year':
        _startDate = DateTime(_endDate.year - 1, _endDate.month, _endDate.day);
        break;
      case 'All Time':
        _startDate = DateTime(2000);
        break;
      default:
        _startDate = DateTime(_endDate.year, _endDate.month - 3, _endDate.day);
    }
  }

  Future<void> _loadExpenseData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final summary = await _maintenanceService.getExpenseSummary(
        _startDate,
        _endDate,
        vehicleId: _selectedVehicleId,
      );

      setState(() {
        _expenseSummary = summary;
        _totalExpenses = summary.values.fold(0, (sum, amount) => sum + amount);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading expense data: $e'),
          backgroundColor: LightColorsPalate.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Reports'),
        backgroundColor: LightColorsPalate.backgroundColor,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.pie_chart), text: 'Summary'),
            Tab(icon: Icon(Icons.bar_chart), text: 'Breakdown'),
          ],
          indicatorColor: LightColorsPalate.primaryColor,
          labelColor: LightColorsPalate.primaryColor,
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter controls
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: LightColorsPalate.backgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Timeframe',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: LightColorsPalate.surfaceColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: LightColorsPalate.outlineColor),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedTimeframe,
                      isExpanded: true,
                      icon: const Icon(Icons.arrow_drop_down),
                      style: Theme.of(context).textTheme.bodyLarge,
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedTimeframe = newValue;
                          });
                          _updateDateRange();
                          _loadExpenseData();
                        }
                      },
                      items: _timeframeOptions
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                if (_selectedVehicleId == null) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Vehicle',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: LightColorsPalate.surfaceColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: LightColorsPalate.outlineColor),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.directions_car,
                          color: LightColorsPalate.tertiaryColor,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'All Vehicles',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                        const Icon(
                          Icons.arrow_drop_down,
                          color: LightColorsPalate.tertiaryColor,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Report content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _expenseSummary.isEmpty
                    ? _buildEmptyState()
                    : TabBarView(
                        controller: _tabController,
                        children: [
                          _buildPieChartReport(),
                          _buildBarChartReport(),
                        ],
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.bar_chart,
            size: 64,
            color: LightColorsPalate.tertiaryColor,
          ),
          const SizedBox(height: 16),
          Text(
            'No expense data for this period',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Try selecting a different timeframe',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: LightColorsPalate.tertiaryColor,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChartReport() {
    final formatter = NumberFormat.currency(locale: 'en_PK', symbol: 'Rs. ');
    final sortedEntries = _expenseSummary.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Total expenses
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: LightColorsPalate.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: LightColorsPalate.primaryColor.withOpacity(0.3),
              ),
            ),
            child: Column(
              children: [
                Text(
                  'Total Expenses',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  formatter.format(_totalExpenses),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: LightColorsPalate.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  'From ${DateFormat('dd MMM yyyy').format(_startDate)} to ${DateFormat('dd MMM yyyy').format(_endDate)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: LightColorsPalate.tertiaryColor,
                      ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Pie chart
          Text(
            'Expense Breakdown',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),

          AspectRatio(
            aspectRatio: 1.3,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections: _buildPieChartSections(),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Legend
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: sortedEntries.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final entry = sortedEntries[index];
              final color = _expenseColors[index % _expenseColors.length];
              final percentage =
                  (entry.value / _totalExpenses * 100).toStringAsFixed(1);

              return ListTile(
                leading: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                title: Text(
                  _formatExpenseType(entry.key),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      formatter.format(entry.value),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '$percentage%',
                      style: TextStyle(
                        color: LightColorsPalate.tertiaryColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildPieChartSections() {
    final List<PieChartSectionData> sections = [];
    final sortedEntries = _expenseSummary.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    for (int i = 0; i < sortedEntries.length; i++) {
      final entry = sortedEntries[i];
      final color = _expenseColors[i % _expenseColors.length];
      final percentage = (entry.value / _totalExpenses) * 100;

      sections.add(
        PieChartSectionData(
          color: color,
          value: entry.value,
          title: '${percentage.toStringAsFixed(1)}%',
          radius: 100,
          titleStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    }

    return sections;
  }

  Widget _buildBarChartReport() {
    final formatter = NumberFormat.currency(locale: 'en_PK', symbol: 'Rs. ');
    final sortedEntries = _expenseSummary.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bar chart title
          Text(
            'Expense Categories',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),

          // Bar chart
          SizedBox(
            height: 300,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: sortedEntries.isNotEmpty
                    ? sortedEntries.first.value * 1.2
                    : 100,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final entry = sortedEntries[groupIndex];
                      return BarTooltipItem(
                        '${_formatExpenseType(entry.key)}\n',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        children: [
                          TextSpan(
                            text: formatter.format(entry.value),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value >= sortedEntries.length || value < 0) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            _formatExpenseType(sortedEntries[value.toInt()].key,
                                abbreviated: true),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        );
                      },
                      reservedSize: 30,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 60,
                      getTitlesWidget: (value, meta) {
                        if (value == 0) {
                          return const SizedBox.shrink();
                        }
                        return Text(
                          formatter.format(value),
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey.withOpacity(0.3),
                      strokeWidth: 1,
                    );
                  },
                  drawVerticalLine: false,
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(sortedEntries.length, (index) {
                  final entry = sortedEntries[index];
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value,
                        color: _expenseColors[index % _expenseColors.length],
                        width: 20,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(6),
                          topRight: Radius.circular(6),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Detailed table
          Text(
            'Detailed Breakdown',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),

          Table(
            border: TableBorder.all(
              color: Colors.grey.withOpacity(0.2),
              width: 1,
            ),
            columnWidths: const {
              0: FlexColumnWidth(2),
              1: FlexColumnWidth(1),
              2: FlexColumnWidth(1),
            },
            children: [
              TableRow(
                decoration: BoxDecoration(
                  color: LightColorsPalate.primaryColor.withOpacity(0.1),
                ),
                children: [
                  _buildTableHeader('Category'),
                  _buildTableHeader('Amount'),
                  _buildTableHeader('% of Total'),
                ],
              ),
              ...sortedEntries.map((entry) {
                final percentage =
                    (entry.value / _totalExpenses * 100).toStringAsFixed(1);
                return TableRow(
                  children: [
                    _buildTableCell(_formatExpenseType(entry.key)),
                    _buildTableCell(formatter.format(entry.value)),
                    _buildTableCell('$percentage%'),
                  ],
                );
              }).toList(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildTableCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        textAlign: TextAlign.center,
      ),
    );
  }

  String _formatExpenseType(String type, {bool abbreviated = false}) {
    if (type.isEmpty) {
      return 'Other';
    }

    if (abbreviated && type.length > 6) {
      return type.substring(0, 5) + '.';
    }

    return type;
  }
}
