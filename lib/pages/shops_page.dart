import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shoppinglist/dialogs/dialogs.dart';
import 'package:shoppinglist/providers/main_provider.dart';
import 'package:shoppinglist/sharedpreferences/preferences.dart';
import 'package:shoppinglist/utils/enums.dart';
import 'package:shoppinglist/utils/utils.dart';
import 'package:shoppinglist/widgets/_widgets.dart';

class ShopsPage extends StatefulWidget {
  static const String routeName = 'ShopsPage';
  const ShopsPage({super.key});

  @override
  State<ShopsPage> createState() => _ShopsPageState();
}

class _ShopsPageState extends State<ShopsPage> {
  ScrollController scrollController = ScrollController();
  late MainProvider mainProvider;

  @override
  void dispose() {
    scrollController.dispose();
    Preferences.tutorialCrearTienda = mainProvider.shops.isNotEmpty;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    mainProvider = Provider.of<MainProvider>(context);

    return Scaffold(
      floatingActionButton: ScrollVisibilityWidget(
        controller: scrollController,
        child: FloatingActionButton(
          onPressed: () => newShop(context),
          child: const Icon(Icons.add),
        ),
      ),
      body: Stack(
        children: [
          const BackgroundWidget(),
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            controller: scrollController,
            slivers: [
              SliverAppBar(
                expandedHeight: 140,
                pinned: false,
                automaticallyImplyLeading: false,
                backgroundColor: Colors.transparent,
                flexibleSpace: FlexibleSpaceBar(
                  background: Column(
                    children: [
                      const TopWidget(showBack: true, title: 'Tiendas'),
                      Container(
                          margin: const EdgeInsets.only(right: 10),
                          child: const SearchWidget(searchType: ESearchType.tiendas)),
                    ],
                  ),
                ),
              ),
              if (mainProvider.filterShops.isNotEmpty) _shops(),
              if (mainProvider.filterShops.isEmpty) _noShops(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _shops() {
    SliverGridDelegate delegate = Utils.homeIconImageSize == Utils.productImageSizeStandar
        ? const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 200,
            childAspectRatio: 0.8,
          )
        : const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3);
    return SliverGrid.builder(
      gridDelegate: delegate,
      itemCount: mainProvider.filterShops.length,
      itemBuilder: (_, index) {
        return FadeIn(
          duration: Utils.fadeInDuration,
          child: ShopWidget(shop: mainProvider.filterShops[index]),
        );
      },
    );
  }

  Widget _noShops() {
    return SliverFillRemaining(
      child: ZoomIn(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Expanded(child: SizedBox(height: 1)),
              SvgPicture.asset('assets/svg/no_data.svg', width: 200, height: 200),
              const SizedBox(height: 30),
              Text('No hay tiendas', style: mainProvider.mainTitleStyle),
              const Expanded(child: SizedBox(height: 1)),
            ],
          ),
        ),
      ),
    );
  }
}
