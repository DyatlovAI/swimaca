import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:swimaca/Screen/JournalPage.dart';
import 'package:swimaca/Screen/StatisticPage.dart';
import 'package:swimaca/Screen/AchivementsPage.dart';
import 'package:swimaca/Screen/ShopPage.dart';
import 'package:swimaca/Screen/HomePage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

  class ShopPage extends StatefulWidget {
  final Map<String, dynamic> userData;

  const ShopPage({super.key, required this.userData});

  @override
  _ShopPageState createState() => _ShopPageState();
  }

  class _ShopPageState extends State<ShopPage> {
  int _currentIndex = 4;

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    switch (index) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => JournalPage(userData: widget.userData)),
        );
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomePage(userData: widget.userData)),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => StatisticPage(userData: widget.userData)),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AchievementsPage(userData: widget.userData)),
        );
        break;
      case 4:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ShopPage(userData: widget.userData)),
        );
        break;
    }
  }

  Future<List<Product>> fetchProducts() async {
    final ref = FirebaseDatabase.instance.ref('shop');
    final snapshot = await ref.get();

    if (snapshot.exists) {
      final products = <Product>[];
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      data.forEach((key, value) {
        final item = Map<String, dynamic>.from(value);
        products.add(Product(
          name: item['name'],
          image: item['image'],
          price: item['price'],
          oldPrice: item['oldPrice'],
          rating: item['rating'],
          reviews: item['reviews'],
          url: item['url'],
        ));
      });
      print('Fetched ${products.length} products from Realtime Database');
      return products;
    } else {
      print('No data in Realtime DB at path /shop');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(20),
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text(
              'Магазин',
              style: TextStyle(color: Colors.white),
            ),
            centerTitle: true,
            automaticallyImplyLeading: false,
          ),
        ),
      ),
      body: FutureBuilder<List<Product>>(
        future: fetchProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            print('Snapshot error: ${snapshot.error}');
            return Center(child: Text('Ошибка загрузки'));
          } else {
            final products = snapshot.data!;
            return SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.6,
                      ),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        return _buildProductCard(products[index]);
                      },
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
        unselectedLabelStyle: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Лента'),
          BottomNavigationBarItem(icon: Icon(Icons.sports), label: 'Тренер'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Профиль'),
          BottomNavigationBarItem(icon: Icon(Icons.flag), label: 'Задания'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_bag), label: 'Магазин'),
        ],
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    return GestureDetector(
      onTap: () => _launchURL(product.url), // Переход на магазин
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  product.image,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    product.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${product.oldPrice} руб',
                    style: const TextStyle(
                      decoration: TextDecoration.lineThrough,
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${product.price} руб',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      for (int i = 0; i < 5; i++)
                        Icon(
                          i < product.rating ? Icons.star : Icons.star_border,
                          color: Colors.redAccent,
                          size: 16,
                        ),
                      Text(' (${product.reviews})'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Product {
  final String name;
  final String image;
  final int price;
  final int oldPrice;
  final int rating;
  final int reviews;
  final String url;

  Product({
    required this.name,
    required this.image,
    required this.price,
    required this.oldPrice,
    required this.rating,
    required this.reviews,
    required this.url,
  });
}

Future<void> _launchURL(String url) async {
  final Uri uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } else {
    throw 'Не удалось открыть ссылку: $url';
  }
}