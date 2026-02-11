import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/transaction_model.dart';
import '../services/data_repository.dart';
import 'dart:math' as math;

/// Tela de Metas Financeiras e Planejamento
/// Projeto FinData Analytics - João Luís Cardoso e Samuel Junqueira
class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  List<TransactionModel> transactions = [];
  bool isLoading = true;
  List<FinancialGoal> goals = [];

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
        _generateGoals();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _generateGoals() {
    double totalIncome = transactions
        .where((t) => t.tipo == TransactionType.receita)
        .map((t) => t.valor)
        .fold(0.0, (sum, value) => sum + value);

    double totalExpenses = transactions
        .where((t) => t.tipo == TransactionType.despesa)
        .map((t) => t.valor.abs())
        .fold(0.0, (sum, value) => sum + value);

    goals = [
      FinancialGoal(
        title: 'Economia Mensal',
        description: 'Poupar 20 porcento da renda',
        target: totalIncome * 0.20,
        current: totalIncome - totalExpenses,
        icon: Icons.savings,
        color: Colors.green,
      ),
      FinancialGoal(
        title: 'Reduzir Gastos',
        description: 'Diminuir despesas em 15 porcento',
        target: totalExpenses * 0.85,
        current: totalExpenses * 0.92,
        icon: Icons.trending_down,
        color: Colors.orange,
      ),
      FinancialGoal(
        title: 'Fundo de Emergência',
        description: '6 meses de despesas',
        target: totalExpenses * 6,
        current: (totalIncome - totalExpenses) * 3,
        icon: Icons.shield,
        color: Colors.blue,
      ),
      FinancialGoal(
        title: 'Investimentos',
        description: 'Investir 10 porcento da renda',
        target: totalIncome * 0.10,
        current: totalIncome * 0.05,
        icon: Icons.show_chart,
        color: Colors.purple,
      ),
    ];
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
                  _buildProgressOverview(),
                  const SizedBox(height: 24),
                  _buildGoalsList(),
                  const SizedBox(height: 24),
                  _buildBudgetPlanner(),
                  const SizedBox(height: 24),
                  _buildSavingsTips(),
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
          colors: [Colors.indigo, Colors.indigo.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withOpacity(0.3),
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
              Icon(Icons.flag, color: Colors.white, size: 28),
              SizedBox(width: 12),
              Text(
                '🎯 MoneyWise - Metas',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            'Planeje e alcance seus objetivos financeiros',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressOverview() {
    int completedGoals = goals.where((g) => g.progressPercentage >= 100).length;
    int totalGoals = goals.length;
    double overallProgress = goals.isEmpty
        ? 0
        : goals.map((g) => g.progressPercentage).reduce((a, b) => a + b) /
              totalGoals;

    return Card(
      elevation: 4,
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text(
                    'Progresso Geral',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: overallProgress >= 75 ? Colors.green : Colors.orange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${overallProgress.toInt()}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: overallProgress / 100,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                overallProgress >= 75 ? Colors.green : Colors.orange,
              ),
              minHeight: 8,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatCard(
                  'Concluídas',
                  '$completedGoals/$totalGoals',
                  Icons.check_circle,
                  Colors.green,
                ),
                _buildStatCard(
                  'Em Progresso',
                  '${totalGoals - completedGoals}',
                  Icons.timelapse,
                  Colors.orange,
                ),
                _buildStatCard(
                  'Média',
                  '${overallProgress.toInt()}%',
                  Icons.trending_up,
                  Colors.blue,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildGoalsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Suas Metas',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...goals.map((goal) => _buildGoalCard(goal)),
      ],
    );
  }

  Widget _buildGoalCard(FinancialGoal goal) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: goal.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(goal.icon, color: goal.color, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goal.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        goal.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: goal.progressPercentage >= 100
                        ? Colors.green
                        : goal.progressPercentage >= 50
                        ? Colors.orange
                        : Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${goal.progressPercentage.toInt()}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: goal.progressPercentage / 100,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(goal.color),
              minHeight: 8,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Atual: R\$ ${goal.current.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Expanded(
                  child: Text(
                    'Meta: R\$ ${goal.target.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
            if (goal.progressPercentage < 100) ...[
              const SizedBox(height: 8),
              Text(
                'Faltam R\$ ${(goal.target - goal.current).toStringAsFixed(2)} para atingir a meta',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetPlanner() {
    Map<String, double> categoryBudget = {
      'Alimentação': 1000.0,
      'Transporte': 500.0,
      'Lazer': 400.0,
      'Saúde': 300.0,
      'Educação': 600.0,
    };

    return Card(
      elevation: 4,
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.account_balance_wallet,
                  color: Colors.teal.shade700,
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Planejamento de Orçamento',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...categoryBudget.entries.map((entry) {
              double spent = math.Random().nextDouble() * entry.value;
              double percentage = (spent / entry.value) * 100;

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
                            entry.key,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'R\$ ${spent.toStringAsFixed(2)} / R\$ ${entry.value.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    LinearProgressIndicator(
                      value: percentage / 100,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        percentage >= 90
                            ? Colors.red
                            : percentage >= 70
                            ? Colors.orange
                            : Colors.green,
                      ),
                      minHeight: 6,
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSavingsTips() {
    return Card(
      elevation: 4,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.amber.shade100, Colors.amber.shade200],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb, color: Colors.amber.shade900, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Dicas de Economia',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber.shade900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTipItem(
              '💡',
              'Regra 50-30-20: 50% necessidades, 30% desejos, 20% poupança',
            ),
            _buildTipItem(
              '🎯',
              'Estabeleça metas SMART (Específicas, Mensuráveis, Atingíveis)',
            ),
            _buildTipItem(
              '📊',
              'Revise seus gastos semanalmente para manter o controle',
            ),
            _buildTipItem(
              '🏦',
              'Automatize suas economias com débito automático',
            ),
            _buildTipItem(
              '🛡️',
              'Priorize criar um fundo de emergência primeiro',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipItem(String emoji, String tip) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              tip,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade800),
            ),
          ),
        ],
      ),
    );
  }
}

class FinancialGoal {
  final String title;
  final String description;
  final double target;
  final double current;
  final IconData icon;
  final Color color;

  FinancialGoal({
    required this.title,
    required this.description,
    required this.target,
    required this.current,
    required this.icon,
    required this.color,
  });

  double get progressPercentage => (current / target * 100).clamp(0, 100);
}
