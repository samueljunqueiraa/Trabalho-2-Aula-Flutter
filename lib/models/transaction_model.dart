/// Modelo de dados para transações financeiras
/// Projeto FinData Analytics - João Luís Cardoso e Samuel Junqueira
class TransactionModel {
  final String id;
  final String titulo;
  final double valor;
  final DateTime data;
  final String categoria;
  final TransactionType tipo;

  TransactionModel({
    required this.id,
    required this.titulo,
    required this.valor,
    required this.data,
    required this.categoria,
    required this.tipo,
  });

  /// Converte para Map para exportação
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titulo': titulo,
      'valor': valor,
      'data': data.toIso8601String(),
      'categoria': categoria,
      'tipo': tipo.toString(),
    };
  }

  /// Formatação para CSV
  List<dynamic> toCsvRow() {
    return [
      data.toIso8601String().split('T')[0],
      tipo == TransactionType.receita ? 'Receita' : 'Despesa',
      categoria,
      valor,
      titulo,
    ];
  }

  /// Valor com sinal (positivo para receita, negativo para despesa)
  double get valorComSinal => tipo == TransactionType.receita ? valor : -valor;

  @override
  String toString() {
    return 'TransactionModel(id: $id, titulo: $titulo, valor: $valor, categoria: $categoria, tipo: $tipo)';
  }
}

enum TransactionType { receita, despesa }

/// Categorias predefinidas
class Categories {
  static const Map<String, List<String>> categoriesByType = {
    'despesas': [
      'Alimentação',
      'Transporte',
      'Lazer',
      'Saúde',
      'Educação',
      'Moradia',
      'Compras',
      'Serviços',
      'Outros',
    ],
    'receitas': [
      'Salário',
      'Freelance',
      'Investimentos',
      'Vendas',
      'Bonificações',
      'Outros',
    ],
  };

  static List<String> get allCategories {
    return [...categoriesByType['despesas']!, ...categoriesByType['receitas']!];
  }

  static List<String> get expenseCategories => categoriesByType['despesas']!;
  static List<String> get incomeCategories => categoriesByType['receitas']!;
}
