import 'package:motorsbay1/SRC/Presentation/service_provider/widgets/home_page/home_page.dart';
import 'package:motorsbay1/SRC/Presentation/service_provider/widgets/home_page/my_service_details.dart';
import 'package:motorsbay1/SRC/Presentation/service_provider/widgets/home_page/my_services.dart';
import 'package:motorsbay1/SRC/Presentation/service_provider/widgets/home_page/sp_profile.dart';
import 'package:motorsbay1/exports.dart';

class MainFrameServiceProvider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // Number of tabs
      child: Scaffold(
        appBar: AppBar(
          title: Text('Service Provider'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'All Services'), // First tab
              Tab(text: 'My Services'), // Second tab
              Tab(text: 'Profile'), // Second tab
            ],
          ),
        ),
        body: TabBarView(
          children: [
            CarServicesScreen(),
            MyServices(),
            SpProfilePage()
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddProductOnboard()),
            );
          },
          backgroundColor: Colors.blue,
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          icon: Icon(Icons.directions_car, color: Colors.white),
          label: Text(
            "Sell Car",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),

      ),
    );
  }
}