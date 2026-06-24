import 'package:flutter/material.dart';

enum EOrderNoGroup { fechaAsc, fechaDesc, precioAsc, precioDesc, cantidadAsc, cantidadDesc }

extension EOrderNoGroupExtension on EOrderNoGroup {
  String displayName() {
    switch (this) {
      case EOrderNoGroup.fechaAsc:
        return 'FECHA ASC';
      case EOrderNoGroup.fechaDesc:
        return 'FECHA DESC';
      case EOrderNoGroup.precioAsc:
        return 'PRECIO ASC';
      case EOrderNoGroup.precioDesc:
        return 'PRECIO DESC';
      case EOrderNoGroup.cantidadAsc:
        return 'CANTIDAD ASC';
      case EOrderNoGroup.cantidadDesc:
        return 'CANTIDAD DESC';
    }
  }
}

enum EMonth {
  enero,
  febrero,
  marzo,
  abril,
  mayo,
  junio,
  julio,
  agosto,
  septiembre,
  octubre,
  noviembre,
  diciembre,
  todos,
}

extension EMonthExtension on EMonth {
  String displayName() {
    switch (this) {
      case EMonth.enero:
        return 'ENERO';
      case EMonth.febrero:
        return 'FEBRERO';
      case EMonth.marzo:
        return 'MARZO';
      case EMonth.abril:
        return 'ABRIL';
      case EMonth.mayo:
        return 'MAYO';
      case EMonth.junio:
        return 'JUNIO';
      case EMonth.julio:
        return 'JULIO';
      case EMonth.agosto:
        return 'AGOSTO';
      case EMonth.septiembre:
        return 'SEPTIEMBRE';
      case EMonth.octubre:
        return 'OCTUBRE';
      case EMonth.noviembre:
        return 'NOVIEMBRE';
      case EMonth.diciembre:
        return 'DICIEMBRE';
      case EMonth.todos:
        return 'TODOS';
    }
  }

  int monthNumber() {
    switch (this) {
      case EMonth.enero:
        return 1;
      case EMonth.febrero:
        return 2;
      case EMonth.marzo:
        return 3;
      case EMonth.abril:
        return 4;
      case EMonth.mayo:
        return 5;
      case EMonth.junio:
        return 6;
      case EMonth.julio:
        return 7;
      case EMonth.agosto:
        return 8;
      case EMonth.septiembre:
        return 9;
      case EMonth.octubre:
        return 10;
      case EMonth.noviembre:
        return 11;
      case EMonth.diciembre:
        return 12;
      case EMonth.todos:
        return -1;
    }
  }
}

enum ETypeGraphic { general, product }

extension ETypeGraphicExtension on ETypeGraphic {
  String displayName() {
    switch (this) {
      case ETypeGraphic.general:
        return 'GENERAL';
      case ETypeGraphic.product:
        return 'PRODUCTO';
    }
  }
}

enum EOrderShop { name, use }

extension EOrderShopExtension on EOrderShop {
  String displayName() {
    switch (this) {
      case EOrderShop.name:
        return 'Nombre';
      case EOrderShop.use:
        return 'Uso';
    }
  }
}

enum EOrderGraphic { ascendingMonth, descendingMonth, amountAsc, amountDesc }

extension EOrderGraphicExtension on EOrderGraphic {
  String displayName() {
    switch (this) {
      case EOrderGraphic.ascendingMonth:
        return 'Mes Asc';
      case EOrderGraphic.descendingMonth:
        return 'Mes Desc';
      case EOrderGraphic.amountAsc:
        return 'Importe Asc';
      case EOrderGraphic.amountDesc:
        return 'Importe Desc';
    }
  }
}

enum EOrderGraphicByProduct { name, usedAscending, usedDescending }

extension EOrderGraphicByProductExtension on EOrderGraphicByProduct {
  String displayName() {
    switch (this) {
      case EOrderGraphicByProduct.name:
        return 'Nombre';
      case EOrderGraphicByProduct.usedAscending:
        return 'Uso Asc';
      case EOrderGraphicByProduct.usedDescending:
        return 'Uso Desc';
    }
  }
}

enum ETypeHistory { shoppings, prices }

extension ETypeHistoryExtension on ETypeHistory {
  String displayName() {
    switch (this) {
      case ETypeHistory.shoppings:
        return 'COMPRAS';
      case ETypeHistory.prices:
        return 'PRECIOS';
    }
  }
}

