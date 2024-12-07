import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../autenticacao/services/user_services.dart';
import 'events_foto.dart';
import 'states_foto.dart';

class PickImageBloc extends Bloc<PickImageEvent, PickImageState> {
  PickImageBloc() : super(PickImageInitial()) {
    final UserServices userServices = UserServices();
    String? foto;
    on<SelectImage>(
      (event, emit) async {
        emit(PickImageLoading());
        try {
          final String? selectedImage = await userServices.pickImage();

          //debugPrint('chegou aqui');
          // final File? imgFile = File(selectedImage);
          // final bytes = await imgFile.readAsBytes();
          // final base64Image = base64Encode(bytes);
          // debugPrint(base64Image);

          if (selectedImage != null) {
            foto = selectedImage;
            emit(
              PickImageLoaded(
                foto,
              ),
            );
          }
        } catch (_) {
          emit(
            PickImageError('Erro ao buscar credencial'),
          );
        }
      },
    );
  }
}
