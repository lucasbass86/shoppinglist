import 'package:shared_preferences/shared_preferences.dart';
import 'package:shoppinglist/utils/enums.dart';

class Preferences {
  static late SharedPreferences _prefs;
  static const String _sWelcomePage = 'WelcomePage';
  static const String _sTutorialPage = 'TutorialPage';
  static const String _sTutorialCrearTienda = 'TutorialCrearTienda';
  static const String _sTutorialCrearProducto = 'TutorialCrearProducto';
  static const String _sTutorialVisitarCarrito = 'TutorialVisitarCarrito';
  static const String _sTutorialVisitarConfiguracion = 'TutorialVisitarConfiguracion';
  static const String _sTheme = 'theme';
  static const String _sAvisoBarato = 'avisoBarato';
  static const String _sUpdateView = 'updateView';
  static const String _sBorrarBusqueda = 'borrarBusqueda';
  static const String _sSelectedShopID = 'selectedShopID';
  static const String _sShowLegend = 'showLegend';
  static const String _sIsViewGraphic = 'isViewGraphic';
  static const String _sEmail = 'email';
  static const String _sPassBackUp = 'passBackUp';
  static const String _sbackUp = 'backUp';
  static const String _sOrder = 'order';
  static const String _sTypeHistory = 'typeHistory';
  static const String _sTypeShoppings = 'typeShoppings';
  static const String _sTypePrices = 'typePrices';
  static const String _sShopHistoryGroup = 'shopHistoryGroup';

  static const String _sLicense = 'license';
  static String _license = '';
  static String get license => _prefs.getString(_sLicense) ?? _license;
  static set license(String value) {
    _license = value;
    _prefs.setString(_sLicense, value);
  }

  /*MANTENIMIENTOS*/

  static const String _smaintenanceIdCartOrder = 'maintenanceIdCartOrder';
  static bool _maintenanceIdCartOrder = false;
  static bool get maintenanceIdCartOrder =>
      _prefs.getBool(_smaintenanceIdCartOrder) ?? _maintenanceIdCartOrder;
  static set maintenanceIdCartOrder(_) {
    _maintenanceIdCartOrder = true;
    _prefs.setBool(_smaintenanceIdCartOrder, _maintenanceIdCartOrder);
  }

  static Future init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static ETypeHistory _typeHistory = ETypeHistory.prices;
  static ETypeHistory get typeHistory {
    final name = _prefs.getString(_sTypeHistory) ?? _typeHistory;
    return ETypeHistory.values.firstWhere(
      (t) => t.name == name,
      orElse: () => ETypeHistory.prices,
    );
  }

  static set typeHistory(ETypeHistory type) {
    _typeHistory = type;
    _prefs.setString(_sTypeHistory, type.name);
  }

  static ETypeShoppings _typeShoppings = ETypeShoppings.nogroup;
  static ETypeShoppings get typeShoppings {
    final name = _prefs.getString(_sTypeShoppings) ?? _typeShoppings;
    return ETypeShoppings.values.firstWhere(
      (t) => t.name == name,
      orElse: () => ETypeShoppings.nogroup,
    );
  }

  static set typeShoppings(ETypeShoppings type) {
    _typeShoppings = type;
    _prefs.setString(_sTypeShoppings, type.name);
  }

  static ShopHistoryGroup _typeShopHistoryGroup = ShopHistoryGroup.nogroup;
  static ShopHistoryGroup get typeShopHistoryGroup {
    final name = _prefs.getString(_sShopHistoryGroup) ?? _typeShopHistoryGroup;
    return ShopHistoryGroup.values.firstWhere(
      (t) => t.name == name,
      orElse: () => ShopHistoryGroup.nogroup,
    );
  }

  static set typeShopHistoryGroup(ShopHistoryGroup type) {
    _typeShopHistoryGroup = type;
    _prefs.setString(_sShopHistoryGroup, type.name);
  }

  static ETypePrices _typePrices = ETypePrices.byProduct;
  static ETypePrices get typePrices {
    final name = _prefs.getString(_sTypePrices) ?? _typePrices;
    return ETypePrices.values.firstWhere(
      (t) => t.name == name,
      orElse: () => ETypePrices.byProduct,
    );
  }

  static set typePrices(ETypePrices order) {
    _typePrices = order;
    _prefs.setString(_sTypePrices, order.name);
  }

  static EOrderType _order = EOrderType.az;
  static EOrderType get orderType {
    final name = _prefs.getString(_sOrder) ?? _order;
    return EOrderType.values.firstWhere(
      (t) => t.name == name,
      orElse: () => EOrderType.az,
    );
  }

  static set orderType(EOrderType order) {
    _order = order;
    _prefs.setString(_sOrder, order.name);
  }

  static String _backUp = '';
  static String get backUp => _prefs.getString(_sbackUp) ?? _backUp;
  static set backUp(String value) {
    _backUp = value;
    _prefs.setString(_sbackUp, _backUp);
  }

