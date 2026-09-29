
import 'package:pinput/pinput.dart';

import '../../../exports.dart';

class PinCodeWidget extends StatefulWidget {
  const PinCodeWidget({super.key, this.controller, this.formKey});

  final TextEditingController? controller;
  final GlobalKey? formKey;

  @override
  State<PinCodeWidget> createState() => _PinCodeWidgetState();
}

class _PinCodeWidgetState extends State<PinCodeWidget> {
  final focusNode = FocusNode();

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    var focusedBorderColor = themeData.colorScheme.primary;
    const fillColor = Color.fromRGBO(243, 246, 249, 0);

    final defaultPinTheme = PinTheme(
      width: 66.w,
      height: 66.h,
      textStyle: themeData.textTheme.bodyMedium,
      decoration: BoxDecoration(
        color: themeData.colorScheme.surface,
        // color: Colors.black,
        //  color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
    );
    final focusedTheme = PinTheme(
      width: 66.w,
      height: 66.h,
      textStyle:
      themeData.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
      decoration: BoxDecoration(
          color: themeData.colorScheme.background,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: themeData.colorScheme.primary),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0F000000),
              blurRadius: 12,
              offset: Offset(0, 6),
              spreadRadius: 0,
            )
          ]),
    );

    /// Optionally you can use form to validate the Pinput
    return Form(
      key: widget.formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Pinput(
            controller: widget.controller,
            focusNode: focusNode,
            length: 6,
            // androidSmsAutofillMethod:
            // AndroidSmsAutofillMethod.smsUserConsentApi,
            // listenForMultipleSmsOnAndroid: true,
            defaultPinTheme: defaultPinTheme,
            pinputAutovalidateMode: PinputAutovalidateMode.disabled,
            separatorBuilder: (index) => 30.x,
            validator: (value) {
              if (value!.isEmpty) {
                return 'Please Provide Otp';
              }
              if (value.length < 6) {
                return 'Please Provide Otp';
              }
              return null;
            },
            hapticFeedbackType: HapticFeedbackType.lightImpact,
            onCompleted: (pin) {
              debugPrint('onCompleted: $pin');
            },
            onChanged: (value) {
              debugPrint('onChanged: $value');
            },
            cursor: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 9),
                  width: 22,
                  height: 1,
                  color: focusedBorderColor,
                ),
              ],
            ),
            enabled: true,
            errorTextStyle: themeData.textTheme.bodySmall
                ?.copyWith(color: themeData.colorScheme.error),
            focusedPinTheme: focusedTheme,
            submittedPinTheme: focusedTheme,
            errorPinTheme: defaultPinTheme.copyBorderWith(
              border: Border.all(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }
}
