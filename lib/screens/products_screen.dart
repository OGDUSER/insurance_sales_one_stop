import 'package:flutter/material.dart';

class ProductsScreen
    extends StatelessWidget {

  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final products = [
      {
        'name': 'Vehicle Insurance',
        'description':
        'Protect your vehicle against accidents and loss.',
        'icon': Icons.directions_car,
      },
      {
        'name': 'Home Insurance',
        'description':
        'Protect your home and belongings.',
        'icon': Icons.home,
      },
      {
        'name': 'Life Insurance',
        'description':
        'Financial protection for your family.',
        'icon': Icons.family_restroom,
      },
      {
        'name': 'Funeral Cover',
        'description':
        'Support for your family during difficult times.',
        'icon': Icons.favorite,
      },
      {
        'name': 'Business Insurance',
        'description':
        'Protect your business and assets.',
        'icon': Icons.business,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title:
        const Text('Insurance Products'),
        backgroundColor:
        const Color(0xFF005A3C),
        foregroundColor: Colors.white,
      ),

      body: ListView.builder(
        padding: const EdgeInsets.all(15),
        itemCount: products.length,

        itemBuilder: (context, index) {

          final product =
          products[index];

          return Card(
            margin:
            const EdgeInsets.only(
                bottom: 15),

            child: ListTile(
              contentPadding:
              const EdgeInsets.all(15),

              leading: Icon(
                product['icon'] as IconData,
                size: 45,
                color:
                const Color(0xFF005A3C),
              ),

              title: Text(
                product['name'] as String,

                style: const TextStyle(
                  fontWeight:
                  FontWeight.bold,
                ),
              ),

              subtitle: Text(
                product['description']
                as String,
              ),

              trailing:
              const Icon(
                  Icons.arrow_forward_ios),

              onTap: () {

                Navigator.pushNamed(
                  context,
                  '/quote',

                  arguments:
                  product['name'],
                );
              },
            ),
          );
        },
      ),
    );
  }
}