import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PublicProfileScreen extends StatelessWidget {
  final String uid;

  const PublicProfileScreen({
    super.key,
    required this.uid,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .get(),
        builder: (context, snapshot) {

          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final data =
          snapshot.data!.data() as Map<String, dynamic>?;

          if (data == null) {
            return const Center(
              child: Text("Usuario no encontrado"),
            );
          }

          final nickname = data['nickname'] ?? "usuario";
          final avatar = data['avatar'];
          final validatedCount =
              data['validatedCount'] ?? 0;

          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [

                CircleAvatar(
                  radius: 50,
                  backgroundImage:
                  avatar != null
                      ? AssetImage(avatar)
                      : null,
                  child: avatar == null
                      ? const Icon(Icons.person, size: 50)
                      : null,
                ),

                const SizedBox(height: 20),

                Text(
                  "@$nickname",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment:
                  MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.verified,
                        color: Colors.green),
                    const SizedBox(width: 6),
                    Text(
                      "$validatedCount productos validados",
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}