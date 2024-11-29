import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import '../models/avaliacao_model.dart';

class PdfAvaliacaoService {
  Future<File> generatePdf(AvaliacaoModel avaliacao) async {
    final pdf = pw.Document();

    // Processa as fotos antes de gerar o PDF
    List<pw.MemoryImage> fotosProcessadas =
        await _processarFotos(avaliacao.fotos);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            _buildHeader(avaliacao),
            _buildMedidasBasicas(avaliacao),
            _buildCircunferencias(avaliacao),
            _buildAdiposimetria(avaliacao),
            _buildResultados(avaliacao),
            if (avaliacao.obs != null && avaliacao.obs!.isNotEmpty)
              _buildObservacoes(avaliacao),
            if (_temFotos(avaliacao)) _buildFotos(fotosProcessadas),
          ];
        },
      ),
    );

    return _savePdf(pdf, avaliacao.titulo ?? 'avaliacao');
  }

  // Novo método para processar as fotos
  Future<List<pw.MemoryImage>> _processarFotos(List<String>? fotos) async {
    List<pw.MemoryImage> fotosProcessadas = [];

    for (var foto in fotos ?? []) {
      if (foto.isNotEmpty) {
        try {
          late final Uint8List fotoBytes;

          if (_isUrl(foto)) {
            fotoBytes = await _downloadImage(foto) ?? base64Decode('');
          } else {
            fotoBytes = base64Decode(foto);
          }

          fotosProcessadas.add(pw.MemoryImage(fotoBytes));
        } catch (e) {
          print('Erro ao processar foto: $e');
        }
      }
    }

    return fotosProcessadas;
  }

  // Modificar _buildFotos para receber imagens já processadas
  pw.Widget _buildFotos(List<pw.MemoryImage> fotos) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Fotos',
          style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 10),
        pw.Wrap(
          spacing: 10,
          runSpacing: 10,
          children: fotos
              .map((foto) => pw.Container(
                    width: 200,
                    height: 200,
                    child: pw.Image(foto, fit: pw.BoxFit.contain),
                  ))
              .toList(),
        ),
      ],
    );
  }

  pw.Widget _buildHeader(AvaliacaoModel avaliacao) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          avaliacao.titulo ?? 'Avaliação Física',
          style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 10),
        pw.Text('Data: ${avaliacao.timestamp}'),
        pw.Divider(),
      ],
    );
  }

  pw.Widget _buildMedidasBasicas(AvaliacaoModel avaliacao) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Medidas Básicas',
          style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 10),
        _buildMedidaRow('Peso', avaliacao.peso, 'kg'),
        _buildMedidaRow('Altura', avaliacao.altura, 'm'),
        pw.SizedBox(height: 10),
      ],
    );
  }

  pw.Widget _buildCircunferencias(AvaliacaoModel avaliacao) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Circunferências',
          style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 10),
        _buildMedidaRow('Panturrilha Esquerda', avaliacao.pantEsq, 'cm'),
        _buildMedidaRow('Panturrilha Direita', avaliacao.pantDir, 'cm'),
        _buildMedidaRow('Coxa Esquerda', avaliacao.coxaEsq, 'cm'),
        _buildMedidaRow('Coxa Direita', avaliacao.coxaDir, 'cm'),
        _buildMedidaRow('Quadril', avaliacao.quadril, 'cm'),
        _buildMedidaRow('Cintura', avaliacao.cintura, 'cm'),
        _buildMedidaRow('Cintura Escapular', avaliacao.cintEscapular, 'cm'),
        _buildMedidaRow('Ombros', avaliacao.torax, 'cm'),
        _buildMedidaRow('Braço Esquerdo', avaliacao.bracoEsq, 'cm'),
        _buildMedidaRow('Braço Direito', avaliacao.bracoDir, 'cm'),
        _buildMedidaRow('Antebraço Esquerdo', avaliacao.antebracoEsq, 'cm'),
        _buildMedidaRow('Antebraço Direito', avaliacao.antebracoDir, 'cm'),
        pw.SizedBox(height: 10),
      ],
    );
  }

  pw.Widget _buildAdiposimetria(AvaliacaoModel avaliacao) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Adiposimetria',
          style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 10),
        _buildMedidaRow('Panturrilha', avaliacao.pantu, 'mm'),
        _buildMedidaRow('Coxa', avaliacao.coxa, 'mm'),
        _buildMedidaRow('Abdominal', avaliacao.abdominal, 'mm'),
        _buildMedidaRow('Supraespinal', avaliacao.supraespinal, 'mm'),
        _buildMedidaRow('Suprailíaca', avaliacao.suprailiaca, 'mm'),
        _buildMedidaRow('Torácica', avaliacao.toracica, 'mm'),
        _buildMedidaRow('Bíceps', avaliacao.biciptal, 'mm'),
        _buildMedidaRow('Tríceps', avaliacao.triciptal, 'mm'),
        _buildMedidaRow('Axilar Média', avaliacao.axilarMedia, 'mm'),
        _buildMedidaRow('Subescapular', avaliacao.subescapular, 'mm'),
        pw.SizedBox(height: 10),
      ],
    );
  }

  pw.Widget _buildResultados(AvaliacaoModel avaliacao) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Resultados',
          style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 10),
        if (avaliacao.imc != null)
          _buildResultadoRow('IMC',
              '${avaliacao.imc!.toStringAsFixed(2)} ${avaliacao.classificacaoImc != null ? "(${avaliacao.classificacaoImc})" : ""}'),
        if (avaliacao.bf != null)
          _buildResultadoRow(
              'Percentual de Gordura', '${avaliacao.bf!.toStringAsFixed(2)}%'),
        if (avaliacao.mm != null)
          _buildResultadoRow(
              'Massa Magra', '${avaliacao.mm!.toStringAsFixed(2)}kg'),
        if (avaliacao.mg != null)
          _buildResultadoRow(
              'Massa Gorda', '${avaliacao.mg!.toStringAsFixed(2)}kg'),
        if (avaliacao.rce != null)
          _buildResultadoRow('RCE',
              '${avaliacao.rce!.toStringAsFixed(2)} ${avaliacao.classificacaoRce != null ? "(${avaliacao.classificacaoRce})" : ""}'),
        pw.SizedBox(height: 10),
      ],
    );
  }

  pw.Widget _buildObservacoes(AvaliacaoModel avaliacao) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Observações',
          style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 10),
        pw.Text(avaliacao.obs ?? ''),
        pw.SizedBox(height: 10),
      ],
    );
  }

  bool _isUrl(String str) {
    try {
      final uri = Uri.parse(str);
      return uri.scheme.startsWith('http');
    } catch (e) {
      return false;
    }
  }

  Future<Uint8List?> _downloadImage(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return response.bodyBytes;
      }
    } catch (e) {
      print('Erro ao baixar imagem: $e');
    }
    return null;
  }

  pw.Widget _buildMedidaRow(String label, double? valor, String unidade) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 5),
      child: pw.Row(
        children: [
          pw.Text(label),
          pw.Text(': '),
          pw.Text(
              valor != null ? '${valor.toStringAsFixed(2)} $unidade' : 'N/D'),
        ],
      ),
    );
  }

  pw.Widget _buildResultadoRow(String label, String valor) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 5),
      child: pw.Row(
        children: [
          pw.Text(label),
          pw.Text(': '),
          pw.Text(valor),
        ],
      ),
    );
  }

  bool _temFotos(AvaliacaoModel avaliacao) {
    return avaliacao.fotos?.any((foto) => foto.isNotEmpty) ?? false;
  }

  Future<File> _savePdf(pw.Document pdf, String fileName) async {
    final bytes = await pdf.save();
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$fileName.pdf');
    await file.writeAsBytes(bytes);
    return file;
  }
}
