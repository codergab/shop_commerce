import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:shop_commerce/screens/edit_product_screen.dart';
import '../providers/products.dart';

import '../widgets/user_product_item.dart';
import '../widgets/app_drawer.dart';

class UserProducts extends StatelessWidget {
  static const routeName = '/my-products';

  Future<void> _refreshProducs(BuildContext context) async {
    await Provider.of<Products>(context, listen: false).fetchProducts(true);
  }

  @override
  Widget build(BuildContext context) {
    // final productsProvider = Provider.of<Products>(context);
    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(
        elevation: 0,
        title: const Text('Your Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).pushNamed(EditProduct.routeName);
            },
          )
        ],
      ),
      body: FutureBuilder(
        future: _refreshProducs(context),
        builder: (context, snapshot) =>
            snapshot.connectionState == ConnectionState.waiting
                ? Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () => _refreshProducs(context),
                    child: Padding(
                        padding: const EdgeInsets.all(5),
                        child: Consumer<Products>(
                          builder: (context, productsProvider, _) =>
                              ListView.builder(
                            itemCount: productsProvider.items.length,
                            itemBuilder: (_, index) => Column(
                              children: [
                                UserProductItem(
                                  productsProvider.items[index].id,
                                  productsProvider.items[index].title,
                                  productsProvider.items[index].imageUrl,
                                ),
                                Divider()
                              ],
                            ),
                          ),
                        )),
                  ),
      ),
    );
  }
}
