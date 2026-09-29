import 'package:motorsbay1/SRC/Data/AppData/app_preferences.dart';
import 'package:motorsbay1/SRC/Data/AppData/data.dart';
import 'package:motorsbay1/SRC/Presentation/Widgets/Auth/Login/login_on_board.dart';
import 'package:motorsbay1/exports.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final isLoggedIn = await Data.app.token;
    bool isServiceProvider = await SharedPrefs.getIsServiceProvider() ?? false;
    print("The Token is : $isServiceProvider");

    Future.delayed(const Duration(seconds: 3), () {
      if (isLoggedIn != null && isLoggedIn.isNotEmpty) {

        // if(isServiceProvider == true){
        //   Navigator.pushReplacement(
        //       context,
        //       MaterialPageRoute(builder: (context) => MainFrameServiceProvider()));
        // }
        // else{
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => AppFrame()),
          );
        // }

      } else {
        // Navigate to Login Screen if not logged in
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginOnBoard()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            color: Colors.black,
          ),
          Positioned(
            top: 400.h,
            child: SizedBox(
              height: 500.h,
              width: 1.sw,
              child: Image.asset(
                'assets/images/splashcar.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: 200.h,
            left: 1.sw / 4,
            child: Text(
              'MOTORS BAY',
              style: TextStyle(
                fontSize: 29.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: 'Cursive',
              ),
            ),
          ),
        ],
      ),
    );
  }
}


