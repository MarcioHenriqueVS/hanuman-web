/*
 * Copyright (c) 2022 Simform Solutions
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */
import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../chat/chat_services.dart';
import '../../../notificacoes/fcm.dart';
import '../models/models.dart';
import '../values/enumaration.dart';
import 'dart:html' as html;

class ChatController {
  /// Represents initial message list in chat which can be add by user.
  List<Message> initialMessageList;

  ScrollController scrollController;

  final FirebaseMessagingService firebaseMessagingService =
      FirebaseMessagingService();

  /// Allow user to show typing indicator defaults to false.
  final ValueNotifier<bool> _showTypingIndicator = ValueNotifier(false);

  /// TypingIndicator as [ValueNotifier] for [GroupedChatList] widget's typingIndicator [ValueListenableBuilder].
  ///  Use this for listening typing indicators
  ///   ```dart
  ///    chatcontroller.typingIndicatorNotifier.addListener((){});
  ///  ```
  /// For more functionalities see [ValueNotifier].
  ValueNotifier<bool> get typingIndicatorNotifier => _showTypingIndicator;

  /// Getter for typingIndicator value instead of accessing [_showTypingIndicator.value]
  /// for better accessibility.
  bool get showTypingIndicator => _showTypingIndicator.value;

  /// Setter for changing values of typingIndicator
  /// ```dart
  ///  chatContoller.setTypingIndicator = true; // for showing indicator
  ///  chatContoller.setTypingIndicator = false; // for hiding indicator
  ///  ````
  set setTypingIndicator(bool value) => _showTypingIndicator.value = value;

  /// Represents list of chat users
  List<ChatUser> chatUsers;

  String chatId;

  String? missaoId;

  DocumentSnapshot? lastDocument;
  bool isLoadingMoreMessages = false;
  final int pageSize = 8; // Define quantas mensagens serão carregadas por vez.

  ChatController({
    required this.initialMessageList,
    required this.scrollController,
    required this.chatUsers,
    required this.chatId,
    this.missaoId,
    this.lastDocument,
  });

  /// Represents message stream of chat
  StreamController<List<Message>> messageStreamController = StreamController();

  ChatServices chatServices = ChatServices();

  /// Used to dispose stream.
  void dispose() => messageStreamController.close();

