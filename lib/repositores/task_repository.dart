import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:projeto_mobile/models/task.dart';

class TaskRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Box<Task> _taskBox;

  TaskRepository(this._taskBox);

  Future<void> syncWithFirebase() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("Erro: Usuário não autenticado!");
      return;
    }

    try {
      final snapshot = await _firestore
          .collection('tasks')
          .where('userId', isEqualTo: user.uid) // Filtra as tarefas do usuário
          .get();
      
      for (var doc in snapshot.docs) {
        final task = Task.fromJson(doc.data());
        _taskBox.put(task.id, task); // Salva no Hive
      }
    } catch (e) {
      print("Erro ao sincronizar dados: $e");
    }
  }

  Future<void> addTask(Task task) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("Erro: Usuário não autenticado!");
      return;
    }
    
    try {
      await _firestore.collection('tasks').doc(task.id).set({
        ...task.toJson(),
        'userId': user.uid, // Associa a tarefa ao usuário autenticado
      });
      _taskBox.put(task.id, task); // Salva no Hive
    } catch (e) {
      print("Erro ao adicionar tarefa: $e");
    }
  }
}
