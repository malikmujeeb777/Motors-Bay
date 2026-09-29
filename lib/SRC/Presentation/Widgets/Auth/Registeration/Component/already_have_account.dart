

import 'package:motorsbay1/SRC/Presentation/Widgets/Auth/Login/login_on_board.dart';
import 'package:motorsbay1/exports.dart';

class AlreadyHaveAnAccount extends StatelessWidget {
  const AlreadyHaveAnAccount({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    // final locale = AppLocalizations.of(context)!;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppText(
          "Already Have An Account Login",
          style: themeData.textTheme.bodyLarge,
        ),
        const SizedBox(width: 4),
        AppText(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context)=>LoginOnBoard()));
          },
         "Log In",
          style: themeData.textTheme.bodyLarge!
              .copyWith(color: themeData.colorScheme.primary),
        )
      ],
    ).pad(
      EdgeInsets.only(bottom: 20.h),
    );
  }
}
