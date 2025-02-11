part of 'order_bloc.dart';

@immutable
sealed class OrderState {}

final class OrderInitial extends OrderState {}

final class SuccssesGetOrdersState extends OrderInitial {
  final List<OrderModel> model;

  SuccssesGetOrdersState({required this.model});
}

final class ErrorGetOrdersState extends OrderInitial { }
