import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_view/photo_view.dart';
import '../autenticacao/tratamento/error_snackbar.dart';
import '../autenticacao/tratamento/success_snackbar.dart';
import '../chat_view/chatview.dart';
import 'chat_services.dart';

class ChatScreen extends StatefulWidget {
  final String? uid;
  const ChatScreen({super.key, this.uid});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

String fotoUrl =
    'https://firebasestorage.googleapis.com/v0/b/hanuman-4e9f4.appspot.com/o/logoTeste.png?alt=media&token=6a45abcc-3b54-41cd-bbd9-41855fab7a46';

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController msgController = TextEditingController();
  final ValueNotifier<bool> isSubmitting = ValueNotifier(false);
  final ScrollController controller = ScrollController();
  bool firstLoad = true;
  late final FirebaseMessaging firebaseMessaging;
  final ChatServices chatServices = ChatServices();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final ChatStatus chatStatus = ChatStatus();
  AppTheme theme = DarkTheme();
  bool isDarkTheme = true;
  late ChatUser currentUser;
  late ChatController _chatController;
  List<Message> messageList = [];
  FirebaseAuth auth = FirebaseAuth.instance;
  late User? user;
  late String? uid;
  late ChatController chatViewController;
  TratamentoDeErros tratamentoDeErros = TratamentoDeErros();
  MensagemDeSucesso mensagemDeSucesso = MensagemDeSucesso();
  DateTime? lastMessageTimestamp;

  void _showHideTypingIndicator() {
    _chatController.setTypingIndicator = !_chatController.showTypingIndicator;
  }

