import 'package:flutter/material.dart';
import 'package:shoppinglist/providers/main_provider.dart';
import 'package:shoppinglist/utils/utils.dart';

class CalculatorWidget extends StatefulWidget {
  final Function(double result) onResult;
  final double? quantity;
  const CalculatorWidget({super.key, required this.onResult, this.quantity});

  @override
  State<CalculatorWidget> createState() => _CalculatorWidgetState();
}

class _CalculatorWidgetState extends State<CalculatorWidget> {
  final ButtonStyle light = ButtonStyle(
    shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(10))),
    backgroundColor: WidgetStateColor.resolveWith(
      (states) {
        if (states.contains(WidgetState.pressed)) {
          return Utils.oscuro;
        }
        return Utils.claro;
      },
    ),
    foregroundColor: WidgetStateColor.resolveWith(
      (states) {
        if (states.contains(WidgetState.pressed)) {
          return Utils.claro;
        }
        return Utils.oscuro;
      },
    ),
  );
  final ButtonStyle dark = ButtonStyle(
    shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(10))),
    backgroundColor: WidgetStateColor.resolveWith(
      (states) {
        if (states.contains(WidgetState.pressed)) {
          return Utils.claro;
        }
        return Utils.oscuro;
      },
    ),
    foregroundColor: WidgetStateColor.resolveWith(
      (states) {
        if (states.contains(WidgetState.pressed)) {
          return Utils.oscuro;
        }
        return Utils.claro;
      },
    ),
  );
  String sres = '0';
  String sN1 = '';
  String sN2 = '';
  String operacion = '';
  double resultado = 0;

  @override
  void initState() {
    super.initState();
    sN1 = widget.quantity != null ? widget.quantity.toString() : '';
    if (sN1.isNotEmpty) sres = sN1;
  }

  @override
  Widget build(BuildContext context) {
    MainProvider mainProvider = Provider.of(context, listen: false);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Utils.medio,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Container(
            height: 100,
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Utils.oscuro, borderRadius: BorderRadius.circular(20)),
            child: Align(
              alignment: Alignment.centerRight,
              child: SelectableText(
                sres,
                style: mainProvider.titleStyle.copyWith(color: Utils.claro, fontSize: 45),
              ),
            ),
          ),
          const SizedBox(height: 5),
          Row(
            spacing: 3,
            children: [
              _button(true, 'C', () {
                sres = '0';
                sN1 = '0';
                sN2 = '0';
                operacion = '';
                setState(() {});
              }),
              _button(false, '%', () {
                _percentage();
              }),
              _button(false, '/', () {
                _symbol('/');
              }),
              _button(false, '<', () {
                _remove();
              }),
            ],
          ),
          const SizedBox(height: 3),
          Row(
            spacing: 3,
            children: [
              _button(true, '7', () {
                _number('7');
              }),
              _button(true, '8', () {
                _number('8');
              }),
              _button(true, '9', () {
                _number('9');
              }),
              _button(false, 'x', () {
                _symbol('x');
              }),
            ],
          ),
          const SizedBox(height: 3),
          Row(
            spacing: 3,
            children: [
              _button(true, '4', () {
                _number('4');
              }),
              _button(true, '5', () {
                _number('5');
              }),
              _button(true, '6', () {
                _number('6');
              }),
              _button(false, '-', () {
                _symbol('-');
              }),
            ],
          ),
          const SizedBox(height: 3),
          Row(
            spacing: 3,
            children: [
              _button(true, '1', () {
                _number('1');
              }),
              _button(true, '2', () {
                _number('2');
              }),
              _button(true, '3', () {
                _number('3');
              }),
              _button(false, '+', () {
                _symbol('+');
              }),
            ],
          ),
          const SizedBox(height: 3),
          Row(
            spacing: 3,
            children: [
              _button(true, '0', () {
                _number('0');
              }),
              _button(true, '.', () {
                _point();
              }),
              _button(false, '=', () {
                _calculate();
              }, flex: 2),
            ],
          ),
        ],
      ),
    );
  }

  Widget _button(bool isLight, String label, Function onPressed, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: ElevatedButton(
        onPressed: () => onPressed.call(),
        style: isLight ? light : dark,
        child: SizedBox(
          height: 55,
          child: Center(
              child: Text(label, style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold))),
        ),
      ),
    );
  }

  void _number(String n) {
    if (sN1.isEmpty || operacion.isEmpty) {
      if (sN1 == '0') {
        sN1 = '';
      }
      if (_checkMaxNumer(sN1 + n)) {
        sN1 += n;
        sres = sN1;
      }
    } else {
      if (sN2 == '0') {
        sN2 = '';
      }
      if (_checkMaxNumer(sN2 + n)) {
        sN2 += n;
        sres += n;
      }
    }
    _checkResultado();
    setState(() {});
  }

  bool _checkMaxNumer(String n) {
    if (n.contains('.')) {
      List<String> parts = n.split('.');
      if (parts[0].length > 4 || parts[1].length > 4) {
        return false;
      }
    } else {
      if (n.length > 4) {
        return false;
      }
    }
    return true;
  }

  void _point() {
    if (sN1.isNotEmpty && operacion.isEmpty) {
      if (!sN1.contains('.')) {
        sN1 += '.';
        sres = sN1;
      }
    } else {
      if (sN2.isNotEmpty && !sN2.contains('.')) {
        sN2 += '.';
        sres += '.';
      }
    }
    _checkResultado();
    setState(() {});
  }

  void _symbol(String s) {
    if (sN1.isEmpty) return;
    if (operacion.isNotEmpty) {
      _calculate();
    }
    sres = sres.replaceAll(operacion, '');
    operacion = s;
    if (!sres.contains(operacion)) {
      sres += operacion;
    }
    setState(() {});
  }

  void _percentage() {
    if (sN1.isEmpty || sN2.isEmpty) return;
    if (operacion != '-' && operacion != '+') return;
    double n1 = double.parse(sN1);
    double n2 = double.parse(sN2);
    double res = 0;
    if (operacion == '-') {
      res = n1 - (n1 * n2 / 100);
    } else {
      res = n1 + (n1 * n2 / 100);
    }
    resultado = res;
    sN1 = _hasNoDecimal(resultado) ? resultado.toStringAsFixed(0) : resultado.toStringAsFixed(2);
    sN2 = '';
    sres = sN1;
    widget.onResult.call(resultado);
    setState(() {});
  }

  void _calculate() {
    if (sN1.isEmpty || sN2.isEmpty || operacion.isEmpty) return;
    double n1 = double.parse(sN1);
    double n2 = double.parse(sN2);
    switch (operacion) {
      case '/':
        resultado = n1 / n2;
        break;
      case 'x':
        resultado = n1 * n2;
        break;
      case '-':
        resultado = n1 - n2;
        break;
      case '+':
        resultado = n1 + n2;
        break;
    }
    if (resultado == double.infinity) {
      resultado = 0;
    }
    //operacion = '';
    sN1 = _hasNoDecimal(resultado) ? resultado.toStringAsFixed(0) : resultado.toStringAsFixed(2);
    sN2 = '';
    sres = sN1;
    widget.onResult.call(resultado);
    setState(() {});
  }

  void _remove() {
    if (sN1.length > 1) {
      sN1 = sN1.substring(0, sN1.length - 1);
      sres = sN1;
    } else {
      sN1 = '0';
      sres = sN1;
    }
    _checkResultado();
    setState(() {});
  }

  bool _hasNoDecimal(double number) {
    return number == number.truncate();
  }

  void _checkResultado() {
    if (sN1.isNotEmpty && operacion.isEmpty) {
      resultado = double.parse(sN1);
      widget.onResult.call(resultado);
    }
  }
}
