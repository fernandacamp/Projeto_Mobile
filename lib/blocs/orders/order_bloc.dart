import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:projeto_mobile/models/order_model.dart';
import 'package:projeto_mobile/services/firestore_service.dart';

part 'order_event.dart';
part 'order_state.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  OrderBloc() : super(OrderInitial()) {
    on<GetOrdersEvent>((event, emit) async {
      try {
        var orders = await FirestoreService.getOrder(event.idUser);

        emit(SuccssesGetOrdersState(model: orders));
      } catch (e) {
        emit(ErrorGetOrdersState());
      }
    });
  }
}
