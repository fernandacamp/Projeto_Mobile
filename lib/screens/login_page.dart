import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:projeto_mobile/services/firestore_service.dart';
import 'package:projeto_mobile/settings/assets.dart';
import 'package:projeto_mobile/settings/color.dart';
import 'package:projeto_mobile/settings/fonts.dart';
import 'package:projeto_mobile/settings/routes.dart';
import '../helper/validator_helper.dart';
import 'package:provider/provider.dart';

import '../providers/usuario_provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Controladores e variáveis
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _key = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _isLoading = false;

  // Método para realizar login
  Future<void> _login() async {
    if (!_key.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      var user = await FirestoreService.getUserbyEmail(_emailController.text);

      var provider = Provider.of<UsuarioProvider>(context, listen: false);

      provider.setUsuario(Usuario(id: user!.id, nome: user.name, email: _emailController.text));

      Navigator.of(context).pushReplacementNamed(AppRoutes.menu); // Navegação
    } on FirebaseAuthException catch (e) {
      String message = _handleFirebaseException(e.code);
      _showErrorDialog(message);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _handleFirebaseException(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Usuário não encontrado.';
      case 'wrong-password':
        return 'Senha incorreta.';
      default:
        return 'Ocorreu um erro. Tente novamente.';
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Erro'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          _buildLogoSection(),
          _buildLoginForm(),
        ],
      ),
    );
  }

  // Seção do logo
  Widget _buildLogoSection() {
    return Container(
      alignment: Alignment.center,
      height: 200,
      child: Image.asset(AppAssets.logoImage),
    );
  }

  // Formulário de login
  Widget _buildLoginForm() {
    return Container(
      height: MediaQuery.of(context).size.height - 200,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      padding: const EdgeInsets.all(30),
      child: Form(
        key: _key,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildTitle(),
            const SizedBox(height: 20),
            _buildEmailField(),
            const SizedBox(height: 20),
            _buildPasswordField(),
            const SizedBox(height: 20),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  // Título
  Widget _buildTitle() {
    return Text(
      "Login",
      style: AppFonts.boldLarge.copyWith(color: AppColors.backgroundColor),
    );
  }

  // Campo de email
  Widget _buildEmailField() {
    return TextFormField(
      validator: (_) {
        if (_emailController.text.isEmpty) return 'Preencha seu email';
        if (!ValidatorHelper.validateEmail(_emailController.text))
          return 'Email inválido';
        return null;
      },
      controller: _emailController,
      decoration: InputDecoration(
        labelText: 'Email',
        labelStyle: AppFonts.boldRegular.copyWith(color: AppColors.greyColor),
        border: const UnderlineInputBorder(),
      ),
    );
  }

  // Campo de senha
  Widget _buildPasswordField() {
    return TextFormField(
      validator: (_) {
        if (_passwordController.text.isEmpty) return 'Preencha sua senha';
        if (_passwordController.text.length < 8)
          return 'Senha deve ter mais que 8 caracteres';
        return null;
      },
      controller: _passwordController,
      obscureText: _obscurePassword,
      decoration: InputDecoration(
        labelText: 'Senha',
        labelStyle: AppFonts.boldRegular.copyWith(color: AppColors.greyColor),
        border: const UnderlineInputBorder(),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off : Icons.visibility,
            color: AppColors.greyColor,
          ),
          onPressed: () {
            setState(() => _obscurePassword = !_obscurePassword);
          },
        ),
      ),
    );
  }

  // Botões de ação (Login e Cadastro)
  Widget _buildActionButtons() {
    return _isLoading
        ? const CircularProgressIndicator()
        : Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () =>
                    Navigator.of(context).pushNamed(AppRoutes.register),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                ),
                child: const Text('Cadastre-se'),
              ),
              ElevatedButton(
                onPressed: _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.backgroundColor,
                  foregroundColor: AppColors.menuTextColor,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                ),
                child: const Text('Login'),
              ),
            ],
          );
  }
}
