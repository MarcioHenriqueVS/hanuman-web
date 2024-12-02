import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../notificacoes/fcm.dart';

class ChatServices {
  FirebaseMessagingService firebaseMessagingService =
      FirebaseMessagingService();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Future<void> sendMessageToFirestore(Message message, String uid) async {
  //   debugPrint(message.paraJson());
  //   debugPrint('======= chegou aqui ==========');
  //   try {
  //     // Verifica se a mensagem é do tipo 'image' ou 'voice'
  //     if (message.messageType == MessageType.image ||
  //         message.messageType == MessageType.voice) {
  //       // Supondo que `message.message` contenha o caminho do arquivo local
  //       final UploadTask uploadTask;
  //       //if (!kIsWeb) {
  //       File file = File(message.message);
  //       String filePath = message.messageType == MessageType.voice
  //           ? 'chatApp/$uid/mensagens/${DateTime.now().toUtc().subtract(const Duration(hours: 3)).millisecondsSinceEpoch}.m4a'
  //           : 'chatApp/$uid/mensagens/${DateTime.now().toUtc().subtract(const Duration(hours: 3)).millisecondsSinceEpoch}';

  //       // Faz o upload do arquivo para o Firebase Storage
  //       uploadTask =
  //           FirebaseStorage.instance.ref().child(filePath).putFile(file);
  //       // } else {
  //       //   debugPrint('======= chegou aqui, web ==========');
  //       //   final response = await html.window.fetch(message.message);
  //       //   final blob = await response.blob();
  //       //   // String filePath = message.messageType == MessageType.voice
  //       //   //     ? 'chatApp/$uid/mensagens/${DateTime.now().millisecondsSinceEpoch}.m4a'
  //       //   //     : 'chatApp/$uid/mensagens/${DateTime.now().millisecondsSinceEpoch}';

  //       //   // // Faz o upload do arquivo para o Firebase Storage
  //       //   // uploadTask =
  //       //   //     FirebaseStorage.instance.ref().child(filePath).putBlob(blob);
  //       //   final storageRef = message.messageType == MessageType.voice
  //       //       ? FirebaseStorage.instance.ref().child(
  //       //           'chatTeste/audio/${DateTime.now().millisecondsSinceEpoch}.m4a')
  //       //       : FirebaseStorage.instance.ref().child(
  //       //           'chatTeste/images/${DateTime.now().millisecondsSinceEpoch}');

  //       //   uploadTask = storageRef.putBlob(blob);
  //       // }

  //       // Aguarda a conclusão do upload e obtém a URL
  //       TaskSnapshot taskSnapshot = await uploadTask;
  //       String fileUrl = await taskSnapshot.ref.getDownloadURL();

  //       // Atualiza o campo 'message' do objeto Message com a URL do arquivo
  //       message.messageType == MessageType.voice
  //           ? message = message.copyWith(message: '${fileUrl}.m4a')
  //           : message = message.copyWith(message: fileUrl);
  //     }

  //     await firestore
  //         .collection('Chat teste')
  //         .doc(uid)
  //         .set({'sinc': 'sincronizado'});
  //     await firestore
  //         .collection('Chat teste')
  //         .doc(uid)
  //         .collection('Mensagens')
  //         .doc()
  //         .set(message.paraJson());

  //     // Chama addMessage para atualizar a lista local e o stream de mensagens
  //     // messageStreamController.sink.add(initialMessageList);
  //   } catch (e) {
  //     debugPrint("Erro ao enviar mensagem: $e");
  //   }
  // }

  Future<List<String>> fetchUserTokens(String uid) async {
    List<String> tokens = [];

    // Referência à coleção de tokens de um usuário específico
    CollectionReference tokensCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('tokens');

    // Busca todos os documentos da coleção de tokens
    QuerySnapshot tokensSnapshot = await tokensCollection.get();

    // Itera sobre os documentos e extrai o valor do token
    for (QueryDocumentSnapshot tokenDoc in tokensSnapshot.docs) {
      Map<String, dynamic> data = tokenDoc.data() as Map<String, dynamic>;
      String? token = data['fcmToken'];
      if (token != null) {
        tokens.add(token);
      }
    }

    return tokens;
  }

  void startListeningForNewChatMissionMessages(
      messageStreamController, missaoId) {
    FirebaseFirestore.instance
        .collection('Chat missão')
        .doc(missaoId)
        .snapshots()
        .listen(
      (snapshot) {
        debugPrint('snapshot: ${snapshot.data()}');
        if (snapshot.exists) {
          if (snapshot.data()!['userUnreadCount'] > 0) {
            messageStreamController.add(true);
          } else {
            messageStreamController.add(false);
          }
          messageStreamController.add(false);
        }
      },
    );
  }

  Stream<int> getUsersMissionConversationsUnreadCount(String missaoId) {
    return FirebaseFirestore.instance
        .collection('Chat missão')
        .doc(missaoId)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        return snapshot.data()!['userUnreadCount'] ?? 0;
      } else {
        return 0;
      }
    });
  }

  Stream<int> getCentralMissionAgentConversationsUnreadCount(String missaoId) {
    return FirebaseFirestore.instance
        .collection('Chat missão')
        .doc(missaoId)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        return snapshot.data()!['unreadCount'] ?? 0;
      } else {
        return 0;
      }
    });
  }

  Future<void> resetChatMissionUserUnreadCount(String missaoId) async {
    await FirebaseFirestore.instance
        .collection('Chat missão')
        .doc(missaoId)
        .set(
      {'userUnreadCount': 0},
      SetOptions(merge: true),
    );
  }

  Stream<int> getCentralMissionClientConversationsUnreadCount(String missaoId) {
    return FirebaseFirestore.instance
        .collection('Chat missão cliente')
        .doc(missaoId)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        return snapshot.data()!['unreadCount'] ?? 0;
      } else {
        return 0;
      }
    });
  }

  Future<Map<String, String>> getUserName(String uid) async {
    DocumentSnapshot<Map<String, dynamic>> document =
        await FirebaseFirestore.instance.collection('User Name').doc(uid).get();

    if (document.data() != null) {
      return {
        'Nome': document.data()!['Nome'],
      };
    } else {
      return {
        'Nome': '',
      };
    }
  }

  Future<List<String>> fetchAllCentralTokens() async {
    List<String> tokens = [];

    // Referência à coleção de tokens de um usuário específico
    CollectionReference tokensCollection = FirebaseFirestore.instance
        .collection('FCM Tokens')
        .doc('Plataforma Sombra')
        .collection('tokens');

    // Busca todos os documentos da coleção de tokens
    QuerySnapshot tokensSnapshot = await tokensCollection.get();

    debugPrint('Tokens snapshot: ${tokensSnapshot.docs.length}');

    // Itera sobre os documentos e extrai o valor do token
    for (QueryDocumentSnapshot tokenDoc in tokensSnapshot.docs) {
      Map<String, dynamic> data = tokenDoc.data() as Map<String, dynamic>;
      String? token = data['FCM Token'];
      if (token != null) {
        tokens.add(token);
      }
    }
    return tokens;
  }

  // Future<bool> insertChatMissaoCache(
  //     String userUid,
  //     String? mensagem,
  //     String? imagem,
  //     timestamp,
  //     missaoId,
  //     String? autor,
  //     String? fotoUrl) async {
  //   Database db = await MissionDatabaseHelper.instance.database;
  //   try {
  //     await db.insert(
  //         ChatMissaoTable.tableName,
  //         {
  //           ChatMissaoTable.columnUserUid: userUid,
  //           ChatMissaoTable.columnMensagem: mensagem,
  //           ChatMissaoTable.columnImagem: imagem,
  //           ChatMissaoTable.columnTimestamp: timestamp,
  //           ChatMissaoTable.columnMissaoId: missaoId,
  //           ChatMissaoTable.columnAutor: autor,
  //           ChatMissaoTable.columnFotoUrl: fotoUrl,
  //         },
  //         conflictAlgorithm: ConflictAlgorithm.replace);
  //   } catch (e) {
  //     debugPrint('Erro ao inserir mensagem no banco de dados: $e');
  //     return false;
  //   }
  //   return true;
  // }

