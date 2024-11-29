import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';
import '../../utils.dart';
import '../services/treino_services.dart';
import 'treino_ia_teste.dart';
import 'dart:ui';

class DialogTreinoIa extends StatefulWidget {
  final String? sexo;
  final String? idade;
  final String? uid;
  const DialogTreinoIa({super.key, this.sexo, this.idade, this.uid});

  @override
  State<DialogTreinoIa> createState() => _DialogTreinoIaState();
}

class _DialogTreinoIaState extends State<DialogTreinoIa> {
  String? _diasSelected;
  String? _nivel;
  String? _objetivo;
  String? _foco;
  List<String> gruposMusculares = [];
  int _currentStep = 0;
  bool panturrilhaCheck = false;
  bool quadricepsCheck = false;
  bool posterioresCheck = false;
  bool abdomeCheck = false;
  bool coreCheck = false;
  bool dorsaisCheck = false;
  bool peitoralCheck = false;
  bool ombrosCheck = false;
  bool bicepsCheck = false;
  bool tricepsCheck = false;
  bool antebracosCheck = false;
  bool gluteosCheck = false;
  final TreinoServices _treinoServices = TreinoServices();

  @override
  void initState() {
    super.initState();
  }

  void _onCheckboxChanged(bool? value, String groupName) {
    setState(() {
      switch (groupName) {
        case 'Panturrilha':
          panturrilhaCheck = value!;
          break;
        case 'Quadríceps':
          quadricepsCheck = value!;
          break;
        case 'Posterior de coxa':
          posterioresCheck = value!;
          break;
        case 'Abdome':
          abdomeCheck = value!;
          break;
        case 'Core':
          coreCheck = value!;
          break;
        case 'Dorsal':
          dorsaisCheck = value!;
          break;
        case 'Peitoral':
          peitoralCheck = value!;
          break;
        case 'Ombros':
          ombrosCheck = value!;
          break;
        case 'Bíceps':
          bicepsCheck = value!;
          break;
        case 'Tríceps':
          tricepsCheck = value!;
          break;
        case 'Antebraços':
          antebracosCheck = value!;
          break;
        case 'Glúteos':
          gluteosCheck = value!;
          break;
      }

      if (value!) {
        gruposMusculares.add(groupName);
      } else {
        gruposMusculares.remove(groupName);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child:
            // Card(
            //   elevation: 8,
            //   margin: const EdgeInsets.all(20),
            //   color: Colors.grey.shade800,
            //   shape: RoundedRectangleBorder(
            //     borderRadius: BorderRadius.circular(15),
            //   ),
            //   child:
            ClipRRect(
          //borderRadius: BorderRadius.circular(15),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              width: 800,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                //color: Colors.black54,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  //botao para voltar para a tela anterior

                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                  // Text(
                  //   'Montagem de Treino Personalizado',
                  //   style: SafeGoogleFont(
                  //     'Open Sans',
                  //     fontSize: 28,
                  //     fontWeight: FontWeight.bold,
                  //     color: Colors.green.shade300,
                  //   ),
                  // ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: Stepper(
                      elevation: 0,
                      currentStep: _currentStep,
                      onStepContinue: _nextStep,
                      onStepCancel: _previousStep,
                      controlsBuilder: (context, details) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: Row(
                            children: [
                              ElevatedButton(
                                onPressed: details.onStepContinue,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green.shade600,
                                  elevation: 2,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 30,
                                    vertical: 15,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                child: Text(
                                  'Continuar',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey.shade100,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              TextButton(
                                onPressed: details.onStepCancel,
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.green.shade300,
                                ),
                                child: const Text(
                                  'Voltar',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      steps: [
                        step1(),
                        step2(),
                        step3(),
                        step4(),
                        step5(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Step step1() {
    return Step(
      isActive: _currentStep >= 0,
      state: _diasSelected == null ? StepState.indexed : StepState.complete,
      title: Text(
        'Frequência Semanal',
        style: SafeGoogleFont(
          'Open Sans',
          fontSize: 21,
          fontWeight: FontWeight.w600,
        ),
      ),
      content: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                'Quantos dias na semana o aluno pode treinar?',
                style: SafeGoogleFont(
                  'Open Sans',
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  for (int i = 1; i <= 7; i++)
                    ChoiceChip(
                      label: Text(
                        i.toString(),
                        style: TextStyle(
                          fontSize: 18,
                          color: _diasSelected == i.toString()
                              ? Colors.white
                              : Colors.grey.shade300,
                        ),
                      ),
                      selected: _diasSelected == i.toString(),
                      side:
                          //sem borda
                          BorderSide(
                        color: Colors.transparent,
                      ),
                      selectedColor:
                          Colors.green.shade600, // Cor quando selecionado
                      backgroundColor:
                          Colors.grey.shade800, // Cor de fundo padrão
                      onSelected: (selected) {
                        setState(() {
                          _diasSelected = selected ? i.toString() : null;
                        });
                      },
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Step step2() {
    return Step(
      isActive: _currentStep >= 1,
      state: _nivel == null ? StepState.indexed : StepState.complete,
      title: Text(
        'Passo 2',
        style: SafeGoogleFont(
          'Open Sans',
          fontSize: 21,
        ),
      ),
      content: Column(
        children: [
          Text(
            'Qual o nível do aluno?',
            style: SafeGoogleFont(
              'Open Sans',
              fontSize: 22,
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          Wrap(
            spacing: 5,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Radio<String>(
                    value: 'Iniciante',
                    groupValue: _nivel,
                    onChanged: (value) {
                      setState(() {
                        _nivel = value;
                      });
                    },
                  ),
                  Text(
                    'Iniciante',
                    style: SafeGoogleFont(
                      'Open Sans',
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Radio<String>(
                    value: 'Intermediário',
                    groupValue: _nivel,
                    onChanged: (value) {
                      setState(() {
                        _nivel = value;
                      });
                    },
                  ),
                  Text(
                    'Intermediário',
                    style: SafeGoogleFont(
                      'Open Sans',
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Radio<String>(
                    value: 'Avançado',
                    groupValue: _nivel,
                    onChanged: (value) {
                      setState(() {
                        _nivel = value;
                      });
                    },
                  ),
                  Text(
                    'Avançado',
                    style: SafeGoogleFont(
                      'Open Sans',
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }

  Step step3() {
    return Step(
      isActive: _currentStep >= 2,
      state: _objetivo == null ? StepState.indexed : StepState.complete,
      title: Text(
        'Passo 3',
        style: SafeGoogleFont(
          'Open Sans',
          fontSize: 21,
        ),
      ),
      content: Column(
        children: [
          Text(
            'Qual o objetivo do aluno?',
            style: SafeGoogleFont(
              'Open Sans',
              fontSize: 22,
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          Wrap(
            spacing: 5,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Radio<String>(
                    value: 'Emagrecimento',
                    groupValue: _objetivo,
                    onChanged: (value) {
                      setState(() {
                        _objetivo = value;
                      });
                    },
                  ),
                  Text(
                    'Emagrecimento',
                    style: SafeGoogleFont(
                      'Open Sans',
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Radio<String>(
                    value: 'Hipertrofia',
                    groupValue: _objetivo,
                    onChanged: (value) {
                      setState(() {
                        _objetivo = value;
                      });
                    },
                  ),
                  Text(
                    'Hipertrofia',
                    style: SafeGoogleFont(
                      'Open Sans',
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }

  Step step4() {
    return Step(
      isActive: _currentStep >= 3,
      state: _foco == null ? StepState.indexed : StepState.complete,
      title: Text(
        'Passo 4',
        style: SafeGoogleFont(
          'Open Sans',
          fontSize: 21,
        ),
      ),
      content: Column(
        children: [
          Text(
            'Qual o tipo/foco principal do treinamento?',
            style: SafeGoogleFont(
              'Open Sans',
              fontSize: 22,
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          Wrap(
            spacing: 5,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Radio<String>(
                    value: 'Ganho de força',
                    groupValue: _foco,
                    onChanged: (value) {
                      setState(() {
                        _foco = value;
                      });
                    },
                  ),
                  Text(
                    'Ganho de força',
                    style: SafeGoogleFont(
                      'Open Sans',
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Radio<String>(
                    value: 'Ganho de resistência',
                    groupValue: _foco,
                    onChanged: (value) {
                      setState(() {
                        _foco = value;
                      });
                    },
                  ),
                  Text(
                    'Ganho de resistência',
                    style: SafeGoogleFont(
                      'Open Sans',
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }

  Step step5() {
    return Step(
      isActive: _currentStep >= 4,
      state: gruposMusculares.isEmpty ? StepState.indexed : StepState.complete,
      title: Text(
        'Passo 5',
        style: SafeGoogleFont(
          'Open Sans',
          fontSize: 21,
        ),
      ),
      content: Column(
        children: [
          Text(
            'Algum grupamento muscular precisa ser mais trabalhado?',
            textAlign: TextAlign.start,
            style: SafeGoogleFont(
              'Open Sans',
              fontSize: 22,
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          Wrap(
            spacing: 5,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              checkBox(
                value: panturrilhaCheck,
                onChanged: (value) => _onCheckboxChanged(value, 'Panturrilha'),
                label: 'Panturrilha',
              ),
              checkBox(
                value: posterioresCheck,
                onChanged: (value) =>
                    _onCheckboxChanged(value, 'Posterior de coxa'),
                label: 'Posterior de coxa',
              ),
              checkBox(
                value: quadricepsCheck,
                onChanged: (value) => _onCheckboxChanged(value, 'Quadríceps'),
                label: 'Quadríceps',
              ),
              checkBox(
                value: abdomeCheck,
                onChanged: (value) => _onCheckboxChanged(value, 'Abdome'),
                label: 'Abdome',
              ),
              checkBox(
                value: dorsaisCheck,
                onChanged: (value) => _onCheckboxChanged(value, 'Dorsal'),
                label: 'Dorsal',
              ),
              checkBox(
                value: peitoralCheck,
                onChanged: (value) => _onCheckboxChanged(value, 'Peitoral'),
                label: 'Peitoral',
              ),
              checkBox(
                value: ombrosCheck,
                onChanged: (value) => _onCheckboxChanged(value, 'Ombro'),
                label: 'Ombro',
              ),
              checkBox(
                value: bicepsCheck,
                onChanged: (value) => _onCheckboxChanged(value, 'Bíceps'),
                label: 'Bíceps',
              ),
              checkBox(
                value: tricepsCheck,
                onChanged: (value) => _onCheckboxChanged(value, 'Tríceps'),
                label: 'Tríceps',
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }

  Widget checkBox({
    required bool value,
    required ValueChanged<bool?> onChanged,
    required String label,
  }) {
    return Card(
      elevation: 1,
      color: Colors.grey.shade800,
      margin: const EdgeInsets.all(4),
      child: InkWell(
        borderRadius: BorderRadius.circular(4),
        onTap: () => onChanged(!value),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Checkbox(
                value: value,
                onChanged: onChanged,
                fillColor: MaterialStateProperty.resolveWith(
                  (states) => states.contains(MaterialState.selected)
                      ? Colors.green.shade600
                      : Colors.grey.shade600,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade100,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _nextStep() async {
    switch (_currentStep) {
      case 0:
        if (_diasSelected == null) {
          // Não permite avançar se o valor não foi selecionado
          return;
        }
        break;
      case 1:
        if (_nivel == null) {
          // Não permite avançar se o nível não foi selecionado
          return;
        }
        break;
      case 2:
        if (_objetivo == null) {
          // Não permite avançar se o objetivo não foi selecionado
          return;
        }
        break;
      case 3:
        if (_foco == null) {
          // Não permite avançar se o foco do treino não foi selecionado
          return;
        }
        break;
      case 4:
        if (gruposMusculares.isNotEmpty) {
          context.loaderOverlay.show();
          final treino = await _treinoServices.getTreinoIA(_diasSelected!,
              _nivel!, _objetivo!, _foco!, gruposMusculares, widget.sexo);
          await Future.delayed(Duration(seconds: 5));
          context.loaderOverlay.hide();
          if (treino != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TreinoIAScreen(
                  trainingPlan: treino,
                  alunoUid: widget.uid,
                ),
              ),
            );
          }
        }
        break;
    }

    setState(() {
      if (_currentStep < 4) {
        _currentStep += 1;
      }
    });
  }

  void _previousStep() {
    setState(() {
      if (_currentStep > 0) {
        _currentStep -= 1;
      }
    });
  }
}
