import 'dart:convert';
import 'package:csv/csv.dart';
import 'package:universal_html/html.dart' as html;
import '../models/transaction_model.dart';

/// Serviço de exportação real com geração de arquivos CSV e PDF
/// Projeto FinData Analytics - João Luís Cardoso e Samuel Junqueira
class ExportService {
  /// Exporta transações para arquivo CSV real
  static Future<bool> exportToCSV(List<TransactionModel> transactions) async {
    try {
      // Preparar dados CSV
      List<List<dynamic>> csvData = [
        ['ID', 'Título', 'Categoria', 'Valor', 'Tipo', 'Data'], // Cabeçalho
      ];

      for (var transaction in transactions) {
        csvData.add([
          transaction.id,
          transaction.titulo,
          transaction.categoria,
          transaction.valor.toStringAsFixed(2),
          transaction.tipo == TransactionType.receita ? 'Receita' : 'Despesa',
          '${transaction.data.day.toString().padLeft(2, '0')}/${transaction.data.month.toString().padLeft(2, '0')}/${transaction.data.year}',
        ]);
      }

      // Converter para CSV
      String csv = const ListToCsvConverter().convert(csvData);

      // Criar arquivo e download
      try {
        final bytes = utf8.encode(csv);
        final blob = html.Blob([bytes], 'text/csv;charset=utf-8');
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.document.createElement('a') as html.AnchorElement
          ..href = url
          ..style.display = 'none'
          ..download =
              'FinData_${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}.csv';
        html.document.body?.children.add(anchor);
        anchor.click();
        await Future.delayed(const Duration(milliseconds: 100));
        html.document.body?.children.remove(anchor);
        html.Url.revokeObjectUrl(url);
      } catch (downloadError) {
        print('❌ Erro ao fazer download: $downloadError');
        rethrow;
      }

      print('✅ CSV Export Realizado:');
      print('📊 Total de transações: ${transactions.length}');
      String filename =
          'FinData_${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}.csv';
      print('📄 Arquivo baixado: $filename');
      print('💾 Dados: ${csvData.length - 1} linhas de transações');

      return true;
    } catch (e) {
      print('❌ Erro ao exportar CSV: $e');
      return false;
    }
  }

