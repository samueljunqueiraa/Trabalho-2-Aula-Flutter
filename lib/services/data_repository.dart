import 'dart:math';
import '../models/transaction_model.dart';

/// Repositório de dados com geração de transações mockadas e lógica de predição
/// Projeto FinData Analytics - João Luís Cardoso e Samuel Junqueira
class DataRepository {
  static final Random _random = Random();
  static List<TransactionModel>? _cachedTransactions;

  /// Gera 50 transações mockadas nos últimos 6 meses
  static List<TransactionModel> generateMockTransactions() {
    if (_cachedTransactions != null) {
      return _cachedTransactions!;
    }

    List<TransactionModel> transactions = [];
    DateTime now = DateTime.now();

    // Gerar transações dos últimos 6 meses
    for (int i = 0; i < 50; i++) {
      int daysAgo = _random.nextInt(180); // 6 meses * 30 dias
      DateTime transactionDate = now.subtract(Duration(days: daysAgo));

      // 75% despesas, 25% receitas para ser mais realista
      TransactionType tipo = _random.nextDouble() < 0.25
          ? TransactionType.receita
          : TransactionType.despesa;

      transactions.add(
        _generateTransaction(
          id: 'txn_${i.toString().padLeft(3, '0')}',
          data: transactionDate,
          tipo: tipo,
        ),
      );
    }

    // Ordenar por data (mais recente primeiro)
    transactions.sort((a, b) => b.data.compareTo(a.data));

    _cachedTransactions = transactions;
    return transactions;
  }

  /// Gera uma transação individual com dados realistas
  static TransactionModel _generateTransaction({
    required String id,
    required DateTime data,
    required TransactionType tipo,
  }) {
    if (tipo == TransactionType.receita) {
      return _generateReceita(id, data);
    } else {
      return _generateDespesa(id, data);
    }
  }

  /// Gera uma receita com valores e categorias realistas
  static TransactionModel _generateReceita(String id, DateTime data) {
    List<String> categorias = Categories.incomeCategories;
    String categoria = categorias[_random.nextInt(categorias.length)];

    double valor;
    String titulo;

    switch (categoria) {
      case 'Salário':
        valor = 2500 + _random.nextDouble() * 4500; // R$ 2500-7000
        titulo = 'Salário mensal - ${_getRandomCompany()}';
        break;
      case 'Freelance':
        valor = 300 + _random.nextDouble() * 1700; // R$ 300-2000
        titulo = 'Projeto freelance - ${_getRandomFreelanceProject()}';
        break;
      case 'Investimentos':
        valor = 50 + _random.nextDouble() * 950; // R$ 50-1000
        titulo = 'Rendimento ${_getRandomInvestment()}';
        break;
      case 'Vendas':
        valor = 100 + _random.nextDouble() * 800; // R$ 100-900
        titulo = 'Venda ${_getRandomSaleItem()}';
        break;
      case 'Bonificações':
        valor = 200 + _random.nextDouble() * 1300; // R$ 200-1500
        titulo = 'Bonificação ${_getRandomBonus()}';
        break;
      default:
        valor = 100 + _random.nextDouble() * 500; // R$ 100-600
        titulo = 'Receita adicional';
    }

    return TransactionModel(
      id: id,
      titulo: titulo,
      valor: double.parse(valor.toStringAsFixed(2)),
      data: data,
      categoria: categoria,
      tipo: TransactionType.receita,
    );
  }

  /// Gera uma despesa com valores e categorias realistas
  static TransactionModel _generateDespesa(String id, DateTime data) {
    List<String> categorias = Categories.expenseCategories;
    String categoria = categorias[_random.nextInt(categorias.length)];

    double valor;
    String titulo;

    switch (categoria) {
      case 'Alimentação':
        valor = 12 + _random.nextDouble() * 88; // R$ 12-100
        titulo = _getRandomFoodExpense();
        break;
      case 'Transporte':
        valor = 8 + _random.nextDouble() * 67; // R$ 8-75
        titulo = _getRandomTransportExpense();
        break;
      case 'Lazer':
        valor = 25 + _random.nextDouble() * 175; // R$ 25-200
        titulo = _getRandomLeisureExpense();
        break;
      case 'Saúde':
        valor = 30 + _random.nextDouble() * 270; // R$ 30-300
        titulo = _getRandomHealthExpense();
        break;
      case 'Educação':
        valor = 40 + _random.nextDouble() * 460; // R$ 40-500
        titulo = _getRandomEducationExpense();
        break;
      case 'Moradia':
        valor = 80 + _random.nextDouble() * 920; // R$ 80-1000
        titulo = _getRandomHousingExpense();
        break;
      case 'Compras':
        valor = 20 + _random.nextDouble() * 180; // R$ 20-200
        titulo = _getRandomShoppingExpense();
        break;
      case 'Serviços':
        valor = 35 + _random.nextDouble() * 265; // R$ 35-300
        titulo = _getRandomServiceExpense();
        break;
      default:
        valor = 15 + _random.nextDouble() * 85; // R$ 15-100
        titulo = 'Despesa diversa';
    }

    return TransactionModel(
      id: id,
      titulo: titulo,
      valor: double.parse(valor.toStringAsFixed(2)),
      data: data,
      categoria: categoria,
      tipo: TransactionType.despesa,
    );
  }

