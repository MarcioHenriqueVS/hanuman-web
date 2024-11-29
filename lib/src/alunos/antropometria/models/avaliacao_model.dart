import 'package:intl/intl.dart';

class AvaliacaoModel {
  String alunoUid;
  String timestamp;
  String titulo;
  double? peso;
  double? altura;
  double? pantEsq;
  double? pantDir;
  double? coxaEsq;
  double? coxaDir;
  double? quadril;
  double? cintura;
  double? cintEscapular;
  double? torax;
  double? bracoEsq;
  double? bracoDir;
  double? antebracoEsq;
  double? antebracoDir;
  double? pantu;
  double? coxa;
  double? abdominal;
  double? supraespinal;
  double? suprailiaca;
  double? toracica;
  double? biciptal;
  double? triciptal;
  double? axilarMedia;
  double? subescapular;
  String? formula;
  double? imc;
  String? classificacaoImc;
  double? bf;
  double? mm;
  double? mg;
  double? rce;
  String? classificacaoRce;
  List<String>? fotos;
  String? obs;
  String? sexo;

  AvaliacaoModel({
    required this.alunoUid,
    required this.timestamp,
    required this.titulo,
    this.peso,
    this.altura,
    this.pantEsq,
    this.pantDir,
    this.coxaEsq,
    this.coxaDir,
    this.quadril,
    this.cintura,
    this.cintEscapular,
    this.torax,
    this.bracoEsq,
    this.bracoDir,
    this.antebracoEsq,
    this.antebracoDir,
    this.pantu,
    this.coxa,
    this.abdominal,
    this.supraespinal,
    this.suprailiaca,
    this.toracica,
    this.biciptal,
    this.triciptal,
    this.axilarMedia,
    this.subescapular,
    this.formula,
    this.imc,
    this.classificacaoImc,
    this.bf,
    this.mm,
    this.mg,
    this.rce,
    this.classificacaoRce,
    this.fotos,
    this.obs,
    this.sexo,
  });

  // Método fromJson para criar uma instância de AvaliacaoModel a partir de um JSON
  factory AvaliacaoModel.fromJson(Map<String, dynamic> json) {
    // Extraindo o timestamp do formato Firestore
    final seconds = json['timestamp']['_seconds'];
    final nanoseconds = json['timestamp']['_nanoseconds'];

    // Convertendo para DateTime
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(
        seconds * 1000 + nanoseconds ~/ 1000000);

    // Formatando para String
    String formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);

    return AvaliacaoModel(
      alunoUid: json['alunoUid'],
      timestamp: formattedDate, // String formatada
      titulo: json['titulo'],
      peso: json['peso']?.toDouble(),
      altura: json['altura']?.toDouble(),
      pantEsq: json['pantEsq']?.toDouble(),
      pantDir: json['pantDir']?.toDouble(),
      coxaEsq: json['coxaEsq']?.toDouble(),
      coxaDir: json['coxaDir']?.toDouble(),
      quadril: json['quadril']?.toDouble(),
      cintura: json['cintura']?.toDouble(),
      cintEscapular: json['cintEscapular']?.toDouble(),
      torax: json['torax']?.toDouble(),
      bracoEsq: json['bracoEsq']?.toDouble(),
      bracoDir: json['bracoDir']?.toDouble(),
      antebracoEsq: json['antebracoEsq']?.toDouble(),
      antebracoDir: json['antebracoDir']?.toDouble(),
      pantu: json['pantu']?.toDouble(),
      coxa: json['coxa']?.toDouble(),
      abdominal: json['abdominal']?.toDouble(),
      supraespinal: json['supraespinal']?.toDouble(),
      suprailiaca: json['suprailiaca']?.toDouble(),
      toracica: json['toracica']?.toDouble(),
      biciptal: json['biciptal']?.toDouble(),
      triciptal: json['triciptal']?.toDouble(),
      axilarMedia: json['axilarMedia']?.toDouble(),
      subescapular: json['subescapular']?.toDouble(),
      formula: json['formula'],
      imc: json['imc']?.toDouble(),
      classificacaoImc: json['classificacaoImc'],
      bf: json['bf']?.toDouble(),
      mm: json['mm']?.toDouble(),
      mg: json['mg']?.toDouble(),
      rce: json['rce']?.toDouble(),
      classificacaoRce: json['classificacaoRce'],
      fotos: List<String>.from(json['fotos'] ?? []),
      obs: json['obs'],
      sexo: json['sexo'],
    );
  }

  // Modificar o método toJson para formatar o timestamp corretamente para o Firestore
  Map<String, dynamic> toJson() {
    return {
      'alunoUid': alunoUid,
      'timestamp':
          timestamp, // Enviamos diretamente a string no formato dd/MM/yyyy HH:mm:ss
      'titulo': titulo,
      'peso': peso,
      'altura': altura,
      'pantEsq': pantEsq,
      'pantDir': pantDir,
      'coxaEsq': coxaEsq,
      'coxaDir': coxaDir,
      'quadril': quadril,
      'cintura': cintura,
      'cintEscapular': cintEscapular,
      'torax': torax,
      'bracoEsq': bracoEsq,
      'bracoDir': bracoDir,
      'antebracoEsq': antebracoEsq,
      'antebracoDir': antebracoDir,
      'pantu': pantu,
      'coxa': coxa,
      'abdominal': abdominal,
      'supraespinal': supraespinal,
      'suprailiaca': suprailiaca,
      'toracica': toracica,
      'biciptal': biciptal,
      'triciptal': triciptal,
      'axilarMedia': axilarMedia,
      'subescapular': subescapular,
      'formula': formula,
      'imc': imc,
      'classificacaoImc': classificacaoImc,
      'bf': bf,
      'mm': mm,
      'mg': mg,
      'rce': rce,
      'classificacaoRce': classificacaoRce,
      'fotos': fotos,
      'obs': obs,
      'sexo': sexo,
    };
  }

  // Adicionar um método específico para salvar offline
  Map<String, dynamic> toJsonOffline() {
    return {
      'alunoUid': alunoUid,
      'timestamp': timestamp,
      'titulo': titulo,
      'peso': peso,
      'altura': altura,
      'pantEsq': pantEsq,
      'pantDir': pantDir,
      'coxaEsq': coxaEsq,
      'coxaDir': coxaDir,
      'quadril': quadril,
      'cintura': cintura,
      'cintEscapular': cintEscapular,
      'torax': torax,
      'bracoEsq': bracoEsq,
      'bracoDir': bracoDir,
      'antebracoEsq': antebracoEsq,
      'antebracoDir': antebracoDir,
      'pantu': pantu,
      'coxa': coxa,
      'abdominal': abdominal,
      'supraespinal': supraespinal,
      'suprailiaca': suprailiaca,
      'toracica': toracica,
      'biciptal': biciptal,
      'triciptal': triciptal,
      'axilarMedia': axilarMedia,
      'subescapular': subescapular,
      'formula': formula,
      'imc': imc,
      'classificacaoImc': classificacaoImc,
      'bf': bf,
      'mm': mm,
      'mg': mg,
      'rce': rce,
      'classificacaoRce': classificacaoRce,
      'fotos': fotos,
      'obs': obs,
      'sexo': sexo,
    };
  }
}
