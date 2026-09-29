import 'package:motorsbay1/SRC/Presentation/service_provider/widgets/Auth/Login/login_page.dart';
import 'package:motorsbay1/SRC/Presentation/service_provider/widgets/Auth/Register/create_account.dart';
import 'package:motorsbay1/exports.dart';


class LoginOnBoard extends StatefulWidget {
  const LoginOnBoard({super.key, this.isLogin});
  final bool? isLogin;
  @override
  State<LoginOnBoard> createState() => _LoginOnBoardState();
}


class _LoginOnBoardState extends State<LoginOnBoard> {
  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          1.statusBarToSizedBox,
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  64.y,
                  AppText(
                    widget.isLogin == null
                        ? 'LetsGet Started'
                        : 'Welcome to Motors Bay',
                    style: themeData.textTheme.headlineMedium
                        ?.copyWith(fontSize: 26.fS),
                  ).padHorizontal(24),
                  8.y,
                  AppText(
                    maxLine: 3,
                    widget.isLogin == null
                        ? 'Sign up or log in to check the best cars.'
                        : 'Create an account to check the best cars.',
                    style: themeData.textTheme.bodyLarge
                        ?.copyWith(fontSize: 16.fS),
                  ).padHorizontal(24),
                  32.y,
                  Center(
                    child: Transform.flip(
                      // flipX: true,
                      child: AssetImageWidget(
                        url: "assets/images/login_car_image.png",
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  36.y,
                  widget.isLogin == null ? CommonButton(
                    horizontalMargin: 0,
                    onTap: (){
                      ContinueWithGoogleController().continueWithGoogle(context);
                    },
                    leadingIconMargins:
                    const EdgeInsets.symmetric(horizontal: 8),
                    text: 'Continue with Google',
                    leadingSvg: "assets/Icons/googleIcon.svg",
                    backgroundColor: Color(0xFF1976D2),
                  ).padHorizontal(24): SizedBox.shrink(),
                  CommonButton(
                    horizontalMargin: 0,
                    leadingIconMargins:
                    const EdgeInsets.symmetric(horizontal: 8),
                    onTap: _onPhone,
                    text: 'Continue with Phone',
                    leadingSvg: "assets/Icons/phoneIcon.svg",
                    borderColor: themeData.colorScheme.outline,
                    leadingColor: themeData.colorScheme.onBackground,
                    backgroundColor: themeData.colorScheme.background,
                    textColor: themeData.colorScheme.onBackground,
                  ).padHorizontal(24),
                  CommonButton(
                    horizontalMargin: 0,
                    onTap: _onEmail,
                    leadingIconMargins:
                    const EdgeInsets.symmetric(horizontal: 8),
                    text: 'Continue with Email',
                    leadingSvg: "assets/Icons/emailIcon.svg",
                    leadingColor: themeData.colorScheme.onBackground,
                    borderColor: themeData.colorScheme.outline,
                    backgroundColor: themeData.colorScheme.background,
                    textColor: themeData.colorScheme.onBackground,
                  ).padHorizontal(24),
                  10.y,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AppText(
                        widget.isLogin == null
                            ? "Dont have an Account"
                            : "Already Have Account",
                        style: themeData.textTheme.bodyLarge,
                      ),
                      7.x,
                      AppText(
                        widget.isLogin == null
                            ? "Create Account"
                            : "Login",
                        style: themeData.textTheme.bodyLarge
                            ?.copyWith(color: themeData.colorScheme.primary),
                      ).onTapped(onTap: _createOrLoginTap),
                    ],
                  ),
                  20.y,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AppText(
                        'Log In as a Service Provider',
                        textAlign: TextAlign.center,
                        style: themeData.textTheme.bodyLarge?.copyWith(
                          color: themeData.colorScheme.primary,
                          decoration: TextDecoration.underline,
                          decorationColor: themeData.colorScheme.primary,
                        ),
                      ),
                    ],
                  ).onTapped(onTap: _onTapGuest).padHorizontal(24),
                ],
              ),
            ),
          ),
          (16 + 1.bottomBar).y,
        ],
      ),

    );
  }

  _onPhone() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context)=>widget.isLogin != null
        ? const RegisterAccountScreen(whichTypeRegistration: 'phonenumber')
        : const LoginPhone()));

  }

  _onEmail() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context)=>widget.isLogin != null
        ? const RegisterAccountScreen(whichTypeRegistration: 'email')
        : const LoginEmail()));

  }

  _createOrLoginTap() {
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=>LoginOnBoard(isLogin: widget.isLogin == null ? true : null)));
  }

  _onTapGuest() {
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=>ServiceProviderLogin()));
  }


}