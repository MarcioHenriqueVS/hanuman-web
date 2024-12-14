import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../autenticacao/tratamento/error_snackbar.dart';
import '../../../autenticacao/tratamento/success_snackbar.dart';
import '../../../notificacoes/fcm.dart';
import '../../../utils.dart';
import '../../../widgets_comuns/button_bloc/elevated_button_bloc.dart';
import '../../../widgets_comuns/button_bloc/elevated_button_bloc_event.dart';
import '../../../widgets_comuns/button_bloc/elevated_button_bloc_state.dart';
import '../../antropometria/bloc/get_foto_avaliacao/get_foto_avaliacao_bloc.dart';
import '../../antropometria/models/avaliacao_model.dart';
import '../../antropometria/services/antropometria_services.dart';
import '../../antropometria/services/pdf_avaliacao_service.dart';
import '../../antropometria/services/pdf_viewer_service.dart';
import '../../antropometria/widgets/measurement_text_field.dart';
import '../../models/aluno_model.dart';
import '../components/add_foto_widget.dart';
import '../components/build_text_form_field_widget.dart';
import '../components/change_foto_avaliacao.dart';

class AddAvaliacaoPage extends StatefulWidget {
  final AlunoModel aluno;
  const AddAvaliacaoPage({super.key, required this.aluno});

  @override
  State<AddAvaliacaoPage> createState() => _AddAvaliacaoPageState();
}

class _AddAvaliacaoPageState extends State<AddAvaliacaoPage> {
    final AntropometriaServices _antropometriaServices = AntropometriaServices();
  final FirebaseMessagingService _firebaseMessagingService =
      FirebaseMessagingService();
  final uid = FirebaseAuth.instance.currentUser!.uid;

  final GlobalKey<FormState> formAvaliacaoKey = GlobalKey<FormState>();

  TextEditingController titulo = TextEditingController();
  TextEditingController obs = TextEditingController();

  TextEditingController peso = TextEditingController();
  TextEditingController altura = TextEditingController();

  //circunferencias controllers
  TextEditingController pantDir = TextEditingController();
  TextEditingController pantEsq = TextEditingController();
  TextEditingController coxaDir = TextEditingController();
  TextEditingController coxaEsq = TextEditingController();
  TextEditingController quadril = TextEditingController();
  TextEditingController cintura = TextEditingController();
  TextEditingController cinturaEscapular = TextEditingController();
  TextEditingController torax = TextEditingController();
  TextEditingController bracoDir = TextEditingController();
  TextEditingController bracoEsq = TextEditingController();
  TextEditingController anteBracoDir = TextEditingController();
  TextEditingController anteBracoEsq = TextEditingController();

  //adipometriaControllers
  TextEditingController triceps = TextEditingController();
  TextEditingController subescapular = TextEditingController();
  TextEditingController biceps = TextEditingController();
  TextEditingController axilarMedia = TextEditingController();
  TextEditingController toracica = TextEditingController();
  TextEditingController supraIliaca = TextEditingController();
  TextEditingController supraEspinal = TextEditingController();
  TextEditingController coxa = TextEditingController();
  TextEditingController panturrilha = TextEditingController();
  TextEditingController abdominal = TextEditingController();

  String? _selectedOption;
  double? bf;
  double? imc;
  String? classificacaoImc;
  double? rce;
  String? classificacaoRce;
  double? massaMagra;
  double? massaGorda;

  Uint8List? foto1;
  Uint8List? foto2;
  Uint8List? foto3;
  Uint8List? foto4;

  bool isSwitched = false;

  @override
  void initState() {
    imcPesoControllerListener();
    imcRceAlturaControllerListener();
    rceCinturaControllerListener();
    bicepsListener();
    tricepsListener();
    subescapularListener();
    supraIliacaListener();
    abdomenListener();
    coxaListener();
    toracicaListener();
    axilarMediaListener();
    super.initState();
  }

  void imcPesoControllerListener() {
    peso.addListener(() {
      if (peso.text.isNotEmpty && altura.text.isNotEmpty) {
        setState(() {
          calcularIMC(
            peso: double.parse(peso.text),
            altura: double.parse(altura.text),
          );
        });
      }
    });
  }

  void imcRceAlturaControllerListener() {
    altura.addListener(() {
      if (peso.text.isNotEmpty && altura.text.isNotEmpty) {
        setState(() {
          calcularIMC(
            peso: double.parse(peso.text),
            altura: double.parse(altura.text),
          );
        });
      }
      if (altura.text.isNotEmpty && cintura.text.isNotEmpty) {
        setState(() {
          calcularRCE(
            double.parse(cintura.text),
            double.parse(altura.text),
          );
        });
      }
    });
  }

  void rceCinturaControllerListener() {
    cintura.addListener(() {
      if (altura.text.isNotEmpty && cintura.text.isNotEmpty) {
        setState(() {
          calcularRCE(
            double.parse(cintura.text),
            double.parse(altura.text),
          );
        });
      }
    });
  }

