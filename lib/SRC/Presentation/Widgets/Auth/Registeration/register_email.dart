import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:motorsbay1/SRC/Data/AppData/app_preferences.dart';
import 'package:motorsbay1/exports.dart';

class RegisterEmail extends StatefulWidget {
  const RegisterEmail({super.key});

  @override
  State<RegisterEmail> createState() => _RegisterEmailState();
}

class _RegisterEmailState extends State<RegisterEmail> {
  final _formRegisterKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool isLoading = false;
  String deviceToken = '';
  NotificationServices notificationServices = NotificationServices();


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    notificationServices.getDeviceToken().then((value){
      setState(() {
        deviceToken = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(),
      body: Form(
        key: _formRegisterKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    48.y,
                    AppText(
                      'Register with Email',
                      style: themeData.textTheme.headlineLarge
                          ?.copyWith(color: themeData.colorScheme.onBackground),
                    ),
                    AppText(
                      maxLine: 2,
                      'Create an account to get started!',
                      style: themeData.textTheme.bodyMedium,
                    ),
                    30.y,
                    AppTextField(
                      controller: nameController,
                      textInputType: TextInputType.text,
                      hintText: 'Full Name',
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                      prefixIcon: DynamicAppIconHandler.buildIcon(
                        iconWidth: 24,
                        context: context,
                        svg: "assets/Icons/userIcon.svg",
                        iconColor: themeData.colorScheme.tertiary,
                      ),
                    ),
                    20.y,
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
                      onTap: _onRegister,
                      text: isLoading ? 'Registering...' : 'Register',
                    ),
                  ],
                ).padHorizontal(24),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppText(
                  'Already have an account?',
                  style: themeData.textTheme.bodyLarge,
                ),
                7.x,
                AppText(
                  'Login',
                  style: themeData.textTheme.bodyLarge
                      ?.copyWith(color: themeData.colorScheme.primary),
                ).onTapped(onTap: _goToLogin),
              ],
            ),
            (16 + 1.bottomBar).y,
          ],
        ),
      ),
    );
  }

void _onRegister() async {
  if (_formRegisterKey.currentState!.validate()) {
    setState(() => isLoading = true);

    String name = nameController.text.trim();
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    try {
      // Register user in Firebase
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      SharedPrefs.setLoginToken(userCredential.user!.uid.toString() ?? '');
      // Save user details in Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'displayName': name,
        'email': email,
        'createdAt': DateTime.now(),
        'uid': userCredential.user!.uid,
        'dob': '',
        'gender': '',
        'phone': '',
        'photoUrl': '',
        'deviceToken': deviceToken,
      });

      // Navigate to HomeScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AppFrame()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }

    setState(() => isLoading = false);
  }
}


  void _goToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginEmail()),
    );
  }
}
