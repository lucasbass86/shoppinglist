import 'package:flutter/material.dart';
import 'package:shoppinglist/providers/main_provider.dart';
import 'package:shoppinglist/utils/utils.dart';
import 'package:shoppinglist/widgets/_widgets.dart';

class HelpPage extends StatelessWidget {
  static const String routeName = 'HelpPage';
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          BackgroundWidget(),
          Column(
            children: [
              TopWidget(showBack: true, title: 'Ayuda', showCart: false, showExit: true),
              Expanded(
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        _HelpWidget(
                            title: 'Productos',
                            message:
                                '''En esta ventana aparecerá la lista de productos introducidos.
Se puede dar de alta un producto indicando el NOMBRE, DETALLE y TIPO. Para guardarlo es necesario pulsar el ICONO GUARDAR.
Indicando el texto en el cuado BUSCAR, se buscarán los productos coincidentes.
Se pueden organizar alfabéticamente, por tipo y por frecuencia de uso.
Pulsando el ICONO CALENDARIO, se abrirá la página de previsiones.
Arrastrando la imagen del producto hacia el carrito, se añadirá a este, indicando previamente la tienda junto con la cantidad.
También se puede añadir pulsando sobre el ICONO MAS e indicando la tienda y la cantidad.
Pulsanso sobre el PRODUCTO, se abrirá la ventana de detalle.
Contiene la siguiente información:
- Arrastrando la imagen se podrá añadir al carrito.
- Manteniendo pulsado, se agregará una unidad del producto al carrito de la última tienda seleccionada.
- Pulsando ICONO LAPIZ, se puede editar el NOMBRE, DETALLE y TIPO del producto.
- Con el ICONO PAPELERA, se borrará definitivamente el producto (mientras no tenga otros datos asociados).
- Pulsando el ICONO EURO, se indicará el precio en la tienda elegida.
- Con el ICONO CESTA, se agregará al carrito con la tienda indicada.
- En el contenedor de la parte inferior saldrán todos los precios guardados en las tiendas indicadas.
- Se podrá editar el precio indicado de dicha tienda y agregar al carrito.
- Para borrar el precio asociado deslizando el producto hacia la derecha.
- Se muestra estadísticas de los precios en las distintas tiendas (con opción de mostrar u ocultar la leyenda). O una lista agrupando la información por tienda.
- Sale un histórico de las veces que se ha comprado el producto. Con la opción de agrupar por tienda.
- En GRAFICA, se indican dos tipos de gráficas junto con un listado de importes y cantidades compradas del producto. Con opción de filtrar por año y/o tienda.
                    '''),
                        _HelpWidget(
                            title: 'Tiendas',
                            message: '''En este apartado saldrán todas las tiendas dadas de alta.
Se podrá crear una tienda nueva pulsando el ICONO MAS.
Será necesario indicar el nombre de la tienda nueva.
En el apartado BUSCAR, indicando el texto se buscarán las tiendas que coincidan con lo indicado.
Pulsado en una tienda, saldrá la siguiente información:
- Con el ICONO LAPIZ, se podrá modificar el nombre de la tienda.
- Con el ICONO PAPELERA, se borrará la tienda con todos los precios asociados. 
- Con el ICONO EURO, eligiendo un producto y el precio se guardará la información en la tienda elegida.
- En la parte inferior saldrán todos los productos con sus precios indicados.
- Se podrá añadir al carrito y modificar el precio.
- Para borrar el precio asociado deslizando el producto hacia la derecha.
- Se muestra una estadística de evolución de precios.
- En el apartado HISTORIAL, se indicarán todas las compras realizadas en la tienda. Con la opción de agrupar por PRODUCTO o FECHA.
- En GRAFICA, se indican dos tipos de gráficas junto con un listado de importes y cantidades de productos comprados en la tienda. Con opción de filtrar por año o mostrar todos los productos comprados.
- Pinchando en producto, abriremos dicha ficha.
'''),
                        _HelpWidget(
                            title: 'Cesta',
                            message:
                                '''Aquí se indicarán todos los productos a comprar agrupado por TIENDA.
Pulsando el ICONO CALENDARIO, se abrirá la página de previsiones.
Dentro de cada producto arriba a la izquierda mostrará un número con la cantidad a comprar.
Pulsando la cantidad, se sumará una unidad a la cantidad existente.
Pulsado el ICONO PAPELERA, borrará de una en una las cantidades del producto elegido. Manteniendo pulsado, se borrarán todas las unidades.
Arrastrando elproducto al NOMBRE de una tienda, se cambiará a dicha tienda.
También se puede cambiar arrastrando al carrito que aparecerá en la parte inferior izquierda.
Abajo se indicará el precio total de la tienda elegida. Si se pulsa, sale el detalle de los productos con las unidades, el precio unitario
asignado en la tienda (en el caso de tenerlo) y el total.
Pulsando el ICONO PAPELERA DEFINITIVO, borrará los productos de la tienda actual del carrito.
Se puede desplazar de tienda en tienda pulsando sobre el NOMBRE o deslizando horizontalmente.
Cuando se pulse sobre cada producto, se guardará un histórico.'''),
                        _HelpWidget(
                            title: 'Previsión',
                            message:
                                '''En esta ventana, accesible desde PRODUCTOS y CARRITO, se mostrará una lista de productos ordenados por fecha prevista de compra. Indicando la tienda y la cantidad recomendada.
Se podrá añadir al carrito pulsando el ICONO "+" o arrastrando la imagen del producto hacia abajo dendro del carrito que se mostrará.
Se agregará al carrito de la tienda recomendada con la cantidad indicada.
Desde los tres puntos en la parte derecha se puede ocultar el producto para que no salga en la previsión (por si es un producto de temporada, por ejemplo).
Los días de previsión se pueden modificar desde la configuración.
En la parte superior, en el primer icono, se mostrará una página con los productos ocultados.

La ventana de Ocultos, mostrará todos los productos que se han ocultado de la previsión.
Pulsando sobre el icono OJO, el producto volverá a aparecer en las listas de previsiones.'''),
                        _HelpWidget(
                            title: 'Historial',
                            message: '''- Aquí aparecerán todas las compras que se han realizado.
- Se podrá organizar por producto, tienda, fecha o de manera genérica, todos los datos sin agrupar.
- Haciendo tap en el elemento, se podrá abrir dicho detalle.'''),
                        _HelpWidget(
                            title: 'Usuario',
                            message: '''- En esta página se podrán realizar copias de seguriad.
- Poniendo el correo electrónico, se podrá guardar en la nube.
- Se podrá guardar e importar desde un archivo.'''),
                        _HelpWidget(
                            title: 'Configuración',
                            message: '''- El TEMA cambiará los colores de la aplicación.
- Ordenar por tiendas, ofrece la posibilidad de cuando se va a añadir un producto, el listado de tiendas salga ordenado por el número de compras de ese producto por tienda o por el nombre.
- Días de previsión sirve para que en la pantalla de previsión, calcule con posibilidad de días anteriores según el número indicado.
- Deshacer el carrito es para cuando borro o compro un producto, ofrezca la oportunidad de deshacer el movimiento.
- Avisar precio más barato es para que cuando agreguemos un producto al carrito de una determinada tienda, nos avise si otra tienda tiene el precio más barato.
- Al añadír, borrar búsqueda significa que en el listado de productos cuando se busca desde el cuadro y se añade
un producto eligiendo la tienda al carrito, borra la búsqueda para mostrar el listado completo en lugar del resultado de la búsqueda.
- Borrar datos, borrará los datos marcados.'''),
                        _HelpWidget(
                            title: 'General',
                            message:
                                '''- Pulsando el ICONO ATRAS o el título, navega a la ventana anterior.
- El icono superior derecho puede tener la función de mostrar el carrito o salir del programa.'''),
                        _HelpWidget(
                          title: 'Cambios en la actualización',
                          message: '''
- Correcciones de informes.
''',
                          justify: false,
                          showExclamation: true,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HelpWidget extends StatelessWidget {
  final String title;
  final String message;
  final bool justify;
  final bool showExclamation;
  const _HelpWidget(
      {required this.title,
      required this.message,
      this.justify = true,
      this.showExclamation = false});

  @override
  Widget build(BuildContext context) {
    MainProvider mainProvider = Provider.of<MainProvider>(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      child: ExpansionTile(
        backgroundColor: Utils.claro,
        leading:
            !mainProvider.updateView && showExclamation ? Icon(Icons.info_outline_rounded) : null,
        title: Text(title, style: mainProvider.titleStyle.copyWith(fontSize: 20)),
        childrenPadding: const EdgeInsets.all(10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(20)),
        showTrailingIcon: true,
        collapsedBackgroundColor: Utils.claro,
        collapsedIconColor: Utils.oscuro,
        iconColor: Utils.oscuro,
        collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(20)),
        children: [
          SizedBox(
            width: double.infinity,
            child: Text(
              message,
              textAlign: justify ? TextAlign.justify : TextAlign.left,
            ),
          )
        ],
        onExpansionChanged: (value) {
          if (showExclamation) {
            mainProvider.updateView = true;
          }
        },
      ),
    );
  }
}
