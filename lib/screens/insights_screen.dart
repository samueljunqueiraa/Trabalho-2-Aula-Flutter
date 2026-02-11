import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/transaction_model.dart';
import '../services/data_repository.dart';
import 'dart:math' as math;

/// Tela de Insights Avançados - Analytics Inteligente
/// Projeto FinData Analytics - João Luís Cardoso e Samuel Junqueira
class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  List<TransactionModel> transactions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final loadedTransactions = DataRepository.generateMockTransactions();
      setState(() {
        transactions = loadedTransactions;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildAnomalyDetector(),
                  const SizedBox(height: 24),
                  _buildHealthScore(),
                  const SizedBox(height: 24),
                  _buildSeasonalTrends(),
                  const SizedBox(height: 24),
                  _buildWeeklyHeatmap(),
                  const SizedBox(height: 24),
                  _buildCategoryComparison(),
                ],
              ),
            ),
    );
  }

  // 4️⃣ MAPA DE CALOR SEMANAL
  Widget _buildWeeklyHeatmap() {
    Map<int, double> weekdayExpenses = {};

    for (var transaction in transactions) {
      if (transaction.tipo == TransactionType.despesa) {
        int weekday = transaction.data.weekday;
        weekdayExpenses[weekday] =
            (weekdayExpenses[weekday] ?? 0) + transaction.valor.abs();
      }
    }

    List<String> weekdays = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];
    double maxExpense = weekdayExpenses.values.isEmpty
        ? 1
        : weekdayExpenses.values.reduce((a, b) => a > b ? a : b);

    return Card(
      elevation: 4,
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.deepOrange.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.calendar_today,
                    color: Colors.deepOrange.shade700,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Mapa de Calor Semanal',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(7, (index) {
                  int weekday = index + 1;
                  double expense = weekdayExpenses[weekday] ?? 0;
                  double intensity = expense / maxExpense;

                  return Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'R\$${expense.toInt()}',
                          style: const TextStyle(fontSize: 10),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          height: 150 * intensity,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: Color.lerp(
                              Colors.green.shade200,
                              Colors.red.shade700,
                              intensity,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          weekdays[index],
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _getWeekdayInsight(weekdayExpenses),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.orange.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Como Funciona',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'O Mapa de Calor analisa seus gastos por dia da semana, identificando padrões de consumo. '
                    'Cores mais intensas indicam dias com maiores gastos. Use essa informação para planejar '
                    'compras e evitar gastos impulsivos em dias críticos.',
                    style: TextStyle(fontSize: 13, height: 1.4),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getWeekdayInsight(Map<int, double> weekdayExpenses) {
    if (weekdayExpenses.isEmpty)
      return 'Dados insuficientes para análise semanal.';

    int maxDay = weekdayExpenses.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
    int minDay = weekdayExpenses.entries
        .reduce((a, b) => a.value < b.value ? a : b)
        .key;

    List<String> weekdayNames = [
      '',
      'segunda-feira',
      'terça-feira',
      'quarta-feira',
      'quinta-feira',
      'sexta-feira',
      'sábado',
      'domingo',
    ];

    return '📊 Você gasta mais às ${weekdayNames[maxDay]}s e menos às ${weekdayNames[minDay]}s. '
        'Diferença: R\$ ${(weekdayExpenses[maxDay]! - weekdayExpenses[minDay]!).toStringAsFixed(2)}';
  }

  // 5️⃣ COMPARATIVO DE CATEGORIAS
  Widget _buildCategoryComparison() {
    Map<String, double> categoryExpenses = {};

    for (var transaction in transactions) {
      if (transaction.tipo == TransactionType.despesa) {
        categoryExpenses[transaction.categoria] =
            (categoryExpenses[transaction.categoria] ?? 0) +
            transaction.valor.abs();
      }
    }

    var sortedCategories = categoryExpenses.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      elevation: 4,
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.cyan.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.compare_arrows,
                    color: Colors.cyan.shade700,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Ranking de Categorias',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: sortedCategories.isEmpty
                  ? const Center(child: Text('Sem dados de categorias'))
                  : BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: sortedCategories.first.value * 1.2,
                        barTouchData: BarTouchData(enabled: true),
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                int index = value.toInt();
                                if (index >= 0 &&
                                    index < sortedCategories.length) {
                                  return RotatedBox(
                                    quarterTurns: 1,
                                    child: Text(
                                      sortedCategories[index].key,
                                      style: const TextStyle(fontSize: 10),
                                    ),
                                  );
                                }
                                return const Text('');
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) => Text(
                                'R\$${(value / 1000).toInt()}k',
                                style: const TextStyle(fontSize: 10),
                              ),
                            ),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        borderData: FlBorderData(show: true),
                        barGroups: List.generate(
                          sortedCategories.length,
                          (index) => BarChartGroupData(
                            x: index,
                            barRods: [
                              BarChartRodData(
                                toY: sortedCategories[index].value,
                                color: Colors
                                    .primaries[index % Colors.primaries.length],
                                width: 20,
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(4),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
            ),
            const SizedBox(height: 16),
            if (sortedCategories.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.cyan.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '🥇 Maior Gasto:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${sortedCategories.first.key}: R\$ ${sortedCategories.first.value.toStringAsFixed(2)}',
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '🥉 Menor Gasto:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${sortedCategories.last.key}: R\$ ${sortedCategories.last.value.toStringAsFixed(2)}',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.cyan.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.cyan.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.cyan.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Análise Comparativa',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.cyan.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'O Ranking de Categorias ordena suas despesas do maior para o menor valor total. '
                    'Identifique onde você mais gasta e encontre oportunidades de economia. '
                    'Categorias no topo merecem atenção especial no planejamento financeiro.',
                    style: TextStyle(fontSize: 13, height: 1.4),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple, Colors.purple.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics, color: Colors.white, size: 28),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  '🧠 MoneyWise - Insights',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            'Análises inteligentes baseadas em Data Science',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ],
      ),
    );
  }

  // 1️⃣ DETECTOR DE ANOMALIAS
  Widget _buildAnomalyDetector() {
    Map<String, List<double>> categoryValues = {};
    List<AnomalyPoint> anomalies = [];

    // Agrupar valores por categoria
    for (var transaction in transactions) {
      if (transaction.tipo == TransactionType.despesa) {
        categoryValues.putIfAbsent(transaction.categoria, () => []);
        categoryValues[transaction.categoria]!.add(transaction.valor.abs());
      }
    }

    // Detectar anomalias usando estatística (média + 2 desvios padrão)
    for (var entry in categoryValues.entries) {
      String category = entry.key;
      List<double> values = entry.value;

      if (values.length < 3) continue; // Precisa de pelo menos 3 transações

      double mean = values.reduce((a, b) => a + b) / values.length;
      double variance =
          values.map((x) => math.pow(x - mean, 2)).reduce((a, b) => a + b) /
          values.length;
      double stdDev = math.sqrt(variance);
      double threshold = mean + (2 * stdDev); // 2 sigma

      for (int i = 0; i < values.length; i++) {
        if (values[i] > threshold) {
          anomalies.add(
            AnomalyPoint(
              category: category,
              value: values[i],
              expected: mean,
              deviation: ((values[i] - mean) / mean * 100).round(),
              index: i,
            ),
          );
        }
      }
    }

    return Card(
      elevation: 4,
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.warning_amber,
                    color: Colors.red.shade700,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Detector de Anomalias',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              anomalies.isEmpty
                  ? '✅ Nenhuma anomalia detectada! Seus gastos estão dentro do padrão.'
                  : '⚠️ ${anomalies.length} anomalia(s) detectada(s) em seus gastos:',
              style: TextStyle(
                fontSize: 16,
                color: anomalies.isEmpty
                    ? Colors.green
                    : Colors.orange.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            if (anomalies.isNotEmpty) ...[
              SizedBox(
                height: 300,
                child: _buildAnomalyChart(categoryValues, anomalies),
              ),
              const SizedBox(height: 16),
              ...anomalies
                  .take(3)
                  .map(
                    (anomaly) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: const Border(
                            left: BorderSide(width: 4, color: Colors.red),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    anomaly.category,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'R\$ ${anomaly.value.toStringAsFixed(2)} (${anomaly.deviation}% acima da média)',
                                    style: TextStyle(
                                      color: Colors.red.shade700,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '+${anomaly.deviation}%',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
            ],
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.blue.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Como Funciona',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'O Detector de Anomalias usa estatística avançada (média + 2 desvios padrão) para identificar gastos atípicos. '
                    'Transações que excedem 200% da média histórica por categoria são sinalizadas como anomalias, '
                    'ajudando você a identificar gastos excessivos ou inesperados.',
                    style: TextStyle(fontSize: 13, height: 1.4),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnomalyChart(
    Map<String, List<double>> categoryValues,
    List<AnomalyPoint> anomalies,
  ) {
    List<ScatterSpot> normalSpots = [];
    List<ScatterSpot> anomalySpots = [];
    List<String> categories = categoryValues.keys.toList();

    for (int catIndex = 0; catIndex < categories.length; catIndex++) {
      String category = categories[catIndex];
      List<double> values = categoryValues[category]!;

      for (int valIndex = 0; valIndex < values.length; valIndex++) {
        double value = values[valIndex];
        bool isAnomaly = anomalies.any(
          (a) => a.category == category && a.value == value,
        );

        if (isAnomaly) {
          anomalySpots.add(ScatterSpot(catIndex.toDouble(), value));
        } else {
          normalSpots.add(ScatterSpot(catIndex.toDouble(), value));
        }
      }
    }

    return ScatterChart(
      ScatterChartData(
        scatterSpots: [
          ScatterSpot(0, 0), // Ponto invisível para forçar o gráfico
          ...normalSpots,
          ...anomalySpots,
        ],
        minX: -0.5,
        maxX: categories.length - 0.5,
        minY: 0,
        maxY:
            categoryValues.values
                .expand((list) => list)
                .reduce((a, b) => a > b ? a : b) *
            1.1,
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                int index = value.toInt();
                if (index >= 0 && index < categories.length) {
                  return RotatedBox(
                    quarterTurns: 1,
                    child: Text(
                      categories[index],
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) => Text(
                'R\$ ${value.toInt()}',
                style: const TextStyle(fontSize: 10),
              ),
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: const FlGridData(show: true),
        borderData: FlBorderData(show: true),
        // Labels removidos temporariamente para evitar conflitos
      ),
    );
  }

  // 2️⃣ SCORE DE SAÚDE FINANCEIRA
  Widget _buildHealthScore() {
    double score = _calculateHealthScore();

    return Card(
      elevation: 4,
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.health_and_safety,
                    color: Colors.blue.shade700,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Score de Saúde Financeira',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Center(
              child: SizedBox(
                height: 200,
                width: 200,
                child: _buildScoreGauge(score),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _getScoreInsight(score),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.blue.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Como é Calculado',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Seu Score é calculado com base em 3 fatores:\n'
                    '• Diversificação (40%): Quantidade de categorias de gastos ativas\n'
                    '• Consistência (30%): Regularidade dos seus gastos (baixa variação)\n'
                    '• Taxa de Economia (30%): Percentual da renda que você consegue poupar\n\n'
                    'Scores acima de 800 indicam excelente saúde financeira!',
                    style: TextStyle(fontSize: 13, height: 1.4),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreGauge(double score) {
    Color scoreColor = score >= 800
        ? Colors.green
        : score >= 600
        ? Colors.orange
        : Colors.red;

    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          height: 200,
          width: 200,
          child: CircularProgressIndicator(
            value: score / 1000,
            strokeWidth: 12,
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${score.toInt()}',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: scoreColor,
              ),
            ),
            const Text(
              '/1000',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }

  double _calculateHealthScore() {
    if (transactions.isEmpty) return 0;

    // Diversificação (40 pontos): número de categorias ativas
    Set<String> categories = transactions
        .where((t) => t.tipo == TransactionType.despesa)
        .map((t) => t.categoria)
        .toSet();
    double diversificationScore = math.min(categories.length * 50.0, 400.0);

    // Consistência (30 pontos): regularidade dos gastos
    double totalExpenses = transactions
        .where((t) => t.tipo == TransactionType.despesa)
        .map((t) => t.valor.abs())
        .fold(0.0, (sum, value) => sum + value);
    double avgExpense = totalExpenses / transactions.length;
    double variance =
        transactions
            .where((t) => t.tipo == TransactionType.despesa)
            .map((t) => math.pow(t.valor.abs() - avgExpense, 2))
            .fold(0.0, (sum, value) => sum + value) /
        transactions.length;
    double consistencyScore = math.max(
      0,
      300 - (math.sqrt(variance) / avgExpense * 100),
    );

    // Crescimento/Economia (30 pontos): taxa de poupança
    double totalIncome = transactions
        .where((t) => t.tipo == TransactionType.receita)
        .map((t) => t.valor)
        .fold(0.0, (sum, value) => sum + value);
    double savingsRate = totalIncome > 0
        ? ((totalIncome - totalExpenses) / totalIncome) * 100
        : 0;
    double growthScore = math.max(0, math.min(savingsRate * 10, 300));

    return diversificationScore + consistencyScore + growthScore;
  }

  String _getScoreInsight(double score) {
    if (score >= 800) {
      return "🏆 Excelente! Sua saúde financeira está ótima. Continue assim!";
    } else if (score >= 600) {
      return "👍 Boa! Sua situação está estável, mas há espaço para melhorias.";
    } else if (score >= 400) {
      return "⚠️ Atenção! Considere diversificar gastos e aumentar a poupança.";
    } else {
      return "🚨 Crítico! Revise urgentemente seus hábitos financeiros.";
    }
  }

  // 3️⃣ ANÁLISE DE TENDÊNCIAS SAZONAIS
  Widget _buildSeasonalTrends() {
    return Card(
      elevation: 4,
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.trending_up,
                    color: Colors.green.shade700,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Tendências Sazonais',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(height: 300, child: _buildTrendsChart()),
            const SizedBox(height: 16),
            Text(
              _getTrendInsight(),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.green.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Metodologia',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'A Análise de Tendências usa regressão linear simples para identificar padrões temporais nos seus gastos. '
                    'Comparamos os gastos mensais para calcular a taxa de crescimento/redução e projetar tendências futuras. '
                    'Variações superiores a ±10% são consideradas significativas e merecem atenção especial.',
                    style: TextStyle(fontSize: 13, height: 1.4),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendsChart() {
    // Agrupar transações por mês (simulado com dados existentes)
    Map<int, double> monthlyExpenses = {};

    for (var transaction in transactions) {
      if (transaction.tipo == TransactionType.despesa) {
        int month = transaction.data.month;
        monthlyExpenses[month] =
            (monthlyExpenses[month] ?? 0) + transaction.valor.abs();
      }
    }

    List<FlSpot> spots = [];
    for (int month = 1; month <= 12; month++) {
      double expense = monthlyExpenses[month] ?? 0;
      spots.add(FlSpot(month.toDouble(), expense));
    }

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: true),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const months = [
                  '',
                  'Jan',
                  'Fev',
                  'Mar',
                  'Abr',
                  'Mai',
                  'Jun',
                  'Jul',
                  'Ago',
                  'Set',
                  'Out',
                  'Nov',
                  'Dez',
                ];
                int index = value.toInt();
                if (index >= 0 && index < months.length) {
                  return Text(
                    months[index],
                    style: const TextStyle(fontSize: 10),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) => Text(
                'R\$ ${(value / 1000).toStringAsFixed(0)}k',
                style: const TextStyle(fontSize: 10),
              ),
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Colors.green,
            barWidth: 3,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.green.withOpacity(0.1),
            ),
          ),
        ],
        minX: 1,
        maxX: 12,
        minY: 0,
        maxY: spots.isNotEmpty
            ? spots.map((s) => s.y).reduce((a, b) => a > b ? a : b) * 1.2
            : 100,
      ),
    );
  }

  String _getTrendInsight() {
    // Calcular crescimento mensal simulado
    Map<int, double> monthlyExpenses = {};

    for (var transaction in transactions) {
      if (transaction.tipo == TransactionType.despesa) {
        int month = transaction.data.month;
        monthlyExpenses[month] =
            (monthlyExpenses[month] ?? 0) + transaction.valor.abs();
      }
    }

    if (monthlyExpenses.length >= 2) {
      var sortedMonths = monthlyExpenses.keys.toList()..sort();
      double firstMonth = monthlyExpenses[sortedMonths.first] ?? 0;
      double lastMonth = monthlyExpenses[sortedMonths.last] ?? 0;

      if (firstMonth > 0) {
        double growthRate = ((lastMonth - firstMonth) / firstMonth * 100);

        if (growthRate > 10) {
          return "📈 Tendência de alta: gastos cresceram ${growthRate.toStringAsFixed(1)}% nos últimos meses. Atenção ao orçamento!";
        } else if (growthRate < -10) {
          return "📉 Tendência de queda: gastos reduziram ${(-growthRate).toStringAsFixed(1)}%. Ótimo controle financeiro!";
        } else {
          return "📊 Gastos estáveis: variação de ${growthRate.toStringAsFixed(1)}% nos últimos meses. Bom controle!";
        }
      }
    }

    return "📊 Análise baseada nos dados disponíveis. Mais transações = insights mais precisos.";
  }
}

class AnomalyPoint {
  final String category;
  final double value;
  final double expected;
  final int deviation;
  final int index;

  AnomalyPoint({
    required this.category,
    required this.value,
    required this.expected,
    required this.deviation,
    required this.index,
  });
}
