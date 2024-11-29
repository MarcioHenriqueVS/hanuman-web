import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../treinos/teste/models/training_program_model.dart';
import '../../../treinos/teste/treino_ia_teste.dart';
import '../models/chat_bubble.dart';
import '../models/link_preview_configuration.dart';
import '../models/message.dart';
import '../models/message_reaction_configuration.dart';
import '../utils/constants/constants.dart';
import 'reaction_widget.dart';

class TreinoMessageView extends StatelessWidget {
  const TreinoMessageView({
    super.key,
    required this.isMessageBySender,
    required this.message,
    this.chatBubbleMaxWidth,
    this.inComingChatBubbleConfig,
    this.outgoingChatBubbleConfig,
    this.messageReactionConfig,
    this.highlightMessage = false,
    this.highlightColor,
  });

  /// Represents current message is sent by current user.
  final bool isMessageBySender;

  /// Provides message instance of chat.
  final Message message;

  /// Allow users to give max width of chat bubble.
  final double? chatBubbleMaxWidth;

  /// Provides configuration of chat bubble appearance from other user of chat.
  final ChatBubble? inComingChatBubbleConfig;

  /// Provides configuration of chat bubble appearance from current user of chat.
  final ChatBubble? outgoingChatBubbleConfig;

  /// Provides configuration of reaction appearance in chat bubble.
  final MessageReactionConfiguration? messageReactionConfig;

  /// Represents message should highlight.
  final bool highlightMessage;

  /// Allow user to set color of highlighted message.
  final Color? highlightColor;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final textMessage = message.message;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          constraints: BoxConstraints(
              maxWidth: chatBubbleMaxWidth ??
                  MediaQuery.of(context).size.width * 0.75),
          padding: _padding ??
              const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
          margin: _margin ??
              EdgeInsets.fromLTRB(
                  5, 0, 6, message.reaction.reactions.isNotEmpty ? 15 : 2),
          decoration: BoxDecoration(
            color: highlightMessage ? highlightColor : _color,
            borderRadius: _borderRadius(textMessage),
          ),
          child: Column(
            children: [
              const Text(
                  'Treino gerado com sucesso! Clique no card abaixo para abrir e enviar para o aluno: '),
              const SizedBox(
                height: 10,
              ),
              GestureDetector(
                onTap: () {
                  TrainingProgram treino;
                  if (message.message != 'Treino gerado com sucesso!') {
                    final decodedData = jsonDecode(message.message);
                    treino = TrainingProgram.fromJson(decodedData);
                  } else {
                    treino = TrainingProgram.fromJson(message.treino!);
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TreinoIAScreen(
                          trainingPlan: treino,
                          alunoUid: message.alunoUid,
                          messageId: message.id),
                    ),
                  );
                },
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Container(
                    height: 45,
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      border: Border.all(color: Colors.green),
                      borderRadius: const BorderRadius.all(
                        Radius.circular(10),
                      ),
                    ),
                    child: const Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                      child: Row(
                        children: [
                          Text(
                            'VISUALIZAR TREINO',
                            style: TextStyle(),
                          ),
                          Icon(
                            Icons.arrow_forward_ios_outlined,
                            size: 16,
                            color: Colors.green,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (message.reaction.reactions.isNotEmpty)
          Positioned(
            bottom: -15, // ajuste a posição conforme necessário
            child: ReactionWidget(
              isMessageBySender: isMessageBySender,
              reaction: message.reaction,
              messageReactionConfig: messageReactionConfig,
            ),
          ),
      ],
    );
  }

  EdgeInsetsGeometry? get _padding => isMessageBySender
      ? outgoingChatBubbleConfig?.padding
      : inComingChatBubbleConfig?.padding;

  EdgeInsetsGeometry? get _margin => isMessageBySender
      ? outgoingChatBubbleConfig?.margin
      : inComingChatBubbleConfig?.margin;

  LinkPreviewConfiguration? get _linkPreviewConfig => isMessageBySender
      ? outgoingChatBubbleConfig?.linkPreviewConfig
      : inComingChatBubbleConfig?.linkPreviewConfig;

  TextStyle? get _textStyle => isMessageBySender
      ? outgoingChatBubbleConfig?.textStyle
      : inComingChatBubbleConfig?.textStyle;

  BorderRadiusGeometry _borderRadius(String message) => isMessageBySender
      ? outgoingChatBubbleConfig?.borderRadius ??
          (message.length < 37
              ? BorderRadius.circular(replyBorderRadius1)
              : BorderRadius.circular(replyBorderRadius2))
      : inComingChatBubbleConfig?.borderRadius ??
          (message.length < 29
              ? BorderRadius.circular(replyBorderRadius1)
              : BorderRadius.circular(replyBorderRadius2));

  Color get _color => isMessageBySender
      ? outgoingChatBubbleConfig?.color ?? Colors.purple
      : inComingChatBubbleConfig?.color ?? Colors.grey.shade500;
}
