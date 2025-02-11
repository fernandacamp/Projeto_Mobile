import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:projeto_mobile/providers/usuario_provider.dart';
import 'package:projeto_mobile/repositores/task_repository.dart';
import 'package:projeto_mobile/services/firebase_messaging_service.dart';
import 'package:projeto_mobile/services/notification_service.dart';
import 'package:provider/provider.dart';
import 'package:projeto_mobile/screens/login_page.dart';
import 'package:projeto_mobile/screens/menu_page.dart';
import 'package:projeto_mobile/settings/routes.dart';
import 'package:projeto_mobile/models/task.dart';
import 'package:projeto_mobile/services/network_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';



Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(FirebaseMessagingService.firebaseMessagingBackgroundHandler);
  FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: true);

  // Inicializa o Hive
  await Hive.initFlutter();
  Hive.registerAdapter(TaskAdapter());

  // Verifica conexão com a internet e sincroniza dados
  if (await isConnected()) {
    print("Conectado à internet. Sincronizando dados...");
    await syncDataToHive();
  } else {
    print("Sem conexão com a internet. Dados não sincronizados.");
  }

  // Abre a caixa de tarefas no Hive e sincroniza com o Firebase
  final taskBox = await Hive.openBox<Task>('tasks');
  final repository = TaskRepository(taskBox);
  await repository.syncWithFirebase();

  // Teste de exemplo: salvar e recuperar uma tarefa no Hive
  taskBox.put('task1', Task(id: '1', title: 'Primeira tarefa'));
  final task = taskBox.get('task1');
  print(task?.title); // Output: Primeira tarefa

  // Inicia o aplicativo com o Provider para gerenciar estado
  runApp(
    ChangeNotifierProvider(
      create: (context) => UsuarioProvider(),
      child: const MyApp(),
    ),
  );
}

void getToken() async {
  String? token = await FirebaseMessaging.instance.getToken();
  print("Token do dispositivo: $token");
}



// Sincroniza dados do Firestore com o Hive
Future<void> syncDataToHive() async {
  try {
    final firestore = FirebaseFirestore.instance;
    final querySnapshot = await firestore.collection('tasks').get();
    final taskBox = await Hive.openBox<Task>('tasks');

    for (var doc in querySnapshot.docs) {
      final task = Task(
        id: doc.id,
        title: doc['title'] ?? 'Descrição não fornecida',
      );
      taskBox.put(doc.id, task);
    }

    print('Sincronização de dados concluída com sucesso.');
  } catch (e) {
    print('Erro durante a sincronização de dados: $e');
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    super.initState();
    FirebaseMessagingService.setupFirebaseMessaging();
    FirebaseMessagingService.getToken();
    setupNotifications();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("📩 Notificação recebida enquanto o app está aberto!");
      showNotification(message);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pet Transporte',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.purple),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData) {
            return MenuPage();
          } else {
            return const LoginPage();
          }
        },
      ),
      routes: AppRoutes.routes,
    );
  }
}