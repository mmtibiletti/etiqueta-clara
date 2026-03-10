import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/models/evaluation_result.dart';
import '../../core/models/product.dart';
import '../../core/models/product_report.dart';
import '../../core/services/product_report_service.dart';
import '../../core/config/intolerance_config.dart';

import '../profile/public_profile_screen.dart';

class ResultScreen extends StatefulWidget {
  final EvaluationResult result;
  final Product product;

  const ResultScreen({
    super.key,
    required this.result,
    required this.product,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {

  late EvaluationResult result;
  bool communityOverride = false;

  @override
  void initState() {
    super.initState();
    result = widget.result;
    _checkCommunityReports();
  }

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
            if (widget.product.imageUrl != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Image.network(
                  widget.product.imageUrl!,
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

            /// 🏷 Nombre + marca
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [

                  Text(
                    widget.product.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  if (widget.product.brand != null &&
                      widget.product.brand!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        widget.product.brand!,
                        style: const TextStyle(
                          color: Colors.black54,
                        ),
                      ),
                    ),

                  /// 🔥 INFO COMUNIDAD (solo productos manuales)
                  if (widget.product.source == 'manual') ...[
                    const SizedBox(height: 12),

                    GestureDetector(
                      onTap: widget.product.createdByUid != null
                          ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PublicProfileScreen(
                              uid: widget.product.createdByUid!,
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
                            "@${widget.product.createdByNickname ?? 'usuario'}",
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// ⚠ AVISO COMUNIDAD
            if (communityOverride)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.people, color: Colors.orange),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Este producto ha sido reportado como inseguro por la comunidad.",
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 20),

            /// 🚩 BOTÓN REPORTAR
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.flag),
                  label: const Text("Reportar problema con este producto"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade400,
                  ),
                  onPressed: () {
                    _showReportDialog(context);
                  },
                ),
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

  /// 🧠 DETALLE DE INTOLERANCIA
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

            const SizedBox(height: 10),

            ...detail.directMatches.map(
                  (r) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text("• $r"),
              ),
            ),

            ...detail.traceMatches.map(
                  (r) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text("• $r"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🚩 DIALOGO REPORTAR
  void _showReportDialog(BuildContext context) {

    String? selected;

    showDialog(
      context: context,
      builder: (context) {

        return AlertDialog(
          title: const Text("Reportar problema"),

          content: DropdownButtonFormField<String>(
            hint: const Text("Selecciona intolerancia"),
            items: intoleranceLabels.entries.map((entry) {
              return DropdownMenuItem(
                value: entry.key,
                child: Text(entry.value),
              );
            }).toList(),
            onChanged: (value) {
              selected = value;
            },
          ),

          actions: [

            TextButton(
              child: const Text("Cancelar"),
              onPressed: () => Navigator.pop(context),
            ),

            ElevatedButton(
              child: const Text("Enviar"),
              onPressed: () async {

                if (selected == null) return;

                final user = FirebaseAuth.instance.currentUser;
                if (user == null) return;

                final report = ProductReport(
                  uid: user.uid,
                  intolerance: selected!,
                  vote: "unsafe",
                  timestamp: DateTime.now(),
                );

                await ProductReportService().reportProduct(
                  productId: widget.product.barcode ?? widget.product.id,
                  report: report,
                );

                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  /// 🧠 REPUTACIÓN COMUNITARIA
  Future<void> _checkCommunityReports() async {

    final votes = await ProductReportService()
        .getUnsafeVotes(widget.product.barcode ?? widget.product.id);

    bool changed = false;

    votes.forEach((intolerance, count) {

      if (count >= 3 && result.results.containsKey(intolerance)) {

        final detail = result.results[intolerance]!;

        result.results[intolerance] = EvaluationDetail(
          status: RiskStatus.red,
          directMatches: [
            ...detail.directMatches,
            "⚠ Reportado como inseguro por la comunidad ($count votos)"
          ],
          traceMatches: detail.traceMatches,
          confidence: detail.confidence,
        );

        changed = true;
      }

    });

    if (changed) {
      setState(() {
        communityOverride = true;
      });
    }
  }
}