  /// Used to add message in message list.
  void addMessage(Message message) {
    initialMessageList.add(message);
    messageStreamController.sink.add(initialMessageList);
  }

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> sendMessageToFirestore(Message message, String uid) async {
    print(message.paraJson());
    print('======= chegou aqui ==========');
    try {
      //String msgType = 'text';
      //firestore.settings = const Settings(persistenceEnabled: true);
      // Verifica se a mensagem é do tipo 'image' ou 'voice'
      if (message.messageType == MessageType.image ||
          message.messageType == MessageType.voice) {
        debugPrint(message.messageType.toString());

        //   SettableMetadata? metadata;
        //   if (message.messageType == MessageType.image) {
        //     metadata = SettableMetadata(
        //       cacheControl: 'max-age=3600',
        //       contentType: 'image/jpeg',
        //     );
        //   } else if (message.messageType == MessageType.voice) {
        //     msgType = 'voice';
        //     metadata = SettableMetadata(
        //       cacheControl: 'public, max-age=3600',
        //       contentType: 'audio/m4a',
        //     );
        //   }
        //   // Supondo que `message.message` contenha o caminho do arquivo local
        //   final UploadTask uploadTask;
        //   File file = File(message.message);
        //   debugPrint('File definido');
        //   String filePath = message.messageType == MessageType.voice
        //       ? 'chatApp/$uid/mensagens/${DateTime.now().millisecondsSinceEpoch}.m4a'
        //       : 'chatApp/$uid/mensagens/${DateTime.now().millisecondsSinceEpoch}';

        //   // Faz o upload do arquivo para o Firebase Storage
        //   uploadTask = message.messageType == MessageType.voice
        //       ? FirebaseStorage.instance
        //           .ref()
        //           .child(filePath)
        //           .putFile(file, metadata)
        //       : FirebaseStorage.instance
        //           .ref()
        //           .child(filePath)
        //           .putFile(file, metadata);
        //   debugPrint('--> upload task: ${uploadTask.toString()}');

        //   // Aguarda a conclusão do upload e obtém a URL
        //   TaskSnapshot taskSnapshot = await uploadTask;
        //   debugPrint(taskSnapshot.toString());
        //   String fileUrl = await taskSnapshot.ref.getDownloadURL();

        //   // Atualiza o campo 'message' do objeto Message com a URL do arquivo
        //   message.messageType == MessageType.voice
        //       ? message = message.copyWith(message: '$fileUrl.m4a')
        //       : message = message.copyWith(message: fileUrl);
        // }
        final UploadTask uploadTask;
        if (!kIsWeb) {
          File file = File(message.message);
          String filePath = message.messageType == MessageType.voice
              ? 'chatApp/$uid/mensagens/${DateTime.now().millisecondsSinceEpoch}.m4a'
              : 'chatApp/$uid/mensagens/${DateTime.now().millisecondsSinceEpoch}';

          // Faz o upload do arquivo para o Firebase Storage
          uploadTask =
              FirebaseStorage.instance.ref().child(filePath).putFile(file);
        } else {
          debugPrint('======= chegou aqui, web ==========');
          final response = await html.window.fetch(message.message);
          final blob = await response.blob();
          // String filePath = message.messageType == MessageType.voice
          //     ? 'chatApp/$uid/mensagens/${DateTime.now().millisecondsSinceEpoch}.m4a'
          //     : 'chatApp/$uid/mensagens/${DateTime.now().millisecondsSinceEpoch}';

          // // Faz o upload do arquivo para o Firebase Storage
          // uploadTask =
          //     FirebaseStorage.instance.ref().child(filePath).putBlob(blob);
          final storageRef = message.messageType == MessageType.voice
              ? FirebaseStorage.instance.ref().child(
                  'chatApp/$uid/mensagens/${DateTime.now().millisecondsSinceEpoch}.m4a')
              : FirebaseStorage.instance.ref().child(
                  'chatApp/$uid/mensagens/${DateTime.now().millisecondsSinceEpoch}');

          uploadTask = storageRef.putBlob(blob);
        }

        // Aguarda a conclusão do upload e obtém a URL
        TaskSnapshot taskSnapshot = await uploadTask;
        String fileUrl = await taskSnapshot.ref.getDownloadURL();

        // Atualiza o campo 'message' do objeto Message com a URL do arquivo
        message.messageType == MessageType.voice
            ? message = message.copyWith(message: '${fileUrl}.m4a')
            : message = message.copyWith(message: fileUrl);
      }

      await firestore.collection('Chat').doc(uid).set({'sinc': 'sincronizado'});
      debugPrint('------- enviando para o banco de dados --------');
      await firestore
          .collection('Chat')
          .doc(uid)
          .collection('Mensagens')
          .doc(message.id)
          .set(message.paraJson());

      String url =
          'https://southamerica-east1-hanuman-4e9f4.cloudfunctions.net/virtualAssistantv2';
          //'http://127.0.0.1:5001/hanuman-4e9f4/southamerica-east1/virtualAssistantv2';

      debugPrint('fazendo requisicao');
      final msgJson = message.paraJson();
      debugPrint(msgJson.entries.toString());

      debugPrint('message id ------> ${message.id}');

      final msgType =  message.messageType == MessageType.text ? 'text' : message.messageType == MessageType.image ? 'image' : 'voice';

      final dioresult = await Dio().post(url, data: {
        'uid': uid,
        'data': {
          'message': message.message,
          'message_type': msgType,
          'messageId': message.id
        }
      });

      debugPrint('requisicao feita');

      debugPrint(dioresult.statusMessage);

      // Incrementar unreadCount quando o atendente envia uma mensagem
      await FirebaseFirestore.instance.collection('Chat').doc(uid).set(
          {'unreadCount': FieldValue.increment(1)}, SetOptions(merge: true));

      await FirebaseFirestore.instance.collection('Chat').doc(uid).set(
          {'lastMessageTimestamp': FieldValue.serverTimestamp()},
          SetOptions(merge: true));

      List<String> centralTokens = await chatServices.fetchAllCentralTokens();

      for (String token in centralTokens) {
        debugPrint('token: $token');
        await firebaseMessagingService.enviarNotificacaoParaAluno(
            token, 'Nova mensagem', message.message, null);
      }
    } catch (e) {
      print("Erro ao enviar mensagem: $e");
    }
  }

  /// Função para carregar as mensagens iniciais
  Future<List<Message>> loadInitialMessages() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Chat')
        .doc(chatId)
        .collection('Mensagens')
        .orderBy('createdAt', descending: true)
        .limit(pageSize) // Limite de mensagens a serem carregadas
        .get();

    List<Message> messages = [];

    // Atualiza o último documento
    if (querySnapshot.docs.isNotEmpty) {
      lastDocument = querySnapshot.docs.last;
      for (var doc in querySnapshot.docs) {
        Message message = Message.fromJson(doc.data() as Map<String, dynamic>);
        messages.add(message);
      }
    }

    // Converte os documentos em mensagens e adiciona à lista
    List<Message> newMessages = querySnapshot.docs
        .map((doc) => Message.fromJson(doc.data() as Map<String, dynamic>))
        .toList();

    // Adiciona as mensagens à lista
    initialMessageList.addAll(
        newMessages.reversed); // Reverte a ordem para exibir corretamente

    messageStreamController
        .add(initialMessageList); // Atualiza o stream com as mensagens

