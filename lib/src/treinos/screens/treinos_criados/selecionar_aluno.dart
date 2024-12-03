import 'dart:async';

import 'package:diacritic/diacritic.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../alunos/bloc/get_alunos/get_alunos_bloc.dart';
import '../../../alunos/pages/components/add_aluno_dialog.dart';
import '../../../alunos/pages/components/aluno_card.dart';
import '../../../alunos/models/aluno_model.dart';
import '../../../utils.dart';
import '../../../widgets_comuns/button_bloc/elevated_button_bloc.dart';
import '../../../widgets_comuns/button_bloc/elevated_button_bloc_event.dart';
import '../../../widgets_comuns/flutter_flow/ff_button_options.dart';
import '../../models/treino_model.dart';

class SelecionarAluno extends StatefulWidget {
  final Treino treino;
  final String pastaId;
  final String treinoId;
  const SelecionarAluno(
      {super.key,
      required this.treino,
      required this.pastaId,
      required this.treinoId});

  @override
  State<SelecionarAluno> createState() => _SelecionarAlunoState();
}

class _SelecionarAlunoState extends State<SelecionarAluno> {
  final TextEditingController _searchController = TextEditingController();
  List<AlunoModel> alunos = [];
  List<AlunoModel> alunosFiltrados = [];
  bool hasMoreData = true;
  bool buscando = false;
  bool buscandoMais = false;
  int page = 1;
  final ScrollController _scrollController = ScrollController();
  bool erroBuscaInicial = false;
  bool semDados = false;

  // Adicione estas variáveis
  Timer? _debounce;
  final Duration _debounceDuration = const Duration(milliseconds: 500);

  @override
  void initState() {
    super.initState();
    // Remova o addListener do initState
    // Vamos usar onChanged no TextField
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // Atualize o método _searchListener
  void _searchListener(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();

    _debounce = Timer(_debounceDuration, () {
      setState(() {
        if (query.isEmpty) {
          alunosFiltrados = List.from(alunos);
        } else {
          alunosFiltrados = alunos.where((aluno) {
            final nomeNormalizado = removeDiacritics(aluno.nome.toLowerCase()).trim();
            final queryNormalizada = removeDiacritics(query.toLowerCase()).trim();
            return nomeNormalizado.contains(queryNormalizada);
          }).toList();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: 600, maxWidth: 600),
        child: Column(
          children: [
            // Header do dialog
            Container(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: Color(0xFF252525),
                borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
                border: Border(bottom: BorderSide(color: Color(0xFF333333))),
              ),
              child: Row(
                children: [
                  Text(
                    'Selecionar Aluno',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  Spacer(),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.white60, size: 20),
                    onPressed: () => Navigator.pop(context),
                    splashRadius: 20,
                  ),
                ],
              ),
            ),

            // Campo de busca
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFF1A1A1A),
                border: Border(bottom: BorderSide(color: Color(0xFF333333))),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _searchListener, // Mudança aqui
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Buscar aluno...',
                  hintStyle: TextStyle(color: Colors.white38),
                  prefixIcon:
                      Icon(Icons.search, color: Colors.white38, size: 20),
                  filled: true,
                  fillColor: Color(0xFF252525),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16),
                ),
              ),
            ),

            // Lista de alunos
            Expanded(
              child: Container(
                color: Color(0xFF1A1A1A),
                child: PopScope(
                  canPop: true,
                  onPopInvokedWithResult: (didPop, result) {
                    BlocProvider.of<ElevatedButtonBloc>(context)
                        .add(ElevatedButtonReset());
                  },
                  child: BlocBuilder<GetAlunosBloc, GetAlunosState>(
                    builder: (context, state) {
                      if (state is GetAlunosInitial ||
                          state is GetAlunosLoading) {
                        return Center(
                          child: CircularProgressIndicator(color: Colors.green),
                        );
                      } else if (state is GetAlunosError) {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.error_outline,
                                  color: Colors.red[300], size: 48),
                              SizedBox(height: 16),
                              Text(
                                'Erro ao buscar alunos',
                                style: TextStyle(color: Colors.white70),
                              ),
                            ],
                          ),
                        );
                      } else if (state is GetAlunosDataIsEmpty) {
                        return _buildEmptyState();
                      } else if (state is GetAlunosLoaded) {
                        alunos = state.alunos;
                        // Só atualize alunosFiltrados se não houver busca ativa
                        if (_searchController.text.isEmpty) {
                          alunosFiltrados = List.from(alunos);
                        }

                        return ListView.builder(
                          itemCount: alunosFiltrados.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 4,
                              ),
                              child: MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: AlunosCard(
                                  aluno: alunosFiltrados[index],
                                  choose: true,
                                  treino: widget.treino,
                                  treinoId: widget.treinoId,
                                  pastaId: widget.pastaId,
                                ),
                              ),
                            );
                          },
                        );
                      }
                      return SizedBox();
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(48),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_outlined, size: 48, color: Colors.grey[600]),
          const SizedBox(height: 16),
          Text(
            'Nenhum aluno encontrado',
            style: SafeGoogleFont(
              'Readex Pro',
              textStyle: TextStyle(
                fontSize: 16,
                color: Colors.grey[400],
              ),
            ),
          ),
          const SizedBox(height: 16),
          FFButtonWidget(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const AddAlunoDialog(),
              );
            },
            text: 'Adicionar aluno',
            icon: const Icon(
              Icons.add_rounded,
              size: 15,
            ),
            options: FFButtonOptions(
              height: 40,
              padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
              iconPadding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
              color: Colors.green,
              textStyle: SafeGoogleFont(
                'Readex Pro',
                textStyle: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              elevation: 3,
              borderSide: const BorderSide(
                color: Colors.transparent,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ],
      ),
    );
  }
}
