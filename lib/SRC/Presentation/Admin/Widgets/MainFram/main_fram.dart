import 'package:flutter/material.dart';
import 'package:motorsbay1/SRC/Presentation/Admin/Widgets/HomePage/admin_homepage.dart';

class MainFrameAdmin extends StatefulWidget {
  const MainFrameAdmin({super.key});

  @override
  MainFrameAdminState createState() => MainFrameAdminState();
}

class MainFrameAdminState extends State<MainFrameAdmin> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Admin Dashboard"),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50),
          child: TabBar(
            controller: _tabController,
            // labelColor: Colors.white,
            unselectedLabelColor: Colors.blue,
            tabs: [
              Tab(text: "Home"),
              Tab(text: "Profile"),
            ],
          ),
        ),
      ),      body: TabBarView(
        controller: _tabController,
        children: [
          AdminHomePage(),
          Center(child: Text("Profile Page Coming Soon")),
        ],
      ),
    );
  }
}