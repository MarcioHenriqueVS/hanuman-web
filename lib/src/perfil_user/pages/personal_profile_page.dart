import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../stripe/blocs/plans_bloc.dart';
import '../../stripe/blocs/subscription_bloc.dart';
import '../../stripe/models/plan_model.dart';
import '../../utils.dart';
import '../../widgets_comuns/flutter_flow/animations.dart';
import '../../widgets_comuns/flutter_flow/ff_button_options.dart';
import '../../widgets_comuns/flutter_flow/model.dart';
import '../edit_foto/events_foto.dart';
import '../edit_foto/foto_bloc.dart';
import '../edit_foto/states_foto.dart';
import '../get_user_data/get_user_data_bloc.dart';
import '../models/edit_profile_screen_model.dart';
import 'components/suporte_widget.dart';

class PersonalProfilePage extends StatefulWidget {
  const PersonalProfilePage({super.key});

  @override
  State<PersonalProfilePage> createState() => _PersonalProfilePageState();
}

class _PersonalProfilePageState extends State<PersonalProfilePage>
    with TickerProviderStateMixin {
  late PerfilScreenModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final animationsMap = <String, AnimationInfo>{};
  String? imagePath;
  Uint8List? imageBytes;
  String? base64Image;
  String uid = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();

    BlocProvider.of<PlansBloc>(context).add(LoadPlans());
    BlocProvider.of<SubscriptionBloc>(context).add(LoadSubscription(uid));

    _model = createModel(context, () => PerfilScreenModel());

    _model.yourNameFocusNode1 ??= FocusNode();

    _model.yourNameFocusNode2 ??= FocusNode();

    animationsMap.addAll({
      'containerOnPageLoadAnimation1': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          VisibilityEffect(duration: 300.ms),
          MoveEffect(
            curve: Curves.bounceOut,
            delay: 300.0.ms,
            duration: 400.0.ms,
            begin: const Offset(0.0, 100.0),
            end: const Offset(0.0, 0.0),
          ),
          FadeEffect(
            curve: Curves.easeInOut,
            delay: 300.0.ms,
            duration: 400.0.ms,
            begin: 0.0,
            end: 1.0,
          ),
        ],
      ),
      'containerOnPageLoadAnimation2': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          VisibilityEffect(duration: 300.ms),
          MoveEffect(
            curve: Curves.bounceOut,
            delay: 300.0.ms,
            duration: 400.0.ms,
            begin: const Offset(0.0, 100.0),
            end: const Offset(0.0, 0.0),
          ),
          FadeEffect(
            curve: Curves.easeInOut,
            delay: 300.0.ms,
            duration: 400.0.ms,
            begin: 0.0,
            end: 1.0,
          ),
        ],
      ),
    });
    setupAnimations(
      animationsMap.values.where((anim) =>
          anim.trigger == AnimationTrigger.onActionTrigger ||
          !anim.applyInitialState),
      this,
    );
  }

  Future<void> _loadUserData() async {
    BlocProvider.of<GetUserDataBloc>(context).add(
      GetUserData(),
    );
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 1200),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //ConfigsWidget(),
              BlocBuilder<GetUserDataBloc, GetUserDataState>(
                builder: (context, userDataState) {
                  if (userDataState is GetUserDataInitial) {
                    return const Center(
                      child: Text('Iniciando busca de dados...'),
                    );
                  } else if (userDataState is GetUserDataLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (userDataState is GetUserDataError) {
                    return const Center(
                      child: Text(
                        'Erro ao buscar dados, atualize a tela',
                        textAlign: TextAlign.center,
                      ),
                    );
                  } else if (userDataState is GetUserDataLoaded) {
                    _model.yourNameTextController1 ??=
                        TextEditingController(text: userDataState.nome);
                    _model.yourNameTextController2 ??=
                        TextEditingController(text: userDataState.email);
                    return BlocListener<PickImageBloc, PickImageState>(
                      listener: (context, pickImageState) {
                        if (pickImageState is PickImageLoaded) {
                          setState(() {
                            imagePath = pickImageState.foto;
                          });
                        }
                      },
                      child: Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(32, 32, 32, 0),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: 845.29,
                          ),
                          child: Container(
                            width: MediaQuery.sizeOf(context).width * 0.6,
                            decoration: BoxDecoration(
                              //color: Theme.of(context).scaffoldBackgroundColor,
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: Theme.of(context).dividerColor,
                                width: 0.5,
                              ),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding:
                                        const EdgeInsetsDirectional.fromSTEB(
                                            24, 16, 0, 0),
                                    child: Text(
                                      'Editar Perfil',
                                      style: SafeGoogleFont(
                                        'Open Sans',
                                        fontSize: 24,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                        const EdgeInsetsDirectional.fromSTEB(
                                            24, 4, 0, 0),
                                    child: Text(
                                      'Abaixo estão os detalhes do seu perfil',
                                      style: SafeGoogleFont(
                                        'Open Sans',
                                        fontSize: 14,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  Column(
                                    mainAxisSize: MainAxisSize.max,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsetsDirectional
                                            .fromSTEB(16, 12, 16, 0),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 100,
                                              height: 100,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                  width: 2,
                                                ),
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(2),
                                                child: Container(
                                                  width: 90,
                                                  height: 90,
                                                  clipBehavior: Clip.antiAlias,
                                                  decoration:
                                                      const BoxDecoration(
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: imagePath != null
                                                      ? Image.file(
                                                          File(imagePath!),
                                                        )
                                                      : CachedNetworkImage(
                                                          fadeInDuration:
                                                              const Duration(
                                                                  milliseconds:
                                                                      500),
                                                          fadeOutDuration:
                                                              const Duration(
                                                                  milliseconds:
                                                                      500),
                                                          imageUrl: userDataState
                                                                  .fotoUrl ??
                                                              'https://images.unsplash.com/photo-1536164261511-3a17e671d380?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=630&q=80',
                                                          fit: BoxFit.fitWidth,
                                                        ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            FFButtonWidget(
                                              onPressed: () {
                                                BlocProvider.of<PickImageBloc>(
                                                        context)
                                                    .add(SelectImage());
                                              },
                                              text: 'Trocar foto',
                                              options: FFButtonOptions(
                                                height: 44,
                                                padding:
                                                    const EdgeInsetsDirectional
                                                        .fromSTEB(24, 0, 24, 0),
                                                iconPadding:
                                                    const EdgeInsetsDirectional
                                                        .fromSTEB(0, 0, 0, 0),
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .surface,
                                                textStyle: SafeGoogleFont(
                                                    'Open Sans',
                                                    fontSize: 14,
                                                    letterSpacing: 0.0,
                                                    fontWeight: FontWeight.w500,
                                                    color: Theme.of(context)
                                                        .textTheme
                                                        .bodySmall!
                                                        .color),
                                                elevation: 0,
                                                borderSide: BorderSide(
                                                  color: Theme.of(context)
                                                      .dividerColor,
                                                  width: 2,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                hoverColor: Theme.of(context)
                                                    .dividerColor,
                                                hoverBorderSide: BorderSide(
                                                  color: Theme.of(context)
                                                      .dividerColor,
                                                  width: 2,
                                                ),
                                                hoverTextColor:
                                                    const Color(0xFF15161E),
                                                hoverElevation: 3,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsetsDirectional
                                            .fromSTEB(16, 16, 16, 0),
                                        child: TextFormField(
                                          keyboardType: TextInputType.name,
                                          inputFormatters: [
                                            FilteringTextInputFormatter.allow(
                                              RegExp(
                                                  "[a-zA-ZáéíóúâêôàüãõçÁÉÍÓÚÂÊÔÀÜÃÕÇ ]"),
                                            ),
                                            LengthLimitingTextInputFormatter(
                                                30),
                                          ],
                                          controller:
                                              _model.yourNameTextController1,
                                          focusNode: _model.yourNameFocusNode1,
                                          autofocus: true,
                                          obscureText: false,
                                          decoration: InputDecoration(
                                            labelText: 'Nome',
                                            labelStyle: SafeGoogleFont(
                                              'Open Sans',
                                              fontSize: 14,
                                              letterSpacing: 0.0,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            hintStyle: SafeGoogleFont(
                                              'Open Sans',
                                              fontSize: 14,
                                              letterSpacing: 0.0,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: Theme.of(context)
                                                    .dividerColor,
                                                width: 2,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: Theme.of(context)
                                                    .primaryColor,
                                                width: 2,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            errorBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .error,
                                                width: 2,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            focusedErrorBorder:
                                                OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .error,
                                                width: 2,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            filled: true,
                                            fillColor: Theme.of(context)
                                                .colorScheme
                                                .surface,
                                            // contentPadding: const EdgeInsetsDirectional.fromSTEB(
                                            //     20, 24, 20, 24),
                                          ),
                                          style: SafeGoogleFont(
                                            'Open Sans',
                                            fontSize: 14,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          cursorColor:
                                              Theme.of(context).primaryColor,
                                          validator: _model
                                              .yourNameTextController1Validator
                                              .asValidator(context),
                                        ),
                                      ),
                                      //email
                                      Padding(
                                        padding: const EdgeInsetsDirectional
                                            .fromSTEB(16, 16, 16, 0),
                                        child: TextFormField(
                                          enabled: false,
                                          keyboardType:
                                              TextInputType.emailAddress,
                                          controller:
                                              _model.yourNameTextController2,
                                          focusNode: _model.yourNameFocusNode2,
                                          obscureText: false,
                                          decoration: InputDecoration(
                                            labelText: 'Email',
                                            labelStyle: SafeGoogleFont(
                                              'Open Sans',
                                              fontSize: 14,
                                              letterSpacing: 0.0,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            hintStyle: SafeGoogleFont(
                                              'Open Sans',
                                              fontSize: 14,
                                              letterSpacing: 0.0,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: Theme.of(context)
                                                    .dividerColor,
                                                width: 2,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: Theme.of(context)
                                                    .primaryColor,
                                                width: 2,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            disabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: Theme.of(context)
                                                    .dividerColor,
                                                width: 2,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            errorBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .error,
                                                width: 2,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            focusedErrorBorder:
                                                OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .error,
                                                width: 2,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            filled: true,
                                            fillColor: Theme.of(context)
                                                .colorScheme
                                                .surface,
                                            // contentPadding: const EdgeInsetsDirectional.fromSTEB(
                                            //     20, 24, 20, 24),
                                          ),
                                          style: SafeGoogleFont(
                                            'Open Sans',
                                            fontSize: 14,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          cursorColor:
                                              Theme.of(context).primaryColor,
                                          validator: _model
                                              .yourNameTextController2Validator
                                              .asValidator(context),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding:
                                        const EdgeInsetsDirectional.fromSTEB(
                                            24, 12, 24, 24),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Align(
                                          alignment: const AlignmentDirectional(
                                              0, 0.05),
                                          child: FFButtonWidget(
                                            onPressed: () async {
                                              String? base64Image;
                                              String? nomeEditado;
                                              if (imagePath != null) {
                                                final File imgFile =
                                                    File(imagePath!);
                                                final bytes =
                                                    await imgFile.readAsBytes();
                                                base64Image =
                                                    base64Encode(bytes);
                                              }
                                              if (_model
                                                      .yourNameTextController1!
                                                      .text !=
                                                  userDataState.nome) {
                                                nomeEditado = _model
                                                    .yourNameTextController1!
                                                    .text
                                                    .trim();
                                              }
                                              if (base64Image != null ||
                                                  nomeEditado != null) {
                                                const url =
                                                    'https://southamerica-east1-hanuman-4e9f4.cloudfunctions.net/updateProfile2v2';
                                                final response = await Dio()
                                                    .post(url, data: {
                                                  "uid": uid,
                                                  "nome": nomeEditado,
                                                  "foto": base64Image
                                                });
                                                debugPrint(
                                                    'response --------> ${response.statusMessage}');
                                                response.statusCode == 200
                                                    ? _loadUserData()
                                                    : null;
                                              }
                                            },
                                            text: 'Salvar',
                                            options: FFButtonOptions(
                                              height: 44,
                                              padding:
                                                  const EdgeInsetsDirectional
                                                      .fromSTEB(24, 0, 24, 0),
                                              iconPadding:
                                                  const EdgeInsetsDirectional
                                                      .fromSTEB(0, 0, 0, 0),
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              textStyle: SafeGoogleFont(
                                                'Open Sans',
                                                fontSize: 14,
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.w500,
                                              ),
                                              elevation: 0,
                                              borderSide: BorderSide(
                                                color: Theme.of(context)
                                                    .primaryColor,
                                                width: 2,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              hoverColor: Theme.of(context)
                                                  .dividerColor,
                                              hoverBorderSide: BorderSide(
                                                color: Theme.of(context)
                                                    .dividerColor,
                                                width: 2,
                                              ),
                                              hoverTextColor:
                                                  const Color(0xFF15161E),
                                              hoverElevation: 3,
                                            ),
                                          ),
                                        ),
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
                  } else {
                    return const Center(
                      child: Text('Erro ao buscar dados'),
                    );
                  }
                },
              ),
              SuporteWidget(),
            ],
          ),
          const SizedBox(height: 20),
          BlocBuilder<PlansBloc, PlansState>(
            builder: (context, state) {
              if (state is PlansLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (state is PlansError) {
                return Center(
                  child: Text('Erro: ${state.message}'),
                );
              }
              if (state is PlansLoaded) {
                return _buildPlansGrid(state.plans);
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPlansGrid(List<PlanModel> plans) {
    return BlocBuilder<SubscriptionBloc, SubscriptionState>(
      builder: (context, state) {
        String? currentPriceId;
        bool hasActiveSubscription = false;

        if (state is SubscriptionLoaded) {
          currentPriceId = state.subscription['price_id'];
          hasActiveSubscription = state.subscription['status'] == 'active';
        }

        return Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(32, 0, 32, 32),
          child: Center(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width > 1200
                    ? 1200
                    : MediaQuery.of(context).size.width * 0.9,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Planos disponíveis',
                          style: SafeGoogleFont(
                                        'Open Sans',
                                        fontSize: 24,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.w500,
                                      ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Escolha o plano que melhor se adapta às suas necessidades',
                          style: SafeGoogleFont(
                                        'Open Sans',
                                        fontSize: 14,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.w500,
                                      ),
                        ),
                      ],
                    ),
                  ),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 400,
                      mainAxisSpacing: 24,
                      crossAxisSpacing: 24,
                      childAspectRatio:
                          MediaQuery.of(context).size.width > 600 ? 1.2 : 1.1,
                    ),
                    itemCount: plans.length,
                    itemBuilder: (context, index) {
                      final plan = plans[index];
                      final isCurrentPlan = plan.id == currentPriceId;

                      return MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isCurrentPlan
                                  ? [
                                      Colors.green[900]!,
                                      Colors.green[800]!,
                                    ]
                                  : [
                                      Colors.grey[850]!,
                                      Colors.grey[900]!,
                                    ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isCurrentPlan
                                  ? Colors.green[400]!
                                  : Colors.grey[700]!,
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {},
                              borderRadius: BorderRadius.circular(20),
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          plan.name,
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: isCurrentPlan
                                                ? Colors.green[100]
                                                : Colors.grey[100],
                                          ),
                                        ),
                                        if (isCurrentPlan)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.green[400],
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: const Text(
                                              'ATUAL',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 20),
                                    Text(
                                      plan.formattedPrice,
                                      style: TextStyle(
                                        fontSize: 36,
                                        fontWeight: FontWeight.w800,
                                        color: isCurrentPlan
                                            ? Colors.green[100]
                                            : Colors.grey[100],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      plan.interval == 'month'
                                          ? 'por mês'
                                          : 'por ano',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: isCurrentPlan
                                            ? Colors.green[200]
                                            : Colors.grey[400],
                                      ),
                                    ),
                                    const Spacer(),
                                    Container(
                                      width: double.infinity,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: isCurrentPlan
                                            ? Colors.green[400]
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: isCurrentPlan
                                              ? Colors.green[400]!
                                              : Colors.grey[400]!,
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          isCurrentPlan
                                              ? 'Plano Atual'
                                              : 'Selecionar Plano',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: isCurrentPlan
                                                ? Colors.black
                                                : Colors.grey[100],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
