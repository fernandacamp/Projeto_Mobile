import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:projeto_mobile/providers/usuario_provider.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projeto_mobile/settings/routes.dart';

import '../services/firestore_service.dart';

class MenuPage extends StatefulWidget {
  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  late Usuario? usuario;
  late UsuarioProvider usuarioProvider;

  bool isLoading = true;

  Future getUser() async {
    usuarioProvider = Provider.of<UsuarioProvider>(context);
    usuario = usuarioProvider.usuario;

    if (usuario == null) {
      var user = await FirestoreService.getUserbyEmail(
          FirebaseAuth.instance.currentUser?.email ?? "");

      if (user == null) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.login);
        return;
      }

      usuario = Usuario(id: user!.id, nome: user.name, email: user.email);

      usuarioProvider.setUsuario(usuario!);
    }

    setState(() => isLoading = false);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    getUser();
    return Scaffold(
      backgroundColor: const Color.fromRGBO(146, 91, 245, 1),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            )
          : SafeArea(
              child: Column(
                children: [
                  // Ícone de fechar no topo esquerdo
                  Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context); // Fecha o menu
                        },
                        child: const CircleAvatar(
                          backgroundColor: Colors.white,
                          child: Icon(Icons.close,
                              color: Color.fromRGBO(146, 91, 245, 1)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Saudação personalizada ao usuário
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Bem-vindo, ${usuario!.nome}!',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Itens do menu
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildMenuItem(
                          context,
                          title: 'New Trip',
                          route: AppRoutes.newTrip,
                          icon: Icons.add_location_alt,
                          color: Colors.white.withOpacity(0.7),
                        ),
                        const SizedBox(height: 20),
                        _buildMenuItem(
                          context,
                          title: 'Order History',
                          route: AppRoutes.orderHistory,
                          icon: Icons.history,
                          color: Colors.white.withOpacity(0.7),
                        ),
                        const SizedBox(height: 20),
                        _buildMenuItem(
                          context,
                          title: 'My Profile',
                          route: AppRoutes.profile,
                          icon: Icons.person,
                          color: Colors.white,
                        ),
                        // const SizedBox(height: 20),
                        // _buildMenuItem(
                        //   context,
                        //   title: 'Change Password',
                        //   route: AppRoutes.changePassword,
                        //   icon: Icons.lock,
                        //   color: Colors.white.withOpacity(0.7),
                        // ),
                        // const SizedBox(height: 20),
                        // // Novo botão para gerenciar pets
                        // ElevatedButton(
                        //   onPressed: () {
                        //     Navigator.push(
                        //       context,
                        //       MaterialPageRoute(
                        //           builder: (context) => PetsPage()),
                        //     );
                        //   },
                        //   style: ElevatedButton.styleFrom(
                        //       backgroundColor: Colors.blueAccent),
                        //   child: const Text('Gerenciar Pets'),
                        // ),
                      ],
                    ),
                  ),

                  // Botão de logout
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton(
                      onPressed: () {
                        usuarioProvider.logout();
                        Navigator.pushReplacementNamed(
                            context, AppRoutes.login);
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white),
                      child: const Text('Logout'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // Método para construir os itens do menu
  Widget _buildMenuItem(
    BuildContext context, {
    required String title,
    required String route,
    required IconData icon,
    required Color color,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(route);
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
            size: 28,
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

// Página para gerenciar pets
class PetsPage extends StatelessWidget {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gerenciar Pets')),
      body: Column(
        children: [
          // Formulário para adicionar um novo pet
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Nome do Pet'),
                ),
                TextField(
                  controller: _typeController,
                  decoration: const InputDecoration(labelText: 'Tipo do Pet'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_nameController.text.isNotEmpty &&
                        _typeController.text.isNotEmpty) {
                      await FirebaseFirestore.instance.collection('pets').add({
                        'name': _nameController.text,
                        'type': _typeController.text,
                        'timestamp': FieldValue.serverTimestamp(),
                      });
                      _nameController.clear();
                      _typeController.clear();
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Pet adicionado com sucesso!'),
                      ));
                    }
                  },
                  child: const Text('Adicionar Pet'),
                ),
              ],
            ),
          ),

          // Exibição em tempo real dos pets
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('pets').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('Nenhum pet encontrado.'));
                }

                final pets = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: pets.length,
                  itemBuilder: (context, index) {
                    final pet = pets[index].data() as Map<String, dynamic>;
                    return ListTile(
                      title: Text(pet['name'] ?? 'Sem nome'),
                      subtitle: Text('Tipo: ${pet['type'] ?? 'N/A'}'),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
