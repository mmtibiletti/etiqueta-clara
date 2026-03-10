import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../../core/models/product.dart';
import '../../core/engine/evaluation_engine.dart';
import '../../core/providers/user_profile_provider.dart';
import '../../core/services/rule_loader_service.dart';
import '../result/result_screen.dart';

class ManualProductScreen extends ConsumerStatefulWidget {
  final String barcode;

  const ManualProductScreen({
    super.key,
    required this.barcode,
  });

  @override
  ConsumerState<ManualProductScreen> createState() =>
      _ManualProductScreenState();
}

class _ManualProductScreenState
    extends ConsumerState<ManualProductScreen> {

  final _nameController = TextEditingController();
  final _ingredientsController = TextEditingController();
  final _brandController = TextEditingController();

  File? _image;
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Producto manual"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            TextField(
              controller: _nameController,
              decoration:
              const InputDecoration(labelText: "Nombre del producto"),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: _brandController,
              decoration: const InputDecoration(
                labelText: "Marca",
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: _ingredientsController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: "Ingredientes (separados por comas)",
              ),
            ),

            /*const SizedBox(height: 20),

            /// 📷 BOTÓN FOTO
            ElevatedButton.icon(
              icon: const Icon(Icons.camera_alt),
              label: const Text("Añadir foto"),
              onPressed: _takePicture,
            ),

            /// 🖼 PREVISUALIZACIÓN IMAGEN
            if (_image != null) ...[
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(
                  _image!,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            ],*/

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _analyze,
                child: const Text("ANALIZAR"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _takePicture() async {

    final pickedFile = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );

    if (pickedFile == null) return;

    setState(() {
      _image = File(pickedFile.path);
    });
  }

  Future<void> _analyze() async {

    final name = _nameController.text.trim();
    final ingredientsRaw = _ingredientsController.text;

    final user = FirebaseAuth.instance.currentUser;
    final profile = ref.read(userProfileProvider);

    if (name.isEmpty || ingredientsRaw.isEmpty) return;

    final ingredients = ingredientsRaw
        .split(',')
        .map((e) => e.trim())
        .toList();

    String? imageUrl = null;

    /// 📤 SUBIR IMAGEN
    /*if (_image != null) {

      final ref = FirebaseStorage.instance
          .ref()
          .child("product_images")
          .child("${widget.barcode}_${DateTime.now().millisecondsSinceEpoch}.jpg");

      await ref.putFile(_image!);

      imageUrl = await ref.getDownloadURL();
    }*/

    final product = Product(
      id: widget.barcode,
      barcode: widget.barcode,
      name: name,
      brand: _brandController.text.trim(),
      ingredients: ingredients,
      imageUrl: imageUrl,
      source: "manual",
      status: "pending",
      createdByUid: user?.uid,
      createdByNickname: profile.nickname,
    );

    await FirebaseFirestore.instance
        .collection('manual_products')
        .doc(widget.barcode)
        .set({
      'barcode': widget.barcode,
      'name': name,
      'brand': _brandController.text.trim(),
      'ingredients': ingredients,
      'imageUrl': imageUrl,
      'createdBy': user?.uid,
      'createdByUid': user?.uid,
      'createdByNickname': profile.nickname ?? "Usuario",
      'status': 'pending',
      'createdAt': Timestamp.now(),
    });

    /// 🧠 MOTOR DE EVALUACIÓN
    final ruleLoader = RuleLoaderService();

    final glutenRules = await ruleLoader.loadGlutenRules();
    final lactoseRules = await ruleLoader.loadLactoseRules();
    final safeGlutenIngredients =
    await ruleLoader.loadSafeGlutenIngredients();

    final engine = EvaluationEngine(
      glutenRules: glutenRules,
      lactoseRules: lactoseRules,
      safeGlutenIngredients: safeGlutenIngredients,
    );

    final result = engine.evaluate(product, profile);

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          result: result,
          product: product,
        ),
      ),
    );
  }
}