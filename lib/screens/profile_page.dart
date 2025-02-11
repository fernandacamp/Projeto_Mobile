import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:projeto_mobile/providers/usuario_provider.dart';
import 'package:projeto_mobile/settings/color.dart';
import 'package:projeto_mobile/settings/routes.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatelessWidget {

  late Usuario? usuario;
  late UsuarioProvider usuarioProvider;

  @override
  Widget build(BuildContext context) {
    usuarioProvider = Provider.of<UsuarioProvider>(context);
    usuario = usuarioProvider.usuario;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('My Profile'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.menu, color: AppColors.greyColor),
          onPressed: () {
            Navigator.of(context).pushNamed(AppRoutes.menu);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Foto de perfil e nome do usuário
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.purple.shade100,
              child: Icon(Icons.person,
                  size: 60, color: Color.fromRGBO(146, 91, 245, 1)),
            ),
            const SizedBox(height: 10),
            Text(
              usuario?.nome ?? "",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            Text(
              usuario?.email ?? "",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 30),

            _buildSettingsOption(
              icon: Icons.logout,
              title: 'Sair',
              onTap: () async {
                usuarioProvider.logout();
                FirebaseAuth.instance.signOut();
                Navigator.of(context).pushReplacementNamed(AppRoutes.login);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsOption(
      {required IconData icon,
      required String title,
      required VoidCallback onTap}) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.purple.shade50,
        child: Icon(icon, color: Colors.purple),
      ),
      title: Text(title),
      trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey),
      onTap: onTap,
    );
  }
}
