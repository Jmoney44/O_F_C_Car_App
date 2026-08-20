import 'package:flutter/material.dart';
import 'package:ofcluxury_app/consts/consts.dart';

/// Grid product card used across Home, Category, Search, and Wishlist —
/// image, favorite toggle, rating, and price on a flat rounded surface.
class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.price,
    this.rating,
    this.badge,
    this.isFavorite = false,
    this.onTap,
    this.onFavoriteToggle,
    this.isNetworkImage = true,
  });

  final String imageUrl;
  final String title;
  final String price;
  final double? rating;
  final String? badge;
  final bool isFavorite;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteToggle;
  final bool isNetworkImage;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: lightGrey,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: AspectRatio(
                    aspectRatio: 1.3,
                    child: isNetworkImage
                        ? Image.network(imageUrl, fit: BoxFit.cover)
                        : Image.asset(imageUrl, fit: BoxFit.cover),
                  ),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: onFavoriteToggle,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: whiteColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        size: 16,
                        color: isFavorite ? dangerColor : darkFontGrey,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            10.heightBox,
            title.text.fontFamily(semibold).size(14).color(darkFontGrey).maxLines(1).ellipsis.make(),
            6.heightBox,
            Row(
              children: [
                if (rating != null) ...[
                  const Icon(Icons.star_rounded, size: 15, color: golden),
                  2.widthBox,
                  "$rating".text.size(12).fontFamily(semibold).color(darkFontGrey).make(),
                ],
                if (rating != null && badge != null) ...[
                  6.widthBox,
                  "|".text.size(12).color(textfieldGrey).make(),
                  6.widthBox,
                ],
                if (badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: whiteColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: badge!.text.size(11).fontFamily(semibold).color(fontGrey).make(),
                  ),
              ],
            ),
            6.heightBox,
            price.text.fontFamily(bold).size(15).color(darkFontGrey).make(),
          ],
        ),
      ),
    );
  }
}
