class OrderModel {
  String id;
  String idUser;
  String date;
  String hour;
  String petName;
  String petType;
  String tutorName;
  String type;
  String cep;
  String address;
  int number;
  String? compl;
  String city;
  String state;
  String orderState = 'Pendente';

  OrderModel({
    required this.id,
    required this.idUser,
    required this.date,
    required this.hour,
    required this.petName,
    required this.petType,
    required this.tutorName,
    required this.type,
    required this.cep,
    required this.address,
    required this.number,
    this.compl,
    required this.city,
    required this.state,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'idUser': idUser,
      'date': date,
      'hour': hour,
      'petName': petName,
      'petType': petType,
      'tutorName': tutorName,
      'type': type,
      'cep': cep,
      'address': address,
      'number': number,
      'compl': compl,
      'city': city,
      'state': state,
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      id: map['id'] as String,
      idUser: map['idUser'] as String,
      date: map['date'] as String,
      hour: map['hour'] as String,
      petName: map['petName'] as String,
      petType: map['petType'] as String,
      tutorName: map['tutorName'] as String,
      type: map['type'] as String,
      cep: map['cep'] as String,
      address: map['address'] as String,
      number: map['number'] as int,
      compl: map['compl'] != null ? map['compl'] as String : null,
      city: map['city'] as String,
      state: map['state'] as String,
    );
  }
}
