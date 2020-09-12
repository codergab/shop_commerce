import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/products.dart';

import './product_item.dart';

class ProductsGrid extends StatelessWidget {
  final bool showFavourites;

  const ProductsGrid(this.showFavourites);
  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<Products>(context);
    final products =
        showFavourites ? productProvider.favourites : productProvider.items;
    return GridView.builder(
      padding: const EdgeInsets.all(10.0),
      itemCount: products.length,
      itemBuilder: (context, index) => ChangeNotifierProvider.value(
        value: products[index],
        child: ProductItem(),
      ),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 3 / 2,
          crossAxisSpacing: 10.0,
          mainAxisSpacing: 10.0),
    );
  }
}