  /// LÓGICA DE PREDIÇÃO - REGRESSÃO SIMPLES
  /// Calcula a média de gastos dos últimos 3 meses e projeta o próximo mês
  static double calculatePrediction(List<TransactionModel> transactions) {
    DateTime now = DateTime.now();
    DateTime threeMonthsAgo = DateTime(now.year, now.month - 3, now.day);

    // Filtrar apenas despesas dos últimos 3 meses
    List<TransactionModel> recentExpenses = transactions
        .where(
          (t) =>
              t.tipo == TransactionType.despesa &&
              t.data.isAfter(threeMonthsAgo),
        )
        .toList();

    if (recentExpenses.isEmpty) return 0.0;

    // Agrupar por mês e calcular totais
    Map<String, double> monthlyTotals = {};

    for (var expense in recentExpenses) {
      String monthKey =
          '${expense.data.year}-${expense.data.month.toString().padLeft(2, '0')}';
      monthlyTotals[monthKey] = (monthlyTotals[monthKey] ?? 0) + expense.valor;
    }

    if (monthlyTotals.isEmpty) return 0.0;

    // Calcular média simples
    double averageMonthly =
        monthlyTotals.values.reduce((a, b) => a + b) / monthlyTotals.length;

    // Aplicar ajuste de tendência (crescimento/decrescimento)
    List<double> monthlyValues = monthlyTotals.values.toList();
    if (monthlyValues.length >= 2) {
      double firstMonth = monthlyValues.first;
      double lastMonth = monthlyValues.last;
      double trend = (lastMonth - firstMonth) / monthlyValues.length;
      averageMonthly += trend * 0.3; // Aplicar 30% da tendência
    }

    return averageMonthly < 0 ? 0 : averageMonthly;
  }

  /// Agrupa despesas por categoria
  static Map<String, double> groupByCategory(
    List<TransactionModel> transactions,
  ) {
    Map<String, double> categoryTotals = {};

    for (var transaction in transactions) {
      if (transaction.tipo == TransactionType.despesa) {
        categoryTotals[transaction.categoria] =
            (categoryTotals[transaction.categoria] ?? 0) + transaction.valor;
      }
    }

    return categoryTotals;
  }

  /// Agrupa despesas por mês (últimos 6 meses)
  static Map<String, double> groupByMonth(List<TransactionModel> transactions) {
    DateTime now = DateTime.now();
    Map<String, double> monthlyTotals = {};

    // Inicializar os últimos 6 meses com zero
    for (int i = 5; i >= 0; i--) {
      DateTime monthDate = DateTime(now.year, now.month - i, 1);
      String monthKey =
          '${monthDate.month.toString().padLeft(2, '0')}/${monthDate.year}';
      monthlyTotals[monthKey] = 0.0;
    }

    // Somar despesas por mês
    for (var transaction in transactions) {
      if (transaction.tipo == TransactionType.despesa) {
        String monthKey =
            '${transaction.data.month.toString().padLeft(2, '0')}/${transaction.data.year}';
        if (monthlyTotals.containsKey(monthKey)) {
          monthlyTotals[monthKey] =
              monthlyTotals[monthKey]! + transaction.valor;
        }
      }
    }

    return monthlyTotals;
  }

  /// Calcula estatísticas básicas
  static Map<String, double> calculateStatistics(
    List<TransactionModel> transactions,
  ) {
    double totalReceitas = transactions
        .where((t) => t.tipo == TransactionType.receita)
        .fold(0.0, (sum, t) => sum + t.valor);

    double totalDespesas = transactions
        .where((t) => t.tipo == TransactionType.despesa)
        .fold(0.0, (sum, t) => sum + t.valor);

    double saldo = totalReceitas - totalDespesas;

    return {
      'totalReceitas': totalReceitas,
      'totalDespesas': totalDespesas,
      'saldo': saldo,
    };
  }

  // Métodos auxiliares para gerar descrições variadas e realistas

  static String _getRandomCompany() {
    List<String> companies = [
      'Tech Solutions Ltda',
      'Inovação Digital',
      'Consultoria Estratégica',
      'Desenvolvimento Web',
      'Sistemas Corporativos',
    ];
    return companies[_random.nextInt(companies.length)];
  }

