import 'package:flutter/material.dart';
import 'package:shoppinglist/providers/main_provider.dart';
import 'package:shoppinglist/utils/enums.dart';
import 'package:shoppinglist/utils/utils.dart';

class SearchWidget extends StatelessWidget {
  final ESearchType searchType;
  const SearchWidget({super.key, required this.searchType});

  @override
  Widget build(BuildContext context) {
    MainProvider mainProvider = Provider.of<MainProvider>(context, listen: true);
    TextEditingController searchController = TextEditingController(text: mainProvider.searchText);
    searchController.selection =
        TextSelection.fromPosition(TextPosition(offset: mainProvider.searchText.length));
    return Container(
      height: 45,
      margin: const EdgeInsets.only(left: 10, top: 10, bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Utils.oscuro),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: TextFormField(
              onChanged: (value) {
                mainProvider.searchText = value;
                searchType == ESearchType.productos
                    ? mainProvider.searchProduct(value.trim())
                    : mainProvider.searchShop(value.trim());
              },
              cursorColor: Utils.oscuro,
              controller: searchController,
              style: mainProvider.itemStyle,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search, color: Utils.oscuro),
                suffixIcon: GestureDetector(
                  onTap: () {
                    searchController.text = '';
                    mainProvider.searchText = '';
                    mainProvider.searchProduct('');
                    mainProvider.searchShop('');
                    WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
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
        ],
      ),
    );
  }
}
