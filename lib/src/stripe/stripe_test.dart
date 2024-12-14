import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe_web/flutter_stripe_web.dart' as stripe;
import 'models/plan_model.dart';
import 'stripe_test_services.dart';
import 'subscription_provider.dart';

class StripeTest extends StatefulWidget {
  const StripeTest({super.key});

  @override
  State<StripeTest> createState() => _StripeTestState();
}

class _StripeTestState extends State<StripeTest> {
  final StripeTestServices _services = StripeTestServices();
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance; // Adicionar esta linha
  PlanModel? _selectedPlan;
  bool _showPaymentForm = false;
  String? uid;
  String? email;
  String? nome;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    uid = _auth.currentUser!.uid;
    email = _auth.currentUser!.email;
    nome = _auth.currentUser!.displayName;
    debugPrintUserData();
    _verificarRetornoPagamento();
    _services.startSubscriptionMonitoring(uid!);
  }

  @override
  void dispose() {
    _services.dispose();
    super.dispose();
  }

  void debugPrintUserData() {
    debugPrint('UID: $uid');
    debugPrint('Email: $email');
    debugPrint('Nome: $nome');
  }

  void _verificarRetornoPagamento() {
    final uri = Uri.base;
    if (uri.toString().contains('payment_intent')) {
      // Remover a chamada para _carregarAssinaturaAtual
      _services.handlePaymentReturn(uri);
    }
  }

  Widget _buildAssinaturaAtual() {
    return StreamBuilder<DocumentSnapshot>(
      stream: _services.assinaturaStream(uid!),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const SizedBox.shrink();
        }

        final assinatura = snapshot.data!.data() as Map<String, dynamic>;
        final status = _services
            .formatarStatusAssinatura(assinatura['status'] ?? 'unknown');
        final subscriptionId = assinatura['subscription_id'];
        final subscriptionItemId = assinatura['subscription_item_id'];

        return Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              gradient: LinearGradient(
                colors: [
                  Colors.grey[900]!,
                  Colors.grey[850]!,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Assinatura Atual',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    if (status == 'Ativa')
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: () => _mostrarOpcoesAtualizacao(
                              subscriptionId,
                              subscriptionItemId,
                            ),
                            icon: const Icon(Icons.upgrade),
                            label: const Text('Alterar Plano'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[700],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            onPressed: () =>
                                _confirmarCancelamento(subscriptionId),
                            icon: const Icon(Icons.cancel),
                            label: const Text('Cancelar'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red[700],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildStatusIndicator(status),
                const SizedBox(height: 12),
                Text(
                  'Criada em: ${_formatDate(assinatura['created_at']?.toDate())}',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusIndicator(String status) {
    Color statusColor;
    IconData statusIcon;

    switch (status) {
      case 'Ativa':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'Cancelada':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      case 'Pendente':
        statusColor = Colors.orange;
        statusIcon = Icons.pending;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.info;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon, color: statusColor, size: 20),
          const SizedBox(width: 8),
          Text(
            'Status: $status',
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _confirmarCancelamento(String subscriptionId) async {
    setState(() => _isLoading = true);
    try {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirmar Cancelamento'),
          content: const Text(
            'Tem certeza que deseja cancelar sua assinatura? Esta ação não pode ser desfeita.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Não'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Sim, Cancelar'),
            ),
          ],
        ),
      );

      if (confirm == true) {
        try {
          await _services.cancelarAssinatura(subscriptionId);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Assinatura cancelada com sucesso')),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Erro ao cancelar assinatura: $e')),
            );
          }
        }
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _mostrarOpcoesAtualizacao(
    String subscriptionId,
    String subscriptionItemId,
  ) async {
    setState(() => _isLoading = true);
    try {
      final planos = await _services.buscarPlanos();

      if (!mounted) return;

      final shouldUpdate = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Atualizar Plano'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Escolha o novo plano:'),
                const SizedBox(height: 16),
                ...planos.map((plan) => ListTile(
                      title: Text('Plano ${plan.interval}'),
                      subtitle: Text(
                          '${plan.formattedPrice} a cada ${plan.intervalCount} ${plan.interval}'),
                      onTap: () async {
                        Navigator.pop(context);
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Confirmar Alteração'),
                            content: Text(
                              'Deseja alterar para o plano ${plan.interval}?\n'
                              'Valor: ${plan.formattedPrice}',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancelar'),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context, true),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Confirmar'),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true && mounted) {
                          try {
                            await _services.atualizarAssinatura(
                              subscriptionId: subscriptionId,
                              subscriptionItemId: subscriptionItemId,
                              newPriceId: plan.id,
                            );
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('Plano atualizado com sucesso!')),
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content:
                                        Text('Erro ao atualizar plano: $e')),
                              );
                            }
                          }
                        }
                      },
                    )),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
          ],
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildPlansGrid(List<PlanModel> plans) {
    return Center(
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width > 1200
              ? 1200
              : MediaQuery.of(context).size.width * 0.9,
        ),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 400,
            mainAxisSpacing: 20,
            crossAxisSpacing: 20,
            childAspectRatio:
                MediaQuery.of(context).size.width > 600 ? 1.5 : 1.3,
          ),
          itemCount: plans.length,
          itemBuilder: (context, index) {
            final plan = plans[index];
            return Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue[700]!, Colors.blue[900]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: InkWell(
                  onTap: () => _selecionarPlano(plan),
                  borderRadius: BorderRadius.circular(15),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          plan.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          plan.formattedPrice,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          plan.interval == 'month' ? 'por mês' : 'por ano',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        StreamBuilder<DocumentSnapshot>(
          stream: _services.assinaturaStream(uid!),
          builder: (context, snapshot) {
            final currentSubscription =
                snapshot.data?.data() as Map<String, dynamic>?;

            return SubscriptionProvider(
              subscriptionStatus: _services.subscriptionStatus,
              currentStatus: currentSubscription?['status'] ?? 'unknown',
              child: Material(
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildAssinaturaAtual(),
                        const SizedBox(height: 32),
                        if (!_showPaymentForm) ...[
                          const Text(
                            'Escolha seu plano',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          FutureBuilder<List<PlanModel>>(
                            future: _services.buscarPlanos(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                              if (snapshot.hasError) {
                                return Center(
                                  child: Text('Erro: ${snapshot.error}'),
                                );
                              }
                              if (snapshot.hasData) {
                                return _buildPlansGrid(snapshot.data!);
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ],
                        if (_showPaymentForm) ...[
                          Container(
                            constraints: const BoxConstraints(maxWidth: 800),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  height: 300,
                                  decoration: BoxDecoration(
                                    border:
                                        Border.all(color: Colors.grey.shade300),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: stripe.PaymentElement(
                                    autofocus: true,
                                    enablePostalCode: true,
                                    onCardChanged: (_) =>
                                        debugPrint('Card changed'),
                                    clientSecret: _services.clientSecret!,
                                    style: stripe.CardStyle(
                                        backgroundColor: Colors.grey),
                                  ),
                                ),
                                const SizedBox(
                                    height:
                                        20), // Espaçamento entre o formulário e o botão
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16),
                                    ),
                                    onPressed: _services.pay,
                                    child: const Text('Confirmar Assinatura'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        if (_isLoading)
          Container(
            color: Colors.black54,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }

  Future<void> _selecionarPlano(PlanModel plan) async {
    setState(() => _isLoading = true);
    try {
      // Obtém a assinatura atual diretamente do Firestore
      final assinaturaDoc =
          await _firestore.collection('subscriptions').doc(uid!).get();
      final currentSubscription = assinaturaDoc.data();

      if (currentSubscription != null &&
          currentSubscription['status'] == 'active') {
        final shouldChange = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Alterar Plano'),
            content: const Text(
                'Você já possui uma assinatura ativa. Deseja alterar seu plano?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Confirmar'),
              ),
            ],
          ),
        );

        if (shouldChange == true) {
          debugPrint('Atualizando assinatura');
          try {
            final subscriptionId = currentSubscription['subscription_id'];
            final subscriptionItemId =
                currentSubscription['subscription_item_id'];
            await _services.atualizarAssinatura(
              subscriptionId: subscriptionId,
              subscriptionItemId: subscriptionItemId,
              newPriceId: plan.id,
            );

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Plano atualizado com sucesso!')),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Erro ao atualizar plano: $e')),
              );
            }
          }
        }
        return;
      }

      // Se não tiver assinatura ativa, prossegue com nova assinatura
      setState(() {
        _selectedPlan = plan;
      });

      await _services.criarCliente(uid!, nome!, email!);
      await _services.criarAssinatura(plan.id, uid!);

      setState(() {
        _showPaymentForm = true;
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