  void tricepsListener() {
    triceps.addListener(() {
      if (_selectedOption == 'Durnin-Womersley') {
        if (triceps.text.isNotEmpty &&
            subescapular.text.isNotEmpty &&
            supraIliaca.text.isNotEmpty &&
            biceps.text.isNotEmpty &&
            peso.text.isNotEmpty &&
            altura.text.isNotEmpty) {
          setState(() {
            calcularPercentualGorduraDurninWomersley(
                triceps: double.parse(triceps.text),
                supraIliaca: double.parse(supraIliaca.text),
                subescapular: double.parse(subescapular.text),
                bicipital: double.parse(biceps.text),
                idade: 20,
                isMale: true,
                peso: peso.text);
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
            peso.text.isNotEmpty &&
            altura.text.isNotEmpty) {
          calcularPercentualGorduraJacksonPollock3(
              triceps: double.parse(triceps.text),
              supraIliaca: double.parse(supraIliaca.text),
              abdominal: double.parse(abdominal.text),
              idade: 20,
              isMale: true,
              peso: peso.text);
        } else {
          setState(() {
            bf = null;
          });
        }
      } else if (_selectedOption == 'Jackson e Pollock (4 dobras)') {
        if (triceps.text.isNotEmpty &&
            supraIliaca.text.isNotEmpty &&
            abdominal.text.isNotEmpty &&
            coxa.text.isNotEmpty &&
            peso.text.isNotEmpty &&
            altura.text.isNotEmpty) {
          calcularPercentualGorduraJacksonPollock4(
              triceps: double.parse(triceps.text),
              supraIliaca: double.parse(supraIliaca.text),
              abdominal: double.parse(abdominal.text),
              coxa: double.parse(coxa.text),
              idade: 20,
              isMale: true,
              peso: peso.text);
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
          calcularPercentualGorduraJacksonPollock7(
              triceps: double.parse(triceps.text),
              subescapular: double.parse(subescapular.text),
              peitoral: double.parse(toracica.text),
              axilarMedio: double.parse(axilarMedia.text),
              supraIliaca: double.parse(supraIliaca.text),
              abdominal: double.parse(abdominal.text),
              coxa: double.parse(coxa.text),
              idade: 20,
              isMale: true,
              peso: peso.text);
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
            biceps.text.isNotEmpty &&
            peso.text.isNotEmpty &&
            altura.text.isNotEmpty) {
          setState(() {
            calcularPercentualGorduraDurninWomersley(
                triceps: double.parse(triceps.text),
                supraIliaca: double.parse(supraIliaca.text),
                subescapular: double.parse(subescapular.text),
                bicipital: double.parse(biceps.text),
                idade: 20,
                isMale: true,
                peso: peso.text);
          });
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
          calcularPercentualGorduraJacksonPollock7(
              triceps: double.parse(triceps.text),
              subescapular: double.parse(subescapular.text),
              peitoral: double.parse(toracica.text),
              axilarMedio: double.parse(axilarMedia.text),
              supraIliaca: double.parse(supraIliaca.text),
              abdominal: double.parse(abdominal.text),
              coxa: double.parse(coxa.text),
              idade: 20,
              isMale: true,
              peso: peso.text);
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
            biceps.text.isNotEmpty &&
            peso.text.isNotEmpty &&
            altura.text.isNotEmpty) {
          setState(() {
            calcularPercentualGorduraDurninWomersley(
                triceps: double.parse(triceps.text),
                supraIliaca: double.parse(supraIliaca.text),
                subescapular: double.parse(subescapular.text),
                bicipital: double.parse(biceps.text),
                idade: 20,
                isMale: true,
                peso: peso.text);
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
            peso.text.isNotEmpty &&
            altura.text.isNotEmpty) {
          calcularPercentualGorduraJacksonPollock3(
              triceps: double.parse(triceps.text),
              supraIliaca: double.parse(supraIliaca.text),
              abdominal: double.parse(abdominal.text),
              idade: 20,
              isMale: true,
              peso: peso.text);
        } else {
          setState(() {
            bf = null;
          });
        }
      } else if (_selectedOption == 'Jackson e Pollock (4 dobras)') {
        if (triceps.text.isNotEmpty &&
            supraIliaca.text.isNotEmpty &&
            abdominal.text.isNotEmpty &&
            coxa.text.isNotEmpty &&
            peso.text.isNotEmpty &&
            altura.text.isNotEmpty) {
          calcularPercentualGorduraJacksonPollock4(
              triceps: double.parse(triceps.text),
              supraIliaca: double.parse(supraIliaca.text),
              abdominal: double.parse(abdominal.text),
              coxa: double.parse(coxa.text),
              idade: 20,
              isMale: true,
              peso: peso.text);
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
          calcularPercentualGorduraJacksonPollock7(
              triceps: double.parse(triceps.text),
              subescapular: double.parse(subescapular.text),
              peitoral: double.parse(toracica.text),
              axilarMedio: double.parse(axilarMedia.text),
              supraIliaca: double.parse(supraIliaca.text),
              abdominal: double.parse(abdominal.text),
              coxa: double.parse(coxa.text),
              idade: 20,
              isMale: true,
              peso: peso.text);
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
            biceps.text.isNotEmpty &&
            peso.text.isNotEmpty &&
            altura.text.isNotEmpty) {
          setState(() {
            calcularPercentualGorduraDurninWomersley(
                triceps: double.parse(triceps.text),
                supraIliaca: double.parse(supraIliaca.text),
                subescapular: double.parse(subescapular.text),
                bicipital: double.parse(biceps.text),
                idade: 20,
                isMale: true,
                peso: peso.text);
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
            abdominal.text.isNotEmpty &&
            peso.text.isNotEmpty &&
            altura.text.isNotEmpty) {
          calcularPercentualGorduraJacksonPollock3(
              triceps: double.parse(triceps.text),
              supraIliaca: double.parse(supraIliaca.text),
              abdominal: double.parse(abdominal.text),
              idade: 20,
              isMale: true,
              peso: peso.text);
        } else {
          setState(() {
            bf = null;
          });
        }
      } else if (_selectedOption == 'Jackson e Pollock (4 dobras)') {
        if (triceps.text.isNotEmpty &&
            supraIliaca.text.isNotEmpty &&
            abdominal.text.isNotEmpty &&
            coxa.text.isNotEmpty &&
            peso.text.isNotEmpty &&
            altura.text.isNotEmpty) {
          calcularPercentualGorduraJacksonPollock4(
              triceps: double.parse(triceps.text),
              supraIliaca: double.parse(supraIliaca.text),
              abdominal: double.parse(abdominal.text),
              coxa: double.parse(coxa.text),
              idade: 20,
              isMale: true,
              peso: peso.text);
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
          calcularPercentualGorduraJacksonPollock7(
              triceps: double.parse(triceps.text),
              subescapular: double.parse(subescapular.text),
              peitoral: double.parse(toracica.text),
              axilarMedio: double.parse(axilarMedia.text),
              supraIliaca: double.parse(supraIliaca.text),
              abdominal: double.parse(abdominal.text),
              coxa: double.parse(coxa.text),
              idade: 20,
              isMale: true,
              peso: peso.text);
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
            coxa.text.isNotEmpty &&
            peso.text.isNotEmpty &&
            altura.text.isNotEmpty) {
          calcularPercentualGorduraJacksonPollock4(
              triceps: double.parse(triceps.text),
              supraIliaca: double.parse(supraIliaca.text),
              abdominal: double.parse(abdominal.text),
              coxa: double.parse(coxa.text),
              idade: 20,
              isMale: true,
              peso: peso.text);
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
          calcularPercentualGorduraJacksonPollock7(
              triceps: double.parse(triceps.text),
              subescapular: double.parse(subescapular.text),
              peitoral: double.parse(toracica.text),
              axilarMedio: double.parse(axilarMedia.text),
              supraIliaca: double.parse(supraIliaca.text),
              abdominal: double.parse(abdominal.text),
              coxa: double.parse(coxa.text),
              idade: 20,
              isMale: true,
              peso: peso.text);
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
            coxa.text.isNotEmpty &&
            peso.text.isNotEmpty &&
            altura.text.isNotEmpty) {
          calcularPercentualGorduraJacksonPollock7(
              triceps: double.parse(triceps.text),
              subescapular: double.parse(subescapular.text),
              peitoral: double.parse(toracica.text),
              axilarMedio: double.parse(axilarMedia.text),
              supraIliaca: double.parse(supraIliaca.text),
              abdominal: double.parse(abdominal.text),
              coxa: double.parse(coxa.text),
              idade: 20,
              isMale: true,
              peso: peso.text);
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
            coxa.text.isNotEmpty &&
            peso.text.isNotEmpty &&
            altura.text.isNotEmpty) {
          calcularPercentualGorduraJacksonPollock7(
              triceps: double.parse(triceps.text),
              subescapular: double.parse(subescapular.text),
              peitoral: double.parse(toracica.text),
              axilarMedio: double.parse(axilarMedia.text),
              supraIliaca: double.parse(supraIliaca.text),
              abdominal: double.parse(abdominal.text),
              coxa: double.parse(coxa.text),
              idade: 20,
              isMale: true,
              peso: peso.text);
        } else {
          setState(() {
            bf = null;
          });
        }
      }
    });
  }

  void toggleTrainSwitch(bool value) {
    setState(() {
      isSwitched = value;
    });
  }

  void salvarAvaliacao() async {
    try {
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

      await _antropometriaServices.addAvaliacao(
        AvaliacaoModel(
          id: null,
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
          cintura: double.tryParse(cintura.text.trim()),
          cintEscapular: double.tryParse(cinturaEscapular.text.trim()),
          torax: double.tryParse(torax.text.trim()),
          bracoEsq: double.tryParse(bracoEsq.text.trim()),
          bracoDir: double.tryParse(bracoDir.text.trim()),
          antebracoEsq: double.tryParse(anteBracoEsq.text.trim()),
          antebracoDir: double.tryParse(anteBracoDir.text.trim()),
          pantu: double.tryParse(panturrilha.text.trim()),
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
          classificacaoRce: classificacaoRce,
          fotos: fotos,
          obs: obs.text.trim(),
          sexo: widget.aluno.sexo,
        ),
      );
      _firebaseMessagingService.enviarNotificacaoParaAluno(
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
    } catch (e) {
      debugPrint('Erro ao tentar salva avaliacao: ${e.toString()}');
      TratamentoDeErros().showErrorSnackbar(
          context, 'Erro ao tentar salvar avaliação, tente novamente!');
      BlocProvider.of<ElevatedButtonBloc>(context).add(ElevatedButtonReset());
    }
  }

  @override
  void dispose() {
    titulo.dispose();
    pantEsq.dispose();
    pantDir.dispose();
    coxaEsq.dispose();
    coxaDir.dispose();
    quadril.dispose();
    cintura.dispose();
    cinturaEscapular.dispose();
    torax.dispose();
    bracoDir.dispose();
    anteBracoDir.dispose();
    anteBracoEsq.dispose();
    triceps.dispose();
    subescapular.dispose();
    biceps.dispose();
    axilarMedia.dispose();
    toracica.dispose();
    supraIliaca.dispose();
    supraEspinal.dispose();
    coxa.dispose();
    panturrilha.dispose();
    abdominal.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Listener(
      onPointerDown: (_) {
        FocusScope.of(context).unfocus();
      },
      child: PopScope(
        canPop: true,
        onPopInvokedWithResult: (didPop, result) {
          BlocProvider.of<GetFotoAvaliacaoBloc>(context)
              .add(RestartFotoEvent(0));
          BlocProvider.of<GetFotoAvaliacaoBloc>(context)
              .add(RestartFotoEvent(1));
          BlocProvider.of<GetFotoAvaliacaoBloc>(context)
              .add(RestartFotoEvent(2));
          BlocProvider.of<GetFotoAvaliacaoBloc>(context)
              .add(RestartFotoEvent(3));
          BlocProvider.of<ElevatedButtonBloc>(context)
              .add(ElevatedButtonReset());
        },
        child:Scaffold(
              appBar: AppBar(),
              body:  Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 1200),
            child: SingleChildScrollView(
                child: Form(
                  key: formAvaliacaoKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 0, horizontal: 25),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Antropometria',
                              style: SafeGoogleFont('Open Sans',
                                  fontSize: 25, fontWeight: FontWeight.bold),
                            ),
                            BlocBuilder<ElevatedButtonBloc,
                                ElevatedButtonBlocState>(
                              builder: (context, buttonState) {
                                return TextButton(
                                  onPressed: () async {
                                    if (formAvaliacaoKey.currentState!
                                        .validate()) {
                                      BlocProvider.of<ElevatedButtonBloc>(
                                              context)
                                          .add(ElevatedButtonPressed());
                                      salvarAvaliacao();
                                    }
                                  },
                                  child: buttonState
                                          is ElevatedButtonBlocLoading
                                      ? const CircularProgressIndicator(
                                          color: Colors.green,
                                        )
                                      : const Text(
                                          'Salvar',
                                          style: TextStyle(color: Colors.green),
                                        ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                              width: width * 0.9,
                              height: 0.5,
                              color: Colors.grey),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: BuildTextFormField(
                          data: TextFormFieldData(
                            controller: titulo,
                            keyboardType: TextInputType.name,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(25),
                            ],
                            labelText: 'Título',
                            validateFunction: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor, insira o título';
                              }
                              return null;
                            },
                            context: context,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 0,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: BuildTextFormField(
                          maxLines: 2,
                          data: TextFormFieldData(
                            controller: obs,
                            keyboardType: TextInputType.name,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp("[a-zA-ZáéíóúâêôàüãõçÁÉÍÓÚÂÊÔÀÜÃÕÇ ]"),
                              ),
                              LengthLimitingTextInputFormatter(200),
                            ],
                            labelText: 'Observação',
                            validateFunction: (value) {
                              return null;
                            },
                            context: context,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Wrap(
                          alignment: WrapAlignment.start,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            SizedBox(
                              width: 125,
                              child: BuildTextFormField(
                                data: TextFormFieldData(
                                  controller: peso,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    LengthLimitingTextInputFormatter(6),
                                    FilteringTextInputFormatter.allow(RegExp(
                                        r'^\d*[.,]?\d*')), // Permite apenas números e ponto
                                    CommaToPointInputFormatter(), // Substitui vírgulas por pontos
                                  ],
                                  labelText: 'Peso (kg)',
                                  validateFunction: (value) {
                                    return null;
                                  },
                                  context: context,
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            SizedBox(
                              width: 125,
                              child: BuildTextFormField(
                                data: TextFormFieldData(
                                  controller: altura,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    LengthLimitingTextInputFormatter(6),
                                    CommaToPointInputFormatter(), // Substitui vírgulas por pontos
                                    FilteringTextInputFormatter.allow(
                                        RegExp(r'^\d*[.,]?\d*')),
                                  ],
                                  labelText: 'Altura (m)',
                                  validateFunction: (value) {
                                    return null;
                                  },
                                  context: context,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 5),
                        child: ExpansionTile(
                          expandedAlignment: Alignment.centerLeft,
                          title: Text(
                            'Circunferências (cm)',
                            style: SafeGoogleFont('Open Sans', fontSize: 18),
                          ),
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15),
                                  child: Wrap(
                                    alignment: WrapAlignment.start,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    children: [
                                      const SizedBox(
                                        width: 95,
                                        child: Text('Panturrilha:'),
                                      ),
                                      MeasurementTextField(
                                        controller: pantEsq,
                                        label: 'Esq',
                                        unit: 'cm',
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      MeasurementTextField(
                                        controller: pantDir,
                                        label: 'Dir',
                                        unit: 'cm',
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15),
                                  child: Wrap(
                                    alignment: WrapAlignment.start,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    children: [
                                      const SizedBox(
                                        width: 95,
                                        child: Text('Coxa:'),
                                      ),
                                      MeasurementTextField(
                                        controller: coxaEsq,
                                        label: 'Esq',
                                        unit: 'cm',
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      MeasurementTextField(
                                        controller: coxaDir,
                                        label: 'Dir',
                                        unit: 'cm',
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15),
                                  child: Wrap(
                                    alignment: WrapAlignment.start,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    children: [
                                      const SizedBox(
                                        width: 95,
                                        child: Text('Quadril:'),
                                      ),
                                      MeasurementTextField(
                                        controller: quadril,
                                        label: 'Quadril',
                                        unit: 'cm',
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15),
                                  child: Wrap(
                                    alignment: WrapAlignment.start,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    children: [
                                      const SizedBox(
                                        width: 95,
                                        child: Text('Cintura:'),
                                      ),
                                      MeasurementTextField(
                                        controller: cintura,
                                        label: 'Cintura',
                                        unit: 'cm',
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15),
                                  child: Wrap(
                                    alignment: WrapAlignment.start,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    children: [
                                      const SizedBox(
                                        width: 95,
                                        child: Text('Cint. Escapular:'),
                                      ),
                                      MeasurementTextField(
                                        controller: cinturaEscapular,
                                        label: 'Cint. Escapular',
                                        unit: 'cm',
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15),
                                  child: Wrap(
                                    alignment: WrapAlignment.start,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    children: [
                                      const SizedBox(
                                        width: 95,
                                        child: Text('Ombros:'),
                                      ),
                                      MeasurementTextField(
                                        controller: torax,
                                        label: 'Ombros',
                                        unit: 'cm',
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15),
                                  child: Wrap(
                                    alignment: WrapAlignment.start,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    children: [
                                      const SizedBox(
                                        width: 95,
                                        child: Text('Braço:'),
                                      ),
                                      MeasurementTextField(
                                        controller: bracoEsq,
                                        label: 'Esq',
                                        unit: 'cm',
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      MeasurementTextField(
                                        controller: bracoDir,
                                        label: 'Dir',
                                        unit: 'cm',
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15),
                                  child: Wrap(
                                    alignment: WrapAlignment.start,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    children: [
                                      const SizedBox(
                                        width: 95,
                                        child: Text('Antebraço:'),
                                      ),
                                      MeasurementTextField(
                                        controller: anteBracoEsq,
                                        label: 'Esq',
                                        unit: 'cm',
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      MeasurementTextField(
                                        controller: anteBracoDir,
                                        label: 'Dir',
                                        unit: 'cm',
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 5),
                        child: ExpansionTile(
                          expandedAlignment: Alignment.centerLeft,
                          title: Text(
                            'Adipometria (mm)',
                            style: SafeGoogleFont('Open Sans', fontSize: 18),
                          ),
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15),
                                  child: Wrap(
                                    alignment: WrapAlignment.start,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    children: [
                                      const SizedBox(
                                        width: 95,
                                        child: Text('Panturrilha:'),
                                      ),
                                      MeasurementTextField(
                                        controller: panturrilha,
                                        label: 'mm',
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15),
                                  child: Wrap(
                                    alignment: WrapAlignment.start,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    children: [
                                      const SizedBox(
                                        width: 95,
                                        child: Text('Coxa:'),
                                      ),
                                      MeasurementTextField(
                                        controller: coxa,
                                        label: 'mm',
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15),
                                  child: Wrap(
                                    alignment: WrapAlignment.start,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    children: [
                                      const SizedBox(
                                        width: 95,
                                        child: Text('Abdominal:'),
                                      ),
                                      MeasurementTextField(
                                        controller: abdominal,
                                        label: 'mm',
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15),
                                  child: Wrap(
                                    alignment: WrapAlignment.start,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    children: [
                                      const SizedBox(
                                        width: 95,
                                        child: Text('Supraespinal:'),
                                      ),
                                      MeasurementTextField(
                                        controller: supraEspinal,
                                        label: 'mm',
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15),
                                  child: Wrap(
                                    alignment: WrapAlignment.start,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    children: [
                                      const SizedBox(
                                        width: 95,
                                        child: Text('Suprailíaca:'),
                                      ),
                                      MeasurementTextField(
                                        controller: supraIliaca,
                                        label: 'mm',
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15),
                                  child: Wrap(
                                    alignment: WrapAlignment.start,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    children: [
                                      const SizedBox(
                                        width: 95,
                                        child: Text('Torácica:'),
                                      ),
                                      MeasurementTextField(
                                        controller: toracica,
                                        label: 'mm',
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15),
                                  child: Wrap(
                                    alignment: WrapAlignment.start,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    children: [
                                      const SizedBox(
                                        width: 95,
                                        child: Text('Bíceps:'),
                                      ),
                                      MeasurementTextField(
                                        controller: biceps,
                                        label: 'mm',
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15),
                                  child: Wrap(
                                    alignment: WrapAlignment.start,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    children: [
                                      const SizedBox(
                                        width: 95,
                                        child: Text('Tríceps:'),
                                      ),
                                      MeasurementTextField(
                                        controller: triceps,
                                        label: 'mm',
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15),
                                  child: Wrap(
                                    alignment: WrapAlignment.start,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    children: [
                                      const SizedBox(
                                        width: 95,
                                        child: Text('Axilar Média:'),
                                      ),
                                      MeasurementTextField(
                                        controller: axilarMedia,
                                        label: 'mm',
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15),
                                  child: Wrap(
                                    alignment: WrapAlignment.start,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    children: [
                                      const SizedBox(
                                        width: 95,
                                        child: Text('Subescapular:'),
                                      ),
                                      MeasurementTextField(
                                        controller: subescapular,
                                        label: 'mm',
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      BlocConsumer<GetFotoAvaliacaoBloc, GetFotoAvaliacaoState>(
                        listener: (context, fotoState) {
                          if (fotoState is GetFotoAvaliacaoLoaded) {
                            setState(
                              () {
                                foto1 = fotoState.fotos[0];
                                foto2 = fotoState.fotos[1];
                                foto3 = fotoState.fotos[2];
                                foto4 = fotoState.fotos[3];
                              },
                            );
                          } else if (fotoState is GetFotoAvaliacaoInitial) {
                            setState(() {
                              foto1 = null;
                              foto2 = null;
                              foto3 = null;
                              foto4 = null;
                            });
                          }
                        },
                        builder: (context, fotoState) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 5),
                            child: ExpansionTile(
                              expandedAlignment: Alignment.centerLeft,
                              title: Text(
                                'Fotos',
                                style:
                                    SafeGoogleFont('Open Sans', fontSize: 18),
                              ),
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 15),
                                  child: Wrap(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          foto1 != null
                                              ? ChangeFotoAvaliacaoWidget(
                                                  index: 0,
                                                  fotoState: fotoState,
                                                )
                                              : const AddFotoAvaliacaoWidget(
                                                  index: 0,
                                                ),
                                          foto2 != null
                                              ? ChangeFotoAvaliacaoWidget(
                                                  index: 1,
                                                  fotoState: fotoState,
                                                )
                                              : const AddFotoAvaliacaoWidget(
                                                  index: 1,
                                                )
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          foto3 != null
                                              ? ChangeFotoAvaliacaoWidget(
                                                  index: 2,
                                                  fotoState: fotoState,
                                                )
                                              : const AddFotoAvaliacaoWidget(
                                                  index: 2,
                                                ),
                                          foto4 != null
                                              ? ChangeFotoAvaliacaoWidget(
                                                  index: 3,
                                                  fotoState: fotoState,
                                                )
                                              : const AddFotoAvaliacaoWidget(
                                                  index: 3,
                                                )
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 15),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 5),
                        child: ExpansionTile(
                          expandedAlignment: Alignment.centerLeft,
                          title: Text(
                            'Fórmula',
                            style: SafeGoogleFont('Open Sans', fontSize: 18),
                          ),
                          children: [
                            Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Radio<String>(
                                      value: 'Durnin-Womersley',
                                      groupValue: _selectedOption,
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedOption = value;
                                          //_updateButtonState();
                                          if (triceps.text.isNotEmpty &&
                                              supraIliaca.text.isNotEmpty &&
                                              subescapular.text.isNotEmpty &&
                                              biceps.text.isNotEmpty &&
                                              peso.text.isNotEmpty &&
                                              altura.text.isNotEmpty) {
                                            calcularPercentualGorduraDurninWomersley(
                                                triceps:
                                                    double.parse(triceps.text),
                                                supraIliaca: double.parse(
                                                    supraIliaca.text),
                                                subescapular: double.parse(
                                                    subescapular.text),
                                                bicipital:
                                                    double.parse(biceps.text),
                                                idade: 20,
                                                isMale: true,
                                                peso: peso.text);
                                          }
                                        });
                                      },
                                    ),
                                    const Text('Durnin-Womersley'),
                                  ],
                                ),
                                const SizedBox(width: 10),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Radio<String>(
                                      value: 'Jackson e Pollock (3 dobras)',
                                      groupValue: _selectedOption,
                                      onChanged: (value) {
                                        setState(() {
                                          debugPrint(
                                              'Jackson e Pollock (3 dobras)');
                                          _selectedOption = value;
                                          debugPrint(triceps.text);
                                          debugPrint(supraIliaca.text);
                                          debugPrint(abdominal.text);
                                          //_updateButtonState();
                                          if (triceps.text.isNotEmpty &&
                                              supraIliaca.text.isNotEmpty &&
                                              abdominal.text.isNotEmpty &&
                                              peso.text.isNotEmpty &&
                                              altura.text.isNotEmpty) {
                                            debugPrint('calculando...');
                                            calcularPercentualGorduraJacksonPollock3(
                                                triceps:
                                                    double.parse(triceps.text),
                                                supraIliaca: double.parse(
                                                    supraIliaca.text),
                                                abdominal: double.parse(
                                                    abdominal.text),
                                                idade: 20,
                                                isMale: true,
                                                peso: peso.text);
                                          }
                                        });
                                      },
                                    ),
                                    const Text('Jackson e Pollock (3 dobras)'),
                                  ],
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Radio<String>(
                                      value: 'Jackson e Pollock (4 dobras)',
                                      groupValue: _selectedOption,
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedOption = value;
                                          //_updateButtonState();
                                          if (triceps.text.isNotEmpty &&
                                              supraIliaca.text.isNotEmpty &&
                                              abdominal.text.isNotEmpty &&
                                              coxa.text.isNotEmpty &&
                                              peso.text.isNotEmpty &&
                                              altura.text.isNotEmpty) {
                                            calcularPercentualGorduraJacksonPollock4(
                                                triceps:
                                                    double.parse(triceps.text),
                                                supraIliaca: double.parse(
                                                    supraIliaca.text),
                                                abdominal: double.parse(
                                                    abdominal.text),
                                                coxa: double.parse(coxa.text),
                                                idade: 20,
                                                isMale: true,
                                                peso: peso.text);
                                          }
                                        });
                                      },
                                    ),
                                    const Text('Jackson e Pollock (4 dobras)'),
                                  ],
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Radio<String>(
                                      value: 'Jackson e Pollock (7 dobras)',
                                      groupValue: _selectedOption,
                                      onChanged: (value) {
                                        setState(
                                          () {
                                            _selectedOption = value;
                                            //_updateButtonState();
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
                                                  triceps: double.parse(
                                                      triceps.text),
                                                  subescapular: double.parse(
                                                      subescapular.text),
                                                  peitoral: double.parse(
                                                      toracica.text),
                                                  axilarMedio: double.parse(
                                                      axilarMedia.text),
                                                  supraIliaca: double.parse(
                                                      supraIliaca.text),
                                                  abdominal: double.parse(
                                                      abdominal.text),
                                                  coxa: double.parse(coxa.text),
                                                  idade: 20,
                                                  isMale: true,
                                                  peso: peso.text);
                                            }
                                          },
                                        );
                                      },
                                    ),
                                    const Text('Jackson e Pollock (7 dobras)'),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 0, horizontal: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Resultado',
                              style: SafeGoogleFont('Open Sans',
                                  fontSize: 25, fontWeight: FontWeight.bold),
                            ),
                            TextButton(
                              onPressed: () async {
                                try {
                                  final pdfService = PdfAvaliacaoService();
                                  final pdfViewerService = PdfViewerService();

                                  // Criar o modelo de avaliação com todos os dados
                                  final avaliacaoAtual = AvaliacaoModel(
                                    id: null,
                                    alunoUid: widget.aluno.uid,
                                    titulo: titulo.text,
                                    timestamp: DateFormat(
                                            'dd/MM/yyyy HH:mm:ss', 'pt_BR')
                                        .format(DateTime.now()),
                                    peso: double.tryParse(peso.text),
                                    altura: double.tryParse(altura.text),
                                    pantEsq: double.tryParse(pantEsq.text),
                                    pantDir: double.tryParse(pantDir.text),
                                    coxaEsq: double.tryParse(coxaEsq.text),
                                    coxaDir: double.tryParse(coxaDir.text),
                                    quadril: double.tryParse(quadril.text),
                                    cintura: double.tryParse(cintura.text),
                                    cintEscapular:
                                        double.tryParse(cinturaEscapular.text),
                                    torax: double.tryParse(torax.text),
                                    bracoEsq: double.tryParse(bracoEsq.text),
                                    bracoDir: double.tryParse(bracoDir.text),
                                    antebracoEsq:
                                        double.tryParse(anteBracoEsq.text),
                                    antebracoDir:
                                        double.tryParse(anteBracoDir.text),
                                    pantu: double.tryParse(panturrilha.text),
                                    coxa: double.tryParse(coxa.text),
                                    abdominal: double.tryParse(abdominal.text),
                                    supraespinal:
                                        double.tryParse(supraEspinal.text),
                                    suprailiaca:
                                        double.tryParse(supraIliaca.text),
                                    toracica: double.tryParse(toracica.text),
                                    biciptal: double.tryParse(biceps.text),
                                    triciptal: double.tryParse(triceps.text),
                                    axilarMedia:
                                        double.tryParse(axilarMedia.text),
                                    subescapular:
                                        double.tryParse(subescapular.text),
                                    formula: _selectedOption,
                                    imc: imc,
                                    classificacaoImc: classificacaoImc,
                                    bf: bf,
                                    mm: massaMagra,
                                    mg: massaGorda,
                                    rce: rce,
                                    classificacaoRce: classificacaoRce,
                                    fotos: [
                                      if (foto1 != null) base64Encode(foto1!),
                                      if (foto2 != null) base64Encode(foto2!),
                                      if (foto3 != null) base64Encode(foto3!),
                                      if (foto4 != null) base64Encode(foto4!),
                                    ],
                                    obs: obs.text,
                                    sexo: widget.aluno.sexo,
                                  );

                                  // Gerar o PDF
                                  final file = await pdfService
                                      .generatePdf(avaliacaoAtual);

                                  // Abrir o PDF
                                  await pdfViewerService.openPdf(file);
                                } catch (e) {
                                  debugPrint('Erro ao gerar/abrir PDF: $e');
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content:
                                          Text('Erro ao gerar/abrir PDF: $e'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              },
                              child: const Text(
                                'Abrir PDF',
                                style: TextStyle(color: Colors.green),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                              width: width * 0.93,
                              height: 0.5,
                              color: Colors.grey),
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        child: Row(
                          children: [
                            Text(
                              'IMC: ',
                              style: SafeGoogleFont('Open Sans', fontSize: 18),
                            ),
                            Text(
                              imc != null ? imc!.toStringAsFixed(2) : 'N/D',
                              style: SafeGoogleFont('Open Sans',
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              classificacaoImc != null
                                  ? ' (${classificacaoImc!})'
                                  : '',
                              style: SafeGoogleFont('Open Sans',
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        child: Row(
                          children: [
                            Text(
                              'Percentual de gordura: ',
                              style: SafeGoogleFont('Open Sans', fontSize: 18),
                            ),
                            Text(
                              bf != null ? '${bf!.toStringAsFixed(2)}%' : 'N/D',
                              style: SafeGoogleFont('Open Sans',
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        child: Row(
                          children: [
                            Text(
                              'Massa magra: ',
                              style: SafeGoogleFont('Open Sans', fontSize: 18),
                            ),
                            Text(
                              massaMagra != null
                                  ? '${massaMagra!.toStringAsFixed(2)}Kg'
                                  : 'N/D',
                              style: SafeGoogleFont('Open Sans',
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        child: Row(
                          children: [
                            Text(
                              'Massa gorda: ',
                              style: SafeGoogleFont('Open Sans', fontSize: 18),
                            ),
                            Text(
                              massaGorda != null
                                  ? '${massaGorda!.toStringAsFixed(2)}Kg'
                                  : 'N/D',
                              style: SafeGoogleFont('Open Sans',
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        child: Row(
                          children: [
                            Text(
                              'RCE: ',
                              style: SafeGoogleFont('Open Sans', fontSize: 18),
                            ),
                            Text(
                              rce != null ? rce!.toStringAsFixed(2) : 'N/D',
                              style: SafeGoogleFont('Open Sans',
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              classificacaoRce != null
                                  ? ' (${classificacaoRce!})'
                                  : '',
                              style: SafeGoogleFont('Open Sans',
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  calcularPercentualGorduraDurninWomersley(
      {required double triceps,
      required double subescapular,
      required double supraIliaca,
      required double bicipital,
      required int idade,
      required bool isMale,
      String? peso}) {
    // Soma das dobras cutâneas
    double somaDobras = triceps + subescapular + supraIliaca + bicipital;

    // Calcular a densidade corporal usando a fórmula de Durnin-Womersley
    double densidadeCorporal;

    if (isMale) {
      // Fórmula para homens
      densidadeCorporal = 1.10938 -
          (0.0008267 * somaDobras) +
          (0.0000016 * somaDobras * somaDobras) -
          (0.0002574 * idade);
    } else {
      // Fórmula para mulheres
      densidadeCorporal = 1.0994921 -
          (0.0009929 * somaDobras) +
          (0.0000023 * somaDobras * somaDobras) -
          (0.0001392 * idade);
    }

    // Calcular o percentual de gordura corporal usando a densidade corporal
    double percentualGordura = (495 / densidadeCorporal) - 450;

    setState(() {
      bf = percentualGordura;
      if (bf != null && peso != null) {
        calcularMassaMagra(
            peso: double.parse(peso), percentualGordura: percentualGordura);
        calcularMassaGorda(
            peso: double.parse(peso), percentualGordura: percentualGordura);
      }
    });
  }

  calcularPercentualGorduraJacksonPollock3(
      {required double triceps,
      required double supraIliaca,
      required double abdominal,
      required int idade,
      required bool isMale,
      String? peso}) {
    // Soma das dobras cutâneas
    double somaDobras = triceps + supraIliaca + abdominal;

    // Calcular a densidade corporal usando a fórmula de Jackson e Pollock 3 dobras
    double densidadeCorporal;

    if (isMale) {
      // Fórmula para homens
      densidadeCorporal = 1.10938 -
          (0.0008267 * somaDobras) +
          (0.0000016 * somaDobras * somaDobras) -
          (0.0002574 * idade);
    } else {
      // Fórmula para mulheres
      densidadeCorporal = 1.0994921 -
          (0.0009929 * somaDobras) +
          (0.0000023 * somaDobras * somaDobras) -
          (0.0001392 * idade);
    }

    // Calcular o percentual de gordura corporal usando a densidade corporal
    double percentualGordura = (495 / densidadeCorporal) - 450;

    setState(() {
      bf = percentualGordura;
      if (bf != null && peso != null) {
        calcularMassaMagra(
            peso: double.parse(peso), percentualGordura: percentualGordura);
        calcularMassaGorda(
            peso: double.parse(peso), percentualGordura: percentualGordura);
      }
    });
  }

  calcularPercentualGorduraJacksonPollock4(
      {required double triceps,
      required double supraIliaca,
      required double abdominal,
      required double coxa,
      required int idade,
      required bool isMale,
      String? peso}) {
    // Soma das dobras cutâneas
    double somaDobras = triceps + supraIliaca + abdominal + coxa;

    // Calcular a densidade corporal usando a fórmula de Jackson e Pollock 4 dobras
    double densidadeCorporal;

    if (isMale) {
      // Fórmula para homens
      densidadeCorporal = 1.112 -
          (0.00043499 * somaDobras) +
          (0.00000055 * somaDobras * somaDobras) -
          (0.00028826 * idade);
    } else {
      // Fórmula para mulheres
      densidadeCorporal = 1.096095 -
          (0.0006952 * somaDobras) +
          (0.0000011 * somaDobras * somaDobras) -
          (0.0000714 * idade);
    }

    // Calcular o percentual de gordura corporal usando a densidade corporal
    double percentualGordura = (495 / densidadeCorporal) - 450;

    setState(() {
      bf = percentualGordura;
      if (bf != null && peso != null) {
        calcularMassaMagra(
            peso: double.parse(peso), percentualGordura: percentualGordura);
        calcularMassaGorda(
            peso: double.parse(peso), percentualGordura: percentualGordura);
      }
    });
  }

  calcularPercentualGorduraJacksonPollock7(
      {required double triceps,
      required double subescapular,
      required double peitoral,
      required double axilarMedio,
      required double supraIliaca,
      required double abdominal,
      required double coxa,
      required int idade,
      required bool isMale,
      String? peso}) {
    // Soma das 7 dobras cutâneas
    double somaDobras = triceps +
        subescapular +
        peitoral +
        axilarMedio +
        supraIliaca +
        abdominal +
        coxa;

    // Calcular a densidade corporal usando a fórmula de Jackson e Pollock 7 dobras
    double densidadeCorporal;

    if (isMale) {
      // Fórmula para homens
      densidadeCorporal = 1.112 -
          (0.00043499 * somaDobras) +
          (0.00000055 * somaDobras * somaDobras) -
          (0.00028826 * idade);
    } else {
      // Fórmula para mulheres
      densidadeCorporal = 1.097 -
          (0.00046971 * somaDobras) +
          (0.00000056 * somaDobras * somaDobras) -
          (0.00012828 * idade);
    }

    // Calcular o percentual de gordura corporal usando a densidade corporal
    double percentualGordura = (495 / densidadeCorporal) - 450;

    setState(() {
      bf = percentualGordura;
      if (bf != null && peso != null) {
        calcularMassaMagra(
            peso: double.parse(peso), percentualGordura: percentualGordura);
        calcularMassaGorda(
            peso: double.parse(peso), percentualGordura: percentualGordura);
      }
    });
  }

  void calcularIMC({
    required double peso, // Peso em quilogramas
    required double altura, // Altura em metros
  }) {
    setState(() {
      imc = peso / (altura * altura);

      imc != null ? classificacaoImc = _classificarIMC(imc!) : null;
    });
  }

  String _classificarIMC(double imc) {
    if (imc < 18.5) {
      return 'Abaixo do peso';
    } else if (imc >= 18.5 && imc < 24.9) {
      return 'Eutrofia (Peso normal)';
    } else if (imc >= 25.0 && imc < 29.9) {
      return 'Sobrepeso';
    } else if (imc >= 30.0 && imc < 34.9) {
      return 'Obesidade Grau 1';
    } else if (imc >= 35.0 && imc < 39.9) {
      return 'Obesidade Grau 2';
    } else if (imc >= 40.0) {
      return 'Obesidade Grau 3';
    } else {
      return 'Valor de IMC inválido';
    }
  }

  calcularMassaMagra({
    required double peso, // Peso em quilogramas
    required double percentualGordura, // Percentual de gordura corporal
  }) {
    setState(() {
      massaMagra = peso * (1 - (percentualGordura / 100));
    });
  }

  calcularMassaGorda({
    required double peso, // Peso em quilogramas
    required double percentualGordura, // Percentual de gordura corporal
  }) {
    setState(() {
      massaGorda = peso * (percentualGordura / 100);
    });
  }

  void calcularRCE(double circunferenciaCintura, double altura) {
    debugPrint('calculando rce...');
    setState(() {
      rce = circunferenciaCintura / altura;
      rce != null ? classificacaoRce = _classificarRCE(rce!) : null;
    });
  }

  String _classificarRCE(double rce) {
    if (rce < 0.35) {
      return 'Baixo risco';
    } else if (rce >= 0.35 && rce < 0.43) {
      return 'Risco moderado';
    } else if (rce >= 0.43 && rce < 0.53) {
      return 'Risco alto';
    } else if (rce >= 0.53 && rce < 0.58) {
      return 'Risco muito alto';
    } else if (rce >= 0.58) {
      return 'Risco extremamente alto';
    } else {
      return 'Valor de RCE inválido';
    }
  }
}
