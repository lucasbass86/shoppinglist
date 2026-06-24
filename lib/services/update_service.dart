import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shoppinglist/models/versiones_model.dart';
import 'package:shoppinglist/secret/secret.dart';

class UpdateService extends ChangeNotifier {
  final String _urlVersiones = Secret.urlVersiones;
  final String _urlUsuarios = Secret.urlUsuarios;
  final String _urlUserLock = Secret.urlUserLock;
  List<Versiones> versiones = [];
  List<CResultado> resultado = [];
  static final String appName = 'SHOPPINGLIST';
  static String urlUpdatePath = '';

  Future<List<Versiones>> getVersiones() async {
    final response = await http.get(Uri.parse(_urlVersiones));
    versiones = versionesFromJson(response.body);
    notifyListeners();
    return versiones;
  }

  Future<List<CResultado>> setUser(String id, String info) async {
    final response = await http.post(
      Uri.parse(_urlUsuarios),
      body: {
        'app': appName,
        'id': id,
        'info': info,
      },
    );
    resultado = cResultadoFromJson(response.body);
    return resultado;
  }

  Future<List<CResultado>> getUserLock(String id, String info) async {
    final params = {
      'app': appName,
      'id': id,
    };
    final uri = Uri.parse(_urlUserLock).replace(queryParameters: params);
    final response = await http.get(uri);

    resultado = cResultadoFromJson(response.body);
    return resultado;
  }
}
