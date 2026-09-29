import 'package:motorsbay1/SRC/Presentation/Admin/Widgets/HomePage/admin_homepage.dart';
import 'package:motorsbay1/exports.dart';

class AdminLoginEmail extends StatefulWidget {
  const AdminLoginEmail({super.key});

  @override
  State<AdminLoginEmail> createState() => _AdminLoginEmailState();
}

class _AdminLoginEmailState extends State<AdminLoginEmail> {
  final _formLoginKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool isLoading = false; // Loading state

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(),
      body: Form(
        key: _formLoginKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    48.y,
                    AppText(
                      'Login with Email',
                      style: themeData.textTheme.headlineLarge
                          ?.copyWith(color: themeData.colorScheme.onSurface),
                    ),
                    AppText(
                      maxLine: 2,
                      'Welcome back! Please enter your email address.',
                      style: themeData.textTheme.bodyMedium,
                    ),
                    30.y,
                    AppTextField(
                      controller: emailController,
                      textInputType: TextInputType.emailAddress,
                      hintText: 'Email',
                      validator: Validate.email,
                      prefixIcon: DynamicAppIconHandler.buildIcon(
                        iconWidth: 24,
                        context: context,
                        svg: "assets/Icons/emailoutlineIcon.svg",
                        iconColor: themeData.colorScheme.tertiary,
                      ),
                    ),
                    20.y,
                    AppTextField(
                      controller: passwordController,
                      textInputType: TextInputType.text,
                      hintText: 'Password',
                      validator: Validate.password,
                      prefixIcon: DynamicAppIconHandler.buildIcon(
                        iconWidth: 24,
                        context: context,
                        svg: "assets/Icons/lockIcon.svg",
                        iconColor: themeData.colorScheme.tertiary,
                      ),
                      isState: true,
                    ),
                    40.y,
                    CommonButton(
                      horizontalMargin: 0,
                      onTap: isLoading ? null : _onLogin, // Disable button while loading
                      text: isLoading ? 'Loading...' : 'Login', // Hide text while loading

                    ),
                  ],
                ).padHorizontal(24),
              ),
            ),
            (16 + 1.bottomBar).y,
          ],
        ),
      ),
    );
  }

  void _onLogin() async {
    if (_formLoginKey.currentState!.validate()) {
      setState(() => isLoading = true); // Start loading

      String email = emailController.text.trim().toLowerCase();
      String password = passwordController.text.trim();

      try {
        if(email.isNotEmpty && password.isNotEmpty) {
          if(email.contains("admin@gmail.com") && password.contains("Admin@123")) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> AdminHomePage()));
          }
          else{
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Please Enter the Correct Email or Password")),
            );
          }

        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Login failed: ${e.toString()}")),
        );
      }

      setState(() => isLoading = false); // Stop loading
    }
  }


}
