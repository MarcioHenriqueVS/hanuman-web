import 'dart:convert';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../autenticacao/tratamento/error_snackbar.dart';
import '../../../autenticacao/tratamento/success_snackbar.dart';
import '../../../notificacoes/fcm.dart';
import '../../../utils.dart';
import '../../../widgets_comuns/button_bloc/elevated_button_bloc.dart';
import '../../../widgets_comuns/button_bloc/elevated_button_bloc_event.dart';
import '../../antropometria/bloc/get_foto_avaliacao/get_foto_avaliacao_bloc.dart';
import '../../antropometria/models/avaliacao_model.dart';
import '../../antropometria/services/antropometria_services.dart';
import '../../models/aluno_model.dart';
import 'header_prototipo.dart';
import 'widgets/form_adipometria_avaliacao_widget.dart';
import 'widgets/form_avaliacao_widget.dart';
import 'widgets/form_medidas_avaliacao_widget.dart';
import 'widgets/resultados_container.dart';
import 'widgets/select_photos_container.dart';

class EditarAvaliacaoPage extends StatefulWidget {
  final AlunoModel aluno;
  final AvaliacaoModel avaliacao;
  const EditarAvaliacaoPage(
      {super.key, required this.aluno, required this.avaliacao});

  @override
  State<EditarAvaliacaoPage> createState() => _EditarAvaliacaoPageState();
}

class _EditarAvaliacaoPageState extends State<EditarAvaliacaoPage> {
  final AntropometriaServices _antropometriaServices = AntropometriaServices();
  final FirebaseMessagingService _firebaseMessagingService =
      FirebaseMessagingService();
  final uid = FirebaseAuth.instance.currentUser!.uid;

  final GlobalKey<FormState> formBasicoAvaliacaoKey = GlobalKey<FormState>();
  final GlobalKey<FormState> formMedidasAvaliacaoKey = GlobalKey<FormState>();
  final GlobalKey<FormState> formAdipometriaAvaliacaoKey =
      GlobalKey<FormState>();

  TextEditingController titulo = TextEditingController();
  TextEditingController obs = TextEditingController();
  TextEditingController peso = TextEditingController();
  TextEditingController altura = TextEditingController();

  String dataFormatada =
      DateFormat('dd/MM/yyyy', 'pt_BR').format(DateTime.now());

  //circunferencias
  TextEditingController pantDir = TextEditingController();
  TextEditingController pantEsq = TextEditingController();
  TextEditingController coxaDir = TextEditingController();
  TextEditingController coxaEsq = TextEditingController();
  TextEditingController bracoDir = TextEditingController();
  TextEditingController bracoEsq = TextEditingController();
  TextEditingController antebracoDir = TextEditingController();
  TextEditingController antebracoEsq = TextEditingController();
  TextEditingController cintura = TextEditingController();
  TextEditingController quadril = TextEditingController();
  TextEditingController torax = TextEditingController();
  TextEditingController cinturaEscapular = TextEditingController();
  TextEditingController abdome = TextEditingController();

  //adipometria
  TextEditingController pantu = TextEditingController();
  TextEditingController coxa = TextEditingController();
  TextEditingController abdominal = TextEditingController();
  TextEditingController supraEspinal = TextEditingController();
  TextEditingController supraIliaca = TextEditingController();
  TextEditingController axilarMedia = TextEditingController();
  TextEditingController toracica = TextEditingController();
  TextEditingController subescapular = TextEditingController();
  TextEditingController triceps = TextEditingController();
  TextEditingController biceps = TextEditingController();

  String? _selectedOption;
  double? bf;
  double? imc;
  String? classificacaoImc;
  double? rce;
  String? classificacaoRce;
  double? massaMagra;
  double? massaGorda;
  double? pesoIdeal;

  Uint8List? foto1;
  Uint8List? foto2;
  Uint8List? foto3;
  Uint8List? foto4;

  bool edit = false;
  AvaliacaoModel? newAvaliacao;

  @override
  void initState() {
    super.initState();
    titulo.text = widget.avaliacao.titulo;
    _selectedOption = widget.avaliacao.formula;
    titulo.text = widget.avaliacao.titulo;
    obs.text = widget.avaliacao.obs ?? '';
    widget.avaliacao.peso != null
        ? peso.text = widget.avaliacao.peso.toString()
        : null;
    widget.avaliacao.altura != null
        ? altura.text = widget.avaliacao.altura.toString()
        : null;
    widget.avaliacao.pantDir != null
        ? pantDir.text = widget.avaliacao.pantDir.toString()
        : null;
    widget.avaliacao.pantEsq != null
        ? pantEsq.text = widget.avaliacao.pantEsq.toString()
        : null;
    widget.avaliacao.coxaDir != null
        ? coxaDir.text = widget.avaliacao.coxaDir.toString()
        : null;
    widget.avaliacao.coxaEsq != null
        ? coxaEsq.text = widget.avaliacao.coxaEsq.toString()
        : null;
    widget.avaliacao.bracoDir != null
        ? bracoDir.text = widget.avaliacao.bracoDir.toString()
        : null;
    widget.avaliacao.bracoEsq != null
        ? bracoEsq.text = widget.avaliacao.bracoEsq.toString()
        : null;
    widget.avaliacao.antebracoDir != null
        ? antebracoDir.text = widget.avaliacao.antebracoDir.toString()
        : null;
    widget.avaliacao.antebracoEsq != null
        ? antebracoEsq.text = widget.avaliacao.antebracoEsq.toString()
        : null;
    widget.avaliacao.cintura != null
        ? cintura.text = widget.avaliacao.cintura.toString()
        : null;
    widget.avaliacao.quadril != null
        ? quadril.text = widget.avaliacao.quadril.toString()
        : null;
    widget.avaliacao.torax != null
        ? torax.text = widget.avaliacao.torax.toString()
        : null;
    widget.avaliacao.cintEscapular != null
        ? cinturaEscapular.text = widget.avaliacao.cintEscapular.toString()
        : null;
    widget.avaliacao.abdome != null
        ? abdome.text = widget.avaliacao.abdome.toString()
        : null;
    widget.avaliacao.pantu != null
        ? pantu.text = widget.avaliacao.pantu.toString()
        : null;
    widget.avaliacao.coxa != null
        ? coxa.text = widget.avaliacao.coxa.toString()
        : null;
    widget.avaliacao.abdominal != null
        ? abdominal.text = widget.avaliacao.abdominal.toString()
        : null;
    widget.avaliacao.supraespinal != null
        ? supraEspinal.text = widget.avaliacao.supraespinal.toString()
        : null;
    widget.avaliacao.suprailiaca != null
        ? supraIliaca.text = widget.avaliacao.suprailiaca.toString()
        : null;
    widget.avaliacao.axilarMedia != null
        ? axilarMedia.text = widget.avaliacao.axilarMedia.toString()
        : null;
    widget.avaliacao.toracica != null
        ? toracica.text = widget.avaliacao.toracica.toString()
        : null;
    widget.avaliacao.subescapular != null
        ? subescapular.text = widget.avaliacao.subescapular.toString()
        : null;
    widget.avaliacao.triciptal != null
        ? triceps.text = widget.avaliacao.triciptal.toString()
        : null;
    widget.avaliacao.biciptal != null
        ? biceps.text = widget.avaliacao.biciptal.toString()
        : null;
    bf = widget.avaliacao.bf;
    imc = widget.avaliacao.imc;
    classificacaoImc = widget.avaliacao.classificacaoImc;
    rce = widget.avaliacao.rce;
    classificacaoRce = widget.avaliacao.classificacaoRce;
    massaMagra = widget.avaliacao.mm;
    massaGorda = widget.avaliacao.mg;
    pesoIdeal = widget.avaliacao.pesoIdeal;
    _carregarFotos();
    pesoControllerListener();
    alturaControllerListener();
    rceCinturaControllerListener();
    bicepsListener();
    tricepsListener();
    subescapularListener();
    supraIliacaListener();
    abdomenListener();
    coxaListener();
    toracicaListener();
    axilarMediaListener();
  }