  static String _getRandomFreelanceProject() {
    List<String> projects = [
      'Website institucional',
      'App mobile',
      'Sistema de gestão',
      'Landing page',
      'E-commerce',
      'Dashboard analytics',
    ];
    return projects[_random.nextInt(projects.length)];
  }

  static String _getRandomInvestment() {
    List<String> investments = [
      'CDB Banco Inter',
      'Tesouro Direto',
      'LCI Nubank',
      'Fundos de investimento',
      'Ações dividendos',
    ];
    return investments[_random.nextInt(investments.length)];
  }

  static String _getRandomSaleItem() {
    List<String> items = [
      'Notebook usado',
      'Móveis antigos',
      'Roupas online',
      'Livros técnicos',
      'Equipamentos eletrônicos',
    ];
    return items[_random.nextInt(items.length)];
  }

  static String _getRandomBonus() {
    List<String> bonuses = [
      'por performance',
      'de final de ano',
      'por projeto concluído',
      'participação nos lucros',
      'por indicação',
    ];
    return bonuses[_random.nextInt(bonuses.length)];
  }

  static String _getRandomFoodExpense() {
    List<String> expenses = [
      'Almoço restaurante executivo',
      'Supermercado semanal',
      'Delivery iFood',
      'Padaria manhã',
      'Jantar romântico',
      'Lanche afternoon',
      'Feira orgânica',
      'Coffee shop trabalho',
    ];
    return expenses[_random.nextInt(expenses.length)];
  }

  static String _getRandomTransportExpense() {
    List<String> expenses = [
      'Uber para reunião',
      'Combustível posto',
      'Bilhete único metrô',
      'Estacionamento shopping',
      '99Pop centro cidade',
      'Manutenção veículo',
      'Pedágio viagem',
      'Taxi aeroporto',
    ];
    return expenses[_random.nextInt(expenses.length)];
  }

  static String _getRandomLeisureExpense() {
    List<String> expenses = [
      'Cinema shopping',
      'Teatro municipal',
      'Show banda favorita',
      'Bar com amigos',
      'Viagem fim de semana',
      'Parque diversões',
      'Jogo futebol estádio',
      'Streaming Netflix',
    ];
    return expenses[_random.nextInt(expenses.length)];
  }

  static String _getRandomHealthExpense() {
    List<String> expenses = [
      'Consulta médico particular',
      'Medicamentos farmácia',
      'Exames laboratório',
      'Academia mensal',
      'Dentista limpeza',
      'Vitaminas suplementos',
      'Fisioterapia sessão',
      'Plano saúde',
    ];
    return expenses[_random.nextInt(expenses.length)];
  }

  static String _getRandomEducationExpense() {
    List<String> expenses = [
      'Curso online Udemy',
      'Livros técnicos Amazon',
      'Certificação profissional',
      'Workshop especialização',
      'Congresso tecnologia',
      'Inglês escola idiomas',
      'Material escritório',
      'Assinatura Medium',
    ];
    return expenses[_random.nextInt(expenses.length)];
  }

  static String _getRandomHousingExpense() {
    List<String> expenses = [
      'Aluguel apartamento',
      'Condomínio mensal',
      'Conta luz Enel',
      'Água e esgoto',
      'Internet fibra',
      'Gás botijão',
      'Reforma banheiro',
      'Móveis sala',
    ];
    return expenses[_random.nextInt(expenses.length)];
  }

  static String _getRandomShoppingExpense() {
    List<String> expenses = [
      'Roupas trabalho',
      'Smartphone novo',
      'Presente aniversário',
      'Decoração casa',
      'Cosméticos farmácia',
      'Tênis esportivo',
      'Acessórios notebook',
      'Utensílios cozinha',
    ];
    return expenses[_random.nextInt(expenses.length)];
  }

  static String _getRandomServiceExpense() {
    List<String> expenses = [
      'Corte cabelo barbearia',
      'Lavanderia roupas',
      'Manutenção ar condicionado',
      'Consultoria jurídica',
      'Design gráfico freelancer',
      'Limpeza apartamento',
      'Seguro veículo',
      'Contador mensalidade',
    ];
    return expenses[_random.nextInt(expenses.length)];
  }

  /// Conta número de transações por categoria
  static Map<String, int> countByCategory(List<TransactionModel> transactions) {
    Map<String, int> categoryCount = {};

    for (var transaction in transactions) {
      // Apenas despesas para análise de categorias
      if (transaction.tipo == TransactionType.despesa) {
        categoryCount[transaction.categoria] =
            (categoryCount[transaction.categoria] ?? 0) + 1;
      }
    }

    return categoryCount;
  }

  /// Limpa cache para regenerar dados
  static void clearCache() {
    _cachedTransactions = null;
  }
}
