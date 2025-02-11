import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projeto_mobile/models/order_model.dart';
import 'package:projeto_mobile/models/usuario_model.dart';

class FirestoreService {
  static final FirebaseFirestore _firebaseFirestore =
      FirebaseFirestore.instance;

  static FirebaseFirestore get firebaseFirestore => _firebaseFirestore;

  static Future<UserModel?> getUserbyEmail(String email) async {
    var user = await FirestoreService.firebaseFirestore
        .collection("users")
        .where('email', isEqualTo: email)
        .get();

    return user.docs.isEmpty ? null : UserModel.fromMap(user.docs.first.data());
  }

  static Future<List<OrderModel>> getOrder(String idUser) async {
    var user = await FirestoreService.firebaseFirestore
        .collection("orders")
        .where('idUser', isEqualTo: idUser)
        .get();

    return user.docs.map((e) => OrderModel.fromMap(e.data())).toList();
  }

  static Future<void> addUser(UserModel endereco) async {
    await firebaseFirestore.collection("users").add(endereco.toMap());
  }

  static Future<void> addOrder(OrderModel endereco) async {
    await firebaseFirestore.collection("orders").add(endereco.toMap());
  }
}
