import 'package:motorsbay1/exports.dart';

class ProfileTile extends StatelessWidget {
  const ProfileTile({
    super.key,
    this.leadingIconPath,
    required this.title,
    this.headline,
    this.showHeadline = false,
    this.onTap,
    this.showArrow = true,
    this.titleStyle,
    this.iconColor,
  });

  final String? leadingIconPath;
  final String title;
  final String? headline;
  final bool showHeadline;
  final VoidCallback? onTap;
  final bool showArrow;
  final TextStyle? titleStyle;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (headline != null && showHeadline)
          AppText(
            headline!,
            style: theme.textTheme.titleMedium!.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ).pad(EdgeInsets.only(bottom: 16.h)),
        Container(
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: theme.colorScheme.surface,
            border: Border.all(
              color: theme.colorScheme.outline,
            ),
          ),
          child: MaterialButton(
              onPressed: onTap ?? () {},
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  if (leadingIconPath != null)
                    DynamicAppIconHandler.buildIcon(
                      context: context,
                      svg: leadingIconPath,
                      iconColor: iconColor ?? theme.colorScheme.tertiary,
                    ).pad(_padding()),
                  10.x,
                  AppText(
                    title,
                    style: titleStyle ?? theme.textTheme.bodyLarge,
                  ),
                  const Spacer(),
                  if (showArrow)
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: theme.colorScheme.tertiary,
                    )
                ],
              )),
        ),
      ],
    );
  }

  EdgeInsets _padding() {
    final code = "languageCode";
    return EdgeInsets.only(
      right: code == 'en' ? 16.w : 0,
      left: code == 'ur' ? 16.w : 0,
    );
  }
}