enum ShopHistoryGroup { nogroup, byProduct, byDate, byShopping }

extension ShopHistoryGroupExtension on ShopHistoryGroup {
  String displayName() {
    switch (this) {
      case ShopHistoryGroup.nogroup:
        return 'SIN AGRUPAR';
      case ShopHistoryGroup.byProduct:
        return 'POR PRODUCTO';
      case ShopHistoryGroup.byDate:
        return 'POR FECHAS';
      case ShopHistoryGroup.byShopping:
        return 'POR COMPRA';
    }
  }
}

enum ETypeShoppings { nogroup, byProduct, /* byDate,*/ byShop, byCart, total }

extension ETypeShoppingsExtension on ETypeShoppings {
  String displayName() {
    switch (this) {
      case ETypeShoppings.nogroup:
        return 'SIN AGRUPAR';
      case ETypeShoppings.byProduct:
        return 'POR PRODUCTO';
      // case ETypeShoppings.byDate:
      //   return 'POR FECHA';
      case ETypeShoppings.byShop:
        return 'POR TIENDA';
      case ETypeShoppings.byCart:
        return 'POR CARRITO';
      case ETypeShoppings.total:
        return 'TOTAL';
    }
  }
}

enum ETypePrices { byProduct, byShop }

extension ETypePricesExtension on ETypePrices {
  String displayName() {
    switch (this) {
      case ETypePrices.byProduct:
        return 'POR PRODUCTO';
      case ETypePrices.byShop:
        return 'POR TIENDA';
    }
  }
}

enum ETypeHistoryGroup { shop, product, date, shopDate, cart }

enum ESearchType { productos, tiendas }

enum EOrderType { az, za, taz, tza, used }

extension EOrderTypeExtension on EOrderType {
  String displayName() {
    switch (this) {
      case EOrderType.az:
        return 'A-Z';
      case EOrderType.za:
        return 'Z-A';
      case EOrderType.taz:
        return 'TIPO A-Z';
      case EOrderType.tza:
        return 'TIPO Z-A';
      case EOrderType.used:
        return 'MÁS USADOS';
    }
  }
}

enum EModificationType { price, quantity, shop, shopping, delete, rename }

extension EModificationTypeExtension on EModificationType {
  String displayName() {
    switch (this) {
      case EModificationType.price:
        return 'Precio';
      case EModificationType.quantity:
        return 'Cantidad';
      case EModificationType.shop:
        return 'Tienda';
      case EModificationType.shopping:
        return 'Comprado';
      case EModificationType.delete:
        return 'Borrar';
      case EModificationType.rename:
        return 'Renombrar';
    }
  }
}

enum EProductView { prices, estatistics, history, graphics }

enum ETheme { verde, natural, dark, azul }

enum EImageType {
  todo,
  aceite,
  agua,
  arroz,
  azucar,
  banana,
  bebidaVegetal,
  bio,
  bombilla,
  cafe,
  carne,
  cereales,
  cerveza,
  champu,
  chocolate,
  conserva,
  crema,
  cremaCacao,
  cremaFacial,
  dulces,
  embutidos,
  encurtidos,
  especias,
  fresa,
  fruta,
  frutosSecos,
  genBanio,
  genBebe,
  genBicicleta,
  genCoche,
  genCocina,
  genComedor,
  genCongelados,
  genHabitacion,
  genPlanta,
  genProducto,
  genTaller,
  hamburguesa,
  harina,
  helado,
  huevos,
  leche,
  limpieza,
  matcha,
  mantequilla,
  maquillaje,
  medicina,
  mermelada,
  miel,
  molde,
  pan,
  papelHigienico,
  papeleria,
  pasta,
  pastaDientes,
  pescado,
  pila,
  piscina,
  pizza,
  proteina,
  queso,
  refresco,
  sal,
  salsa,
  semillas,
  snack,
  te,
  zumo,
  vela,
  verdura,
  vino,
  vitaminas,
  yogur,
  spray,
  clothes,
  shoes,
  aguacate,
  kettlebell,
  nachos,
  legumbres,
  watermelon,
  gazpacho,
  precocinado,
  croissant,
}

extension EImageTypeToString on EImageType {
  String nameToString() {
    return toString().split('.').last;
  }

