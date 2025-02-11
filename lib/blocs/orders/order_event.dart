part of 'order_bloc.dart';

@immutable
sealed class OrderEvent {}

class GetOrdersEvent extends OrderEvent {
  String idUser;

  GetOrdersEvent({required this.idUser});
}
