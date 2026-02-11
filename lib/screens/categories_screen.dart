import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/transaction_model.dart';
import '../services/data_repository.dart';

/// Tela de Análise por Categorias com PieChart interativo
/// Projeto FinData Analytics - João Luís Cardoso e Samuel Junqueira
class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({Key? key}) : super(key: key);

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  List<TransactionModel> transactions = [];
  Map<String, double> categoryData = {};
  Map<String, int> categoryCount = {};
  bool isLoading = true;
  int touchedIndex = -1;

  @override
  void initState() {
    super.initState();
    _loadCategoryData();
  }

  void _loadCategoryData() {
    setState(() {
      isLoading = true;
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      transactions = DataRepository.generateMockTransactions();
      categoryData = DataRepository.groupByCategory(transactions);
      categoryCount = DataRepository.countByCategory(transactions);

      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Categorias'),
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Carregando análise por categorias...'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('🥧 MoneyWise - Categorias'),
        backgroundColor: Colors.orangeAccent,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCategoryData,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderCard(),
            const SizedBox(height: 20),
            _buildPieChart(),
            const SizedBox(height: 20),
            _buildCategoryList(),
            const SizedBox(height: 20),
            _buildInsightsCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange, Colors.orange.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.pie_chart, color: Colors.white, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: const Text(
                  'Distribuição por Categorias',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${categoryData.length} categorias analisadas\n${transactions.length} transações processadas',
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart() {
    if (categoryData.isEmpty) {
      return const Center(child: Text('Nenhum dado disponível'));
    }

    // Calculate dynamic radius based on screen width
    double screenWidth = MediaQuery.of(context).size.width;
    double baseRadius = (screenWidth * 0.45).clamp(
      120.0,
      200.0,
    ); // 45% of screen width, clamped between 120-200
    double selectedRadius =
        baseRadius + 20; // Selected sections are 20px larger

    List<PieChartSectionData> sections = [];
    List<Color> colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.purple,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
      Colors.amber,
      Colors.cyan,
      Colors.brown,
    ];

    int index = 0;
    double totalValue = categoryData.values.fold(
      0,
      (sum, value) => sum + value,
    );

    for (var entry in categoryData.entries) {
      double percentage = (entry.value / totalValue) * 100;
      bool isSelected = index == touchedIndex;

      sections.add(
        PieChartSectionData(
          color: colors[index % colors.length],
          value: entry.value,
          title: '${percentage.toStringAsFixed(1)}%',
          radius: isSelected ? selectedRadius : baseRadius,
          titleStyle: TextStyle(
            fontSize: isSelected ? 16 : 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          titlePositionPercentageOffset: 0.6,
        ),
      );
      index++;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Distribuição de Gastos por Categoria',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 40),
          SizedBox(
            height: 600,
            child: PieChart(
              PieChartData(
                sections: sections,
                pieTouchData: PieTouchData(
                  touchCallback: (FlTouchEvent event, pieTouchResponse) {
                    setState(() {
                      if (!event.isInterestedForInteractions ||
                          pieTouchResponse == null ||
                          pieTouchResponse.touchedSection == null) {
                        touchedIndex = -1;
                        return;
                      }
                      touchedIndex =
                          pieTouchResponse.touchedSection!.touchedSectionIndex;
                    });
                  },
                ),
                borderData: FlBorderData(show: false),
                sectionsSpace: 2,
                centerSpaceRadius: 0,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildLegend(colors),
        ],
      ),
    );
  }

  Widget _buildLegend(List<Color> colors) {
    List<Widget> legendItems = [];
    int index = 0;

    for (var entry in categoryData.entries) {
      legendItems.add(
        Row(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: colors[index % colors.length],
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                entry.key,
                style: const TextStyle(fontSize: 12),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              _formatCurrency(entry.value),
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
      index++;
    }

    return Column(children: legendItems);
  }

  Widget _buildCategoryList() {
    List<String> sortedCategories = categoryData.keys.toList()
      ..sort((a, b) => categoryData[b]!.compareTo(categoryData[a]!));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ranking por Valor',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...sortedCategories
              .map((category) => _buildCategoryItem(category))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(String category) {
    double value = categoryData[category] ?? 0;
    int count = categoryCount[category] ?? 0;
    double maxValue = categoryData.values.reduce((a, b) => a > b ? a : b);
    double percentage = (value / maxValue);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  category,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatCurrency(value),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '$count transações',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: percentage,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
            minHeight: 6,
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsCard() {
    String topCategory = '';
    double topValue = 0;
    String leastCategory = '';
    double leastValue = double.infinity;

    for (var entry in categoryData.entries) {
      if (entry.value > topValue) {
        topValue = entry.value;
        topCategory = entry.key;
      }
      if (entry.value < leastValue) {
        leastValue = entry.value;
        leastCategory = entry.key;
      }
    }

    double totalValue = categoryData.values.fold(
      0,
      (sum, value) => sum + value,
    );
    double topPercentage = (topValue / totalValue) * 100;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.teal.shade400, Colors.teal.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.lightbulb, color: Colors.white, size: 24),
              SizedBox(width: 12),
              Text(
                'Insights Inteligentes',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInsightItem(
            '🏆 Maior Gasto',
            '$topCategory representa ${topPercentage.toStringAsFixed(1)}% dos seus gastos',
            _formatCurrency(topValue),
          ),
          const SizedBox(height: 12),
          _buildInsightItem(
            '💡 Menor Gasto',
            'Você economizou mais na categoria $leastCategory',
            _formatCurrency(leastValue),
          ),
          const SizedBox(height: 12),
          _buildInsightItem(
            '📊 Diversificação',
            'Você gastou em ${categoryData.length} categorias diferentes',
            'Bom controle!',
          ),
        ],
      ),
    );
  }

  Widget _buildInsightItem(String title, String description, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  String _formatCurrency(double value) {
    return 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
  }
}
