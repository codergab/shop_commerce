import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/product.dart';
import '../providers/cart.dart';
import '../providers/auth.dart';

// Screens
import '../screens/product_detail_screen.dart';

class ProductItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final product = Provider.of<Product>(context);
    final cartProvider = Provider.of<Cart>(context, listen: false);
    final authProvider = Provider.of<Auth>(context, listen: false);
    return Consumer<Product>(
      builder: (ctx, product, child) => ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: GridTile(
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).pushNamed(ProductDetailScreen.routeName,
                  arguments: product.id);
            },
            child: Image.network(
              product.imageUrl,
              fit: BoxFit.cover,
            ),
          ),
          footer: GridTileBar(
            leading: IconButton(
                icon: Icon(
                  product.isFavourite ? Icons.favorite : Icons.favorite_border,
                  color: Colors.black,
                ),
                onPressed: () {
                  product.toggleFavouriteStatus(
                      authProvider.authToken, authProvider.userId);
                }),
            backgroundColor: Theme.of(context).accentColor,
            title: Text(
              product.title,
              textAlign: TextAlign.center,
            ),
            trailing: IconButton(
              icon: Icon(
                Icons.shopping_cart,
                color: Colors.black,
              ),
              onPressed: () {
                cartProvider.addItem(product.id, product.price, product.title);
                Scaffold.of(context).hideCurrentSnackBar();
                Scaffold.of(context).showSnackBar(SnackBar(
                  duration: Duration(seconds: 5),
                  content: Text('Item Added to Cart'),
                  // backgroundColor: Colors.green,
                  action: SnackBarAction(
                    label: 'Undo',
                    onPressed: () {
                      cartProvider.removeSingleItem(product.id);
                    },
                  ),
                ));
              },
            ),
          ),
        ),
      ),
    );
  }
}