  /// Exporta transações para arquivo PDF/HTML
  static Future<bool> exportToPDF(
    List<TransactionModel> transactions,
    double prediction,
  ) async {
    try {
      // Calcular estatísticas reais
      double totalReceitas = 0;
      double totalDespesas = 0;
      Map<String, double> categorias = {};

      for (var transaction in transactions) {
        if (transaction.tipo == TransactionType.receita) {
          totalReceitas += transaction.valor;
        } else {
          totalDespesas += transaction.valor.abs();
          categorias[transaction.categoria] =
              (categorias[transaction.categoria] ?? 0) +
              transaction.valor.abs();
        }
      }

      double saldo = totalReceitas - totalDespesas;
      var sortedCategorias = categorias.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      // Criar conteúdo HTML para o relatório
      String htmlContent =
          '''<!DOCTYPE html>
<html>
<head>
    <title>FinData Analytics - Relatório Financeiro</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; line-height: 1.6; }
        .header { text-align: center; color: #2196F3; margin-bottom: 30px; }
        .section { margin: 20px 0; }
        .summary { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 15px; margin: 20px 0; }
        .summary-card { padding: 15px; background: #f5f5f5; border-radius: 8px; text-align: center; }
        .summary-card strong { display: block; margin-bottom: 5px; font-size: 18px; }
        table { width: 100%; border-collapse: collapse; margin: 20px 0; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #2196F3; color: white; }
        .receita { color: green; font-weight: bold; }
        .despesa { color: red; font-weight: bold; }
        .footer { text-align: center; margin-top: 30px; font-size: 12px; color: #666; }
        ul li { margin: 8px 0; }
    </style>
</head>
<body>
    <div class="header">
        <h1>🏦 FinData Analytics</h1>
        <h2>📊 Relatório Financeiro Completo</h2>
        <p>📅 Gerado em ${DateTime.now().day.toString().padLeft(2, '0')}/${DateTime.now().month.toString().padLeft(2, '0')}/${DateTime.now().year}</p>
    </div>
    
    <div class="section">
        <h3>💼 Resumo Financeiro</h3>
        <div class="summary">
            <div class="summary-card">
                <strong>💰 Total Receitas</strong>
                <span>R\$ ${totalReceitas.toStringAsFixed(2)}</span>
            </div>
            <div class="summary-card">
                <strong>📉 Total Despesas</strong>
                <span>R\$ ${totalDespesas.toStringAsFixed(2)}</span>
            </div>
            <div class="summary-card">
                <strong>💳 Saldo Atual</strong>
                <span>R\$ ${saldo.toStringAsFixed(2)}</span>
            </div>
            <div class="summary-card">
                <strong>🤖 Predição IA</strong>
                <span>R\$ ${prediction.toStringAsFixed(2)}</span>
            </div>
        </div>
    </div>
    
    <div class="section">
        <h3>🏆 Top Categorias de Despesas</h3>
        <ul>''';

      // Adicionar categorias
      for (int i = 0; i < 5 && i < sortedCategorias.length; i++) {
        var entry = sortedCategorias[i];
        double percent = totalDespesas > 0
            ? (entry.value / totalDespesas) * 100
            : 0;
        htmlContent += '''
            <li><strong>${entry.key}:</strong> R\$ ${entry.value.toStringAsFixed(2)} (${percent.toStringAsFixed(1)}%)</li>''';
      }

      htmlContent += '''
        </ul>
    </div>
    
    <div class="section">
        <h3>📋 Histórico de Transações (Últimas 20)</h3>
        <table>
            <tr>
                <th>📅 Data</th>
                <th>📝 Título</th>
                <th>🏷️ Categoria</th>
                <th>💵 Valor</th>
                <th>📊 Tipo</th>
            </tr>''';

      // Adicionar transações
      for (int i = 0; i < 20 && i < transactions.length; i++) {
        var transaction = transactions[i];
        String cssClass = transaction.tipo == TransactionType.receita
            ? 'receita'
            : 'despesa';
        String tipo = transaction.tipo == TransactionType.receita
            ? '💰 Receita'
            : '💸 Despesa';

        htmlContent +=
            '''
            <tr>
                <td>${transaction.data.day.toString().padLeft(2, '0')}/${transaction.data.month.toString().padLeft(2, '0')}/${transaction.data.year}</td>
                <td>${transaction.titulo}</td>
                <td>${transaction.categoria}</td>
                <td class="$cssClass">R\$ ${transaction.valor.toStringAsFixed(2)}</td>
                <td>$tipo</td>
            </tr>''';
      }

      htmlContent += '''
        </table>
    </div>
    
    <div class="footer">
        <p>📄 Relatório gerado pelo FinData Analytics</p>
        <p>👨‍💻 João Luís Cardoso e Samuel Junqueira</p>
        <p>💡 <strong>Dica:</strong> Use Ctrl+P para salvar como PDF</p>
    </div>
</body>
</html>''';

      // Criar e baixar arquivo HTML
      try {
        final bytes = utf8.encode(htmlContent);
        final blob = html.Blob([bytes], 'text/html;charset=utf-8');
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.document.createElement('a') as html.AnchorElement
          ..href = url
          ..style.display = 'none'
          ..download =
              'FinData_Report_${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}.html';
        html.document.body?.children.add(anchor);
        anchor.click();
        await Future.delayed(const Duration(milliseconds: 100));
        html.document.body?.children.remove(anchor);
        html.Url.revokeObjectUrl(url);
      } catch (downloadError) {
        print('❌ Erro ao fazer download do relatório: $downloadError');
        rethrow;
      }

      print('✅ Relatório HTML Exportado:');
      print('📊 Relatório Financeiro Completo');
      print('💰 Total Receitas: R\$ ${totalReceitas.toStringAsFixed(2)}');
      print('📉 Total Despesas: R\$ ${totalDespesas.toStringAsFixed(2)}');
      print('💼 Saldo: R\$ ${saldo.toStringAsFixed(2)}');
      print('🤖 Predição IA: R\$ ${prediction.toStringAsFixed(2)}');
      print('💡 Dica: Abra o HTML e use Ctrl+P para salvar como PDF');

      return true;
    } catch (e) {
      print('❌ Erro ao exportar PDF: $e');
      return false;
    }
  }
}