  Future<void> resetUserUnreadCount(String uid) async {
    await FirebaseFirestore.instance.collection('Chat').doc(uid).set({
      'userUnreadCount': 0,
      //'lastMessageTimestamp': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> getCurrentChatUser() async {
    final user = FirebaseAuth.instance.currentUser;
    final userUid = user?.uid;
    final userName = user?.displayName;
    final userPhoto = user?.photoURL;

    setState(() {
      currentUser = ChatUser(
        id: userUid!,
        name: userName!,
        profilePhoto: userPhoto!,
      );
    });
  }

  Future<void> chatController(uid) async {
    _chatController = ChatController(
      initialMessageList: messageList,
      scrollController: ScrollController(),
      chatId: uid,
      chatUsers: [
        ChatUser(
          id: 'assistant',
          name: 'Assistente',
          profilePhoto: fotoUrl,
        ),
      ],
    );
    setState(() {
      chatViewController = _chatController;
    });
  }

  void checkPermission() async {
    await Permission.microphone.request();
  }

  Future<void> getLastMessageTimestamp() async {
    // Obtém o último timestamp da última mensagem carregada
    final lastMsgTimestamp = await _chatController
        .getLastMessageTimestamp(); // Agora esta é a mensagem mais recente

    setState(() {
      lastMessageTimestamp = lastMsgTimestamp;
    });
  }

  @override
  void initState() {
    user = auth.currentUser;
    uid = user!.uid;

    //getConversationMessages();
    chatStatus.isInChatScreen = true;
    firebaseMessaging = FirebaseMessaging.instance;

    // getCurrentChatUser().then((_) {
    //   chatController(uid!);
    //   startListeningForNewMessages(uid!);
    // });
    chatController(uid!);
    getCurrentChatUser();
    getLastMessageTimestamp();
    //!chatViewController.startListeningForNewMessages();
    // Listener para detectar rolagem para o topo
    _chatController.scrollController.addListener(() {
      if (_chatController.scrollController.position.pixels ==
          _chatController.scrollController.position.maxScrollExtent) {
        // Chama a função para carregar mais mensagens quando chega ao fundo
        _chatController.loadMoreMessages();
      }
    });

    // Carrega as mensagens iniciais e depois inicia o listener para novas mensagens
    _chatController.loadInitialMessages().then((_) {
      _chatController.startListeningForNewMessages(lastMessageTimestamp);
    });

    //startListeningForNewMessages(uid!);
    // Checa e atualiza o FCM Token se necessário
    // _checkAndUpdateFcmToken();
    super.initState();
  }

  @override
  void dispose() {
    msgController.dispose();
    controller.dispose();
    chatStatus.isInChatScreen = false;
    _chatController.dispose();
    //_messagesSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //final user = FirebaseAuth.instance.currentUser;
    // final userUid = user?.uid;
    // final userName = user?.displayName;
    debugPrint(
        'initialMessageList: ${_chatController.initialMessageList.length}');
    resetUserUnreadCount(uid!);
    return Center(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        //const Color.fromARGB(255, 14, 14, 14),
        // appBar: AppBar(
        //   title: const Text('Chat'),
        //   centerTitle: true,
        // ),
        body: Padding(
          padding: const EdgeInsets.all(0),
          child: ChatView(
            //loadMoreData: () => _chatController.loadMoreMessages(),
            currentUser: currentUser,
            chatController: _chatController,
            onSendTap: _onSendTap,
            featureActiveConfig: const FeatureActiveConfig(
              lastSeenAgoBuilderVisibility: false,
              receiptsBuilderVisibility: true,
              enableDoubleTapToLike: false,
            ),
            chatViewState: ChatViewState.hasMessages,
            chatViewStateConfig: ChatViewStateConfiguration(
              loadingWidgetConfig: ChatViewStateWidgetConfiguration(
                loadingIndicatorColor: theme.outgoingChatBubbleColor,
              ),
              onReloadButtonTap: () {},
            ),
            typeIndicatorConfig: TypeIndicatorConfiguration(
              flashingCircleBrightColor: theme.flashingCircleBrightColor,
              flashingCircleDarkColor: theme.flashingCircleDarkColor,
            ),
            chatBackgroundConfig: ChatBackgroundConfiguration(
              messageTimeIconColor: theme.messageTimeIconColor,
              messageTimeTextStyle:
                  TextStyle(color: theme.messageTimeTextColor),
              defaultGroupSeparatorConfig: DefaultGroupSeparatorConfiguration(
                textStyle: TextStyle(
                  color: theme.chatHeaderColor,
                  fontSize: 17,
                ),
              ),
              backgroundColor: Colors.transparent,
            ),
            sendMessageConfig: SendMessageConfiguration(
              enableCameraImagePicker: false,
              enableGalleryImagePicker: false,
              imagePickerIconsConfig: ImagePickerIconsConfiguration(
                cameraIconColor: theme.cameraIconColor,
                galleryIconColor: theme.galleryIconColor,
              ),
              replyMessageColor: theme.replyMessageColor,
              defaultSendButtonColor: theme.sendButtonColor,
              replyDialogColor: theme.replyDialogColor,
              replyTitleColor: theme.replyTitleColor,
              textFieldBackgroundColor:
                  //theme.textFieldBackgroundColor,
                  Colors.transparent,
              closeIconColor: theme.closeIconColor,
              textFieldConfig: TextFieldConfiguration(
                onMessageTyping: (status) {
                  /// Do with status
                  debugPrint(status.toString());
                },
                borderRadius: BorderRadius.circular(21),
                compositionThresholdTime: const Duration(seconds: 1),
                textStyle: TextStyle(color: theme.textFieldTextColor),
                hintStyle: TextStyle(
                  color: Colors.grey[500],
                ),
              ),
              micIconColor: theme.replyMicIconColor,
              voiceRecordingConfiguration: VoiceRecordingConfiguration(
                backgroundColor: theme.waveformBackgroundColor,
                recorderIconColor: theme.recordIconColor,
                waveStyle: WaveStyle(
                  showMiddleLine: false,
                  waveColor: theme.waveColor ?? Colors.white,
                  extendWaveform: true,
                ),
              ),
            ),
            chatBubbleConfig: ChatBubbleConfiguration(
              outgoingChatBubbleConfig: ChatBubble(
                linkPreviewConfig: LinkPreviewConfiguration(
                  backgroundColor: theme.linkPreviewOutgoingChatColor,
                  bodyStyle: theme.outgoingChatLinkBodyStyle,
                  titleStyle: theme.outgoingChatLinkTitleStyle,
                ),
                receiptsWidgetConfig: const ReceiptsWidgetConfig(
                    showReceiptsIn: ShowReceiptsIn.all),
                color: theme.outgoingChatBubbleColor,
              ),
              inComingChatBubbleConfig: ChatBubble(
                linkPreviewConfig: LinkPreviewConfiguration(
                  linkStyle: TextStyle(
                    color: theme.inComingChatBubbleTextColor,
                    decoration: TextDecoration.underline,
                  ),
                  backgroundColor: theme.linkPreviewIncomingChatColor,
                  bodyStyle: theme.incomingChatLinkBodyStyle,
                  titleStyle: theme.incomingChatLinkTitleStyle,
                ),
                textStyle: TextStyle(color: theme.inComingChatBubbleTextColor),
                onMessageRead: (message) {
                  /// send your message reciepts to the other client
                  debugPrint('Message Read');
                },
                senderNameTextStyle:
                    TextStyle(color: theme.inComingChatBubbleTextColor),
                color: theme.inComingChatBubbleColor,
              ),
            ),
            replyPopupConfig: ReplyPopupConfiguration(
              backgroundColor: theme.replyPopupColor,
              buttonTextStyle: TextStyle(color: theme.replyPopupButtonColor),
              topBorderColor: theme.replyPopupTopBorderColor,
            ),
            reactionPopupConfig: ReactionPopupConfiguration(
              shadow: BoxShadow(
                color: isDarkTheme ? Colors.black54 : Colors.grey.shade400,
                blurRadius: 20,
              ),
              backgroundColor: theme.reactionPopupColor,
            ),
            messageConfig: MessageConfiguration(
              messageReactionConfig: MessageReactionConfiguration(
                backgroundColor: theme.messageReactionBackGroundColor,
                borderColor: theme.messageReactionBackGroundColor,
                reactedUserCountTextStyle:
                    TextStyle(color: theme.inComingChatBubbleTextColor),
                reactionCountTextStyle:
                    TextStyle(color: theme.inComingChatBubbleTextColor),
                reactionsBottomSheetConfig: ReactionsBottomSheetConfiguration(
                  backgroundColor: theme.backgroundColor,
                  reactedUserTextStyle: TextStyle(
                    color: theme.inComingChatBubbleTextColor,
                  ),
                  reactionWidgetDecoration: BoxDecoration(
                    color: theme.inComingChatBubbleColor,
                    boxShadow: [
                      BoxShadow(
                        color:
                            isDarkTheme ? Colors.black12 : Colors.grey.shade200,
                        offset: const Offset(0, 20),
                        blurRadius: 40,
                      )
                    ],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              imageMessageConfig: ImageMessageConfiguration(
                onTap: (message) {
                  showDialog(
                    context: context,
                    builder: (_) {
                      return Dialog(
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height * 0.6,
                          width: MediaQuery.of(context).size.width * 0.9,
                          child: PhotoView(
                            minScale: PhotoViewComputedScale.contained,
                            maxScale: PhotoViewComputedScale.contained * 2.5,
                            imageProvider: NetworkImage(message),
                          ),
                        ),
                      );
                    },
                  );
                },
                margin:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                shareIconConfig: ShareIconConfiguration(
                  defaultIconBackgroundColor: theme.shareIconBackgroundColor,
                  defaultIconColor: theme.shareIconColor,
                ),
              ),
            ),
            profileCircleConfig: ProfileCircleConfiguration(
              profileImageUrl: fotoUrl,
            ),
            repliedMessageConfig: RepliedMessageConfiguration(
              backgroundColor: theme.repliedMessageColor,
              verticalBarColor: theme.verticalBarColor,
              repliedMsgAutoScrollConfig: RepliedMsgAutoScrollConfig(
                enableHighlightRepliedMsg: true,
                highlightColor: Colors.pinkAccent.shade100,
                highlightScale: 1.1,
              ),
              textStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.25,
              ),
              replyTitleTextStyle:
                  TextStyle(color: theme.repliedTitleTextColor),
            ),
            swipeToReplyConfig: SwipeToReplyConfiguration(
              replyIconColor: theme.swipeToReplyIconColor,
            ),
          ),
        ),
      ),
    );
  }

  void _onSendTap(
    String message,
    ReplyMessage replyMessage,
    MessageType messageType,
  ) async {
    debugPrint('messagetype: ${messageType.name}');
    debugPrint('MessaType: ${messageType.toString()}');

    // final lastid = messageList.isEmpty ? '0' : messageList.last.id;
    // debugPrint('lastid: $lastid');
    // final id = int.parse(lastid) + 1;
    final id = DateTime.now().microsecondsSinceEpoch;

    _chatController.sendMessageToFirestore(
      Message(
          id: id.toString(),
          createdAt: DateTime.now(),
          timestamp: FieldValue.serverTimestamp(),
          message: message,
          sendBy: currentUser.id,
          replyMessage: replyMessage,
          messageType: messageType,
          voiceMessageDuration: MessageType.voice == messageType
              ? const Duration(minutes: 10).inSeconds
              : null,
          autor: 'user'),
      uid!,
    );

    Future.delayed(const Duration(milliseconds: 300), () {
      _chatController.initialMessageList.last.setStatus =
          MessageStatus.undelivered;
    });
    Future.delayed(const Duration(seconds: 1), () {
      _chatController.initialMessageList.last.setStatus = MessageStatus.read;
    });
  }

  void _onThemeIconTap() {
    setState(() {
      if (isDarkTheme) {
        theme = LightTheme();
        isDarkTheme = false;
      } else {
        theme = DarkTheme();
        isDarkTheme = true;
      }
    });
  }
}

//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

class ChatStatus {
  bool isInChatScreen = false;
  static final ChatStatus _singleton = ChatStatus._internal();

  factory ChatStatus() {
    return _singleton;
  }

  ChatStatus._internal();
}

// E em algum lugar no seu código (por exemplo, no início de main.dart), você pode inicializá-la:
ChatStatus chatStatus = ChatStatus();

class AppTheme {
  final Color? appBarColor;
  final Color? backArrowColor;
  final Color? backgroundColor;
  final Color? replyDialogColor;
  final Color? replyTitleColor;
  final Color? textFieldBackgroundColor;

  final Color? outgoingChatBubbleColor;

  final Color? inComingChatBubbleColor;

  final Color? inComingChatBubbleTextColor;
  final Color? repliedMessageColor;
  final Color? repliedTitleTextColor;
  final Color? textFieldTextColor;

  final Color? closeIconColor;
  final Color? shareIconBackgroundColor;

  final Color? sendButtonColor;
  final Color? cameraIconColor;
  final Color? galleryIconColor;
  final Color? recordIconColor;
  final Color? stopIconColor;
  final Color? swipeToReplyIconColor;
  final Color? replyMessageColor;
  final Color? appBarTitleTextStyle;
  final Color? messageReactionBackGroundColor;
  final Color? messageTimeIconColor;
  final Color? messageTimeTextColor;
  final Color? reactionPopupColor;
  final Color? replyPopupColor;
  final Color? replyPopupButtonColor;
  final Color? replyPopupTopBorderColor;
  final Color? reactionPopupTitleColor;
  final Color? flashingCircleDarkColor;
  final Color? flashingCircleBrightColor;
  final Color? waveformBackgroundColor;
  final Color? waveColor;
  final Color? replyMicIconColor;
  final Color? messageReactionBorderColor;

  final Color? verticalBarColor;
  final Color? chatHeaderColor;
  final Color? themeIconColor;
  final Color? shareIconColor;
  final double? elevation;
  final Color? linkPreviewIncomingChatColor;
  final Color? linkPreviewOutgoingChatColor;
  final TextStyle? linkPreviewIncomingTitleStyle;
  final TextStyle? linkPreviewOutgoingTitleStyle;
  final TextStyle? incomingChatLinkTitleStyle;
  final TextStyle? outgoingChatLinkTitleStyle;
  final TextStyle? outgoingChatLinkBodyStyle;
  final TextStyle? incomingChatLinkBodyStyle;

  AppTheme({
    this.cameraIconColor,
    this.galleryIconColor,
    this.flashingCircleDarkColor,
    this.flashingCircleBrightColor,
    this.outgoingChatLinkBodyStyle,
    this.incomingChatLinkBodyStyle,
    this.incomingChatLinkTitleStyle,
    this.outgoingChatLinkTitleStyle,
    this.linkPreviewOutgoingChatColor,
    this.linkPreviewIncomingChatColor,
    this.linkPreviewIncomingTitleStyle,
    this.linkPreviewOutgoingTitleStyle,
    this.repliedTitleTextColor,
    this.swipeToReplyIconColor,
    this.textFieldTextColor,
    this.reactionPopupColor,
    this.replyPopupButtonColor,
    this.replyPopupTopBorderColor,
    this.reactionPopupTitleColor,
    this.appBarColor,
    this.backArrowColor,
    this.backgroundColor,
    this.replyDialogColor,
    this.replyTitleColor,
    this.textFieldBackgroundColor,
    this.outgoingChatBubbleColor,
    this.inComingChatBubbleColor,
    this.inComingChatBubbleTextColor,
    this.repliedMessageColor,
    this.closeIconColor,
    this.shareIconBackgroundColor,
    this.sendButtonColor,
    this.replyMessageColor,
    this.appBarTitleTextStyle,
    this.messageReactionBackGroundColor,
    this.messageReactionBorderColor,
    this.verticalBarColor,
    this.chatHeaderColor,
    this.themeIconColor,
    this.shareIconColor,
    this.elevation,
    this.messageTimeIconColor,
    this.messageTimeTextColor,
    this.replyPopupColor,
    this.recordIconColor,
    this.stopIconColor,
    this.waveformBackgroundColor,
    this.waveColor,
    this.replyMicIconColor,
  });
}

class DarkTheme extends AppTheme {
  DarkTheme({
    Color super.flashingCircleDarkColor = Colors.white,
    Color super.flashingCircleBrightColor = Colors.white,
    TextStyle super.incomingChatLinkTitleStyle =
        const TextStyle(color: Colors.black),
    TextStyle super.outgoingChatLinkTitleStyle =
        const TextStyle(color: Colors.white),
    TextStyle super.outgoingChatLinkBodyStyle =
        const TextStyle(color: Colors.white),
    TextStyle super.incomingChatLinkBodyStyle =
        const TextStyle(color: Colors.white),
    double super.elevation = 1,
    Color super.repliedTitleTextColor = Colors.white,
    super.swipeToReplyIconColor = Colors.white,
    Color super.textFieldTextColor = Colors.white,
    Color super.appBarColor = const Color.fromARGB(255, 27, 31, 37),
    Color super.backArrowColor = Colors.white,
    Color super.backgroundColor = Colors.black,
    Color super.replyDialogColor = const Color.fromARGB(255, 35, 43, 54),
    Color super.linkPreviewOutgoingChatColor =
        const Color.fromARGB(255, 35, 43, 54),
    Color super.linkPreviewIncomingChatColor =
        const Color.fromARGB(255, 133, 180, 255),
    TextStyle super.linkPreviewIncomingTitleStyle = const TextStyle(),
    TextStyle super.linkPreviewOutgoingTitleStyle = const TextStyle(),
    Color super.replyTitleColor = Colors.white,
    Color super.textFieldBackgroundColor =
        const Color.fromARGB(255, 56, 142, 60),
    Color super.outgoingChatBubbleColor =
        const Color.fromARGB(255, 56, 142, 60),
    Color super.inComingChatBubbleColor = const Color.fromARGB(255, 76, 76, 76),
    Color super.reactionPopupColor = Colors.green,
    Color super.replyPopupColor = Colors.green,
    Color super.replyPopupButtonColor = Colors.white,
    Color super.replyPopupTopBorderColor = Colors.black54,
    Color super.reactionPopupTitleColor = Colors.white,
    Color super.inComingChatBubbleTextColor = Colors.white,
    Color super.repliedMessageColor = Colors.green,
    Color super.closeIconColor = Colors.white,
    Color super.shareIconBackgroundColor = Colors.green,
    Color super.sendButtonColor = Colors.white,
    Color super.cameraIconColor = Colors.white,
    Color super.galleryIconColor = Colors.white,
    Color recorderIconColor = Colors.white,
    Color super.stopIconColor = Colors.white,
    Color super.replyMessageColor = Colors.white,
    Color super.appBarTitleTextStyle = Colors.white,
    Color super.messageReactionBackGroundColor =
        const Color.fromARGB(255, 31, 45, 79),
    Color super.messageReactionBorderColor =
        const Color.fromARGB(255, 29, 52, 88),
    Color super.verticalBarColor = const Color.fromARGB(255, 34, 53, 87),
    Color super.chatHeaderColor = Colors.white,
    Color super.themeIconColor = Colors.white,
    Color super.shareIconColor = Colors.white,
    Color super.messageTimeIconColor = Colors.white,
    Color super.messageTimeTextColor = Colors.white,
    Color super.waveformBackgroundColor = const Color.fromARGB(255, 22, 36, 78),
    Color super.waveColor = Colors.white,
    Color super.replyMicIconColor = Colors.white,
  }) : super(
          recordIconColor: recorderIconColor,
        );
}

class LightTheme extends AppTheme {
  LightTheme({
    Color flashingCircleDarkColor = const Color(0xffEE5366),
    Color flashingCircleBrightColor = const Color(0xffFCD8DC),
    TextStyle incomingChatLinkTitleStyle = const TextStyle(color: Colors.black),
    TextStyle outgoingChatLinkTitleStyle = const TextStyle(color: Colors.black),
    TextStyle outgoingChatLinkBodyStyle = const TextStyle(color: Colors.grey),
    TextStyle incomingChatLinkBodyStyle = const TextStyle(color: Colors.grey),
    Color textFieldTextColor = Colors.black,
    Color repliedTitleTextColor = Colors.black,
    Color swipeToReplyIconColor = Colors.black,
    double elevation = 2,
    Color appBarColor = Colors.white,
    Color backArrowColor = const Color(0xffEE5366),
    Color backgroundColor = const Color(0xffeeeeee),
    Color replyDialogColor = const Color(0xffFCD8DC),
    Color linkPreviewOutgoingChatColor = const Color(0xffFCD8DC),
    Color linkPreviewIncomingChatColor = const Color(0xFFEEEEEE),
    TextStyle linkPreviewIncomingTitleStyle = const TextStyle(),
    TextStyle linkPreviewOutgoingTitleStyle = const TextStyle(),
    Color replyTitleColor = const Color(0xffEE5366),
    Color reactionPopupColor = Colors.white,
    Color replyPopupColor = Colors.white,
    Color replyPopupButtonColor = Colors.black,
    Color replyPopupTopBorderColor = const Color(0xFFBDBDBD),
    Color reactionPopupTitleColor = Colors.grey,
    Color textFieldBackgroundColor = Colors.white,
    Color outgoingChatBubbleColor = const Color(0xffEE5366),
    Color inComingChatBubbleColor = Colors.white,
    Color inComingChatBubbleTextColor = Colors.black,
    Color repliedMessageColor = const Color(0xffff8aad),
    Color closeIconColor = Colors.black,
    Color shareIconBackgroundColor = const Color(0xFFE0E0E0),
    Color sendButtonColor = const Color(0xffEE5366),
    Color cameraIconColor = Colors.black,
    Color galleryIconColor = Colors.black,
    Color replyMessageColor = Colors.black,
    Color appBarTitleTextStyle = Colors.black,
    Color messageReactionBackGroundColor = const Color(0xFFEEEEEE),
    Color messageReactionBorderColor = Colors.white,
    Color verticalBarColor = const Color(0xffEE5366),
    Color chatHeaderColor = Colors.black,
    Color themeIconColor = Colors.black,
    Color shareIconColor = Colors.black,
    Color messageTimeIconColor = Colors.black,
    Color messageTimeTextColor = Colors.black,
    Color recorderIconColor = Colors.black,
    Color stopIconColor = Colors.black,
    Color waveformBackgroundColor = Colors.white,
    Color waveColor = Colors.black,
    Color replyMicIconColor = Colors.black,
  }) : super(
          reactionPopupColor: reactionPopupColor,
          closeIconColor: closeIconColor,
          verticalBarColor: verticalBarColor,
          textFieldBackgroundColor: textFieldBackgroundColor,
          replyTitleColor: replyTitleColor,
          replyDialogColor: replyDialogColor,
          backgroundColor: backgroundColor,
          appBarColor: appBarColor,
          appBarTitleTextStyle: appBarTitleTextStyle,
          backArrowColor: backArrowColor,
          chatHeaderColor: chatHeaderColor,
          inComingChatBubbleColor: inComingChatBubbleColor,
          inComingChatBubbleTextColor: inComingChatBubbleTextColor,
          messageReactionBackGroundColor: messageReactionBackGroundColor,
          messageReactionBorderColor: messageReactionBorderColor,
          outgoingChatBubbleColor: outgoingChatBubbleColor,
          repliedMessageColor: repliedMessageColor,
          replyMessageColor: replyMessageColor,
          sendButtonColor: sendButtonColor,
          shareIconBackgroundColor: shareIconBackgroundColor,
          themeIconColor: themeIconColor,
          shareIconColor: shareIconColor,
          elevation: elevation,
          messageTimeIconColor: messageTimeIconColor,
          messageTimeTextColor: messageTimeTextColor,
          textFieldTextColor: textFieldTextColor,
          repliedTitleTextColor: repliedTitleTextColor,
          swipeToReplyIconColor: swipeToReplyIconColor,
          replyPopupColor: replyPopupColor,
          replyPopupButtonColor: replyPopupButtonColor,
          replyPopupTopBorderColor: replyPopupTopBorderColor,
          reactionPopupTitleColor: reactionPopupTitleColor,
          linkPreviewOutgoingChatColor: linkPreviewOutgoingChatColor,
          linkPreviewIncomingChatColor: linkPreviewIncomingChatColor,
          linkPreviewIncomingTitleStyle: linkPreviewIncomingTitleStyle,
          linkPreviewOutgoingTitleStyle: linkPreviewOutgoingTitleStyle,
          incomingChatLinkBodyStyle: incomingChatLinkBodyStyle,
          incomingChatLinkTitleStyle: incomingChatLinkTitleStyle,
          outgoingChatLinkBodyStyle: outgoingChatLinkBodyStyle,
          outgoingChatLinkTitleStyle: outgoingChatLinkTitleStyle,
          flashingCircleDarkColor: flashingCircleDarkColor,
          flashingCircleBrightColor: flashingCircleBrightColor,
          galleryIconColor: galleryIconColor,
          cameraIconColor: cameraIconColor,
          stopIconColor: stopIconColor,
          recordIconColor: recorderIconColor,
          waveformBackgroundColor: waveformBackgroundColor,
          waveColor: waveColor,
          replyMicIconColor: replyMicIconColor,
        );
}
