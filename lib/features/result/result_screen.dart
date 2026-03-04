import 'package:flutter/material.dart';
import '../../core/models/evaluation_result.dart';
import '../../core/models/product.dart';
import '../../core/config/intolerance_config.dart';

import '../profile/public_profile_screen.dart';

class ResultScreen extends StatelessWidget {
  final EvaluationResult result;
  final Product product;

  const ResultScreen({
    super.key,
    required this.result,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    final globalStatus = result.globalStatus;

    late Color mainColor;
    late String mainLabel;

    switch (globalStatus) {
      case RiskStatus.green:
        mainColor = Colors.green;
        mainLabel = "APTO";
        break;
      case RiskStatus.yellow:
        mainColor = Colors.orange;
        mainLabel = "PRECAUCIÓN";
        break;
      case RiskStatus.red:
        mainColor = Colors.red;
        mainLabel = "NO RECOMENDADO";
        break;
    }
    print("Producto creado por UID: ${product.createdByUid}");
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resultado'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [

            /// 🔴🔵🟢 SEMÁFORO PRINCIPAL
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32),
              color: mainColor.withOpacity(0.1),
              child: Column(
                children: [
                  Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      color: mainColor,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      mainLabel,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Según tu perfil configurado",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// 📦 Imagen producto
            if (product.imageUrl != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Image.network(
                  product.imageUrl!,
                  height: 180,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.image_not_supported,
                      size: 80,
                      color: Colors.grey,
                    );
                  },
                ),
              ),

            const SizedBox(height: 16),

            /// 🏷 Nombre + marca + estado comunidad
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  Text(
                    product.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  if (product.brand != null &&
                      product.brand!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        product.brand!,
                        style: const TextStyle(
                          color: Colors.black54,
                        ),
                      ),
                    ),

                  /// 🔥 INFO COMUNIDAD
                  if (product.source == 'manual') ...[
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: product.createdByUid != null
                          ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PublicProfileScreen(
                              uid: product.createdByUid!,
                            ),
                          ),
                        );
                      }
                          : null,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.account_circle,
                            size: 18,
                            color: Colors.black54,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "@${product.createdByNickname ?? 'usuario'}",
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (product.status == 'pending')
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          "⏳ Pendiente de Validación",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                    if (product.status == 'validated')
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          "✔ Producto Validado",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 30),

            /// 🔍 BLOQUES DETALLE
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: result.results.entries.map((entry) {
                  final key = entry.key;
                  final detail = entry.value;
                  final title = intoleranceLabels[key] ?? key;
                  return _buildDetailBlock(title, detail);
                }).toList(),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailBlock(String title, EvaluationDetail detail) {
    late Color statusColor;
    late String statusLabel;

    switch (detail.status) {
      case RiskStatus.green:
        statusColor = Colors.green;
        statusLabel = "Apto";
        break;
      case RiskStatus.yellow:
        statusColor = Colors.orange;
        statusLabel = "Precaución";
        break;
      case RiskStatus.red:
        statusColor = Colors.red;
        statusLabel = "No apto";
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              statusLabel,
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.bold,
              ),
            ),

            if (!detail.hasAlerts)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text("No se detectan ingredientes problemáticos."),
              ),

            /// 🔴 INGREDIENTES DIRECTOS
            if (detail.directMatches.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text(
                "Ingredientes detectados:",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              ...detail.directMatches.map(
                    (i) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(
                    "• $i",
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ),
            ],

            /// 🟠 TRAZAS
            if (detail.traceMatches.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text(
                "Trazas detectadas:",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              ...detail.traceMatches.map(
                    (i) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(
                    "• $i",
                    style: const TextStyle(color: Colors.orange),
                  ),
                ),
              ),
            ],
            if (detail.confidence < 60)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  "Información limitada del producto",
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}