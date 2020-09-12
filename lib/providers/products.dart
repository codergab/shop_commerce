import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../exceptions/http_exception.dart';

import './product.dart';

class Products with ChangeNotifier {
  final String token;
  final String userId;

  List<Product> _items = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
  ];
  Products(this.token, this.userId, this._items);

  List<Product> get items {
    return [..._items];
  }

  List<Product> get favourites {
    return _items.where((item) => item.isFavourite).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((item) => item.id == id);
  }

  Future<void> fetchProducts([bool filterByUser = false]) async {
    final isFiltered =
        filterByUser ? '&orderBy="userId"&equalTo="$userId"' : '';
    final url =
        'https://fire-demo-74202.firebaseio.com/products.json?auth=$token$isFiltered';
    try {
      final response = await http.get(url);
      final decodedResponse =
          json.decode(response.body) as Map<String, dynamic>;
      final List<Product> loadedProducts = [];

      if (decodedResponse == null) {
        return;
      }

      final favouriteProducts = await http.get(
          'https://fire-demo-74202.firebaseio.com/userFavourites/$userId.json?auth=$token');

      final favouriteData = json.decode(favouriteProducts.body);

      decodedResponse.forEach((productId, productData) {
        loadedProducts.add(
          Product(
            id: productId,
            title: productData['title'],
            description: productData['description'],
            price: productData['price'],
            isFavourite: favouriteData == null
                ? false
                : favouriteData[productId] ?? false,
            imageUrl: productData['imageUrl'],
          ),
        );
      });

      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> addProduct(Product product) async {
    final url =
        'https://fire-demo-74202.firebaseio.com/products.json?auth=$token';
    try {
      final result = await http.post(
        url,
        body: json.encode({
          'title': product.title,
          'description': product.description,
          'imageUrl': product.imageUrl,
          'price': product.price,
          'userId': userId
        }),
      );

      final decodedResult = json.decode(result.body);
      final newProduct = Product(
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
        id: decodedResult['name'],
      );
      _items.add(newProduct);
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> updateProduct(String id, Product product) async {
    final productIndex = _items.indexWhere((prod) => prod.id == id);
    if (productIndex >= 0) {
      try {
        final url =
            'https://fire-demo-74202.firebaseio.com/products/$id.json?auth=$token';
        await http.patch(url,
            body: json.encode({
              'title': product.title,
              'description': product.description,
              'imageUrl': product.imageUrl,
              'price': product.price,
            }));
        _items[productIndex] = product;
        notifyListeners();
      } catch (error) {
        throw error;
      }
    } else {
      print('...');
    }
  }

  Future<void> deleteProduct(String id) async {
    final url =
        'https://fire-demo-74202.firebaseio.com/products/$id.json?auth=$token';
    final existingProductIndex =
        _items.indexWhere((product) => product.id == id);
    var existingProduct = _items[existingProductIndex];
    _items.removeAt(existingProductIndex);
    notifyListeners();
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException('Could not Delete product');
    }
    existingProduct = null;
  }
}
