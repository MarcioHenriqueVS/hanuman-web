import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../services/alunos_services.dart';
part 'get_foto_cadastro_aluno_event.dart';
part 'get_foto_cadastro_aluno_state.dart';

class GetFotoCadastroAlunoBloc
    extends Bloc<GetFotoCadastroAlunoEvent, GetFotoCadastroAlunoState> {
  GetFotoCadastroAlunoBloc() : super(GetFotoCadastroAlunoInitial()) {
    AlunosServices alunosServices = AlunosServices();
    on<SelecionarFotoEvent>(
      (event, emit) async {
        try {
          final fotoBytes = await alunosServices.selectImageBytes();
          debugPrint(fotoBytes.toString());
          fotoBytes != null
              ? emit(
                  GetFotoCadastroAlunoLoaded(fotoBytes),
                )
              : emit(GetFotoCadastroAlunoInitial());
        } catch (e) {
          GetFotoCadastroAlunoError(e.toString());
        }
      },
    );
    on<RestartFotoEvent>(
      (event, emit) async {
        emit(GetFotoCadastroAlunoInitial());
      },
    );
  }
}
