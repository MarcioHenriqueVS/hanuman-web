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
import '../../antropometria/models/avaliacao_model.dart';
import '../../antropometria/services/antropometria_services.dart';
import '../../models/aluno_model.dart';
import 'header_prototipo.dart';
import 'widgets/form_adipometria_avaliacao_widget.dart';
import 'widgets/form_avaliacao_widget.dart';
import 'widgets/form_medidas_avaliacao_widget.dart';
import 'widgets/resultados_container.dart';
import 'widgets/select_photos_container.dart';

class AddAvaPrototipo extends StatefulWidget {
  final AlunoModel aluno;
  const AddAvaPrototipo({super.key, required this.aluno});

  @override
  State<AddAvaPrototipo> createState() => _AddAvaPrototipoState();
}

class _AddAvaPrototipoState extends State<AddAvaPrototipo> {
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

  @override
  void initState() {
    super.initState();
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
    titulo.text = dataFormatada;
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

  void salvarAvaliacao() async {
    try {
      if (!formBasicoAvaliacaoKey.currentState!.validate() ||
          !formMedidasAvaliacaoKey.currentState!.validate() ||
          !formAdipometriaAvaliacaoKey.currentState!.validate()) {
        return;
      } else if (
          //verificar se ao menos um campo foi preenchido
          (pantDir.text.isEmpty &&
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
              peso.text.isEmpty &&
              altura.text.isEmpty &&
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

        await _antropometriaServices.addAvaliacao(
          AvaliacaoModel(
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
                                  'Outfit',
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
                                    'Readex Pro',
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
                                        'Readex Pro',
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
                                        'Readex Pro',
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
                                        'Readex Pro',
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
                                        'Readex Pro',
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
