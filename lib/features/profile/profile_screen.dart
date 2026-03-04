import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

import '../../core/providers/subscription_provider.dart';
import '../../core/models/subscription_status.dart';
import '../../core/providers/user_profile_provider.dart';
import '../../core/services/user_profile_service.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

final List<String> _availableAvatars = [
  "assets/avatars/cat.png",
  "assets/avatars/dog.png",
  "assets/avatars/panda.png",
  "assets/avatars/fox.png",
  "assets/avatars/lion.png",
];

class _ProfileScreenState extends ConsumerState<ProfileScreen> {

  late TextEditingController _nicknameController;

  bool _isSaving = false;
  String? _nicknameError;
  bool _isCheckingNickname = false;
  bool? _isNicknameAvailable;

  @override
  void initState() {
    super.initState();

    final profile = ref.read(userProfileProvider);
    _nicknameController =
        TextEditingController(text: profile.nickname ?? "");
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _checkNicknameAvailability(String value) async {
    final nickname = value.trim().toLowerCase();
    final regex = RegExp(r'^[a-z0-9_]{3,15}$');

    if (!regex.hasMatch(nickname)) {
      setState(() {
        _nicknameError =
        "3-15 caracteres. Solo letras, números y _";
        _isNicknameAvailable = null;
      });
      return;
    }

    setState(() {
      _nicknameError = null;
      _isCheckingNickname = true;
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('nicknames')
        .doc(nickname)
        .get();

    if (!mounted) return;

    setState(() {
      _isCheckingNickname = false;

      if (!doc.exists || doc.data()?['uid'] == user.uid) {
        _isNicknameAvailable = true;
      } else {
        _isNicknameAvailable = false;
      }
    });
  }

  Future<void> _saveNickname() async {
    final newNickname =
    _nicknameController.text.trim().toLowerCase();

    final regex = RegExp(r'^[a-z0-9_]{3,15}$');
    if (!regex.hasMatch(newNickname)) return;

    setState(() => _isSaving = true);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final profile = ref.read(userProfileProvider);
    final oldNickname = profile.nickname;

    if (oldNickname == newNickname) {
      setState(() => _isSaving = false);
      return;
    }

    final nicknamesCollection =
    FirebaseFirestore.instance.collection('nicknames');

    final newRef =
    nicknamesCollection.doc(newNickname);

    final existing = await newRef.get();

    if (existing.exists &&
        existing.data()?['uid'] != user.uid) {
      setState(() => _isSaving = false);
      return;
    }

    final batch = FirebaseFirestore.instance.batch();

    batch.set(newRef, {'uid': user.uid});

    if (oldNickname != null && oldNickname.isNotEmpty) {
      batch.delete(
          nicknamesCollection.doc(oldNickname));
    }

    await batch.commit();

    final updated =
    profile.copyWith(nickname: newNickname);

    ref.read(userProfileProvider.notifier)
        .updateProfile(updated);

    await UserProfileService()
        .saveProfile(updated);

    setState(() => _isSaving = false);
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final subscription =
    ref.watch(subscriptionProvider);
    final profile =
    ref.watch(userProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mi perfil"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [

              const SizedBox(height: 20),

              Center(
                child: GestureDetector(
                  onTap: _showAvatarSelector,
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 45,
                        backgroundImage: profile.avatar != null
                            ? AssetImage(profile.avatar!)
                            : null,
                        child: profile.avatar == null
                            ? const Icon(Icons.person, size: 45)
                            : null,
                      ),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.edit,
                          size: 16,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Center(
                child: Text(
                  user?.email ?? "Usuario desconocido",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              const Center(
                child: Text(
                  "Proveedor: Google",
                  style: TextStyle(
                      color:
                      Colors.black54),
                ),
              ),

              const SizedBox(height: 30),

              Row(
                children: [
                  const Text("Plan actual: "),
                  Text(
                    subscription ==
                        SubscriptionStatus
                            .premium
                        ? "Premium"
                        : "Free",
                    style: TextStyle(
                      fontWeight:
                      FontWeight.bold,
                      color: subscription ==
                          SubscriptionStatus
                              .premium
                          ? Colors.green
                          : Colors.orange,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              const Divider(),

              const SizedBox(height: 20),

              const Text(
                "Nickname público",
                style: TextStyle(
                  fontWeight:
                  FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              TextField(
                controller:
                _nicknameController,
                textCapitalization:
                TextCapitalization.none,
                inputFormatters: [
                  FilteringTextInputFormatter
                      .allow(RegExp(
                      r'[a-zA-Z0-9_]')),
                ],
                onChanged:
                _checkNicknameAvailability,
                decoration:
                InputDecoration(
                  hintText:
                  "Introduce tu nickname",
                  border:
                  const OutlineInputBorder(),
                  errorText:
                  _nicknameError,
                  suffixIcon:
                  _isCheckingNickname
                      ? const Padding(
                    padding:
                    EdgeInsets
                        .all(10),
                    child:
                    CircularProgressIndicator(
                        strokeWidth:
                        2),
                  )
                      : _isNicknameAvailable ==
                      null
                      ? null
                      : Icon(
                    _isNicknameAvailable!
                        ? Icons
                        .check_circle
                        : Icons
                        .cancel,
                    color:
                    _isNicknameAvailable!
                        ? Colors
                        .green
                        : Colors
                        .red,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  onPressed:
                  (_isSaving ||
                      _isNicknameAvailable !=
                          true)
                      ? null
                      : _saveNickname,
                  child: _isSaving
                      ? const CircularProgressIndicator(
                    color:
                    Colors.white,
                  )
                      : const Text(
                      "Guardar Nickname"),
                ),
              ),
              const SizedBox(height: 30),
              const SizedBox(height: 40),
              const Divider(),
              TextButton(
                onPressed: () {},
                child: const Text(
                    "Política de privacidad"),
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                    "Términos y condiciones"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAvatarSelector() {

    final profile = ref.read(userProfileProvider);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) {

        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              const Text(
                "Selecciona un avatar",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                children: _availableAvatars.map((avatar) {

                  final isSelected = profile.avatar == avatar;

                  return GestureDetector(
                    onTap: () {

                      final updated =
                      profile.copyWith(avatar: avatar);

                      ref
                          .read(userProfileProvider.notifier)
                          .updateProfile(updated);
                      UserProfileService()
                          .saveProfile(updated);
                      Navigator.pop(context);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? Colors.green
                                : Colors.transparent,
                            width: 3,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 30,
                          backgroundImage:
                          AssetImage(avatar),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

}