import 'package:flutter/material.dart';
import 'package:shoppinglist/dialogs/bottoms.dart';
import 'package:shoppinglist/models/models.dart';
import 'package:shoppinglist/providers/main_provider.dart';
import 'package:shoppinglist/sharedpreferences/preferences.dart';
import 'package:shoppinglist/utils/enums.dart';
import 'package:shoppinglist/utils/utils.dart';
import 'package:shoppinglist/widgets/_widgets.dart';

class ShopSliverHistoryWidget extends StatefulWidget {
  final List<ShoppingHistory> historicoCompras;

  const ShopSliverHistoryWidget({super.key, required this.historicoCompras});

  @override
  State<ShopSliverHistoryWidget> createState() => _ShopSliverHistoryWidgetState();
}

class _ShopSliverHistoryWidgetState extends State<ShopSliverHistoryWidget> {
  TextEditingController searchController = TextEditingController();
  late MainProvider mainProvider;
  List<ShoppingHistory> historicoCompras = [];
  ShopHistoryGroup groupSelected = Preferences.typeShopHistoryGroup;
  EOrderHistory orderHistory = EOrderHistory.date;
  EAscDesc orderAsc = EAscDesc.descendent;
  double totalAmount = 0;
  int totalQuantity = 0;
  List<int> years = [];
  int selectedYear = DateTime.now().year;

