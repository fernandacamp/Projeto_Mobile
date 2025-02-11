import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:projeto_mobile/models/order_model.dart';
import 'package:projeto_mobile/providers/usuario_provider.dart';
import 'package:projeto_mobile/services/firestore_service.dart';
import 'package:projeto_mobile/services/cep_service.dart';
import 'package:projeto_mobile/settings/assets.dart';
import 'package:projeto_mobile/settings/color.dart';
import 'package:projeto_mobile/settings/fonts.dart';
import 'package:intl/intl.dart';
import 'package:projeto_mobile/settings/routes.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class NewTripPage extends StatefulWidget {
  const NewTripPage({super.key});

  @override
  State<NewTripPage> createState() => _NewTripPageState();
}

class _NewTripPageState extends State<NewTripPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _departureDateController = TextEditingController();
  final TextEditingController _departureTimeController = TextEditingController();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _nomeTutorController = TextEditingController();
  final TextEditingController _especieController = TextEditingController();
  final TextEditingController _cepController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _compController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _ufController = TextEditingController();

  late Usuario? usuario;
  late UsuarioProvider usuarioProvider;

  bool loading = false;

  String? serviceSelected;
  Map<String, String> services = {
    "Hospedagem": AppAssets.hotelIcon,
    "Transporte": AppAssets.carIcon,
    "Petshop": AppAssets.cutIcon
  };

  @override
  void initState() {
    super.initState();
    _cepController.addListener(_onCepChanged);
  }

  @override
  void dispose() {
    _cepController.removeListener(_onCepChanged);
    super.dispose();
  }

  void _onCepChanged() {
    if (_cepController.text.length == 8) {
      fetchAddress();
    }
  }

  Future<void> fetchAddress() async {
    final cep = _cepController.text.replaceAll(RegExp(r'[^0-9]'), ''); // Apenas números
    if (cep.length == 8) {
      final address = await CepService.getAddress(cep);
      if (address != null) {
        setState(() {
          _addressController.text = address['logradouro'] ?? '';
          _cityController.text = address['localidade'] ?? '';
          _ufController.text = address['uf'] ?? '';
        });
      } else {
        print("CEP inválido");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    usuarioProvider = Provider.of<UsuarioProvider>(context);
    usuario = usuarioProvider.usuario;

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(color: AppColors.menuTextColor),
        title: Text(
          'Home',
          style: AppFonts.defaultLarger.copyWith(color: AppColors.menuTextColor),
        ),
        centerTitle: true,
        backgroundColor: AppColors.backgroundColor,
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              var order = OrderModel(
                  id: const Uuid().v4(),
                  idUser: usuario!.id,
                  date: _departureDateController.text,
                  hour: _departureTimeController.text,
                  petName: _nomeController.text,
                  petType: _especieController.text,
                  tutorName: _nomeTutorController.text,
                  type: serviceSelected ?? "Hospedagem",
                  cep: _cepController.text,
                  address: _addressController.text,
                  number: 89,
                  city: _cityController.text,
                  state: _ufController.text);

              try {
                await FirestoreService.addOrder(order);
              } on FirebaseException catch (e) {
                // Tratamento específico para erros do Firebase
                print('Erro do Firebase: ${e.message}');
              } catch (e) {
                // Tratamento genérico para outras exceções
                print('Erro desconhecido: $e');
              }

              _showConfirmationDialog(context);
            }
          },
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            backgroundColor: AppColors.backgroundColor,
          ),
          child: Text(
            'Adicionar Viagem',
            style: AppFonts.defaultRegular.copyWith(
              color: AppColors.menuTextColor,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Campo para escolher a data de ida
                LayoutBuilder(
                  builder: (context, constrains) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: constrains.maxWidth / 2 - 10,
                          child: TextFormField(
                            controller: _departureDateController,
                            decoration: InputDecoration(
                              labelText: 'Data',
                              labelStyle: AppFonts.boldLarge.copyWith(color: AppColors.textColor),
                              prefixIcon: Icon(Icons.calendar_today),
                            ),
                            readOnly: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'A data é obrigatória';
                              }
                              return null;
                            },
                            onTap: () async {
                              final pickedDate = await _selectDate(context);
                              if (pickedDate != null) {
                                setState(() {
                                  _departureDateController.text = pickedDate;
                                });
                              }
                            },
                          ),
                        ),
                        SizedBox(
                          width: constrains.maxWidth / 2 - 10,
                          child: TextFormField(
                            controller: _departureTimeController,
                            decoration: InputDecoration(
                              labelText: 'Horário',
                              labelStyle: AppFonts.boldLarge.copyWith(color: AppColors.textColor),
                              prefixIcon: Icon(Icons.access_time),
                            ),
                            readOnly: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'O horário é obrigatório';
                              }
                              return null;
                            },
                            onTap: () async {
                              final pickedTime = await _selectTime(context);
                              if (pickedTime != null) {
                                setState(() {
                                  _departureTimeController.text = pickedTime;
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _nomeController,
                  label: 'Nome do Pet',
                  validatorMessage: 'O nome do pet é obrigatório',
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _nomeTutorController,
                  label: 'Nome do Tutor',
                  validatorMessage: 'O nome do tutor é obrigatório',
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _especieController,
                  label: 'Espécie',
                  validatorMessage: 'A espécie é obrigatória',
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: services.entries.map((x) {
                    return GestureDetector(
                      onTap: () => setState(() => serviceSelected = x.key),
                      child: Container(
                        alignment: Alignment.center,
                        width: 80,
                        height: 60,
                        decoration: BoxDecoration(
                          color: serviceSelected == x.key
                              ? AppColors.backgroundColor.withOpacity(0.6)
                              : Colors.transparent,
                          border: serviceSelected == x.key
                              ? Border.all(color: AppColors.backgroundColor)
                              : null,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SvgPicture.asset(
                              x.value,
                              color: serviceSelected == x.key
                                  ? AppColors.menuTextColor
                                  : AppColors.textColor,
                            ),
                            const SizedBox(height: 5),
                            Text(
                              x.key,
                              style: AppFonts.defaultaSmall.copyWith(
                                color: serviceSelected == x.key
                                    ? AppColors.menuTextColor
                                    : AppColors.textColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                LayoutBuilder(
                  builder: (context, constrains) {
                    return Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: constrains.maxWidth - 100,
                          child: _buildTextField(
                            controller: _cepController,
                            label: 'CEP',
                            keyboardType: TextInputType.number,
                            validatorMessage: 'O CEP é obrigatório',
                          ),
                        ),

                        ElevatedButton(
                          onPressed: () => _obterLocalizacaoAtual(),
                          child: loading ? CircularProgressIndicator(color: AppColors.backgroundColor,) : const Icon(Icons.location_on_sharp, color: AppColors.backgroundColor,),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(horizontal: 0, vertical: 15),
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            side: BorderSide(color: AppColors.backgroundColor),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        )
                      ],
                    );
                  }
                ),
                const SizedBox(height: 20),
                _buildDisabledTextField(
                  controller: _addressController,
                  label: 'Endereço',
                ),
                const SizedBox(height: 20),
                LayoutBuilder(builder: (context, constrains) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: constrains.maxWidth * 1 / 4 - 10,
                        child: _buildTextField(
                          controller: _numberController,
                          label: 'Número',
                          keyboardType: TextInputType.number,
                          validatorMessage: 'O número é obrigatório',
                        ),
                      ),
                      SizedBox(
                        width: constrains.maxWidth * 3 / 4 - 10,
                        child: TextFormField(
                          controller: _compController,
                          decoration: InputDecoration(
                            labelText: 'Complemento',
                            labelStyle: AppFonts.boldLarge.copyWith(color: AppColors.textColor),
                          ),
                        ),
                      ),
                    ],
                  );
                }),
                const SizedBox(height: 20),
                LayoutBuilder(builder: (context, constrains) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: constrains.maxWidth * 3 / 4 - 10,
                        child: _buildDisabledTextField(
                          controller: _cityController,
                          label: 'Cidade',
                        ),
                      ),
                      SizedBox(
                        width: constrains.maxWidth * 1 / 4 - 10,
                        child: _buildDisabledTextField(
                          controller: _ufController,
                          label: 'UF',
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    required String validatorMessage,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppFonts.boldLarge.copyWith(color: AppColors.textColor),
      ),
      keyboardType: keyboardType,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return validatorMessage;
        }
        return null;
      },
    );
  }

  Widget _buildDisabledTextField({
    required TextEditingController controller,
    required String label,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppFonts.boldLarge.copyWith(color: AppColors.textColor),
      ),
      enabled: false,
    );
  }

  Future<String?> _selectDate(BuildContext context) async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (selectedDate != null) {
      return DateFormat('dd/MM/yyyy').format(selectedDate);
    }
    return null;
  }

  Future<String?> _selectTime(BuildContext context) async {
    TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (selectedTime != null) {
      return selectedTime.format(context);
    }
    return null;
  }

  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmação'),
          content: Text('Viagem adicionada com sucesso!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed(AppRoutes.orderHistory);
              },
              child: Text('Confirmar'),
            ),
          ],
        );
      },
    );
  }

  _obterLocalizacaoAtual() async {
    setState(() => loading = true);
    LocationPermission permission;
    permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      final snackBar = SnackBar(
        content: Text('Permissão de localização é necessária'),
        duration: Duration(seconds: 2),
      );

      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);

      Placemark place = placemarks[0];

      setState(() {
        _addressController.text = place.street ?? "";
        _numberController.text = place.subThoroughfare ?? "";
        _cityController.text = place.subAdministrativeArea ?? "";
        _ufController.text = place.administrativeArea ?? "";
        _cepController.text = place.postalCode ?? "";
        loading = false;
      });
    } catch (e) {
      final snackBar = SnackBar(
        content: Text('Erro: $e'),
        duration: Duration(seconds: 2),
      );

      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }
}