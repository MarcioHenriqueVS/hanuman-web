import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:open_file/open_file.dart';
import 'package:url_launcher/url_launcher.dart';

class PdfViewerService {
  Future<void> openPdf(File file) async {
    try {
      if (kIsWeb) {
        // Para Web, crie uma URL do arquivo e abra em uma nova aba
        final url = Uri.dataFromBytes(
          await file.readAsBytes(),
          mimeType: 'application/pdf',
        ).toString();

        if (await canLaunchUrl(Uri.parse(url))) {
          await launchUrl(Uri.parse(url));
        } else {
          throw 'Não foi possível abrir o PDF';
        }
      } else {
        // Para dispositivos móveis, use o open_file
        final result = await OpenFile.open(file.path);
        if (result.type != ResultType.done) {
          throw 'Não foi possível abrir o PDF: ${result.message}';
        }
      }
    } catch (e) {
      debugPrint('Erro ao abrir PDF: $e');
      rethrow;
    }
  }
}
