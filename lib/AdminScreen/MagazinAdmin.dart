import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:url_launcher/url_launcher.dart';
import 'MagazinEditAdmin.dart';

class MagazinAdmin extends StatefulWidget {
  const MagazinAdmin({super.key});

  @override
  State<MagazinAdmin> createState() => _MagazinAdminState();
}

class _MagazinAdminState extends State<MagazinAdmin> {
  final DatabaseReference _shopRef = FirebaseDatabase.instance.ref().child('shop');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Магазин'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      backgroundColor: Colors.white,
      body: StreamBuilder(
        stream: _shopRef.onValue,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
            final data = Map<String, dynamic>.from(snapshot.data!.snapshot.value as Map);
            final products = data.entries.toList();

            return GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.45,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = Map<String, dynamic>.from(products[index].value);
                return GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Выберите действие'),
                        content: const Text('Что вы хотите сделать с товаром?'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => MagazinEditAdmin(
                                    keyId: products[index].key,
                                    product: product,
                                  ),
                                ),
                              );
                            },
                            child: const Text('Редактировать'),
                          ),
                          TextButton(
                            onPressed: () async {
                              Navigator.pop(context);
                              final url = product['url'];
                              if (url != null) {
                                await launchUrl(Uri.parse(url));
                              }
                            },
                            child: const Text('Перейти'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Card(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    color: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Container(
                      width: 200,
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (product['image'] != null)
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                              child: Image.network(
                                product['image'],
                                height: 200,
                                width: 200,
                                fit: BoxFit.cover,
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product['name'] ?? '',
                                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text.rich(
                                  TextSpan(
                                    text: 'Цена: ',
                                    style: const TextStyle(fontSize: 16, color: Colors.black),
                                    children: [
                                      if (product['oldPrice'] != null)
                                        TextSpan(
                                          text: '${product['oldPrice']}₽ ',
                                          style: const TextStyle(
                                            decoration: TextDecoration.lineThrough,
                                            color: Colors.grey,
                                            fontSize: 12,
                                          ),
                                        ),
                                      TextSpan(
                                        text: '${product['price']}₽',
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text(
                                      'Рейтинг: ${product['rating']} ',
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                    const Icon(Icons.star, color: Colors.amber, size: 14),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text('Отзывов: ${product['reviews']}', style: const TextStyle(fontSize: 12)),
                                const SizedBox(height: 4),

                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return const Center(child: Text('Ошибка загрузки товаров.'));
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}