  @override
  void dispose() {
    // Remover listeners quando o widget for destruído
    peso.dispose();
    altura.dispose();
    pantDir.dispose();
    pantEsq.dispose();
    coxaDir.dispose();
    coxaEsq.dispose();
    bracoDir.dispose();
    bracoEsq.dispose();
    antebracoDir.dispose();
    antebracoEsq.dispose();
    cintura.dispose();
    quadril.dispose();
    torax.dispose();
    cinturaEscapular.dispose();
    abdome.dispose();
    pantu.dispose();
    coxa.dispose();
    abdominal.dispose();
    supraEspinal.dispose();
    supraIliaca.dispose();
    axilarMedia.dispose();
    toracica.dispose();
    subescapular.dispose();
    triceps.dispose();
    biceps.dispose();
    super.dispose();
  }

  Future<void> _carregarFotos() async {
    try {
      // Foto 1
      if (widget.avaliacao.fotos != null &&
          widget.avaliacao.fotos!.isNotEmpty) {
        if (widget.avaliacao.fotos![0].startsWith('http')) {
          final fotoBytes = await _antropometriaServices
              .urlToUint8List(widget.avaliacao.fotos![0]);
          setState(() => foto1 = fotoBytes);
          // Adicionar ao bloc
          context
              .read<GetFotoAvaliacaoBloc>()
              .add(CarregarFotoExistenteEvent(0, fotoBytes));
        } else if (widget.avaliacao.fotos![0].isNotEmpty) {
          final fotoBytes = base64Decode(widget.avaliacao.fotos![0]);
          setState(() => foto1 = fotoBytes);
          // Adicionar ao bloc
          context
              .read<GetFotoAvaliacaoBloc>()
              .add(CarregarFotoExistenteEvent(0, fotoBytes));
        }
      }

      // Foto 2
      if (widget.avaliacao.fotos != null &&
          widget.avaliacao.fotos!.length > 1) {
        if (widget.avaliacao.fotos![1].startsWith('http')) {
          final fotoBytes = await _antropometriaServices
              .urlToUint8List(widget.avaliacao.fotos![1]);
          setState(() => foto2 = fotoBytes);
          // Adicionar ao bloc
          context
              .read<GetFotoAvaliacaoBloc>()
              .add(CarregarFotoExistenteEvent(1, fotoBytes));
        } else if (widget.avaliacao.fotos![1].isNotEmpty) {
          final fotoBytes = base64Decode(widget.avaliacao.fotos![1]);
          setState(() => foto2 = fotoBytes);
          // Adicionar ao bloc
          context
              .read<GetFotoAvaliacaoBloc>()
              .add(CarregarFotoExistenteEvent(1, fotoBytes));
        }
      }

      // Foto 3
      if (widget.avaliacao.fotos != null &&
          widget.avaliacao.fotos!.length > 2) {
        if (widget.avaliacao.fotos![2].startsWith('http')) {
          final fotoBytes = await _antropometriaServices
              .urlToUint8List(widget.avaliacao.fotos![2]);
          setState(() => foto3 = fotoBytes);
          // Adicionar ao bloc
          context
              .read<GetFotoAvaliacaoBloc>()
              .add(CarregarFotoExistenteEvent(2, fotoBytes));
        } else if (widget.avaliacao.fotos![2].isNotEmpty) {
          final fotoBytes = base64Decode(widget.avaliacao.fotos![2]);
          setState(() => foto3 = fotoBytes);
          // Adicionar ao bloc
          context
              .read<GetFotoAvaliacaoBloc>()
              .add(CarregarFotoExistenteEvent(2, fotoBytes));
        }
      }

      // Foto 4
      if (widget.avaliacao.fotos != null &&
          widget.avaliacao.fotos!.length > 3) {
        if (widget.avaliacao.fotos![3].startsWith('http')) {
          final fotoBytes = await _antropometriaServices
              .urlToUint8List(widget.avaliacao.fotos![3]);
          setState(() => foto4 = fotoBytes);
          // Adicionar ao bloc
          context
              .read<GetFotoAvaliacaoBloc>()
              .add(CarregarFotoExistenteEvent(3, fotoBytes));
        } else if (widget.avaliacao.fotos![3].isNotEmpty) {
          final fotoBytes = base64Decode(widget.avaliacao.fotos![3]);
          setState(() => foto4 = fotoBytes);
          // Adicionar ao bloc
          context
              .read<GetFotoAvaliacaoBloc>()
              .add(CarregarFotoExistenteEvent(3, fotoBytes));
        }
      }
    } catch (e) {
      debugPrint('Erro ao carregar fotos: $e');
    }
  }

  void onBack() async {
    // verifica se houve alterações através do edit e retorna a newAvaliacao para a tela anterior
    if (edit) {
      Navigator.of(context).pop(newAvaliacao);
    } else {
      Navigator.of(context).pop();
    }
  }

