import 'package:flutter/material.dart';

class ShopPage extends StatelessWidget {
  const ShopPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
                  childAspectRatio: 0.7,
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
        currentIndex: 4,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Feed'),
          BottomNavigationBarItem(icon: Icon(Icons.sports), label: 'Coach'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'You'),
          BottomNavigationBarItem(icon: Icon(Icons.flag), label: 'Challenges'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Shop'),
        ],
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.asset(
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
                const Chip(
                  label: Text('SALE'),
                  backgroundColor: Colors.white,
                ),
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

  Product({
    required this.name,
    required this.image,
    required this.price,
    required this.oldPrice,
    required this.rating,
    required this.reviews,
  });
}

final List<Product> products = [
  Product(
    name: 'Купальник женский',
    image: 'assets/images/swimsuit1.png',
    price: 1500,
    oldPrice: 7500,
    rating: 4,
    reviews: 17,
  ),
  Product(
    name: 'Брюки мужские для плавания',
    image: 'assets/images/swimsuit2.png',
    price: 2500,
    oldPrice: 12500,
    rating: 4,
    reviews: 7,
  ),
  Product(
    name: 'Купальник спортивный',
    image: 'assets/images/swimsuit3.png',
    price: 2000,
    oldPrice: 9000,
    rating: 5,
    reviews: 25,
  ),
  Product(
    name: 'Комбинезон для плавания',
    image: 'assets/images/swimsuit4.png',
    price: 3000,
    oldPrice: 11000,
    rating: 5,
    reviews: 12,
  ),
];