  static String _email = '';
  static String get email => _prefs.getString(_sEmail) ?? _email;
  static set email(String value) {
    _email = value;
    _prefs.setString(_sEmail, value);
  }

  static String _passBackUp = '';
  static String get passBackUp => _prefs.getString(_sPassBackUp) ?? _passBackUp;
  static set passBackUp(String value) {
    _passBackUp = value;
    _prefs.setString(_sPassBackUp, value);
  }

  static bool _showLegend = true;
  static bool get showLegend => _prefs.getBool(_sShowLegend) ?? _showLegend;
  static set showLegend(bool value) {
    _showLegend = value;
    _prefs.setBool(_sShowLegend, value);
  }

  static bool _isViewGraphic = true;
  static bool get isViewGraphic => _prefs.getBool(_sIsViewGraphic) ?? _isViewGraphic;
  static set isViewGraphic(bool value) {
    _isViewGraphic = value;
    _prefs.setBool(_sIsViewGraphic, value);
  }

  static int _selectedShopID = -100;
  static int get selectedShopID {
    return _prefs.getInt(_sSelectedShopID) ?? _selectedShopID;
  }

  static set selectedShopID(int id) {
    _selectedShopID = id;
    _prefs.setInt(_sSelectedShopID, id);
  }

  static bool _welcomePage = false;

  static bool get welcomePage {
    return _prefs.getBool(_sWelcomePage) ?? _welcomePage;
  }

  static set welcomePage(bool value) {
    _welcomePage = value;
    _prefs.setBool(_sWelcomePage, value);
  }

  static bool _tutorialPage = false;

  static bool get tutorialPage {
    return _prefs.getBool(_sTutorialPage) ?? _tutorialPage;
  }

  static set tutorialPage(bool value) {
    _tutorialPage = value;
    _prefs.setBool(_sTutorialPage, value);
  }

  static bool _tutorialCrearTienda = false;

  static bool get tutorialCrearTienda {
    return _prefs.getBool(_sTutorialCrearTienda) ?? _tutorialCrearTienda;
  }

  static set tutorialCrearTienda(bool value) {
    _tutorialCrearTienda = value;
    _prefs.setBool(_sTutorialCrearTienda, value);
  }

  static bool _tutorialCrearProducto = false;

  static bool get tutorialCrearProducto {
    return _prefs.getBool(_sTutorialCrearProducto) ?? _tutorialCrearProducto;
  }

  static set tutorialCrearProducto(bool value) {
    _tutorialCrearProducto = value;
    _prefs.setBool(_sTutorialCrearProducto, value);
  }

  static bool _tutorialVisitarCarrito = false;

  static bool get tutorialVisitarCarrito {
    return _prefs.getBool(_sTutorialVisitarCarrito) ?? _tutorialVisitarCarrito;
  }

  static set tutorialVisitarCarrito(bool value) {
    _tutorialVisitarCarrito = value;
    _prefs.setBool(_sTutorialVisitarCarrito, value);
  }

  static bool _tutorialVisitarConfiguracion = false;

  static bool get tutorialVisitarConfiguracion {
    return _prefs.getBool(_sTutorialVisitarConfiguracion) ?? _tutorialVisitarConfiguracion;
  }

  static set tutorialVisitarConfiguracion(bool value) {
    _tutorialVisitarConfiguracion = value;
    _prefs.setBool(_sTutorialVisitarConfiguracion, value);
  }

  static int _theme = 3;
  static int get theme {
    return _prefs.getInt(_sTheme) ?? _theme;
  }

  static set theme(int value) {
    _theme = value;
    _prefs.setInt(_sTheme, value);
  }

  static const bool _borrarBusqueda = true;
  static bool get borrarBusqueda {
    return _prefs.getBool(_sBorrarBusqueda) ?? _borrarBusqueda;
  }

  static set borrarBusqueda(bool value) {
    _prefs.setBool(_sBorrarBusqueda, value);
  }

  static bool _avisoBarato = true;
  static bool get avisoBarato {
    return _prefs.getBool(_sAvisoBarato) ?? _avisoBarato;
  }

  static set avisoBarato(bool value) {
    _avisoBarato = value;
    _prefs.setBool(_sAvisoBarato, value);
  }

  static bool _updateView = false;
  static bool get updateView {
    return _prefs.getBool(_sUpdateView) ?? _updateView;
  }

  static set updateView(bool value) {
    _updateView = value;
    _prefs.setBool(_sUpdateView, value);
  }

  static const String _sisOrderShopByName = 'isOrderShopByName';
  static bool _isOrderShopByName = true;
  static bool get isOrderShopByName => _prefs.getBool(_sisOrderShopByName) ?? _isOrderShopByName;
  static set isOrderShopByName(bool value) {
    _isOrderShopByName = value;
    _prefs.setBool(_sisOrderShopByName, value);
  }

