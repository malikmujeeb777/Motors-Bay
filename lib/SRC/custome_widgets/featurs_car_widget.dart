import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class FeatursCar extends StatelessWidget {
  final String imageUrl;
  final String title;

  const FeatursCar({
    super.key,
    required this.imageUrl,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // height: 170,
      width: 150,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        // color: Colors.grey.shade200, // Optional background color
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Align text properly
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(
              10,
            ), // Applies rounding to image
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              placeholder:
                  (context, url) => Container(
                    height: 130,
                    width: double.infinity,
                    alignment: Alignment.center,
                    child: const CircularProgressIndicator(),
                  ),
              errorWidget:
                  (context, url, error) => Container(
                    height: 130,
                    width: double.infinity,
                    alignment: Alignment.center,
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.error, size: 40),
                  ),
              height: 130, // Fixes image height
              width: double.infinity,
              fit: BoxFit.fill, // Ensures full image coverage
            ),
          ),
          const SizedBox(height: 8), // Space between image and text
          Center(
            child: Text(
              title,
              style: TextStyle(
                color: Colors.grey,
               
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis, // Prevents text overflow
            ),
          ),
        ],
      ),
    );
  }
}
