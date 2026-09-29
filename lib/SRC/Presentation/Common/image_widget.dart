import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:motorsbay1/SRC/Application/Utils/Extensions/extensions.dart';


class AssetImageWidget extends StatelessWidget {
  final String url;
  final double? scale;
  final double? width;
  final double? height;
  final Color? color;
  final bool? isCircle;
  final double? radius;
  final BoxFit? fit;

  const AssetImageWidget({
    super.key,
    required this.url,
    this.fit,
    this.scale = 1,
    this.width,
    this.height,
    this.color,
    this.isCircle,
    this.radius,
  });

  final String errorImageUrl = "";

  @override
  Widget build(BuildContext context) {
    return isCircle != null
        ? CircleAvatar(
        radius: radius,
        backgroundColor: color,
        backgroundImage: AssetImage(url))
        : url.imageType == ImageType.png
        ? Image(
      fit: fit ?? BoxFit.fill,
      color: color,
      errorBuilder: (context, url, error) {
        return isCircle == true
            ? CircleAvatar(
            radius: radius,
            backgroundImage:
            AssetImage("Assets.icons.informationIcon"))
            : Image.network(
          url.toString(),
          width: width ?? 110,
          height: height ?? 110,
        );
      },
      width: width,
      height: height,
      image: AssetImage(url),
    )
        : SvgPicture.asset(
      url,
      color: color,
      fit: fit ?? BoxFit.contain,
      width: width,
      height: height,
    );
  }
}

class CachedImage extends StatelessWidget {
  final String url;
  final double? scale;
  final double? radius;
  final bool? isCircle;
  final double? containerRadius;
  final double? bottomRadius;
  final double? topRadius;
  final BoxFit? fit;
  final double? width;
  final double? height;
  final String? errorImageUrl;
  const CachedImage({
    super.key,
    required this.url,
    this.errorImageUrl,
    this.scale = 1,
    this.radius = 50,
    this.isCircle = true,
    this.containerRadius = 0,
    this.topRadius,
    this.bottomRadius,
    this.fit = BoxFit.fill,
    this.height,
    this.width,
  });

  // final String errorImageUrl = "";

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    // print(url);
    return CachedNetworkImage(
      imageUrl: url,
      placeholder: (context, url) => isCircle!
          ? Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          border: Border.all(
            color: themeData.colorScheme.primary,
          ),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: CircularProgressIndicator(
            color: themeData.colorScheme.primary,
          ),
        ),
      )
          : Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: themeData.colorScheme.primary,
          borderRadius: BorderRadius.circular(containerRadius!),
        ),
        child: Center(
          child: CircularProgressIndicator(
            color: themeData.colorScheme.primary,
          ),
        ),
      ),
      errorWidget: (context, url, error) {
        return isCircle!
            ? CircleAvatar(
            radius: radius,
            // backgroundColor: Colors.transparent,
            backgroundImage: AssetImage(errorImageUrl ?? ""))
            : AssetImageWidget(
          fit: fit,
          width: width ?? 110,
          height: height ?? 110,
          url: errorImageUrl ?? "",
        );
      },
      imageBuilder: (context, imageProvider) => isCircle!
          ? CircleAvatar(
        radius: radius,
        onBackgroundImageError: (exception, stackTrace) {
          log("in erorr 400 -403 ");
        },
        backgroundImage: imageProvider,
      )
          : ClipRRect(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(topRadius ?? containerRadius!),
          topLeft: Radius.circular(topRadius ?? containerRadius!),
          bottomLeft: Radius.circular(bottomRadius ?? containerRadius!),
          bottomRight: Radius.circular(bottomRadius ?? containerRadius!),
        ),
        child: Image(
          image: imageProvider,
          width: width,
          height: height,
          fit: fit,
        ),
      ),
    );
  }
}