  String displayName() {
    switch (this) {
      case EImageType.todo:
        return 'Todo';
      case EImageType.aceite:
        return 'Aceite';
      case EImageType.agua:
        return 'Agua';
      case EImageType.arroz:
        return 'Arroz';
      case EImageType.azucar:
        return 'Azúcar';
      case EImageType.banana:
        return 'Plátano';
      case EImageType.bebidaVegetal:
        return 'Bebida Vegetal';
      case EImageType.bio:
        return 'Bio';
      case EImageType.bombilla:
        return 'Bombilla';
      case EImageType.cafe:
        return 'Café';
      case EImageType.carne:
        return 'Carne';
      case EImageType.cereales:
        return 'Cereales';
      case EImageType.cerveza:
        return 'Cerveza';
      case EImageType.champu:
        return 'Champú';
      case EImageType.chocolate:
        return 'Chocolate';
      case EImageType.conserva:
        return 'Conserva';
      case EImageType.crema:
        return 'Crema';
      case EImageType.cremaCacao:
        return 'Crema Cacao';
      case EImageType.cremaFacial:
        return 'Crema Facial';
      case EImageType.dulces:
        return 'Dulce';
      case EImageType.embutidos:
        return 'Embutido';
      case EImageType.encurtidos:
        return 'Encurtido';
      case EImageType.especias:
        return 'Espepcia';
      case EImageType.fresa:
        return 'Fresa';
      case EImageType.fruta:
        return 'Fruta';
      case EImageType.frutosSecos:
        return 'Frutos Secos';
      case EImageType.genBanio:
        return 'Baño';
      case EImageType.genBebe:
        return 'Bebe';
      case EImageType.genBicicleta:
        return 'Bicicleta';
      case EImageType.genCoche:
        return 'Coche';
      case EImageType.genCocina:
        return 'Cocina';
      case EImageType.genComedor:
        return 'Comedor';
      case EImageType.genCongelados:
        return 'Congelados';
      case EImageType.genHabitacion:
        return 'Habitación';
      case EImageType.genPlanta:
        return 'Planta';
      case EImageType.genProducto:
        return 'Producto';
      case EImageType.genTaller:
        return 'Taller';
      case EImageType.hamburguesa:
        return 'Hamburguesa';
      case EImageType.harina:
        return 'Harina';
      case EImageType.helado:
        return 'Helado';
      case EImageType.huevos:
        return 'Huevos';
      case EImageType.leche:
        return 'Leche';
      case EImageType.limpieza:
        return 'Limpieza';
      case EImageType.matcha:
        return 'Matcha';
      case EImageType.mantequilla:
        return 'Mantequilla';
      case EImageType.maquillaje:
        return 'Maquillaje';
      case EImageType.medicina:
        return 'Medicina';
      case EImageType.mermelada:
        return 'Mermelada';
      case EImageType.miel:
        return 'Miel';
      case EImageType.molde:
        return 'Molde';
      case EImageType.pan:
        return 'Pan';
      case EImageType.papelHigienico:
        return 'Papel Higiénico';
      case EImageType.papeleria:
        return 'Papelería';
      case EImageType.pasta:
        return 'Pasta';
      case EImageType.pastaDientes:
        return 'Pasta Dientes';
      case EImageType.pescado:
        return 'Pescado';
      case EImageType.pila:
        return 'Pila';
      case EImageType.piscina:
        return 'Piscina';
      case EImageType.pizza:
        return 'Pizza';
      case EImageType.proteina:
        return 'Proteinas';
      case EImageType.queso:
        return 'Queso';
      case EImageType.refresco:
        return 'Refresco';
      case EImageType.sal:
        return 'Sal';
      case EImageType.salsa:
        return 'Salsa';
      case EImageType.semillas:
        return 'Semillas';
      case EImageType.snack:
        return 'Snack';
      case EImageType.te:
        return 'Te';
      case EImageType.zumo:
        return 'Zumo';
      case EImageType.vela:
        return 'Vela';
      case EImageType.verdura:
        return 'Verdura';
      case EImageType.vino:
        return 'Vino';
      case EImageType.vitaminas:
        return 'Vitaminas';
      case EImageType.yogur:
        return 'Yogur';
      case EImageType.spray:
        return 'Spray';
      case EImageType.clothes:
        return 'Ropa';
      case EImageType.shoes:
        return 'Zapatos';
      case EImageType.aguacate:
        return 'Aguacate';
      case EImageType.kettlebell:
        return 'Ejercicio';
      case EImageType.nachos:
        return 'Aperitivos';
      case EImageType.legumbres:
        return 'Legumbres';
      case EImageType.watermelon:
        return 'Sandía';
      case EImageType.gazpacho:
        return 'Gazpacho';
      case EImageType.precocinado:
        return 'Precocinado';
      case EImageType.croissant:
        return 'Croissant';
    }
  }

