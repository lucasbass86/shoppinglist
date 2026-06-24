import 'dart:io';

import 'package:diacritic/diacritic.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;
import 'package:permission_handler/permission_handler.dart';
import 'package:shoppinglist/secret/secret.dart';

export 'package:shoppinglist/utils/extensions.dart';

class Utils {
  static String urlUpdatePath = Secret.urlUpdatePath;
  static Directory path = Directory('');
  static const int productImageSizeStandar = 70;
  static int productImageSize = productImageSizeStandar;
  static const int homeIconImageSizeStandar = 110;
  static int homeIconImageSize = homeIconImageSizeStandar;
  static final List<String> opcionesOrden = ['A-Z', 'Z-A', 'TIPO A-Z', 'TIPO Z-A', 'MAS USADOS'];

  static const int productLargeImageSize = 100;

  static const String tagProduct = 'Product:';
  static const String tagShop = 'Shop:';

  static const String assetShop = 'assets/tienda.png';

  static const double iconSizeStandar = 40;
  static const double iconSizeBig = 80;
  static double iconSizeSelected = iconSizeStandar;
  static double iconSizeDrag = iconSizeSelected == iconSizeStandar ? 80 : 120;

  static final Box boxProducts = Hive.box('shoppingListProductos');
  static final Box boxShops = Hive.box('shoppingListTiendas');
  static final Box boxPrices = Hive.box('shoppingListPrecios');
  static final Box boxCart = Hive.box('shoppingListCart');
  static final Box boxHistoryPrice = Hive.box('shoppingHistoricoPrecios');
  static final Box boxShoppingHistory = Hive.box('shoppingHistoricoCompras');
  static final Box boxHiddenForecast = Hive.box('shoppingHiddenForecast');

  static Duration fadeInDuration = const Duration(milliseconds: 800);
  static Color cVerdeOscuro = const Color(0xFF045256);
  static Color cVerdeMedio = const Color(0xFF9AB8BA);
  static Color cVerdeClaro = const Color(0xFFDDF7F8);

  static Color cNaturalOscuro = const Color(0xFFF29A7C);
  static Color cNaturalMedio = const Color(0xFFFBD5C2);
  static Color cNaturalClaro = const Color(0xFFFDF6ED);

  static Color cAzulOscuro = const Color(0xFF7078D3);
  static Color cAzulMedio = const Color(0xFFBDCEE8);
  static Color cAzulClaro = const Color(0xFFE8EAF7);

  static Color cDarkOscuro = const Color.fromARGB(255, 83, 83, 83);
  static Color cDarkMedio = const Color.fromARGB(255, 119, 119, 119);
  static Color cDarkClaro = const Color.fromARGB(255, 175, 173, 173);

  static Color oscuro = const Color(0xFF045256);
  static Color medio = const Color(0xFF9AB8BA);
  static Color claro = const Color(0xFFDDF7F8);

  //COLOR SVG: #C8C8CE

  static final Color colorNumItems = Colors.red[900]!;

  static final List<Color> palettes = [
    Color(0xFFCFD4C5),
    Color(0xFFeecfd4),
    Color(0xFFefb9cb),
    Color(0xFFe6adec),
    Color(0xFFc287e8),
    Color(0xFFF7D1CD),
    Color(0xFFE8C2CA),
    Color(0xFFD1B3C4),
    Color(0xFFB392AC),
    Color(0xFF735D78),
    Color(0xFF56E39F),
    Color(0xFF59C9A5),
    Color(0xFF5B6C5D),
    Color(0xFF3B2C35),
    Color(0xFF2A1F2D),
    Color(0xFFF0B67F),
    Color(0xFFFE5F55),
    Color(0xFFD6D1B1),
    Color(0xFFC7EFCF),
    Color(0xFFEEF5DB),
    Color(0xFF253031),
    Color(0xFF315659),
    Color(0xFF2978A0),
    Color(0xFFBCAB79),
    Color(0xFFC6E0FF),
  ];

  static String monthName(int month) {
    switch (month) {
      case 1:
        return 'ENERO';
      case 2:
        return 'FEBRERO';
      case 3:
        return 'MARZO';
      case 4:
        return 'ABRIL';
      case 5:
        return 'MAYO';
      case 6:
        return 'JUNIO';
      case 7:
        return 'JULIO';
      case 8:
        return 'AGOSTO';
      case 9:
        return 'SEPTIEMBRE';
      case 10:
        return 'OCTUBRE';
      case 11:
        return 'NOVIEMBRE';
      case 12:
        return 'DICIEMBRE';
      default:
        return '';
    }
  }

  static RegExp regNumeroDecimal =
      RegExp('^([1-9]{1}[0-9]{0,}(\\.[0-9]{0,2})?|0(\\.[0-9]{0,2})?|\\.[0-9]{1,2})');

  static SnackBar snackBar(String title, {bool isGood = true}) {
    return SnackBar(
      content: Text(title, style: TextStyle(color: isGood ? Colors.white : Colors.black)),
      backgroundColor: isGood ? medio : Colors.red[200],
    );
  }

