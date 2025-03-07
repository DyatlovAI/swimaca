import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:swimaca/Screen/JournalPage.dart';
import 'package:swimaca/Screen/StatisticPage.dart';
import 'package:swimaca/Screen/AchivementsPage.dart';
import 'package:swimaca/Screen/ShopPage.dart';
import 'package:swimaca/Screen/HomePage.dart';
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



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Магазин'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
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
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Feed'),
          BottomNavigationBarItem(icon: Icon(Icons.sports), label: 'Coach'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'You'),
          BottomNavigationBarItem(icon: Icon(Icons.flag), label: 'Challenges'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_bag), label: 'Shop'),
        ],
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    return GestureDetector(
      onTap: () => _launchURL(product.url), // Переход на магазин
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.asset(
                  product.image, // Загружаем локальное изображение
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
                  Text('${product.price} руб',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      )),
                  Text(
                    '${product.oldPrice} руб',
                    style: const TextStyle(
                      decoration: TextDecoration.lineThrough,
                      color: Colors.grey,
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
  final String url; // Ссылка на магазин

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

final List<Product> products = [
  Product(
    name: 'Гидрокостюм Arena',
    image: 'assets/images/i4.jpg',
    price: 389,
    oldPrice: 1299,
    rating: 4,
    reviews: 21,
    url: 'https://www.proswim.ru/product/arena-gidrokostyum-carbon-air-fbslob-4984/',
  ),
  Product(
    name: 'Доска для плавания',
    image: 'assets/images/i5r.jpg',
    price: 10999,
    oldPrice: 13999,
    rating: 5,
    reviews: 15,
    url: 'https://www.proswim.ru/product/arena-doska-dlya-plavaniya-pull-kick-2181/',
  ),
  Product(
    name: 'Очки для плавания',
    image: 'assets/images/i6.jpg',
    price: 1599,
    oldPrice: 3199,
    rating: 4,
    reviews: 30,
    url: 'https://www.proswim.ru/product/ochki-dlya-plavaniya-s-dioptriyami-yingfa-optical-goggle-11429/',
  ),
];