  ImageProvider image() {
    switch (this) {
      case EImageType.aceite:
        return Image.asset('assets/alimentacion/aceite.png').image;
      case EImageType.agua:
        return Image.asset('assets/alimentacion/agua.png').image;
      case EImageType.aguacate:
        return Image.asset('assets/alimentacion/aguacate.png').image;
      case EImageType.arroz:
        return Image.asset('assets/alimentacion/arroz.png').image;
      case EImageType.azucar:
        return Image.asset('assets/alimentacion/azucar.png').image;
      case EImageType.banana:
        return Image.asset('assets/alimentacion/banana.png').image;
      case EImageType.bebidaVegetal:
        return Image.asset('assets/alimentacion/bebidaVegetal.png').image;
      case EImageType.bio:
        return Image.asset('assets/alimentacion/bio.png').image;
      case EImageType.cafe:
        return Image.asset('assets/alimentacion/cafe.png').image;
      case EImageType.carne:
        return Image.asset('assets/alimentacion/carne.png').image;
      case EImageType.cereales:
        return Image.asset('assets/alimentacion/cereales.png').image;
      case EImageType.cerveza:
        return Image.asset('assets/alimentacion/cerveza.png').image;
      case EImageType.chocolate:
        return Image.asset('assets/alimentacion/chocolate.png').image;
      case EImageType.conserva:
        return Image.asset('assets/alimentacion/conserva.png').image;
      case EImageType.crema:
        return Image.asset('assets/alimentacion/crema.png').image;
      case EImageType.cremaCacao:
        return Image.asset('assets/alimentacion/cremaCacao.png').image;
      case EImageType.dulces:
        return Image.asset('assets/alimentacion/dulces.png').image;
      case EImageType.embutidos:
        return Image.asset('assets/alimentacion/embutidos.png').image;
      case EImageType.encurtidos:
        return Image.asset('assets/alimentacion/encurtidos.png').image;
      case EImageType.especias:
        return Image.asset('assets/alimentacion/especias.png').image;
      case EImageType.fresa:
        return Image.asset('assets/alimentacion/fresa.png').image;
      case EImageType.fruta:
        return Image.asset('assets/alimentacion/frutas.png').image;
      case EImageType.frutosSecos:
        return Image.asset('assets/alimentacion/frutosSecos.png').image;
      case EImageType.hamburguesa:
        return Image.asset('assets/alimentacion/hamburguesa.png').image;
      case EImageType.harina:
        return Image.asset('assets/alimentacion/harina.png').image;
      case EImageType.helado:
        return Image.asset('assets/alimentacion/helado.png').image;
      case EImageType.huevos:
        return Image.asset('assets/alimentacion/huevos.png').image;
      case EImageType.leche:
        return Image.asset('assets/alimentacion/leche.png').image;
      case EImageType.mantequilla:
        return Image.asset('assets/alimentacion/mantequilla.png').image;
      case EImageType.matcha:
        return Image.asset('assets/alimentacion/matcha.png').image;
      case EImageType.mermelada:
        return Image.asset('assets/alimentacion/mermelada.png').image;
      case EImageType.miel:
        return Image.asset('assets/alimentacion/miel.png').image;
      case EImageType.molde:
        return Image.asset('assets/alimentacion/molde.png').image;
      case EImageType.nachos:
        return Image.asset('assets/alimentacion/nachos.png').image;
      case EImageType.pan:
        return Image.asset('assets/alimentacion/pan.png').image;
      case EImageType.pasta:
        return Image.asset('assets/alimentacion/pasta.png').image;
      case EImageType.pescado:
        return Image.asset('assets/alimentacion/pescado.png').image;
      case EImageType.pizza:
        return Image.asset('assets/alimentacion/pizza.png').image;
      case EImageType.proteina:
        return Image.asset('assets/alimentacion/proteina.png').image;
      case EImageType.queso:
        return Image.asset('assets/alimentacion/queso.png').image;
      case EImageType.refresco:
        return Image.asset('assets/alimentacion/refresco.png').image;
      case EImageType.sal:
        return Image.asset('assets/alimentacion/sal.png').image;
      case EImageType.salsa:
        return Image.asset('assets/alimentacion/salsa.png').image;
      case EImageType.semillas:
        return Image.asset('assets/alimentacion/semillas.png').image;
      case EImageType.snack:
        return Image.asset('assets/alimentacion/barrita.png').image;
      case EImageType.te:
        return Image.asset('assets/alimentacion/te.png').image;
      case EImageType.verdura:
        return Image.asset('assets/alimentacion/verdura.png').image;
      case EImageType.vino:
        return Image.asset('assets/alimentacion/vino.png').image;
      case EImageType.vitaminas:
        return Image.asset('assets/alimentacion/vitaminas.png').image;
      case EImageType.yogur:
        return Image.asset('assets/alimentacion/yogur.png').image;
      case EImageType.zumo:
        return Image.asset('assets/alimentacion/zumo.png').image;
      case EImageType.legumbres:
        return Image.asset('assets/alimentacion/legumbres.png').image;
      case EImageType.watermelon:
        return Image.asset('assets/alimentacion/watermelon.png').image;
      case EImageType.gazpacho:
        return Image.asset('assets/alimentacion/gazpacho.png').image;
      case EImageType.precocinado:
        return Image.asset('assets/alimentacion/precocinado.png').image;
      case EImageType.croissant:
        return Image.asset('assets/alimentacion/croissant.png').image;

      case EImageType.bombilla:
        return Image.asset('assets/otros/bombilla.png').image;
      case EImageType.champu:
        return Image.asset('assets/otros/champu.png').image;
      case EImageType.cremaFacial:
        return Image.asset('assets/otros/cremaFacial.png').image;
      case EImageType.limpieza:
        return Image.asset('assets/otros/limpieza.png').image;
      case EImageType.maquillaje:
        return Image.asset('assets/otros/maquillaje.png').image;
      case EImageType.medicina:
        return Image.asset('assets/otros/medicina.png').image;
      case EImageType.papelHigienico:
        return Image.asset('assets/otros/papelHigienico.png').image;
      case EImageType.papeleria:
        return Image.asset('assets/otros/papeleria.png').image;
      case EImageType.pastaDientes:
        return Image.asset('assets/otros/pastaDientes.png').image;
      case EImageType.pila:
        return Image.asset('assets/otros/pila.png').image;
      case EImageType.piscina:
        return Image.asset('assets/otros/piscina.png').image;
      case EImageType.vela:
        return Image.asset('assets/otros/vela.png').image;
      case EImageType.spray:
        return Image.asset('assets/otros/spray.png').image;
      case EImageType.clothes:
        return Image.asset('assets/otros/clothes.png').image;
      case EImageType.shoes:
        return Image.asset('assets/otros/shoes.png').image;
      case EImageType.kettlebell:
        return Image.asset('assets/otros/kettlebell.png').image;

      case EImageType.genBanio:
        return Image.asset('assets/genericos/genBanio.png').image;
      case EImageType.genBebe:
        return Image.asset('assets/genericos/genBebe.png').image;
      case EImageType.genBicicleta:
        return Image.asset('assets/genericos/genBicicleta.png').image;
      case EImageType.genCoche:
        return Image.asset('assets/genericos/genCoche.png').image;
      case EImageType.genCocina:
        return Image.asset('assets/genericos/genCocina.png').image;
      case EImageType.genComedor:
        return Image.asset('assets/genericos/genComedor.png').image;
      case EImageType.genCongelados:
        return Image.asset('assets/genericos/genCongelados.png').image;
      case EImageType.genHabitacion:
        return Image.asset('assets/genericos/genHabitacion.png').image;
      case EImageType.genPlanta:
        return Image.asset('assets/genericos/genPlanta.png').image;
      case EImageType.genProducto:
      case EImageType.todo:
        return Image.asset('assets/genericos/genProducto.png').image;
      case EImageType.genTaller:
        return Image.asset('assets/genericos/genTaller.png').image;
    }
  }
}

enum EOrderHistory { date, name }

extension EOrderHistoryExtension on EOrderHistory {
  String displayName() {
    switch (this) {
      case EOrderHistory.date:
        return 'FECHA';
      case EOrderHistory.name:
        return 'NOMBRE';
    }
  }
}

enum EAscDesc { ascendent, descendent }

extension EAscDescExtension on EAscDesc {
  String displayName() {
    switch (this) {
      case EAscDesc.ascendent:
        return 'ASC';
      case EAscDesc.descendent:
        return 'DESC';
    }
  }
}
