
import 'package:motorsbay1/SRC/Presentation/Widgets/Auth/Registeration/Component/already_have_account.dart';
import 'package:motorsbay1/SRC/Presentation/Widgets/Auth/Registeration/verify_screen.dart';
import 'package:motorsbay1/exports.dart';

import 'create_password_screen.dart';

class RegisterAccountScreen extends StatefulWidget {
  const RegisterAccountScreen({
    super.key,
    required this.whichTypeRegistration,
  });

  final String whichTypeRegistration;

  @override
  State<RegisterAccountScreen> createState() => _RegisterAccountScreenState();
}

class _RegisterAccountScreenState extends State<RegisterAccountScreen> {
  TextEditingController emailController = TextEditingController();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController numberController = TextEditingController();
  String countryCode = '+92';
  String countryFlag = '🇵🇰';

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    // final applocale = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(),
      body: Form(
        key: formKey,
        child: ListView(
          physics: const NeverScrollableScrollPhysics(),
          children: [
            12.y,
            AppText(
              widget.whichTypeRegistration == 'phonenumber'
                  ? "Create An Account With Number"
                  : "Create An Account With Email",
              maxLine: 2,
              style: themeData.textTheme.headlineMedium,
            ),
            8.y,
            AppText(
              widget.whichTypeRegistration == 'phonenumber'
                  ? "Welcome Back Please Enter Your Phone Number"
                  : "Welcome Back Please Enter Your Email Address",
              maxLine: 3,
              style: themeData.textTheme.bodyLarge,
            ),
            140.y,
            if (widget.whichTypeRegistration == 'phonenumber')
              AppTextField(
                prefixIcon: Container(
                  clipBehavior: Clip.hardEdge,
                  decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(12)),
                  width: 100.w,
                  child: MaterialButton(
                    padding: const EdgeInsets.only(left: 6, right: 6),
                    onPressed: () {
                      showCountryPicker(
                          showPhoneCode: true,
                          context: context,
                          onSelect: (v) {
                            countryCode = "+${v.phoneCode}";
                            countryFlag = v.flagEmoji;
                            setState(() {});
                          });
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        AppText(
                          countryFlag,
                          style: themeData.textTheme.bodyMedium!.copyWith(
                            color: Theme.of(context).colorScheme.tertiary,
                          ),
                        ),
                        5.x,
                        AppText(
                          countryCode,
                          style: themeData.textTheme.bodyMedium!.copyWith(
                            color: Theme.of(context).colorScheme.tertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                controller: numberController,
                textInputType: TextInputType.phone,
                hintText: "Phone Number",
                validator: Validate.phone,
              )
            else
              AppTextField(
                prefixIcon: DynamicAppIconHandler.buildIcon(
                  iconWidth: 24,
                  context: context,
                  svg: "assets/Icons/emailoutlineIcon.svg",
                  iconColor: themeData.colorScheme.tertiary,
                ),
                controller: emailController,
                textInputType: TextInputType.emailAddress,
                hintText: "Email",
                validator: Validate.email,
              ),
            24.y,
            CommonButton(
              verticalMargin: 0,
              horizontalMargin: 0,
              onTap: () {
                if (formKey.currentState!.validate()) {
                  if(widget.whichTypeRegistration == 'phonenumber'){
                    Navigator.of(context).push(MaterialPageRoute(builder: (context)=>VerifyPhoneOrEmail(phone: numberController.text.toString(),whichTypeVerification: widget.whichTypeRegistration,)));
                  }
                  else{
                    Navigator.of(context).push(MaterialPageRoute(builder: (context)=>
                        CreatePasswordScreen(
                          whichTypeRegistration: widget.whichTypeRegistration,
                          email: emailController.text.trim(),
                          phoneNumber: numberController.text.trim(),
                        ),
                    ));
                  }
                }
              },
              text: "Next",
            )
          ],
        ).padHorizontal(24),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: const AlreadyHaveAnAccount(),
      resizeToAvoidBottomInset: false,
    );
  }
}
