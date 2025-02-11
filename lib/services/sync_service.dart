import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'package:projeto_mobile/models/task.dart';

Future<void> syncDataToHive() async {
  final firestore = FirebaseFirestore.instance;
  final taskBox = await Hive.openBox<Task>('tasks');

  final snapshot = await firestore.collection('tasks').get();
  for (var doc in snapshot.docs) {
    final data = doc.data();
    final task = Task(
      id: doc.id,
      title: data['description'],
    );
    taskBox.put(doc.id, task); // Salva no Hive
  }
}
