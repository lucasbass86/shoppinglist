import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shoppinglist/providers/main_provider.dart';
import 'package:shoppinglist/secret/secret.dart';

import 'dart:convert';

import 'package:shoppinglist/utils/utils.dart';

class LicenseData {}

class ListData extends LicenseData {
  final List<dynamic> value;
  ListData(this.value);
}

class BoolData extends LicenseData {
  final bool value;
  BoolData(this.value);
}

class IntData extends LicenseData {
  final int value;
  IntData(this.value);
}

class StringData extends LicenseData {
  final String value;
  StringData(this.value);
}

class MapData extends LicenseData {
  final Map value;
  License? license;
  MapData({required this.value, this.license}) {
    license = License.fromJson(value as Map<String, dynamic>);
  }
}

GetLicenseCodeResponse getLicenseCodeResponseFromJson(String str) =>
    GetLicenseCodeResponse.fromJson(json.decode(str));

class GetLicenseCodeResponse {
  String status;
  String message;
  LicenseData data;

  GetLicenseCodeResponse({required this.status, required this.message, required this.data});

  factory GetLicenseCodeResponse.fromJson(Map<String, dynamic> json) {
    final dataJson = json["data"];
    dynamic data;

    if (dataJson is List) {
      data = ListData(dataJson);
    } else if (dataJson is bool) {
      data = BoolData(dataJson);
    } else if (dataJson is String) {
      data = StringData(dataJson);
    } else if (dataJson is int) {
      data = IntData(dataJson);
    } else if (dataJson is Map) {
      data = MapData(value: dataJson);
    } else {
      throw FormatException('Invalid data type: $dataJson');
    }

    return GetLicenseCodeResponse(
        status: json["status"] as String, message: json["message"] as String, data: data);
  }
}

class License {
  String license;
  String app;
  String email;
  DateTime activatedDate;
  int locked;
  String message;

  License(
      {required this.license,
      required this.app,
      required this.email,
      required this.activatedDate,
      required this.locked,
      required this.message});

  factory License.fromJson(Map<String, dynamic> json) => License(
      license: json["LICENSE"],
      app: json["APP"],
      email: json["EMAIL"],
      activatedDate: DateTime.parse(json["ACTIVATED_DATE"]),
      locked: int.parse(json["LOCKED"]),
      message: json["MESSAGE"]);
}

class LicenseService {
  static final String baseUrl = Secret.licensebaseUrl;
  static final String emailDev = Secret.emailDev;
  static final String appName = 'Shoppinglist';
  static final String success = 'success';
  static final String error = 'error';

  static Future<GetLicenseCodeResponse> obtainLicense(String email) async {
    final url = Uri.parse('${baseUrl}get_license.php');
    final response = await http.post(url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'app': appName}));
    GetLicenseCodeResponse licenseCodeResponse =
        GetLicenseCodeResponse.fromJson(json.decode(response.body));
    return licenseCodeResponse;
  }

  static Future<GetLicenseCodeResponse> setLicenseCode(String licenseCode, String email) async {
    final url = Uri.parse('${baseUrl}set_license.php');
    final response = await http.post(url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'license': licenseCode, 'app': appName, 'email': email}));
    GetLicenseCodeResponse licenseCodeResponse =
        GetLicenseCodeResponse.fromJson(json.decode(response.body));
    return licenseCodeResponse;
  }

  static Future<GetLicenseCodeResponse> checkLicenseCode(String licenseCode) async {
    final url = Uri.parse('${baseUrl}check_license.php');
    final response = await http.post(url,
        headers: {'Content-Type': 'application/json'}, body: jsonEncode({'license': licenseCode}));
    GetLicenseCodeResponse licenseCodeResponse =
        GetLicenseCodeResponse.fromJson(json.decode(response.body));
    return licenseCodeResponse;
  }
}

Future<dynamic> showDialogInput(BuildContext scaffoldContext,
    {TextInputType? inputType, String subtitle = '', String label = '', int maxLength = 75}) {
  TextEditingController controller = TextEditingController();
  MainProvider mainProvider = Provider.of(scaffoldContext, listen: false);
  final formKey = GlobalKey<FormState>();
  return showDialog(
    context: scaffoldContext,
    barrierDismissible: false,
    builder: (context) {
      return BounceInDown(
        child: AlertDialog(
          backgroundColor: Utils.claro,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
          title: Column(children: [
            Text(
              'Indica el $label',
              style: mainProvider.titleStyle,
            ),
            if (subtitle.isNotEmpty)
              Text(
                subtitle,
                style: mainProvider.itemStyle,
              )
          ]),
          content: StatefulBuilder(
            builder: (context, setState) {
              return SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    children: [
                      ZoomIn(
                        child: TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Rellena el $label';
                            }
                            return null;
                          },
                          controller: controller,
                          maxLength: maxLength,
                          decoration: InputDecoration(labelText: label, counterText: ''),
                          keyboardType: inputType ?? TextInputType.text,
                          textCapitalization: TextCapitalization.words,
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              );
            },
          ),
          actions: [
            OutlinedButton(
                onPressed: () => Navigator.of(context).pop([false]), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.of(context).pop([true, controller.text]);
                } else {
                  return;
                }
              },
              child: const Text('Aceptar'),
            ),
          ],
        ),
      );
    },
  );
}
