import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:projeto_mobile/helper/validator_helper.dart';
import 'package:projeto_mobile/models/usuario_model.dart';
import 'package:projeto_mobile/services/firestore_service.dart';
import 'package:projeto_mobile/settings/assets.dart';
import 'package:projeto_mobile/settings/color.dart';
import 'package:projeto_mobile/settings/fonts.dart';
import 'package:projeto_mobile/settings/routes.dart';
import 'package:uuid/uuid.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final GlobalKey<FormState> _key = GlobalKey<FormState>();

  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _acceptedTerms = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              alignment: Alignment.center,
              height: 200,
              child: Image.asset(AppAssets.logoImage),
            ),
            Container(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height - 200,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              padding: const EdgeInsets.all(30),
              child: Form(
                key: _key,
                child: Column(
                  children: [
                    Text(
                      "Cadastre-se",
                      style: AppFonts.boldLarge.copyWith(
                        color: AppColors.backgroundColor,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Nome Completo
                    TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Preencha seu nome';
                        }
                        if (value.length < 3) {
                          return 'Nome deve ter pelo menos 3 caracteres';
                        }
                        return null;
                      },
                      controller: _userNameController,
                      decoration: InputDecoration(
                        labelText: 'Nome Completo',
                        labelStyle: AppFonts.boldRegular.copyWith(
                          color: AppColors.greyColor,
                        ),
                        border: const UnderlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Email
                    TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Preencha seu email';
                        }
                        if (!ValidatorHelper.validateEmail(value)) {
                          return 'Email inválido';
                        }
                        return null;
                      },
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: AppFonts.boldRegular.copyWith(
                          color: AppColors.greyColor,
                        ),
                        border: const UnderlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 20),
                    // Senha
                    TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Preencha sua senha';
                        }
                        if (value.length < 8) {
                          return 'Senha deve ter mais que 8 caracteres';
                        }
                        return null;
                      },
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Senha',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: AppColors.greyColor,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Confirmar Senha
                    TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Confirme sua senha';
                        }
                        if (value != _passwordController.text) {
                          return 'As senhas não coincidem';
                        }
                        return null;
                      },
                      controller: _confirmPasswordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Confirmar Senha',
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Aceitar Termos
                    Row(
                      children: [
                        Checkbox(
                          value: _acceptedTerms,
                          onChanged: (value) {
                            setState(() {
                              _acceptedTerms = value ?? false;
                            });
                          },
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              // Exibir os termos de uso
                            },
                            child: Text(
                              "Concordo com os Termos de Uso e Política de Privacidade",
                              style: AppFonts.boldSmall.copyWith(
                                color: AppColors.greyColor,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Voltar'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            if (!_acceptedTerms) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Você precisa aceitar os Termos de Uso',
                                  ),
                                ),
                              );
                              return;
                            }
                            if (_key.currentState!.validate()) {
                              _register();
                            }
                          },
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text('Cadastre-se'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _register() async {
    if (!_key.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      await FirestoreService.addUser(UserModel(
          id: const Uuid().v4(),
          name: _userNameController.text,
          email: _emailController.text));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cadastro realizado com sucesso!'),
        ),
      );
      Navigator.of(context).pop();
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
}
