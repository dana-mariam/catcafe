import 'package:flutter/material.dart';

class AdoptionScreen extends StatelessWidget {
  const AdoptionScreen({super.key});

  static const Color backgroundColor = Color(0xFFF8EBD7);
  static const Color cardColor = Color(0xFFFFFCF6);
  static const Color brown = Color(0xFF713D27);
  static const Color lightBrown = Color(0xFF9A6D58);
  static const Color softBrown = Color(0xFFF0DDC8);

  @override
  Widget build(BuildContext context) {
    final cats = [
      {
        'name': 'Milo',
        'age': '2 years',
        'gender': 'Male',
        'image':
        'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?w=800',
        'description':
        'A sweet and playful cat who loves cuddles and cozy naps.',
      },
      {
        'name': 'Luna',
        'age': '1 year',
        'gender': 'Female',
        'image':
        'https://images.unsplash.com/photo-1518791841217-8f162f1e1131?w=800',
        'description':
        'Gentle, curious and always ready to make a new friend.',
      },
      {
        'name': 'Oliver',
        'age': '3 years',
        'gender': 'Male',
        'image':
        'https://images.unsplash.com/photo-1573865526739-10659fec78a5?w=800',
        'description':
        'A calm and friendly companion looking for a loving home.',
      },
      {
        'name': 'Bella',
        'age': '8 months',
        'gender': 'Female',
        'image':
        'https://images.unsplash.com/photo-1533738363-b7f9aef128ce?w=800',
        'description':
        'A little bundle of joy with a playful and loving personality.',
      },
    ];

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  20,
                  20,
                  0,
                ),
                child: _header(),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  20,
                  20,
                  16,
                ),
                child: _introCard(),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                20,
                0,
                20,
                25,
              ),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    final cat = cats[index];

                    return Padding(
                      padding: const EdgeInsets.only(
                        bottom: 16,
                      ),
                      child: _catCard(
                        context,
                        name: cat['name']!,
                        age: cat['age']!,
                        gender: cat['gender']!,
                        image: cat['image']!,
                        description: cat['description']!,
                      ),
                    );
                  },
                  childCount: cats.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _header() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'FIND A FRIEND',
                style: TextStyle(
                  color: lightBrown,
                  fontSize: 8,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Adopt a Cat',
                style: TextStyle(
                  color: brown,
                  fontSize: 27,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'serif',
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'A little love is waiting for you.',
                style: TextStyle(
                  color: lightBrown.withOpacity(0.9),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),

        Container(
          width: 45,
          height: 45,
          decoration: const BoxDecoration(
            color: cardColor,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.pets_rounded,
            color: brown,
            size: 21,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // INTRO CARD
  // ============================================================

  Widget _introCard() {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: softBrown,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              color: cardColor,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.favorite_rounded,
              color: brown,
              size: 19,
            ),
          ),

          const SizedBox(width: 12),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Give a cat a forever home',
                  style: TextStyle(
                    color: brown,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Meet our lovely cats and find your new best friend.',
                  style: TextStyle(
                    color: lightBrown,
                    fontSize: 9,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CAT CARD
  // ============================================================

  Widget _catCard(
      BuildContext context, {
        required String name,
        required String age,
        required String gender,
        required String image,
        required String description,
      }) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: const Color(0xFFEAD5BF),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ------------------------------------------------------
          // IMAGE
          // ------------------------------------------------------

          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(25),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 205,
              child: Image.network(
                image,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) {
                  return Container(
                    color: softBrown,
                    child: const Center(
                      child: Icon(
                        Icons.pets_rounded,
                        color: lightBrown,
                        size: 45,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // ------------------------------------------------------
          // CONTENT
          // ------------------------------------------------------

          Padding(
            padding: const EdgeInsets.fromLTRB(
              16,
              14,
              16,
              16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(
                          color: brown,
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'serif',
                        ),
                      ),
                    ),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: softBrown,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.favorite_border_rounded,
                        color: brown,
                        size: 17,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                Row(
                  children: [
                    _infoChip(
                      Icons.cake_outlined,
                      age,
                    ),
                    const SizedBox(width: 7),
                    _infoChip(
                      gender == 'Male'
                          ? Icons.male_rounded
                          : Icons.female_rounded,
                      gender,
                    ),
                  ],
                ),

                const SizedBox(height: 11),

                Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: lightBrown,
                    fontSize: 10,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 14),

                SizedBox(
                  width: double.infinity,
                  height: 43,
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Meet $name coming soon 🐾',
                          ),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: brown,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: brown,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.pets_rounded,
                          size: 16,
                        ),
                        SizedBox(width: 7),
                        Text(
                          'MEET ME',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // INFO CHIP
  // ============================================================

  Widget _infoChip(
      IconData icon,
      String text,
      ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: lightBrown,
            size: 13,
          ),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(
              color: lightBrown,
              fontSize: 8,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}