  static void snackBarOverlay(BuildContext context, String message, {bool isGood = true}) {
    final overlay = Overlay.of(context);
    OverlayEntry entry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 40,
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: isGood ? medio : Colors.red[200],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              message,
              style: TextStyle(color: isGood ? Colors.white : Colors.black),
            ),
          ),
        ),
      ),
    );

    overlay.insert(entry);
    Future.delayed(const Duration(seconds: 2)).then((_) => entry.remove());
  }

  static String? getCurrentRoute(BuildContext context) {
    return ModalRoute.of(context)?.settings.name;
  }

  static Color adaptativeColor(Color backColor) {
    final double luminance = backColor.computeLuminance();
    return luminance < 0.5 ? oscuro : claro;
  }

  static Future<void> solicitarPermisoStorage() async {
    var status = await Permission.storage.status;

    if (status.isGranted) {
      // print("Permiso ya concedido");
      return;
    }

    if (status.isDenied) {
      // Primer intento o denegado sin "No volver a preguntar"
      var nuevoStatus = await Permission.storage.request();
      if (nuevoStatus.isGranted) {
        // print("Permiso concedido tras solicitarlo");
      } else if (nuevoStatus.isPermanentlyDenied) {
        // Lo denegó y marcó “No volver a preguntar”
        // print("Permiso denegado permanentemente. Redirigiendo a configuración...");
        openAppSettings();
      } else {
        // print("Permiso denegado");
      }
    } else if (status.isPermanentlyDenied) {
      // print("Permiso ya estaba denegado permanentemente. Redirigiendo...");
      openAppSettings();
    }
  }

  static Future<bool> guardarArchivoEnDescargas(String nombreArchivo, String contenido) async {
    // Pide permisos
    solicitarPermisoStorage();

    // Obtiene la ruta de Descargas (solo Android)
    final Directory downloadsDir = Directory('/storage/emulated/0/Download');

    if (downloadsDir.existsSync()) {
      final archivo = File(p.join(downloadsDir.path, nombreArchivo));
      await archivo.writeAsString(contenido);
      notificarSistemaArchivo(archivo.path);
      return true;
    } else {
      return false;
    }
  }

  static Future<void> notificarSistemaArchivo(String pathArchivo) async {
    const platform = MethodChannel('com.lucas.shoppinglist');
    try {
      await platform.invokeMethod('scanFile', {'path': pathArchivo});
    } catch (e) {
      // print("Error al notificar sistema: $e");
    }
  }

  static Future<String> seleccionarArchivo() async {
    FilePickerResult? filePicker = await FilePicker.platform.pickFiles(
      withData: false,
      type: FileType.any,
      allowMultiple: false,
    );
    if (filePicker != null && filePicker.files.single.path != null) {
      File file = File(filePicker.files.single.path!);
      String contenido = await file.readAsString();
      return contenido;
    } else {
      return '';
    }
  }

  static Future<bool> checkConnection() async {
    try {
      final result = await InternetAddress.lookup('www.google.es');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      } else {
        return false;
      }
    } on SocketException catch (_) {
      return false;
    }
  }

  static String dateEnglishToSpanish(String date, {bool showTime = true}) {
    String year = date.substring(0, 4);
    String month = date.substring(5, 7);
    String day = date.substring(8, 10);
    if (!showTime) {
      return "$day-$month-$year";
    } else if (date.length > 10) {
      String hour = date.substring(11, 13);
      String minute = date.substring(14, 16);
      // String seconds = date.substring(17, 19);
      return "$day-$month-$year $hour:$minute";
    } else {
      return "$day-$month-$year 00:00";
    }
  }

  static String dateSpanishSort(String date) {
    return '${date.substring(0, 6)}.${date.substring(8, 10)}';
  }

  static String quitarTildes(String palabra) {
    return removeDiacritics(palabra);
  }

  /// Devuelve una nueva fecha solo con año, mes y día (hora 00:00:00)
  static DateTime stripTime(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Retorna true si `a` y `b` son el mismo día (ignorando hora)
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Retorna true si `a` es igual o después del día `b` (ignorando hora)
  static bool isSameOrAfterDay(DateTime a, DateTime b) {
    final da = stripTime(a);
    final db = stripTime(b);
    return da.isAtSameMomentAs(db) || da.isAfter(db);
  }

  /// Retorna true si `a` es igual o antes del día `b` (ignorando hora)
  static bool isSameOrBeforeDay(DateTime a, DateTime b) {
    final da = stripTime(a);
    final db = stripTime(b);
    return da.isAtSameMomentAs(db) || da.isBefore(db);
  }

  /// Retorna true si `target` está entre `from` y `to` (inclusive), ignorando hora
  static bool isBetweenDays(DateTime target, DateTime from, DateTime to) {
    final t = stripTime(target);
    final f1 = stripTime(from);
    final f2 = stripTime(to);

    final start = f1.isBefore(f2) ? f1 : f2;
    final end = f1.isBefore(f2) ? f2 : f1;

    return (t.isAtSameMomentAs(start) || t.isAfter(start)) &&
        (t.isAtSameMomentAs(end) || t.isBefore(end));
  }
}
