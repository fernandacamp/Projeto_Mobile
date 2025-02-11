import 'dart:convert';
import 'package:http/http.dart' as http;

class CepService {
  static Future<Map<String, dynamic>?> getAddress(String cep) async {
    if (!RegExp(r'^\d{8}$').hasMatch(cep)) {
      print('CEP inválido: deve conter exatamente 8 números.');
      return null;
    }

    try {
      final url = Uri.parse('https://viacep.com.br/ws/$cep/json/');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data.containsKey('erro')) {
          print('CEP não encontrado.');
          return null;
        }

        return data;
      } else {
        print('Erro na requisição: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Erro ao buscar o CEP: $e');
      return null;
    }
  }
}
