import "dart:convert";
import "package:flutter/material.dart";
import "package:flutter_stripe_web/flutter_stripe_web.dart";
import "package:http/http.dart" as http;
import "package:cloud_firestore/cloud_firestore.dart";
import "models/plan_model.dart";
import 'dart:async';

class StripeTestServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _customerId;
  String? _clientSecret;
  String? _subscriptionId;
  String? _subscription_item_id;

  final _subscriptionStatusController = StreamController<String>.broadcast();
  Stream<String> get subscriptionStatus => _subscriptionStatusController.stream;

  // Adicione o estado de loading
  final _loadingController = StreamController<bool>.broadcast();
  Stream<bool> get isLoading => _loadingController.stream;

  void notifyLoading(bool loading) {
    _loadingController.add(loading);
  }

  // Função para criar cliente
  Future<void> criarCliente(String uid, String nome, String email) async {
    notifyLoading(true);
    try {
      debugPrint('Iniciando criação do cliente...');

      // Verifica se já existe customer_id
      final userDoc = await _firestore.collection('users').doc(uid).get();
      if (userDoc.exists && userDoc.data()?['customer_id'] != null) {
        _customerId = userDoc.data()?['customer_id'];
        debugPrint('Customer ID existente encontrado: $_customerId');
        return;
      }

      // Validação dos dados do usuário
      String errorMessage = '';
      if (nome.isEmpty) {
        errorMessage += 'Nome não fornecido.\n';
      }
      if (email.isEmpty) {
        errorMessage += 'Email não fornecido.\n';
      }
      if (uid.isEmpty) {
        errorMessage += 'UID não fornecido.\n';
      }

      if (errorMessage.isNotEmpty) {
        debugPrint('❌ Dados inválidos para criar cliente:');
        debugPrint('Nome: $nome');
        debugPrint('Email: $email');
        debugPrint('UID: $uid');
        throw Exception('Dados incompletos para criar cliente:\n$errorMessage');
      } else {
        debugPrint('✅ Dados validados com sucesso:');
        debugPrint('Nome: $nome');
        debugPrint('Email: $email');
        debugPrint('UID: $uid');

        final response = await http.post(
            Uri.parse(
                'http://127.0.0.1:5001/hanuman-4e9f4/southamerica-east1/criarCliente4'
                //'https://southamerica-east1-hanuman-4e9f4.cloudfunctions.net/criarCliente4'
                ),
            body: {
              'name': nome,
              'email': email,
              'uid': uid,
            });

        final data = jsonDecode(response.body);
        _customerId = data['customerId'];

        // Salva o customer_id no documento do usuário
        await _firestore.collection('users').doc(uid).set({
          'customer_id': _customerId,
        }, SetOptions(merge: true));

        debugPrint('Cliente criado com sucesso! CustomerId: $_customerId');
      }
    } catch (e) {
      debugPrint('❌ Erro ao criar cliente: $e');
      rethrow;
    } finally {
      notifyLoading(false);
    }
  }

  Future<List<PlanModel>> buscarPlanos() async {
    notifyLoading(true);
    try {
      debugPrint('Buscando planos');
      final response = await http.get(
        Uri.parse(
            'http://127.0.0.1:5001/hanuman-4e9f4/southamerica-east1/buscarPlanos4'),
        //'https://southamerica-east1-hanuman-4e9f4.cloudfunctions.net/buscarPlanos4'),
        headers: {'Content-Type': 'application/json'},
      );

      debugPrint('Planos: ${response.body}');

      final data = jsonDecode(response.body);
      debugPrint('Planos: ${data.toString()}');
      final prices = data['prices'] as List;
      return prices.map((price) => PlanModel.fromJson(price)).toList();
    } finally {
      notifyLoading(false);
    }
  }

  // Função para criar assinatura
  Future<void> criarAssinatura(String priceId, String uid) async {
    try {
      debugPrint('Iniciando criação da assinatura para priceId: $priceId...');
      final response = await http.post(
        Uri.parse(
            'http://127.0.0.1:5001/hanuman-4e9f4/southamerica-east1/criarAssinatura4'),
        //'https://southamerica-east1-hanuman-4e9f4.cloudfunctions.net/criarAssinatura4'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'customerId': _customerId,
          'priceId': priceId,
        }),
      );

      final data = jsonDecode(response.body);
      //debugPrint de toda a resposta
      debugPrint('Resposta: ${data.toString()}');
      _clientSecret = data['clientSecret'];
      _subscriptionId = data['subscriptionId'];
      _subscription_item_id = data['subscriptionItemId'];
      debugPrint('Assinatura criada com sucesso!');
      debugPrint('SubscriptionId: $_subscriptionId');
      debugPrint('ClientSecret: $_clientSecret');
      debugPrint('SubscriptionItemId: $_subscription_item_id');

      // Salva os dados da assinatura no Firestore
      await _firestore.collection('subscriptions').doc(uid).set({
        'subscription_id': _subscriptionId,
        'subscription_item_id': _subscription_item_id,
        'price_id': priceId,
        'status': 'incomplete',
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('❌ Erro ao criar assinatura: $e');
      rethrow;
    }
  }

  // Modificar a função pay existente
  Future<void> pay() async {
    try {
      debugPrint('Iniciando processo de pagamento...');

      if (_clientSecret == null || _subscriptionId == null) {
        throw Exception('Client Secret ou Subscription ID não definidos');
      }

      // Usar a URL de produção quando estiver em produção
      final returnUrl = Uri.base.toString().contains('localhost')
          ? 'http://localhost:63484/#/painel'
          : 'https://hanuman-4e9f4.web.app/#/painel';

      debugPrint('URL de retorno: $returnUrl');
      await WebStripe.instance.confirmPaymentElement(
        ConfirmPaymentElementOptions(
          confirmParams: ConfirmPaymentParams(
            return_url: returnUrl,
          ),
        ),
      );
    } catch (e) {
      debugPrint('❌ Erro no processo de pagamento: $e');
      rethrow;
    }
  }

  // Nova função para verificar o status do pagamento pela URL
  Future<void> handlePaymentReturn(Uri uri) async {
    try {
      debugPrint('Verificando retorno do pagamento: ${uri.toString()}');
      final parameters = uri.queryParameters;
      final redirectStatus = parameters['redirect_status'];

      if (redirectStatus == 'succeeded') {
        // Apenas atualiza a UI para mostrar que o pagamento foi processado
        debugPrint('Pagamento processado com sucesso');

        // Consulta o status atual da assinatura
        await verificarAssinaturaAtiva();
      } else {
        debugPrint('Pagamento não foi bem-sucedido. Status: $redirectStatus');
      }
    } catch (e) {
      debugPrint('❌ Erro ao processar retorno do pagamento: $e');
      rethrow;
    }
  }

  Future<bool> verificarAssinaturaAtiva() async {
    try {
      final response = await http.post(
        Uri.parse(
            'https://southamerica-east1-hanuman-4e9f4.cloudfunctions.net/verificarStatusAssinatura4'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'subscriptionId': _subscriptionId,
        }),
      );

      final data = jsonDecode(response.body);
      debugPrint('Status atual da assinatura: ${data['status']}');

      return data['status'] == 'active';
    } catch (e) {
      debugPrint('❌ Erro ao verificar assinatura: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> getAssinaturaAtual(String uid) async {
    try {
      final doc = await _firestore.collection('subscriptions').doc(uid).get();
      return doc.data();
    } catch (e) {
      debugPrint('❌ Erro ao buscar assinatura atual: $e');
      return null;
    }
  }

  // Adicionar método para iniciar monitoramento
  Future<void> startSubscriptionMonitoring(String uid) async {
    // Monitorar mudanças na coleção subscriptions
    _firestore
        .collection('subscriptions')
        .doc(uid)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        final status = snapshot.data()?['status'] ?? 'unknown';
        _subscriptionStatusController.add(status);
        debugPrint('Status da assinatura atualizado: $status');
      }
    });
  }

  Future<void> atualizarAssinatura({
    required String subscriptionId,
    required String subscriptionItemId,
    required String newPriceId,
  }) async {
    try {
      debugPrint('Iniciando atualização da assinatura...');
      debugPrint('SubscriptionId: $subscriptionId');
      debugPrint('Novo PriceId: $newPriceId');

      final response = await http.post(
        Uri.parse(
            //'https://southamerica-east1-hanuman-4e9f4.cloudfunctions.net/atualizarAssinatura',
            'http://127.0.0.1:5001/hanuman-4e9f4/southamerica-east1/updateSubscription'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'subscriptionId': subscriptionId,
          'subscriptionItemId': subscriptionItemId,
          'newPriceId': newPriceId,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Erro ao atualizar assinatura: ${response.body}');
      }

      final data = jsonDecode(response.body);
      debugPrint('Assinatura atualizada com sucesso!');
      debugPrint('Nova assinatura: ${data.toString()}');

      // Atualiza o status no StreamController
      _subscriptionStatusController.add('updating');
    } catch (e) {
      debugPrint('❌ Erro ao atualizar assinatura: $e');
      rethrow;
    }
  }

  Future<void> cancelarAssinatura(String subscriptionId) async {
    try {
      final response = await http.post(
        Uri.parse(
            'http://127.0.0.1:5001/hanuman-4e9f4/southamerica-east1/cancelarAssinatura4'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'subscriptionId': subscriptionId,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Erro ao cancelar assinatura: ${response.body}');
      }

      debugPrint('Assinatura cancelada com sucesso');
    } catch (e) {
      debugPrint('❌ Erro ao cancelar assinatura: $e');
      rethrow;
    }
  }

  // Não esquecer de fechar o stream quando não for mais necessário
  @override
  void dispose() {
    _subscriptionStatusController.close();
    _loadingController.close();
  }

  String? get clientSecret => _clientSecret;

  String formatarStatusAssinatura(String status) {
    switch (status) {
      case 'active':
        return 'Ativa';
      case 'canceled':
        return 'Cancelada';
      case 'incomplete':
        return 'Pendente';
      case 'incomplete_expired':
        return 'Expirada';
      case 'past_due':
        return 'Atrasada';
      case 'trialing':
        return 'Em período de teste';
      case 'unpaid':
        return 'Não paga';
      default:
        return status;
    }
  }

  Stream<DocumentSnapshot> assinaturaStream(String uid) {
    return _firestore.collection('subscriptions').doc(uid).snapshots();
  }
}