    return messages;
  }

  /// Função para carregar mais mensagens ao rolar para o topo
  Future<void> loadMoreMessages() async {
    debugPrint('----------------> loadmoredata <-------------');
    if (isLoadingMoreMessages || lastDocument == null) {
      debugPrint('no more data');
      return; // Se já estiver carregando ou não houver mais mensagens, interrompe.
    }

    isLoadingMoreMessages = true;

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Chat')
        .doc(chatId)
        .collection('Mensagens')
        .orderBy('createdAt', descending: true)
        .startAfterDocument(
            lastDocument!) // Inicia após o último documento carregado
        .limit(pageSize) // Limite de mensagens a serem carregadas
        .get();

    // Atualiza o último documento
    if (querySnapshot.docs.isNotEmpty) {
      lastDocument = querySnapshot.docs.last;
    } else {
      lastDocument = null; // Não há mais mensagens a carregar
    }

    // Converte os documentos em mensagens e adiciona ao início da lista
    List<Message> newMessages = querySnapshot.docs
        .map((doc) => Message.fromJson(doc.data() as Map<String, dynamic>))
        .toList();

    if (newMessages.isNotEmpty) {
      loadMoreData(newMessages.reversed.toList());
    }

    isLoadingMoreMessages = false;
  }

  /// Função para iniciar o listener de novas mensagens
  void startListeningForNewMessages(DateTime? lastMessageTimestamp) {
    FirebaseFirestore.instance
        .collection('Chat')
        .doc(chatId)
        .collection('Mensagens')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .listen((snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          var rawData = change.doc.data() as Map<String, dynamic>;

          // Faz o debugPrint do campo createdAt diretamente
          debugPrint('Raw createdAt: ${rawData['createdAt']}');

          Message newMessage =
              Message.fromJson(change.doc.data() as Map<String, dynamic>);

          // Adiciona apenas se a mensagem for mais nova que a última mensagem conhecida
          if (lastMessageTimestamp == null ||
              newMessage.createdAt.isAfter(lastMessageTimestamp!)) {
            initialMessageList.add(newMessage);
            lastMessageTimestamp = newMessage.createdAt; // Atualiza o timestamp
          }
        } else if (change.type == DocumentChangeType.modified) {
          // var rawData = change.doc.data() as Map<String, dynamic>;

          // // Faz o debugPrint do campo createdAt diretamente
          // debugPrint('Raw createdAt: ${rawData['createdAt']}');

          Message updatedMessage =
              Message.fromJson(change.doc.data() as Map<String, dynamic>);
          int index =
              initialMessageList.indexWhere((msg) => msg.id == change.doc.id);

          if (index != -1) {
            initialMessageList[index] =
                updatedMessage; // Atualiza a mensagem na lista
          } else {
            // Se a mensagem não foi encontrada, adicione-a à lista
            initialMessageList.add(updatedMessage);
          }
        } else if (change.type == DocumentChangeType.removed) {
          initialMessageList.removeWhere((msg) => msg.id == change.doc.id);
        }
      }

      // Emitir a lista atualizada
      if (!messageStreamController.isClosed) {
        messageStreamController.add(List.from(initialMessageList));
      }
    });
  }

  Future<DateTime?> getLastMessageTimestamp() async {
    var snapshot = await FirebaseFirestore.instance
        .collection('Chat')
        .doc(chatId)
        .collection('Mensagens')
        .orderBy('createdAt', descending: true)
        .limit(1) // Apenas uma mensagem
        .get();

    if (snapshot.docs.isNotEmpty) {
      var data = snapshot.docs.first.data() as Map<String, dynamic>;
      return (data['createdAt'] as Timestamp)
          .toDate(); // Converte para DateTime
    }
    return null; // Retorna null se não houver mensagens
  }

  /// Function for setting reaction on specific chat bubble
  void setReaction({
    required String emoji,
    required String messageId,
    required String userId,
  }) {
    final message =
        initialMessageList.firstWhere((element) => element.id == messageId);
    final reactedUserIds = message.reaction.reactedUserIds;
    final indexOfMessage = initialMessageList.indexOf(message);
    final userIndex = reactedUserIds.indexOf(userId);
    if (userIndex != -1) {
      if (message.reaction.reactions[userIndex] == emoji) {
        message.reaction.reactions.removeAt(userIndex);
        message.reaction.reactedUserIds.removeAt(userIndex);
      } else {
        message.reaction.reactions[userIndex] = emoji;
      }
    } else {
      message.reaction.reactions.add(emoji);
      message.reaction.reactedUserIds.add(userId);
    }
    initialMessageList[indexOfMessage] = Message(
      id: messageId,
      message: message.message,
      createdAt: message.createdAt,
      sendBy: message.sendBy,
      replyMessage: message.replyMessage,
      reaction: message.reaction,
      messageType: message.messageType,
      status: message.status,
      autor: message.autor,
    );
    messageStreamController.sink.add(initialMessageList);
  }

  /// Function to scroll to last messages in chat view
  void scrollToLastMessage() => Timer(
        const Duration(milliseconds: 300),
        () => scrollController.animateTo(
          scrollController.position.minScrollExtent,
          curve: Curves.easeIn,
          duration: const Duration(milliseconds: 300),
        ),
      );

  /// Function for loading data while pagination.
  void loadMoreData(List<Message> messageList) {
    /// Here, we have passed 0 index as we need to add data before first data
    initialMessageList.insertAll(0, messageList);
    messageStreamController.sink.add(initialMessageList);
  }

  /// Function for getting ChatUser object from user id
  ChatUser getUserFromId(String userId) =>
      chatUsers.firstWhere((element) => element.id == userId);
}
