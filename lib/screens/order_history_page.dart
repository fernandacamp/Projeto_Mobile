import 'package:flutter/material.dart';
import 'package:projeto_mobile/blocs/orders/order_bloc.dart';
import 'package:projeto_mobile/models/order_model.dart';
import 'package:projeto_mobile/providers/usuario_provider.dart';
import 'package:projeto_mobile/settings/color.dart';
import 'package:projeto_mobile/settings/fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({super.key});

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  final OrderBloc bloc = OrderBloc();

  late Usuario? usuario;
  late UsuarioProvider usuarioProvider;

  List<OrderModel> _orderHistory = List.empty(growable: true);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    usuarioProvider = Provider.of<UsuarioProvider>(context);
    usuario = usuarioProvider.usuario;

    bloc.add(GetOrdersEvent(idUser: usuario!.id));

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(
          color: AppColors.menuTextColor,
        ),
        title: Text('Histórico de Pedidos de Pets',
            style: AppFonts.defaultLarger
                .copyWith(color: AppColors.menuTextColor)),
        centerTitle: true,
        backgroundColor: AppColors.backgroundColor,
      ),
      body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: BlocConsumer<OrderBloc, OrderState>(
              bloc: bloc,
              listener: (context, state) {
                if (state is SuccssesGetOrdersState) {
                  setState(() => _orderHistory = state.model);
                }
              },
              builder: (context, state) {
                if (state is SuccssesGetOrdersState) {
                  return _orderHistory.isEmpty
                      ? Center(
                          child: Text(
                            'Nenhum pedido encontrado.',
                            style: AppFonts.boldRegular
                                .copyWith(color: AppColors.backgroundColor),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _orderHistory
                              .length, // Alterado para a quantidade de pets
                          itemBuilder: (context, index) {
                            final order = _orderHistory[
                                index]; // Acesso ao histórico de pedidos
                            return Card(
                              margin: EdgeInsets.only(bottom: 16),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.purple.shade100,
                                  child: Icon(Icons.pets, color: Colors.purple),
                                ),
                                title: Text(
                                  order.petName, // Exibe o nome do pet
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                    'Data: ${order.date}'), // Exibe a data do pedido
                                trailing: Text(
                                  order.orderState, // Exibe o status do pedido
                                  style: TextStyle(
                                    color: order.orderState == 'Entregue'
                                        ? Colors.green
                                        : order.orderState == 'Em trânsito' ||
                                                order.orderState == 'Pendente'
                                            ? Colors.orange
                                            : Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                onTap: () {
                                  // Ação ao clicar no pedido (exibir detalhes, por exemplo)
                                },
                              ),
                            );
                          },
                        );
                } else if (state is ErrorGetOrdersState) {
                  return const Center(
                    child: Text(
                      "Erro ao buscar pedidos",
                      style: AppFonts.boldLarge,
                    ),
                  );
                } else {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.backgroundColor,
                    ),
                  );
                }
              })),
    );
  }
}
