import 'package:flutter/material.dart';
import 'package:shoppinglist/models/models.dart';
import 'package:shoppinglist/providers/main_provider.dart';
import 'package:shoppinglist/utils/enums.dart';
import 'package:shoppinglist/utils/utils.dart';
import 'package:shoppinglist/widgets/_widgets.dart';

class NewProductPage extends StatefulWidget {
  static const String routeName = 'NewProductPage';
  const NewProductPage({super.key});

  @override
  State<NewProductPage> createState() => _NewProductPageState();
}

class _NewProductPageState extends State<NewProductPage> {
  late MainProvider mainProvider;
  PageController pageController = PageController();
  ScrollController scrollController = ScrollController();
  TextEditingController nameController = TextEditingController();
  TextEditingController detailController = TextEditingController();
  bool isLoaded = false;
  Product? product;

  @override
  void dispose() {
    pageController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    mainProvider = Provider.of<MainProvider>(context, listen: false);

    if (ModalRoute.of(context)?.settings.arguments != null && !isLoaded) {
      product = ModalRoute.of(context)!.settings.arguments as Product;
      nameController.text = product!.name;
      mainProvider.selectedProductType = product!.imageType;
      detailController.text = product!.details;
      isLoaded = true;
    } else {
      if (mainProvider.searchText.isNotEmpty) {
        nameController.text = mainProvider.searchText;
      }
    }

    return Scaffold(
      floatingActionButton: _fab(context),
      body: Stack(
        children: [
          const BackgroundWidget(),
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            controller: scrollController,
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            slivers: [
              _appBar(),
              _sliverProductos(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _appBar() {
    return SliverAppBar(
      expandedHeight: 180,
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        background: Column(
          children: [
            TopWidget(
                showBack: true,
                title: '${product == null ? 'Nuevo' : 'Editando'} Producto',
                showCart: false),
            _name(),
          ],
        ),
      ),
    );
  }

  Widget _fab(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        if (nameController.text == '') {
          ScaffoldMessenger.of(context)
              .showSnackBar(Utils.snackBar('Falta el nombre', isGood: false));
        } else {
          if (product == null) {
            mainProvider.addEmptyProduct(nameController.text.trim(), detailController.text.trim(),
                mainProvider.selectedProductType /*, mainType*/);
          } else {
            product!.name = nameController.text.trim();
            product!.details = detailController.text.trim();
            product!.imageType = mainProvider.selectedProductType;
            mainProvider.updateProduct(product!);
          }
          mainProvider.searchText = '';
          ScaffoldMessenger.of(context).showSnackBar(
              Utils.snackBar('Producto ${product == null ? 'guardado' : 'modificado'}'));
          Navigator.pop(context);
        }
      },
      child: Icon(Icons.save, color: Utils.claro),
    );
  }

  Widget _name() {
    return Container(
      height: 100,
      margin: const EdgeInsets.only(left: 20, right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 45,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: TextFormField(
              controller: nameController,
              cursorColor: Utils.oscuro,
              style: mainProvider.itemStyle,
              decoration: InputDecoration(
                hintText: 'Nombre',
                hintStyle: TextStyle(fontSize: 15.0, color: Utils.medio),
                counterText: '',
              ),
              maxLength: 50,
              textCapitalization: TextCapitalization.words,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            height: 45,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: TextFormField(
              controller: detailController,
              cursorColor: Utils.oscuro,
              style: mainProvider.itemStyle,
              decoration: InputDecoration(
                hintText: 'Detalles',
                hintStyle: TextStyle(fontSize: 15.0, color: Utils.medio),
                counterText: '',
              ),
              maxLength: 150,
              textCapitalization: TextCapitalization.words,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sliverProductos() {
    return SliverGrid.count(
      crossAxisCount: 3,
      children: [
        const ProductTypeWidget(type: EImageType.aceite),
        const ProductTypeWidget(type: EImageType.agua),
        const ProductTypeWidget(type: EImageType.aguacate),
        const ProductTypeWidget(type: EImageType.arroz),
        const ProductTypeWidget(type: EImageType.azucar),
        const ProductTypeWidget(type: EImageType.banana),
        const ProductTypeWidget(type: EImageType.bebidaVegetal),
        const ProductTypeWidget(type: EImageType.bio),
        const ProductTypeWidget(type: EImageType.cafe),
        const ProductTypeWidget(type: EImageType.carne),
        const ProductTypeWidget(type: EImageType.cereales),
        const ProductTypeWidget(type: EImageType.cerveza),
        const ProductTypeWidget(type: EImageType.champu),
        const ProductTypeWidget(type: EImageType.chocolate),
        const ProductTypeWidget(type: EImageType.conserva),
        const ProductTypeWidget(type: EImageType.crema),
        const ProductTypeWidget(type: EImageType.cremaCacao),
        const ProductTypeWidget(type: EImageType.cremaFacial),
        const ProductTypeWidget(type: EImageType.croissant),
        const ProductTypeWidget(type: EImageType.dulces),
        const ProductTypeWidget(type: EImageType.embutidos),
        const ProductTypeWidget(type: EImageType.encurtidos),
        const ProductTypeWidget(type: EImageType.especias),
        const ProductTypeWidget(type: EImageType.fresa),
        const ProductTypeWidget(type: EImageType.fruta),
        const ProductTypeWidget(type: EImageType.frutosSecos),
        const ProductTypeWidget(type: EImageType.gazpacho),
        const ProductTypeWidget(type: EImageType.hamburguesa),
        const ProductTypeWidget(type: EImageType.harina),
        const ProductTypeWidget(type: EImageType.helado),
        const ProductTypeWidget(type: EImageType.huevos),
        const ProductTypeWidget(type: EImageType.leche),
        const ProductTypeWidget(type: EImageType.legumbres),
        const ProductTypeWidget(type: EImageType.limpieza),
        const ProductTypeWidget(type: EImageType.matcha),
        const ProductTypeWidget(type: EImageType.mantequilla),
        const ProductTypeWidget(type: EImageType.maquillaje),
        const ProductTypeWidget(type: EImageType.medicina),
        const ProductTypeWidget(type: EImageType.mermelada),
        const ProductTypeWidget(type: EImageType.miel),
        const ProductTypeWidget(type: EImageType.molde),
        const ProductTypeWidget(type: EImageType.nachos),
        const ProductTypeWidget(type: EImageType.pan),
        const ProductTypeWidget(type: EImageType.papeleria),
        const ProductTypeWidget(type: EImageType.papelHigienico),
        const ProductTypeWidget(type: EImageType.pasta),
        const ProductTypeWidget(type: EImageType.pastaDientes),
        const ProductTypeWidget(type: EImageType.pescado),
        const ProductTypeWidget(type: EImageType.pila),
        const ProductTypeWidget(type: EImageType.piscina),
        const ProductTypeWidget(type: EImageType.pizza),
        const ProductTypeWidget(type: EImageType.precocinado),
        const ProductTypeWidget(type: EImageType.proteina),
        const ProductTypeWidget(type: EImageType.queso),
        const ProductTypeWidget(type: EImageType.refresco),
        const ProductTypeWidget(type: EImageType.sal),
        const ProductTypeWidget(type: EImageType.salsa),
        const ProductTypeWidget(type: EImageType.semillas),
        const ProductTypeWidget(type: EImageType.shoes),
        const ProductTypeWidget(type: EImageType.snack),
        const ProductTypeWidget(type: EImageType.spray),
        const ProductTypeWidget(type: EImageType.te),
        const ProductTypeWidget(type: EImageType.vela),
        const ProductTypeWidget(type: EImageType.verdura),
        const ProductTypeWidget(type: EImageType.vino),
        const ProductTypeWidget(type: EImageType.vitaminas),
        const ProductTypeWidget(type: EImageType.watermelon),
        const ProductTypeWidget(type: EImageType.yogur),
        const ProductTypeWidget(type: EImageType.zumo),
        // Container(),
        Divider(color: Utils.oscuro, height: 5),
        Divider(color: Utils.oscuro, height: 5),
        Divider(color: Utils.oscuro, height: 5),
        const ProductTypeWidget(type: EImageType.bombilla),
        const ProductTypeWidget(type: EImageType.clothes),
        const ProductTypeWidget(type: EImageType.kettlebell),
        const ProductTypeWidget(type: EImageType.genBanio),
        const ProductTypeWidget(type: EImageType.genBebe),
        const ProductTypeWidget(type: EImageType.genBicicleta),
        const ProductTypeWidget(type: EImageType.genCoche),
        const ProductTypeWidget(type: EImageType.genCocina),
        const ProductTypeWidget(type: EImageType.genComedor),
        const ProductTypeWidget(type: EImageType.genCongelados),
        const ProductTypeWidget(type: EImageType.genHabitacion),
        const ProductTypeWidget(type: EImageType.genPlanta),
        const ProductTypeWidget(type: EImageType.genProducto),
        const ProductTypeWidget(type: EImageType.genTaller),
      ],
    );
  }
}
