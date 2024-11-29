import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import '../model/exercicio_model.dart';

class ExerciciosServices {
  dynamic castValue(dynamic value) {
    if (value is Map) {
      return safeMapCast(value);
    } else if (value is List) {
      return value.map((e) => castValue(e)).toList();
    }
    return value;
  }

  Map<String, dynamic> safeMapCast(Map<Object?, Object?>? data) {
    if (data == null) return {};

    return data.map(
      (key, value) => MapEntry(key as String, castValue(value)),
    );
  }

 Future<List<Exercicio>?> getAllExercicios() async {
    HttpsCallable callable =
        FirebaseFunctions.instanceFor(region: 'southamerica-east1')
            .httpsCallable('getAllExerciciosv2');

    try {
      debugPrint("Chamando função para obter todos os exercícios.");
      final HttpsCallableResult result = await callable.call();

      debugPrint(
          "Função chamada. Resultado obtido. Data: ${result.data.toString()}");

      if (result.data != null) {
        debugPrint("Dados não são nulos. Processando...");
        List<dynamic> dataList = result.data;

        debugPrint("DataList: $dataList");

        List<Exercicio> exercicios = dataList.map((data) {
          var safeData = safeMapCast(data as Map<Object?, Object?>);

          return Exercicio.fromFirestore(
              safeData, safeData['id'] as String);
        }).toList();

        debugPrint("Exercícios processados: ${exercicios.length}");
        debugPrint("Exercícios: $exercicios");
        for (Exercicio exercicio in exercicios) {
          debugPrint("Exercício: ${exercicio.nome}");
        }

        return exercicios;
      } else {
        debugPrint("Dados são nulos.");
        return null;
      }
    } catch (e) {
      debugPrint("Erro ao chamar a função: $e");
      throw Exception('Erro ao obter exercícios. Tente novamente mais tarde.');
    } finally {
      debugPrint("Função getAllExercicios terminada.");
    }
}


  Future<void> getUserName(uid) async {
    HttpsCallable callable =
        FirebaseFunctions.instanceFor(region: 'southamerica-east1')
            .httpsCallable('getUserNameFuncional');
    try {
      final HttpsCallableResult result =
          await callable.call(<String, dynamic>{'uid': uid});
      debugPrint(result.data['message']);
      debugPrint(result.data['Nome']);
      //return result.data['Nome'];
    } on FirebaseFunctionsException catch (e) {
      debugPrint('Erro na requisicao: ${e.code}\n${e.message}');
      //return 'Erro ao buscar nome';
    }
  }

  Future<Exercicio?> getExercicio(
      String grupoMuscular, String mecanismo, String nome) async {
    HttpsCallable callable =
        FirebaseFunctions.instanceFor(region: 'southamerica-east1')
            .httpsCallable('getExercicio');

    try {
      final HttpsCallableResult result = await callable.call(<String, dynamic>{
        'grupoMuscular': grupoMuscular,
        'mecanismo': mecanismo,
        'nome': nome,
      });

      if (result.data != null) {
        Map<String, dynamic> data = result.data;
        String id = data['id'] as String;
        Exercicio exercicio =
            Exercicio.fromFirestore(data['data'] as Map<String, dynamic>, id);
        return exercicio;
      }
      return null;
    } catch (e) {
      debugPrint("Erro ao chamar a função: ${e.toString()}");
      return null;
    }
  }

  Future<List<Exercicio>?> getExerciciosByMecanismo(String mecanismo) async {
    HttpsCallable callable =
        FirebaseFunctions.instanceFor(region: 'southamerica-east1')
            .httpsCallable('getExerciciosByMecanismo');

    try {
      final HttpsCallableResult result = await callable.call(<String, dynamic>{
        'mecanismo': mecanismo,
      });

      if (result.data != null) {
        List<dynamic> dataList = result.data;
        List<Exercicio> exercicios = dataList.map((data) {
          return Exercicio.fromFirestore(
              data['data'] as Map<String, dynamic>, data['id'] as String);
        }).toList();
        return exercicios;
      }
      return null;
    } catch (e) {
      debugPrint("Erro ao chamar a função: $e");
      return null;
    }
  }

  Future<List<Exercicio>?> getExerciciosByGrupoMuscular(
      String grupoMuscular) async {
    HttpsCallable callable =
        FirebaseFunctions.instanceFor(region: 'southamerica-east1')
            .httpsCallable('getExerciciosByGrupoMuscular');

    try {
      final HttpsCallableResult result = await callable.call(<String, dynamic>{
        'grupoMuscular': grupoMuscular,
      });

      if (result.data != null) {
        List<dynamic> dataList = result.data;
        List<Exercicio> exercicios = dataList.map((data) {
          return Exercicio.fromFirestore(
              data['data'] as Map<String, dynamic>, data['id'] as String);
        }).toList();
        return exercicios;
      }
      return null;
    } catch (e) {
      debugPrint("Erro ao chamar a função: $e");
      return null;
    }
  }

  Future<List<Exercicio>?> getExerciciosByGrupoMuscularAndMecanismo(
      String grupoMuscular, String mecanismo) async {
    HttpsCallable callable = FirebaseFunctions.instanceFor(
            region: 'southamerica-east1')
        .httpsCallable(
            'getExerciciosByGrupoMuscularAndMecanismo'); // Substitua pelo nome real da sua função Cloud

    try {
      final HttpsCallableResult result = await callable.call(<String, dynamic>{
        'grupoMuscular': grupoMuscular,
        'mecanismo': mecanismo,
      });

      if (result.data != null) {
        List<dynamic> dataList = result.data;
        List<Exercicio> exercicios = dataList.map((data) {
          return Exercicio.fromFirestore(
              data['data'] as Map<String, dynamic>, data['id'] as String);
        }).toList();
        return exercicios;
      }
      return null;
    } catch (e) {
      debugPrint("Erro ao chamar a função: $e");
      return null;
    }
  }
}