// Future<bool> insertChatMissaoCache(
//       Message? message) async {
//     Database db = await MissionDatabaseHelper.instance.database;
//     try {
//       await db.insert(
//           ChatMissaoTable.tableName,
//           {

//           },
//           conflictAlgorithm: ConflictAlgorithm.replace);
//     } catch (e) {
//       debugPrint('Erro ao inserir mensagem no banco de dados: $e');
//       return false;
//     }
//     return true;
//   }

  // Future<List<Map<String, dynamic>>> getChatMissaoCache(String missaoId) async {
  //   Database db = await MissionDatabaseHelper.instance.database;
  //   List<Map<String, dynamic>> result = await db.query(
  //     ChatMissaoTable.tableName,
  //     where: '${ChatMissaoTable.columnMissaoId} = ?',
  //     whereArgs: [missaoId],
  //     orderBy: '${ChatMissaoTable.columnTimestamp} ASC',
  //   );
  //   return result;
  // }

  // Future<List<Message>> getChatMissaoCache(String missaoId) async {
  //   Database db = await MissionDatabaseHelper.instance.database;
  //   List<Message> result = (await db.query(
  //     ChatMissaoTable.tableName,
  //     //where: '${ChatMissaoTable.columnMissaoId} = ?',
  //     whereArgs: [missaoId],
  //     orderBy: '${ChatMissaoTable.message!.createdAt} ASC',
  //   ))
  //       .map((e) => Message.fromJson(e))
  //       .toList();
  //   return result;
  // }

  // Future<void> deleteChatMissaoCache(String missaoId) async {
  //   Database db = await MissionDatabaseHelper.instance.database;
  //   await db.delete(
  //     ChatMissaoTable.tableName,
  //     //where: '${ChatMissaoTable.columnMissaoId} = ?',
  //     whereArgs: [missaoId],
  //   );
  // }

  // //verificar se ha conversa de chat salva no banco de dados local
  // Future<bool> verificarChatMissaoCache(String missaoId) async {
  //   Database db = await MissionDatabaseHelper.instance.database;
  //   List<Map<String, dynamic>> result = await db.query(
  //     ChatMissaoTable.tableName,
  //     //where: '${ChatMissaoTable.columnMissaoId} = ?',
  //     whereArgs: [missaoId],
  //   );
  //   if (result.isNotEmpty) {
  //     return true;
  //   } else {
  //     return false;
  //   }
  // }
}