  void salvarAvaliacao() async {
    try {
      if (!formBasicoAvaliacaoKey.currentState!.validate() ||
          !formMedidasAvaliacaoKey.currentState!.validate() ||
          !formAdipometriaAvaliacaoKey.currentState!.validate()) {
        return;
      }

      // Verifica se algum campo além do título está preenchido
      bool temDadosPreenchidos = peso.text.isNotEmpty ||
          altura.text.isNotEmpty ||
          pantDir.text.isNotEmpty ||
          pantEsq.text.isNotEmpty ||
          coxaDir.text.isNotEmpty ||
          coxaEsq.text.isNotEmpty ||
          bracoDir.text.isNotEmpty ||
          bracoEsq.text.isNotEmpty ||
          antebracoDir.text.isNotEmpty ||
          antebracoEsq.text.isNotEmpty ||
          cintura.text.isNotEmpty ||
          quadril.text.isNotEmpty ||
          torax.text.isNotEmpty ||
          cinturaEscapular.text.isNotEmpty ||
          abdome.text.isNotEmpty ||
          pantu.text.isNotEmpty ||
          coxa.text.isNotEmpty ||
          abdominal.text.isNotEmpty ||
          supraEspinal.text.isNotEmpty ||
          supraIliaca.text.isNotEmpty ||
          axilarMedia.text.isNotEmpty ||
          toracica.text.isNotEmpty ||
          subescapular.text.isNotEmpty ||
          triceps.text.isNotEmpty ||
          biceps.text.isNotEmpty ||
          obs.text.trim().isNotEmpty ||
          foto1 != null ||
          foto2 != null ||
          foto3 != null ||
          foto4 != null;

      if (!temDadosPreenchidos) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Aviso', style: TextStyle(color: Colors.white)),
              content: const Text(
                  'Preencha ao menos um campo além do título para salvar a avaliação.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Ok'),
                ),
              ],
            );
          },
        );
        return;
      }

      // Verifica se houve alterações
      bool foiAlterado = false;

      // Verifica alterações nas fotos
      bool fotosForamAlteradas = false;

      // Foto 1
      if ((widget.avaliacao.fotos == null ||
              widget.avaliacao.fotos!.isEmpty ||
              widget.avaliacao.fotos![0].isEmpty) &&
          foto1 != null) {
        fotosForamAlteradas = true;
      } else if (widget.avaliacao.fotos != null &&
          widget.avaliacao.fotos!.isNotEmpty &&
          foto1 != null &&
          !widget.avaliacao.fotos![0].startsWith('http')) {
        final fotoOriginal = base64Decode(widget.avaliacao.fotos![0]);
        if (foto1!.length != fotoOriginal.length) {
          fotosForamAlteradas = true;
        }
      } else if (widget.avaliacao.fotos != null &&
          widget.avaliacao.fotos!.isNotEmpty &&
          widget.avaliacao.fotos![0].startsWith('http') &&
          foto1 != null) {
        fotosForamAlteradas = true;
      }

      // Foto 2
      if ((widget.avaliacao.fotos == null ||
              widget.avaliacao.fotos!.length < 2 ||
              widget.avaliacao.fotos![1].isEmpty) &&
          foto2 != null) {
        fotosForamAlteradas = true;
      } else if (widget.avaliacao.fotos != null &&
          widget.avaliacao.fotos!.length > 1 &&
          foto2 != null &&
          !widget.avaliacao.fotos![1].startsWith('http')) {
        final fotoOriginal = base64Decode(widget.avaliacao.fotos![1]);
        if (foto2!.length != fotoOriginal.length) {
          fotosForamAlteradas = true;
        }
      } else if (widget.avaliacao.fotos != null &&
          widget.avaliacao.fotos!.length > 1 &&
          widget.avaliacao.fotos![1].startsWith('http') &&
          foto2 != null) {
        fotosForamAlteradas = true;
      }

      // Foto 3
      if ((widget.avaliacao.fotos == null ||
              widget.avaliacao.fotos!.length < 3 ||
              widget.avaliacao.fotos![2].isEmpty) &&
          foto3 != null) {
        fotosForamAlteradas = true;
      } else if (widget.avaliacao.fotos != null &&
          widget.avaliacao.fotos!.length > 2 &&
          foto3 != null &&
          !widget.avaliacao.fotos![2].startsWith('http')) {
        final fotoOriginal = base64Decode(widget.avaliacao.fotos![2]);
        if (foto3!.length != fotoOriginal.length) {
          fotosForamAlteradas = true;
        }
      } else if (widget.avaliacao.fotos != null &&
          widget.avaliacao.fotos!.length > 2 &&
          widget.avaliacao.fotos![2].startsWith('http') &&
          foto3 != null) {
        fotosForamAlteradas = true;
      }

      // Foto 4
      if ((widget.avaliacao.fotos == null ||
              widget.avaliacao.fotos!.length < 4 ||
              widget.avaliacao.fotos![3].isEmpty) &&
          foto4 != null) {
        fotosForamAlteradas = true;
      } else if (widget.avaliacao.fotos != null &&
          widget.avaliacao.fotos!.length > 3 &&
          foto4 != null &&
          !widget.avaliacao.fotos![3].startsWith('http')) {
        final fotoOriginal = base64Decode(widget.avaliacao.fotos![3]);
        if (foto4!.length != fotoOriginal.length) {
          fotosForamAlteradas = true;
        }
      } else if (widget.avaliacao.fotos != null &&
          widget.avaliacao.fotos!.length > 3 &&
          widget.avaliacao.fotos![3].startsWith('http') &&
          foto4 != null) {
        fotosForamAlteradas = true;
      }

      if (titulo.text.trim() != widget.avaliacao.titulo ||
          obs.text.trim() != (widget.avaliacao.obs ?? '') ||
          double.tryParse(peso.text.trim()) != widget.avaliacao.peso ||
          double.tryParse(altura.text.trim()) != widget.avaliacao.altura ||
          double.tryParse(pantDir.text.trim()) != widget.avaliacao.pantDir ||
          double.tryParse(pantEsq.text.trim()) != widget.avaliacao.pantEsq ||
          double.tryParse(coxaDir.text.trim()) != widget.avaliacao.coxaDir ||
          double.tryParse(coxaEsq.text.trim()) != widget.avaliacao.coxaEsq ||
          double.tryParse(bracoDir.text.trim()) != widget.avaliacao.bracoDir ||
          double.tryParse(bracoEsq.text.trim()) != widget.avaliacao.bracoEsq ||
          double.tryParse(antebracoDir.text.trim()) !=
              widget.avaliacao.antebracoDir ||
          double.tryParse(antebracoEsq.text.trim()) !=
              widget.avaliacao.antebracoEsq ||
          double.tryParse(cintura.text.trim()) != widget.avaliacao.cintura ||
          double.tryParse(quadril.text.trim()) != widget.avaliacao.quadril ||
          double.tryParse(torax.text.trim()) != widget.avaliacao.torax ||
          double.tryParse(cinturaEscapular.text.trim()) !=
              widget.avaliacao.cintEscapular ||
          double.tryParse(abdome.text.trim()) != widget.avaliacao.abdome ||
          double.tryParse(pantu.text.trim()) != widget.avaliacao.pantu ||
          double.tryParse(coxa.text.trim()) != widget.avaliacao.coxa ||
          double.tryParse(abdominal.text.trim()) !=
              widget.avaliacao.abdominal ||
          double.tryParse(supraEspinal.text.trim()) !=
              widget.avaliacao.supraespinal ||
          double.tryParse(supraIliaca.text.trim()) !=
              widget.avaliacao.suprailiaca ||
          double.tryParse(axilarMedia.text.trim()) !=
              widget.avaliacao.axilarMedia ||
          double.tryParse(toracica.text.trim()) != widget.avaliacao.toracica ||
          double.tryParse(subescapular.text.trim()) !=
              widget.avaliacao.subescapular ||
          double.tryParse(triceps.text.trim()) != widget.avaliacao.triciptal ||
          double.tryParse(biceps.text.trim()) != widget.avaliacao.biciptal ||
          _selectedOption != widget.avaliacao.formula ||
          fotosForamAlteradas) {
        foiAlterado = true;
      }

      // Se nada foi alterado, mostra mensagem e retorna
      if (!foiAlterado) {
        MensagemDeSucesso()
            .showSuccessSnackbar(context, 'Nenhuma alteração detectada!');
        return;
      }

      debugPrint('--------------> tem diferença (antes de salvar)');

      // Continua com a verificação de campos vazios e salvamento
      if ((peso.text.isEmpty &&
          altura.text.isEmpty &&
          pantDir.text.isEmpty &&
          pantEsq.text.isEmpty &&
          coxaDir.text.isEmpty &&
          coxaEsq.text.isEmpty &&
          bracoDir.text.isEmpty &&
          bracoEsq.text.isEmpty &&
          antebracoDir.text.isEmpty &&
          antebracoEsq.text.isEmpty &&
          cintura.text.isEmpty &&
          quadril.text.isEmpty &&
          torax.text.isEmpty &&
          cinturaEscapular.text.isEmpty &&
          abdome.text.isEmpty &&
          pantu.text.isEmpty &&
          coxa.text.isEmpty &&
          abdominal.text.isEmpty &&
          supraEspinal.text.isEmpty &&
          supraIliaca.text.isEmpty &&
          axilarMedia.text.isEmpty &&
          toracica.text.isEmpty &&
          subescapular.text.isEmpty &&
          triceps.text.isEmpty &&
          biceps.text.isEmpty &&
          foto1 == null &&
          foto2 == null &&
          foto3 == null &&
          foto4 == null)) {
        //exibir dialogo
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Aviso', style: TextStyle(color: Colors.white)),
              content: const Text(
                  'Preencha ao menos um campo de medidas para salvar a avaliação.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Ok'),
                ),
              ],
            );
          },
        );
      } else {
        List<String>? fotos = [];
        if (foto1 != null) {
          debugPrint('--------------> chegou aqui (foto)');
          final foto1base64 = base64Encode(foto1!);
          fotos.add(foto1base64);
        } else {
          fotos.add('');
        }
        if (foto2 != null) {
          final foto2base64 = base64Encode(foto2!);
          fotos.add(foto2base64);
        } else {
          fotos.add('');
        }
        if (foto3 != null) {
          final foto3base64 = base64Encode(foto3!);
          fotos.add(foto3base64);
        } else {
          fotos.add('');
        }
        if (foto4 != null) {
          final foto4base64 = base64Encode(foto4!);
          fotos.add(foto4base64);
        } else {
          fotos.add('');
        }
        DateTime timestamp = DateTime.now();

        String dataFormatada =
            DateFormat('dd/MM/yyyy HH:mm:ss', 'pt_BR').format(timestamp);

        newAvaliacao = AvaliacaoModel(
            id: widget.avaliacao.id,
            alunoUid: widget.aluno.uid,
            timestamp: dataFormatada,
            titulo: titulo.text.trim(),
            peso: double.tryParse(peso.text.trim()),
            altura: double.tryParse(altura.text.trim()),
            pantEsq: double.tryParse(pantEsq.text.trim()),
            pantDir: double.tryParse(pantDir.text.trim()),
            coxaEsq: double.tryParse(coxaEsq.text.trim()),
            coxaDir: double.tryParse(coxaDir.text.trim()),
            quadril: double.tryParse(quadril.text.trim()),
            abdome: double.tryParse(abdome.text.trim()),
            cintura: double.tryParse(cintura.text.trim()),
            cintEscapular: double.tryParse(cinturaEscapular.text.trim()),
            torax: double.tryParse(torax.text.trim()),
            bracoEsq: double.tryParse(bracoEsq.text.trim()),
            bracoDir: double.tryParse(bracoDir.text.trim()),
            antebracoEsq: double.tryParse(antebracoEsq.text.trim()),
            antebracoDir: double.tryParse(antebracoDir.text.trim()),
            pantu: double.tryParse(pantu.text.trim()),
            coxa: double.tryParse(coxa.text.trim()),
            abdominal: double.tryParse(abdominal.text.trim()),
            supraespinal: double.tryParse(supraEspinal.text.trim()),
            suprailiaca: double.tryParse(supraIliaca.text.trim()),
            toracica: double.tryParse(toracica.text.trim()),
            biciptal: double.tryParse(biceps.text.trim()),
            triciptal: double.tryParse(triceps.text.trim()),
            axilarMedia: double.tryParse(axilarMedia.text.trim()),
            subescapular: double.tryParse(subescapular.text.trim()),
            formula: _selectedOption,
            imc: imc,
            classificacaoImc: classificacaoImc,
            bf: bf,
            mm: massaMagra,
            mg: massaGorda,
            rce: rce,
            pesoIdeal: pesoIdeal,
            classificacaoRce: classificacaoRce,
            fotos: fotos,
            obs: obs.text.trim(),
            sexo: widget.aluno.sexo,
          );

        await _antropometriaServices.updateAvaliacao(
          newAvaliacao!
        );
        edit = true;
        await _firebaseMessagingService.enviarNotificacaoParaAluno(
            widget.aluno.uid,
            'Nova avaliação!',
            'Seu personal adicionou uma nova avaliação física, clique para conferir.',
            {
              'info': titulo.text.trim(),
              'infoAdicional': uid,
              'tipo': 'novaAvaliacao'
            });
        MensagemDeSucesso()
            .showSuccessSnackbar(context, 'Avalição salva com sucesso!');
        BlocProvider.of<ElevatedButtonBloc>(context).add(ElevatedButtonReset());
      }
    } catch (e) {
      debugPrint('Erro ao tentar salva avaliacao: ${e.toString()}');
      TratamentoDeErros().showErrorSnackbar(
          context, 'Erro ao tentar salvar avaliação, tente novamente!');
      BlocProvider.of<ElevatedButtonBloc>(context).add(ElevatedButtonReset());
    }
  }

  void _handleFotoChanged(Uint8List? foto, int index) {
    setState(() {
      switch (index) {
        case 0:
          foto1 = foto;
          break;
        case 1:
          foto2 = foto;
          break;
        case 2:
          foto3 = foto;
          break;
        case 3:
          foto4 = foto;
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isSmallScreen = MediaQuery.of(context).size.width < 1200;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            HeaderPrototipo(
              onSave: salvarAvaliacao,
              onBack: onBack,
              title: 'Avaliação Antropométrica',
              subtitle: 'Insira os dados coletados',
              button: 'Salvar',
              icon: false,
            ),
            const SizedBox(height: 25),
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 1400),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center, // Adicionado aqui
                crossAxisAlignment: CrossAxisAlignment.start, // Alterado aqui
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start, // Adicionado
                    children: [
                      Container(
                        width: isSmallScreen
                            ? MediaQuery.of(context).size.width * 0.55
                            : 600,
                        decoration: BoxDecoration(
                          color: Colors.grey[900],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: FormBasicoAvaliacaoWidget(
                            titulo: titulo,
                            obs: obs,
                            pesoController: peso,
                            alturaController: altura,
                            formBasicoAvaliacaoKey:
                                formBasicoAvaliacaoKey, // Nova chave aqui
                          ),
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? 15 : 25),
                      Container(
                        width: isSmallScreen
                            ? MediaQuery.of(context).size.width * 0.55
                            : 600,
                        decoration: BoxDecoration(
                          color: Colors.grey[900],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: FormMedidasAvaliacaoWidget(
                            pantDir: pantDir,
                            pantEsq: pantEsq,
                            coxaDir: coxaDir,
                            coxaEsq: coxaEsq,
                            bracoDir: bracoDir,
                            bracoEsq: bracoEsq,
                            antebracoDir: antebracoDir,
                            antebracoEsq: antebracoEsq,
                            cintura: cintura,
                            quadril: quadril,
                            torax: torax,
                            cinturaEscapular: cinturaEscapular,
                            abdome: abdome,
                            formMedidasAvaliacaoKey:
                                formMedidasAvaliacaoKey, // Nova chave aqui
                          ),
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? 15 : 25),
                      Container(
                        width: isSmallScreen
                            ? MediaQuery.of(context).size.width * 0.55
                            : 600,
                        decoration: BoxDecoration(
                          color: Colors.grey[900],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: FormAdipometriaAvaliacaoWidget(
                            pantu: pantu,
                            coxa: coxa,
                            abdominal: abdominal,
                            supraEspinal: supraEspinal,
                            supraIliaca: supraIliaca,
                            axilarMedia: axilarMedia,
                            toracica: toracica,
                            subescapular: subescapular,
                            tricipital: triceps,
                            bicipital: biceps,
                            formAvaliacaoKey: formAdipometriaAvaliacaoKey,
                          ),
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? 15 : 25),
                      SelectPhotosContainer(
                        foto1: foto1,
                        foto2: foto2,
                        foto3: foto3,
                        foto4: foto4,
                        onFotoChanged: _handleFotoChanged, // Passar o callback
                      ),
                      SizedBox(height: isSmallScreen ? 15 : 25),
                    ],
                  ),
                  SizedBox(width: isSmallScreen ? 15 : 25),
                  Column(
                    children: [
                      Container(
                        width: isSmallScreen
                            ? MediaQuery.of(context).size.width * 0.39
                            : 400,
                        decoration: BoxDecoration(
                          color: Colors.grey[900],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Selecione a fórmula',
                                style: SafeGoogleFont(
                                  'Open Sans',
                                  textStyle: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              DropdownButtonFormField<String>(
                                hint: Text(
                                  'Selecione',
                                  style: SafeGoogleFont(
                                    'Open Sans',
                                    textStyle: const TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                //cor
                                dropdownColor: Colors.grey[800],
                                value: _selectedOption,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedOption = value;
                                  });
                                },
                                items: [
                                  DropdownMenuItem(
                                    value: 'Durnin-Womersley',
                                    onTap: () {
                                      if (triceps.text.isNotEmpty &&
                                          supraIliaca.text.isNotEmpty &&
                                          subescapular.text.isNotEmpty &&
                                          biceps.text.isNotEmpty &&
                                          peso.text.isNotEmpty &&
                                          altura.text.isNotEmpty) {
                                        calcularPercentualGorduraDurninWomersley(
                                            triceps: double.parse(triceps.text),
                                            supraIliaca:
                                                double.parse(supraIliaca.text),
                                            subescapular:
                                                double.parse(subescapular.text),
                                            bicipital:
                                                double.parse(biceps.text),
                                            idade: 20,
                                            isMale: true,
                                            peso: peso.text);
                                      } else {
                                        setState(() {
                                          bf = null;
                                        });
                                      }
                                    },
                                    child: Text(
                                      'Durnin-Womersley',
                                      style: SafeGoogleFont(
                                        'Open Sans',
                                        textStyle: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Jackson e Pollock (3 dobras)',
                                    onTap: () {
                                      if (triceps.text.isNotEmpty &&
                                          supraIliaca.text.isNotEmpty &&
                                          abdominal.text.isNotEmpty &&
                                          peso.text.isNotEmpty) {
                                        calcularPercentualGorduraJacksonPollock3(
                                            triceps: double.parse(triceps.text),
                                            supraIliaca:
                                                double.parse(supraIliaca.text),
                                            abdominal:
                                                double.parse(abdominal.text),
                                            idade: 20,
                                            isMale: true);
                                      } else {
                                        setState(() {
                                          bf = null;
                                        });
                                      }
                                    },
                                    child: Text(
                                      'Jackson e Pollock (3 dobras)',
                                      style: SafeGoogleFont(
                                        'Open Sans',
                                        textStyle: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Jackson e Pollock (4 dobras)',
                                    onTap: () {
                                      if (triceps.text.isNotEmpty &&
                                          supraIliaca.text.isNotEmpty &&
                                          abdominal.text.isNotEmpty &&
                                          coxa.text.isNotEmpty &&
                                          peso.text.isNotEmpty) {
                                        calcularPercentualGorduraJacksonPollock4(
                                            triceps: double.parse(triceps.text),
                                            supraIliaca:
                                                double.parse(supraIliaca.text),
                                            abdominal:
                                                double.parse(abdominal.text),
                                            coxa: double.parse(coxa.text),
                                            idade: 20,
                                            isMale: true);
                                      } else {
                                        setState(() {
                                          bf = null;
                                        });
                                      }
                                    },
                                    child: Text(
                                      'Jackson e Pollock (4 dobras)',
                                      style: SafeGoogleFont(
                                        'Open Sans',
                                        textStyle: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Jackson e Pollock (7 dobras)',
                                    onTap: () {
                                      if (triceps.text.isNotEmpty &&
                                          subescapular.text.isNotEmpty &&
                                          toracica.text.isNotEmpty &&
                                          axilarMedia.text.isNotEmpty &&
                                          supraIliaca.text.isNotEmpty &&
                                          abdominal.text.isNotEmpty &&
                                          coxa.text.isNotEmpty &&
                                          peso.text.isNotEmpty &&
                                          altura.text.isNotEmpty) {
                                        calcularPercentualGorduraJacksonPollock7(
                                            triceps: double.parse(triceps.text),
                                            subescapular:
                                                double.parse(subescapular.text),
                                            toracica:
                                                double.parse(toracica.text),
                                            axilarMedia:
                                                double.parse(axilarMedia.text),
                                            supraIliaca:
                                                double.parse(supraIliaca.text),
                                            abdominal:
                                                double.parse(abdominal.text),
                                            coxa: double.parse(coxa.text),
                                            idade: 20,
                                            isMale: true);
                                      } else {
                                        setState(() {
                                          bf = null;
                                        });
                                      }
                                    },
                                    child: Text(
                                      'Jackson e Pollock (7 dobras)',
                                      style: SafeGoogleFont(
                                        'Open Sans',
                                        textStyle: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide.none,
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[800],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? 15 : 25),
                      ResultadosContainer(
                        imc: imc,
                        classificacaoImc: classificacaoImc,
                        rce: rce,
                        classificacaoRce: classificacaoRce,
                        bf: bf,
                        massaMagra: massaMagra,
                        massaGorda: massaGorda,
                        pesoIdeal: pesoIdeal,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void pesoControllerListener() {
    peso.addListener(() {
      if (peso.text.isNotEmpty && altura.text.isNotEmpty) {
        double resultado = _antropometriaServices.calcularIMC(
          double.parse(peso.text),
          double.parse(altura.text),
        );

        setState(() {
          imc = resultado;
          if (imc != null) {
            classificacaoImc = _antropometriaServices.classificarIMC(imc!);
          }
        });
      }
    });
  }

  void alturaControllerListener() {
    altura.addListener(() {
      if (altura.text.isNotEmpty) {
        double resultado =
            _antropometriaServices.calcularPesoIdeal(double.parse(altura.text));
        setState(() {
          pesoIdeal = resultado;
        });

        if (peso.text.isNotEmpty) {
          double resultado2 = _antropometriaServices.calcularIMC(
            double.parse(peso.text),
            double.parse(altura.text),
          );

          setState(() {
            imc = resultado2;
            if (imc != null) {
              classificacaoImc = _antropometriaServices.classificarIMC(imc!);
            }
          });
        }
      }
      if (altura.text.isNotEmpty && cintura.text.isNotEmpty) {
        double resultado3 = _antropometriaServices.calcularRCE(
          double.parse(cintura.text),
          double.parse(altura.text),
        );

        setState(
          () {
            rce = resultado3;

            if (rce != null) {
              classificacaoRce = _antropometriaServices.classificarRCE(rce!);
            }
          },
        );
      }
    });
  }

  void rceCinturaControllerListener() {
    cintura.addListener(() {
      if (altura.text.isNotEmpty && cintura.text.isNotEmpty) {
        double resultado = _antropometriaServices.calcularRCE(
          double.parse(cintura.text),
          double.parse(altura.text),
        );

        setState(
          () {
            rce = resultado;

            if (rce != null) {
              classificacaoRce = _antropometriaServices.classificarRCE(rce!);
            }
          },
        );
      }
    });
  }

  void tricepsListener() {
    triceps.addListener(() {
      if (_selectedOption == 'Durnin-Womersley') {
        if (triceps.text.isNotEmpty &&
            subescapular.text.isNotEmpty &&
            supraIliaca.text.isNotEmpty &&
            biceps.text.isNotEmpty) {
          setState(() {
            double resultado =
                _antropometriaServices.calcularPercentualGorduraDurninWomersley(
                    double.parse(triceps.text),
                    double.parse(supraIliaca.text),
                    double.parse(subescapular.text),
                    double.parse(biceps.text),
                    20,
                    true);

            setState(
              () {
                bf = resultado;

                if (bf != null && peso.text.isNotEmpty) {
                  massaMagra = _antropometriaServices.calcularMassaMagra(
                    double.parse(peso.text),
                    bf!,
                  );
                  massaGorda = _antropometriaServices.calcularMassaGorda(
                    double.parse(peso.text),
                    bf!,
                  );
                }
              },
            );
          });
        } else {
          setState(() {
            bf = null;
          });
        }
      } else if (_selectedOption == 'Jackson e Pollock (3 dobras)') {
        if (triceps.text.isNotEmpty &&
            supraIliaca.text.isNotEmpty &&
            abdominal.text.isNotEmpty &&
            peso.text.isNotEmpty) {
          double resultado =
              _antropometriaServices.calcularPercentualGorduraJacksonPollock3(
                  double.parse(triceps.text),
                  double.parse(supraIliaca.text),
                  double.parse(abdominal.text),
                  20,
                  true);

          setState(
            () {
              bf = resultado;

              if (bf != null && peso.text.isNotEmpty) {
                massaMagra = _antropometriaServices.calcularMassaMagra(
                    double.parse(peso.text), bf!);
                massaGorda = _antropometriaServices.calcularMassaGorda(
                    double.parse(peso.text), bf!);
              }
            },
          );
        } else {
          setState(() {
            bf = null;
          });
        }
      } else if (_selectedOption == 'Jackson e Pollock (4 dobras)') {
        if (triceps.text.isNotEmpty &&
            supraIliaca.text.isNotEmpty &&
            abdominal.text.isNotEmpty &&
            coxa.text.isNotEmpty) {
          double resultado =
              _antropometriaServices.calcularPercentualGorduraJacksonPollock4(
                  double.parse(triceps.text),
                  double.parse(supraIliaca.text),
                  double.parse(abdominal.text),
                  double.parse(coxa.text),
                  20,
                  true);

          setState(
            () {
              bf = resultado;

              if (bf != null && peso.text.isNotEmpty) {
                massaMagra = _antropometriaServices.calcularMassaMagra(
                    double.parse(peso.text), bf!);
                massaGorda = _antropometriaServices.calcularMassaGorda(
                    double.parse(peso.text), bf!);
              }
            },
          );
        } else {
          setState(() {
            bf = null;
          });
        }
      } else if (_selectedOption == 'Jackson e Pollock (7 dobras)') {
        if (triceps.text.isNotEmpty &&
            subescapular.text.isNotEmpty &&
            toracica.text.isNotEmpty &&
            axilarMedia.text.isNotEmpty &&
            supraIliaca.text.isNotEmpty &&
            abdominal.text.isNotEmpty &&
            coxa.text.isNotEmpty &&
            peso.text.isNotEmpty &&
            altura.text.isNotEmpty) {
          double resultado =
              _antropometriaServices.calcularPercentualGorduraJacksonPollock7(
                  double.parse(triceps.text),
                  double.parse(subescapular.text),
                  double.parse(toracica.text),
                  double.parse(axilarMedia.text),
                  double.parse(supraIliaca.text),
                  double.parse(abdominal.text),
                  double.parse(coxa.text),
                  20,
                  true);

          setState(
            () {
              bf = resultado;

              if (bf != null && peso.text.isNotEmpty) {
                massaMagra = _antropometriaServices.calcularMassaMagra(
                    double.parse(peso.text), bf!);
                massaGorda = _antropometriaServices.calcularMassaGorda(
                    double.parse(peso.text), bf!);
              }
            },
          );
        } else {
          setState(() {
            bf = null;
          });
        }
      }
    });
  }

  void subescapularListener() {
    subescapular.addListener(() {
      if (_selectedOption == 'Durnin-Womersley') {
        if (triceps.text.isNotEmpty &&
            subescapular.text.isNotEmpty &&
            supraIliaca.text.isNotEmpty &&
            biceps.text.isNotEmpty) {
          double resultado =
              _antropometriaServices.calcularPercentualGorduraDurninWomersley(
                  double.parse(triceps.text),
                  double.parse(supraIliaca.text),
                  double.parse(subescapular.text),
                  double.parse(biceps.text),
                  20,
                  true);

          setState(
            () {
              bf = resultado;

              if (bf != null && peso.text.isNotEmpty) {
                massaMagra = _antropometriaServices.calcularMassaMagra(
                  double.parse(peso.text),
                  bf!,
                );
                massaGorda = _antropometriaServices.calcularMassaGorda(
                  double.parse(peso.text),
                  bf!,
                );
              }
            },
          );
        } else {
          setState(() {
            bf = null;
          });
        }
      } else if (_selectedOption == 'Jackson e Pollock (7 dobras)') {
        if (triceps.text.isNotEmpty &&
            subescapular.text.isNotEmpty &&
            toracica.text.isNotEmpty &&
            axilarMedia.text.isNotEmpty &&
            supraIliaca.text.isNotEmpty &&
            abdominal.text.isNotEmpty &&
            coxa.text.isNotEmpty) {
          double resultado =
              _antropometriaServices.calcularPercentualGorduraJacksonPollock7(
                  double.parse(triceps.text),
                  double.parse(subescapular.text),
                  double.parse(toracica.text),
                  double.parse(axilarMedia.text),
                  double.parse(supraIliaca.text),
                  double.parse(abdominal.text),
                  double.parse(coxa.text),
                  20,
                  true);

          setState(
            () {
              bf = resultado;

              if (bf != null && peso.text.isNotEmpty) {
                massaMagra = _antropometriaServices.calcularMassaMagra(
                  double.parse(peso.text),
                  bf!,
                );
                massaGorda = _antropometriaServices.calcularMassaGorda(
                  double.parse(peso.text),
                  bf!,
                );
              }
            },
          );
        } else {
          setState(() {
            bf = null;
          });
        }
      }
    });
  }

  void supraIliacaListener() {
    supraIliaca.addListener(() {
      if (_selectedOption == 'Durnin-Womersley') {
        if (triceps.text.isNotEmpty &&
            subescapular.text.isNotEmpty &&
            supraIliaca.text.isNotEmpty &&
            biceps.text.isNotEmpty) {
          setState(() {
            double resultado =
                _antropometriaServices.calcularPercentualGorduraDurninWomersley(
                    double.parse(triceps.text),
                    double.parse(supraIliaca.text),
                    double.parse(subescapular.text),
                    double.parse(biceps.text),
                    20,
                    true);

            setState(
              () {
                bf = resultado;

                if (bf != null && peso.text.isNotEmpty) {
                  massaMagra = _antropometriaServices.calcularMassaMagra(
                    double.parse(peso.text),
                    bf!,
                  );
                  massaGorda = _antropometriaServices.calcularMassaGorda(
                    double.parse(peso.text),
                    bf!,
                  );
                }
              },
            );
          });
        } else {
          setState(() {
            bf = null;
          });
        }
      } else if (_selectedOption == 'Jackson e Pollock (3 dobras)') {
        if (triceps.text.isNotEmpty &&
            supraIliaca.text.isNotEmpty &&
            abdominal.text.isNotEmpty) {
          double resultado =
              _antropometriaServices.calcularPercentualGorduraJacksonPollock3(
                  double.parse(triceps.text),
                  double.parse(supraIliaca.text),
                  double.parse(abdominal.text),
                  20,
                  true);

          setState(
            () {
              bf = resultado;

              if (bf != null && peso.text.isNotEmpty) {
                massaMagra = _antropometriaServices.calcularMassaMagra(
                    double.parse(peso.text), bf!);
                massaGorda = _antropometriaServices.calcularMassaGorda(
                    double.parse(peso.text), bf!);
              }
            },
          );
        } else {
          setState(() {
            bf = null;
          });
        }
      } else if (_selectedOption == 'Jackson e Pollock (4 dobras)') {
        if (triceps.text.isNotEmpty &&
            supraIliaca.text.isNotEmpty &&
            abdominal.text.isNotEmpty &&
            coxa.text.isNotEmpty) {
          double resultado =
              _antropometriaServices.calcularPercentualGorduraJacksonPollock4(
                  double.parse(triceps.text),
                  double.parse(supraIliaca.text),
                  double.parse(abdominal.text),
                  double.parse(coxa.text),
                  20,
                  true);

          setState(
            () {
              bf = resultado;

              if (bf != null && peso.text.isNotEmpty) {
                massaMagra = _antropometriaServices.calcularMassaMagra(
                    double.parse(peso.text), bf!);
                massaGorda = _antropometriaServices.calcularMassaGorda(
                    double.parse(peso.text), bf!);
              }
            },
          );
        } else {
          setState(() {
            bf = null;
          });
        }
      } else if (_selectedOption == 'Jackson e Pollock (7 dobras)') {
        if (triceps.text.isNotEmpty &&
            subescapular.text.isNotEmpty &&
            toracica.text.isNotEmpty &&
            axilarMedia.text.isNotEmpty &&
            supraIliaca.text.isNotEmpty &&
            abdominal.text.isNotEmpty &&
            coxa.text.isNotEmpty) {
          double resultado =
              _antropometriaServices.calcularPercentualGorduraJacksonPollock7(
                  double.parse(triceps.text),
                  double.parse(subescapular.text),
                  double.parse(toracica.text),
                  double.parse(axilarMedia.text),
                  double.parse(supraIliaca.text),
                  double.parse(abdominal.text),
                  double.parse(coxa.text),
                  20,
                  true);

          setState(
            () {
              bf = resultado;

              if (bf != null && peso.text.isNotEmpty) {
                massaMagra = _antropometriaServices.calcularMassaMagra(
                    double.parse(peso.text), bf!);
                massaGorda = _antropometriaServices.calcularMassaGorda(
                    double.parse(peso.text), bf!);
              }
            },
          );
        } else {
          setState(() {
            bf = null;
          });
        }
      }
    });
  }

  void bicepsListener() {
    biceps.addListener(() {
      if (_selectedOption == 'Durnin-Womersley') {
        if (triceps.text.isNotEmpty &&
            subescapular.text.isNotEmpty &&
            supraIliaca.text.isNotEmpty &&
            biceps.text.isNotEmpty) {
          setState(() {
            double resultado =
                _antropometriaServices.calcularPercentualGorduraDurninWomersley(
                    double.parse(triceps.text),
                    double.parse(supraIliaca.text),
                    double.parse(subescapular.text),
                    double.parse(biceps.text),
                    20,
                    true);

            setState(
              () {
                bf = resultado;

                if (bf != null && peso.text.isNotEmpty) {
                  massaMagra = _antropometriaServices.calcularMassaMagra(
                    double.parse(peso.text),
                    bf!,
                  );
                  massaGorda = _antropometriaServices.calcularMassaGorda(
                    double.parse(peso.text),
                    bf!,
                  );
                }
              },
            );
          });
        } else {
          setState(() {
            bf = null;
          });
        }
      }
    });
  }

  void abdomenListener() {
    abdominal.addListener(() {
      if (_selectedOption == 'Jackson e Pollock (3 dobras)') {
        if (triceps.text.isNotEmpty &&
            supraIliaca.text.isNotEmpty &&
            abdominal.text.isNotEmpty) {
          double resultado =
              _antropometriaServices.calcularPercentualGorduraJacksonPollock3(
                  double.parse(triceps.text),
                  double.parse(supraIliaca.text),
                  double.parse(abdominal.text),
                  20,
                  true);

          setState(
            () {
              bf = resultado;

              if (bf != null && peso.text.isNotEmpty) {
                massaMagra = _antropometriaServices.calcularMassaMagra(
                    double.parse(peso.text), bf!);
                massaGorda = _antropometriaServices.calcularMassaGorda(
                    double.parse(peso.text), bf!);
              }
            },
          );
        } else {
          setState(() {
            bf = null;
          });
        }
      } else if (_selectedOption == 'Jackson e Pollock (4 dobras)') {
        if (triceps.text.isNotEmpty &&
            supraIliaca.text.isNotEmpty &&
            abdominal.text.isNotEmpty &&
            coxa.text.isNotEmpty) {
          double resultado =
              _antropometriaServices.calcularPercentualGorduraJacksonPollock4(
                  double.parse(triceps.text),
                  double.parse(supraIliaca.text),
                  double.parse(abdominal.text),
                  double.parse(coxa.text),
                  20,
                  true);

          setState(
            () {
              bf = resultado;

              if (bf != null && peso.text.isNotEmpty) {
                massaMagra = _antropometriaServices.calcularMassaMagra(
                    double.parse(peso.text), bf!);
                massaGorda = _antropometriaServices.calcularMassaGorda(
                    double.parse(peso.text), bf!);
              }
            },
          );
        } else {
          setState(() {
            bf = null;
          });
        }
      } else if (_selectedOption == 'Jackson e Pollock (7 dobras)') {
        if (triceps.text.isNotEmpty &&
            subescapular.text.isNotEmpty &&
            toracica.text.isNotEmpty &&
            axilarMedia.text.isNotEmpty &&
            supraIliaca.text.isNotEmpty &&
            abdominal.text.isNotEmpty &&
            coxa.text.isNotEmpty) {
          double resultado =
              _antropometriaServices.calcularPercentualGorduraJacksonPollock7(
                  double.parse(triceps.text),
                  double.parse(subescapular.text),
                  double.parse(toracica.text),
                  double.parse(axilarMedia.text),
                  double.parse(supraIliaca.text),
                  double.parse(abdominal.text),
                  double.parse(coxa.text),
                  20,
                  true);

          setState(
            () {
              bf = resultado;

              if (bf != null && peso.text.isNotEmpty) {
                massaMagra = _antropometriaServices.calcularMassaMagra(
                    double.parse(peso.text), bf!);
                massaGorda = _antropometriaServices.calcularMassaGorda(
                    double.parse(peso.text), bf!);
              }
            },
          );
        } else {
          setState(() {
            bf = null;
          });
        }
      }
    });
  }

  void coxaListener() {
    coxa.addListener(() {
      if (_selectedOption == 'Jackson e Pollock (4 dobras)') {
        if (triceps.text.isNotEmpty &&
            supraIliaca.text.isNotEmpty &&
            abdominal.text.isNotEmpty &&
            coxa.text.isNotEmpty) {
          double resultado =
              _antropometriaServices.calcularPercentualGorduraJacksonPollock4(
                  double.parse(triceps.text),
                  double.parse(supraIliaca.text),
                  double.parse(abdominal.text),
                  double.parse(coxa.text),
                  20,
                  true);

          setState(
            () {
              bf = resultado;

              if (bf != null && peso.text.isNotEmpty) {
                massaMagra = _antropometriaServices.calcularMassaMagra(
                    double.parse(peso.text), bf!);
                massaGorda = _antropometriaServices.calcularMassaGorda(
                    double.parse(peso.text), bf!);
              }
            },
          );
        } else {
          setState(() {
            bf = null;
          });
        }
      } else if (_selectedOption == 'Jackson e Pollock (7 dobras)') {
        if (triceps.text.isNotEmpty &&
            subescapular.text.isNotEmpty &&
            toracica.text.isNotEmpty &&
            axilarMedia.text.isNotEmpty &&
            supraIliaca.text.isNotEmpty &&
            abdominal.text.isNotEmpty &&
            coxa.text.isNotEmpty) {
          double resultado =
              _antropometriaServices.calcularPercentualGorduraJacksonPollock7(
                  double.parse(triceps.text),
                  double.parse(subescapular.text),
                  double.parse(toracica.text),
                  double.parse(axilarMedia.text),
                  double.parse(supraIliaca.text),
                  double.parse(abdominal.text),
                  double.parse(coxa.text),
                  20,
                  true);

          setState(
            () {
              bf = resultado;

              if (bf != null && peso.text.isNotEmpty) {
                massaMagra = _antropometriaServices.calcularMassaMagra(
                    double.parse(peso.text), bf!);
                massaGorda = _antropometriaServices.calcularMassaGorda(
                    double.parse(peso.text), bf!);
              }
            },
          );
        } else {
          setState(() {
            bf = null;
          });
        }
      }
    });
  }

  void toracicaListener() {
    toracica.addListener(() {
      if (_selectedOption == 'Jackson e Pollock (7 dobras)') {
        if (triceps.text.isNotEmpty &&
            subescapular.text.isNotEmpty &&
            toracica.text.isNotEmpty &&
            axilarMedia.text.isNotEmpty &&
            supraIliaca.text.isNotEmpty &&
            abdominal.text.isNotEmpty &&
            coxa.text.isNotEmpty) {
          double resultado =
              _antropometriaServices.calcularPercentualGorduraJacksonPollock7(
                  double.parse(triceps.text),
                  double.parse(subescapular.text),
                  double.parse(toracica.text),
                  double.parse(axilarMedia.text),
                  double.parse(supraIliaca.text),
                  double.parse(abdominal.text),
                  double.parse(coxa.text),
                  20,
                  true);

          setState(
            () {
              bf = resultado;

              if (bf != null && peso.text.isNotEmpty) {
                massaMagra = _antropometriaServices.calcularMassaMagra(
                    double.parse(peso.text), bf!);
                massaGorda = _antropometriaServices.calcularMassaGorda(
                    double.parse(peso.text), bf!);
              }
            },
          );
        } else {
          setState(() {
            bf = null;
          });
        }
      }
    });
  }

  void axilarMediaListener() {
    axilarMedia.addListener(() {
      if (_selectedOption == 'Jackson e Pollock (7 dobras)') {
        if (triceps.text.isNotEmpty &&
            subescapular.text.isNotEmpty &&
            toracica.text.isNotEmpty &&
            axilarMedia.text.isNotEmpty &&
            supraIliaca.text.isNotEmpty &&
            abdominal.text.isNotEmpty &&
            coxa.text.isNotEmpty) {
          double resultado =
              _antropometriaServices.calcularPercentualGorduraJacksonPollock7(
                  double.parse(triceps.text),
                  double.parse(subescapular.text),
                  double.parse(toracica.text),
                  double.parse(axilarMedia.text),
                  double.parse(supraIliaca.text),
                  double.parse(abdominal.text),
                  double.parse(coxa.text),
                  20,
                  true);

          setState(() {
            bf = resultado;

            if (bf != null && peso.text.isNotEmpty) {
              massaMagra = _antropometriaServices.calcularMassaMagra(
                  double.parse(peso.text), bf!);
              massaGorda = _antropometriaServices.calcularMassaGorda(
                  double.parse(peso.text), bf!);
            }
          });
        } else {
          setState(() {
            bf = null;
          });
        }
      }
    });
  }

  void calcularPercentualGorduraDurninWomersley(
      {required double triceps,
      required double supraIliaca,
      required double subescapular,
      required double bicipital,
      required int idade,
      required bool isMale,
      required String peso}) {
    double resultado =
        _antropometriaServices.calcularPercentualGorduraDurninWomersley(
      triceps,
      supraIliaca,
      subescapular,
      bicipital,
      idade,
      isMale,
    );

    setState(
      () {
        bf = resultado;

        if (bf != null && peso.isNotEmpty) {
          massaMagra = _antropometriaServices.calcularMassaMagra(
            double.parse(peso),
            bf!,
          );
          massaGorda = _antropometriaServices.calcularMassaGorda(
            double.parse(peso),
            bf!,
          );
        }
      },
    );
  }

  void calcularPercentualGorduraJacksonPollock3(
      {required double triceps,
      required double supraIliaca,
      required double abdominal,
      required int idade,
      required bool isMale}) {
    double resultado =
        _antropometriaServices.calcularPercentualGorduraJacksonPollock3(
      triceps,
      supraIliaca,
      abdominal,
      idade,
      isMale,
    );

    setState(
      () {
        bf = resultado;

        if (bf != null && peso.text.isNotEmpty) {
          massaMagra = _antropometriaServices.calcularMassaMagra(
            double.parse(peso.text),
            bf!,
          );
          massaGorda = _antropometriaServices.calcularMassaGorda(
            double.parse(peso.text),
            bf!,
          );
        }
      },
    );
  }

  void calcularPercentualGorduraJacksonPollock4(
      {required double triceps,
      required double supraIliaca,
      required double abdominal,
      required double coxa,
      required int idade,
      required bool isMale}) {
    double resultado =
        _antropometriaServices.calcularPercentualGorduraJacksonPollock4(
      triceps,
      supraIliaca,
      abdominal,
      coxa,
      idade,
      isMale,
    );

    setState(
      () {
        bf = resultado;

        if (bf != null && peso.text.isNotEmpty) {
          massaMagra = _antropometriaServices.calcularMassaMagra(
            double.parse(peso.text),
            bf!,
          );
          massaGorda = _antropometriaServices.calcularMassaGorda(
            double.parse(peso.text),
            bf!,
          );
        }
      },
    );
  }

  void calcularPercentualGorduraJacksonPollock7(
      {required double triceps,
      required double subescapular,
      required double toracica,
      required double axilarMedia,
      required double supraIliaca,
      required double abdominal,
      required double coxa,
      required int idade,
      required bool isMale}) {
    double resultado =
        _antropometriaServices.calcularPercentualGorduraJacksonPollock7(
      triceps,
      subescapular,
      toracica,
      axilarMedia,
      supraIliaca,
      abdominal,
      coxa,
      idade,
      isMale,
    );

    setState(
      () {
        bf = resultado;

        if (bf != null && peso.text.isNotEmpty) {
          massaMagra = _antropometriaServices.calcularMassaMagra(
            double.parse(peso.text),
            bf!,
          );
          massaGorda = _antropometriaServices.calcularMassaGorda(
            double.parse(peso.text),
            bf!,
          );
        }
      },
    );
  }
}