  static const String _sGroupByShop = 'groupByShop';
  static bool _groupByShop = false;
  static bool get groupByShop => _prefs.getBool(_sGroupByShop) ?? _groupByShop;
  static set groupByShop(bool value) {
    _groupByShop = value;
    _prefs.setBool(_sGroupByShop, value);
  }

  static const String _sForecastDays = 'forecastDays';
  static int _forecastDays = 0;
  static int get forecastDays => _prefs.getInt(_sForecastDays) ?? _forecastDays;
  static set forecastDays(int value) {
    _forecastDays = value;
    _prefs.setInt(_sForecastDays, value);
  }

  static const String _sDeshacer = 'deshacer';
  static bool _deshacer = false;
  static bool get deshacer => _prefs.getBool(_sDeshacer) ?? _deshacer;
  static set deshacer(bool value) {
    _deshacer = value;
    _prefs.setBool(_sDeshacer, value);
  }

  static const String _sProductTabIndex = 'productTabIndex';
  static EProductView _productTabIndex = EProductView.prices;
  static EProductView get productTabIndex {
    int val = _prefs.getInt(_sProductTabIndex) ?? EProductView.prices.index;
    _productTabIndex = EProductView.values[val];
    return _productTabIndex;
  }

  static set productTabIndex(EProductView value) {
    _productTabIndex = value;
    _prefs.setInt(_sProductTabIndex, value.index);
  }

  static const String _sGraphicByAmount = 'graphicByAmount';
  static bool _graphicByAmount = true;
  static bool get graphicByAmount => _prefs.getBool(_sGraphicByAmount) ?? _graphicByAmount;
  static set graphicByAmount(bool value) {
    _graphicByAmount = value;
    _prefs.setBool(_sGraphicByAmount, value);
  }

  static const String _sGraphicShopGeneralOrder = 'graphicShopGeneralOrder';
  static EOrderGraphic _graphicShopGeneralOrder = EOrderGraphic.descendingMonth;
  static EOrderGraphic get graphicShopGeneralOrder {
    int val = _prefs.getInt(_sGraphicShopGeneralOrder) ?? EOrderGraphic.descendingMonth.index;
    _graphicShopGeneralOrder = EOrderGraphic.values[val];
    return _graphicShopGeneralOrder;
  }

  static set graphicShopGeneralOrder(EOrderGraphic value) {
    _graphicShopGeneralOrder = value;
    _prefs.setInt(_sGraphicShopGeneralOrder, value.index);
  }

  static const String _sGraphicShopProductOrder = 'graphicShopProductOrder';
  static EOrderGraphicByProduct _graphicShopProductOrder = EOrderGraphicByProduct.name;
  static EOrderGraphicByProduct get graphicShopProductOrder {
    int val = _prefs.getInt(_sGraphicShopProductOrder) ?? EOrderGraphicByProduct.name.index;
    _graphicShopProductOrder = EOrderGraphicByProduct.values[val];
    return _graphicShopProductOrder;
  }

  static set graphicShopProductOrder(EOrderGraphicByProduct value) {
    _graphicShopProductOrder = value;
    _prefs.setInt(_sGraphicShopProductOrder, value.index);
  }

  static const String _sGraphicProductGeneralOrder = 'graphicProductGeneralOrder';
  static EOrderGraphic _graphicProductGeneralOrder = EOrderGraphic.descendingMonth;
  static EOrderGraphic get graphicProductGeneralOrder {
    int val = _prefs.getInt(_sGraphicProductGeneralOrder) ?? EOrderGraphic.descendingMonth.index;
    _graphicProductGeneralOrder = EOrderGraphic.values[val];
    return _graphicProductGeneralOrder;
  }

  static set graphicProductGeneralOrder(EOrderGraphic value) {
    _graphicProductGeneralOrder = value;
    _prefs.setInt(_sGraphicProductGeneralOrder, value.index);
  }

  static const String _sShopTypeGraphic = 'shopTypeGraphic';
  static ETypeGraphic _shopTypeGraphic = ETypeGraphic.general;
  static ETypeGraphic get shopTypeGraphic {
    int val = _prefs.getInt(_sShopTypeGraphic) ?? ETypeGraphic.general.index;
    _shopTypeGraphic = ETypeGraphic.values[val];
    return _shopTypeGraphic;
  }

  static set shopTypeGraphic(ETypeGraphic value) {
    _shopTypeGraphic = value;
    _prefs.setInt(_sShopTypeGraphic, value.index);
  }

  static const String _sShowForecastOnRun = 'showForecastOnRun';
  static bool _showForecastOnRun = false;
  static bool get showForecastOnRun => _prefs.getBool(_sShowForecastOnRun) ?? _showForecastOnRun;

  static set showForecastOnRun(bool value) {
    _showForecastOnRun = value;
    _prefs.setBool(_sShowForecastOnRun, value);
  }
}