  @override
  Widget build(BuildContext context) {
    mainProvider = Provider.of(context);
    historicoCompras = widget.historicoCompras;
    years = historicoCompras.map((e) => e.date.year).toSet().toList();
    if (searchController.text.isNotEmpty) {
      historicoCompras = historicoCompras
          .where((h) => Utils.quitarTildes(h.product.name.toUpperCase())
              .contains(Utils.quitarTildes(searchController.text.toUpperCase())))
          .toList();
    }
    totalAmount =
        historicoCompras.fold(0, (previousValue, e) => previousValue + (e.price * e.quantity));
    totalQuantity = historicoCompras.fold(0, (previousValue, e) => previousValue + e.quantity);
    return SliverMainAxisGroup(
      slivers: historicoCompras.isNotEmpty
          ? [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      spacing: 10,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _groupBy(),
                        _orderBy(),
                        _ascDesc(),
                        _dropYears(),
                      ],
                    ),
                  ),
                ),
              ),
              _searchBar(),
              SliverToBoxAdapter(child: SizedBox(height: 10)),
              _history(),
              _total(),
            ]
          : [_noHistory()],
    );
  }

  Widget _noHistory() {
    return SliverFillRemaining(
      child: Center(child: Text('No hay compras', style: mainProvider.titleStyle)),
    );
  }

  Widget _total() {
    int countShowSaving = 0;
    return SliverToBoxAdapter(
      child: Column(
        children: [
          Divider(color: Utils.medio),
          GestureDetector(
            onTap: () async {
              countShowSaving++;
              if (countShowSaving == 7) {
                await showSavingAmount(context, mainProvider, historicoCompras[0].shop,
                    historicoCompras.where((s) => s.price == 0).toList());
                countShowSaving = 0;
              }
            },
            child: HistoryLevelTotalWidget(
                title: 'TOTAL ${historicoCompras[0].shop.name.toUpperCase()}',
                uds: totalQuantity,
                amount: totalAmount,
                isLastTotal: true),
          ),
        ],
      ),
    );
  }

  Widget _ascDesc() {
    if (groupSelected == ShopHistoryGroup.byProduct || groupSelected == ShopHistoryGroup.nogroup) {
      return Container(
        padding: const EdgeInsets.only(left: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Utils.claro,
          ),
        ),
        child: DropdownButton(
          borderRadius: BorderRadius.circular(20),
          dropdownColor: Utils.claro,
          isExpanded: false,
          value: orderAsc,
          underline: Container(),
          items: EAscDesc.values.map<DropdownMenuItem<EAscDesc>>((EAscDesc value) {
            return DropdownMenuItem<EAscDesc>(
              value: value,
              child:
                  Text(value.displayName(), style: mainProvider.itemStyle.copyWith(fontSize: 13)),
            );
          }).toList(),
          onChanged: <EAscDesc>(value) {
            orderAsc = value;
          },
        ),
      );
    } else {
      return SizedBox.shrink();
    }
  }

  Widget _orderBy() {
    if (groupSelected == ShopHistoryGroup.nogroup) {
      return Container(
        padding: const EdgeInsets.only(left: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Utils.claro,
          ),
        ),
        child: DropdownButton(
          borderRadius: BorderRadius.circular(20),
          dropdownColor: Utils.claro,
          isExpanded: false,
          value: orderHistory,
          underline: Container(),
          items: EOrderHistory.values.map<DropdownMenuItem<EOrderHistory>>((EOrderHistory value) {
            return DropdownMenuItem<EOrderHistory>(
              value: value,
              child:
                  Text(value.displayName(), style: mainProvider.itemStyle.copyWith(fontSize: 13)),
            );
          }).toList(),
          onChanged: <EOrderHistory>(value) {
            orderHistory = value;
          },
        ),
      );
    } else {
      return SizedBox.shrink();
    }
  }

  Widget _groupBy() {
    return Container(
      padding: const EdgeInsets.only(left: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Utils.claro,
        ),
      ),
      child: DropdownButton(
        borderRadius: BorderRadius.circular(20),
        dropdownColor: Utils.oscuro,
        isExpanded: false,
        value: groupSelected,
        underline: Container(),
        items: ShopHistoryGroup.values
            .map<DropdownMenuItem<ShopHistoryGroup>>((ShopHistoryGroup value) {
          return DropdownMenuItem<ShopHistoryGroup>(
            value: value,
            child: Text(value.displayName(),
                style: mainProvider.itemStyle.copyWith(fontSize: 13, color: Utils.claro)),
          );
        }).toList(),
        onChanged: <ShopHistoryGroup>(value) {
          groupSelected = value;
          Preferences.typeShopHistoryGroup = groupSelected;
        },
      ),
    );
  }

  Widget _dropYears() {
    return Container(
      margin: const EdgeInsets.only(left: 10),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Utils.claro,
        ),
      ),
      child: Row(
        spacing: 5,
        children: [
          Icon(
            Icons.calendar_month,
            color: Utils.medio,
          ),
          DropdownButton(
            borderRadius: BorderRadius.circular(20),
            dropdownColor: Utils.oscuro,
            isExpanded: false,
            value: selectedYear,
            underline: Container(),
            items: years.map<DropdownMenuItem<int>>((int value) {
              return DropdownMenuItem<int>(
                value: value,
                child: Text(value.toString(),
                    style: mainProvider.itemStyle.copyWith(fontSize: 13, color: Utils.claro)),
              );
            }).toList(),
            onChanged: <int>(value) {
              selectedYear = value;
            },
          ),
        ],
      ),
    );
  }

  Widget _searchBar() {
    return SliverToBoxAdapter(
      child: Container(
        height: 45,
        margin: const EdgeInsets.only(left: 10, top: 20, bottom: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Utils.claro,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Utils.oscuro),
        ),
        child: TextFormField(
          onChanged: (value) => setState(() {}),
          cursorColor: Utils.oscuro,
          controller: searchController,
          style: mainProvider.itemStyle,
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.search, color: Utils.oscuro),
            suffixIcon: GestureDetector(
              onTap: () {
                searchController.text = '';
                WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
                setState(() {});
              },
              child: Icon(Icons.clear, color: Utils.oscuro, size: 25),
            ),
            border: InputBorder.none,
            disabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
            hintText: 'Buscar . . .',
            hintStyle: TextStyle(fontSize: 15.0, color: Utils.medio),
            isCollapsed: true,
          ),
          textCapitalization: TextCapitalization.sentences,
        ),
      ),
    );
  }

  Widget _history() {
    switch (groupSelected) {
      case ShopHistoryGroup.nogroup:
        switch (orderHistory) {
          case EOrderHistory.date:
            if (orderAsc == EAscDesc.ascendent) {
              historicoCompras.sort((a, b) => a.date.compareTo(b.date));
            } else {
              historicoCompras.sort((a, b) => b.date.compareTo(a.date));
            }
            break;
          case EOrderHistory.name:
            if (orderAsc == EAscDesc.ascendent) {
              historicoCompras.sort((a, b) => a.product.name.compareTo(b.product.name));
            } else {
              historicoCompras.sort((a, b) => b.product.name.compareTo(a.product.name));
            }
            break;
        }
        return HistoryListProductWidget(
            historicoCompras: historicoCompras.where((h) => h.date.year == selectedYear).toList(),
            isProduct: false);
      case ShopHistoryGroup.byProduct:
        List<Product> products = historicoCompras
            .where((h) => h.date.year == selectedYear)
            .map((e) => e.product)
            .toSet()
            .toList();
        switch (orderHistory) {
          case EOrderHistory.date:
          case EOrderHistory.name:
            if (orderAsc == EAscDesc.ascendent) {
              products.sort((a, b) => a.name.compareTo(b.name));
            } else {
              products.sort((a, b) => b.name.compareTo(a.name));
            }
            break;
        }
        return SliverList.builder(
          itemCount: products.length,
          itemBuilder: (context, index) {
            final List<ShoppingHistory> shoppingList = historicoCompras
                .where((h) => h.product.id == products[index].id && h.date.year == selectedYear)
                .toList();
            return HistoryGroupedDetailWidget(shoppingHistory: shoppingList);
          },
        );
      case ShopHistoryGroup.byDate:
        return HistoryShopGroupedByDate(
            shoppingHistory: historicoCompras.where((h) => h.date.year == selectedYear).toList());
      case ShopHistoryGroup.byShopping:
        List<String> idCarts = historicoCompras
            .where((h) => h.date.year == selectedYear)
            .map((e) => e.cartId)
            .toSet()
            .toList();
        return SliverList.builder(
          itemCount: idCarts.length,
          itemBuilder: (context, index) {
            final List<ShoppingHistory> shoppingList = historicoCompras
                .where((h) => h.cartId == idCarts[index] && h.date.year == selectedYear)
                .toList();
            return HistoryByShoppingWidget(shoppingHistory: shoppingList, showShopName: false);
          },
        );
    }
  }
}
