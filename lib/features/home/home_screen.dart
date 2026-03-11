import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

import '../../core/engine/evaluation_engine.dart';
import '../../core/services/rule_loader_service.dart';
import '../../core/services/openfoodfacts_service.dart';
import '../../core/services/user_profile_service.dart';
import '../../core/services/history_service.dart';
import '../../core/providers/user_profile_provider.dart';
import '../../core/providers/subscription_provider.dart';
import '../../core/models/subscription_status.dart';

import '../result/result_screen.dart';
import '../scan/scan_screen.dart';
import '../history/history_screen.dart';
import '../onboarding/settings_screen.dart';
import '../profile/profile_screen.dart';
import '../manual/manual_product_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {

  bool _isLoading = false;

  final TextEditingController _barcodeController = TextEditingController();

  StreamSubscription? _profileSubscription;

  @override
  void initState() {
    super.initState();
    final service = UserProfileService();
    _profileSubscription =
        service.profileStream().listen((profile) {
          if (profile != null) {
            ref
                .read(userProfileProvider.notifier)
                .updateProfile(profile);
          }
        });
  }

  @override
  void dispose() {
    _profileSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final subscription = ref.watch(subscriptionProvider);
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Etiqueta Clara'),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ProfileScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const HistoryScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SettingsScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final shouldLogout = await showDialog<bool>(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text("Cerrar sesión"),
                    content: const Text(
                      "¿Estás seguro de que deseas cerrar sesión?",
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text("Cancelar"),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text("Salir"),
                      ),
                    ],
                  );
                },
              );

              if (shouldLogout == true) {
                await FirebaseAuth.instance.signOut();
              }
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                const SizedBox(height: 20),
                if (user != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.account_circle,
                          size: 18,
                          color: Colors.black54,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            user.email ?? "",
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                /// 🔹 Mensaje protector
                const Text(
                  "Compra con tranquilidad",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  "Analiza productos en segundos según tu perfil configurado.",
                  style: TextStyle(
                    color: Colors.black54,
                  ),
                ),

                const SizedBox(height: 30),

                /// 🔹 Tarjeta principal
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [

                        const Icon(
                          Icons.qr_code_scanner,
                          size: 60,
                        ),

                        const SizedBox(height: 16),

                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () async {
                              final barcode = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ScanScreen(),
                                ),
                              );

                              if (barcode != null) {
                                await _handleBarcode(barcode);
                              }
                            },
                            child: const Text(
                              "ESCANEAR PRODUCTO",
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  "o introducir código manualmente",
                  style: TextStyle(color: Colors.black54),
                ),

                const SizedBox(height: 10),

                TextField(
                  onSubmitted: (value) async {
                    await _handleBarcode(value);
                  },
                  controller: _barcodeController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: "Código de barras",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {

                      final code = _barcodeController.text.trim();

                      if (code.isEmpty) return;

                      await _handleBarcode(code);

                    },
                    child: const Text("BUSCAR PRODUCTO"),
                  ),
                ),

                const SizedBox(height: 30),
                const SizedBox(height: 40),
                const Text(
                  "Tu asistente alimentario personal",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          if (subscription == SubscriptionStatus.free)
            Container(
              width: double.infinity,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.grey.shade300,
                ),
              ),
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  const Icon(
                    Icons.local_grocery_store,
                    color: Colors.green,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Espacio patrocinado",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Productos sin gluten recomendados",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.4),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _handleBarcode(String barcode) async {

    setState(() {
      _isLoading = true;
    });

    try {
      final profile = ref.read(userProfileProvider);

      final service = OpenFoodFactsService();
      final product = await service.fetchProduct(barcode);

      if (!mounted) return;

      if (product == null) {
        setState(() => _isLoading = false);

        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => ManualProductScreen(barcode: barcode),
          ),
        );

        return;
      }

      final ruleLoader = RuleLoaderService();
      final allRules = await ruleLoader.loadAllRules();
      final safeGlutenIngredients =
      await ruleLoader.loadSafeGlutenIngredients();
      final engine = EvaluationEngine(
        rules: allRules,
        safeGlutenIngredients: safeGlutenIngredients,
      );

      final result = engine.evaluate(product, profile);
      final historyService = HistoryService();
      await historyService.saveScan(
        barcode: barcode,
        product: product,
        result: result,
      );

      setState(() {
        _isLoading = false;
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            result: result,
            product: product,
          ),
        ),
      );
      _barcodeController.clear();
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error de conexión'),
          ),
        );
      }
      _barcodeController.clear();
    }
  }

  Future<void> _loadUserProfile() async {
    final service = UserProfileService();
    final profile = await service.loadProfile();
    if (profile != null) {
      ref
          .read(userProfileProvider.notifier)
          .updateProfile(profile);
    }
  }
}