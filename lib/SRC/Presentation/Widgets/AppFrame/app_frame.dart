import 'package:firebase_auth/firebase_auth.dart';
import 'package:motorsbay1/SRC/Data/AppData/data.dart';
import 'package:motorsbay1/exports.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:motorsbay1/SRC/Presentation/Widgets/ChatScreen/fixed_chat_screen.dart';
import 'package:motorsbay1/SRC/Presentation/Widgets/Community/community.dart';
import 'package:motorsbay1/SRC/Application/Services/Notification/notification_services.dart';
import 'package:get/get.dart';
import 'package:motorsbay1/SRC/Presentation/Widgets/3DModel/home_model.dart';
import 'package:motorsbay1/SRC/Presentation/Widgets/Common/custom_loader.dart';
import 'dart:math' show cos, sin, pi;

import '../Maintenance/maintenance_home.dart';

class AppFrame extends StatefulWidget {
  const AppFrame({super.key});

  @override
  State<AppFrame> createState() => _AppFrameState();
}

class _AppFrameState extends State<AppFrame> {
  // Track the index of the selected tab
  int _selectedIndex = 0;
  
  // List of page keys for refresh control
  final List<GlobalKey<_RefreshableState>> _pageKeys = List.generate(
    7,
    (_) => GlobalKey<_RefreshableState>(),
  );
  
  // List of pages for each tab
  late final List<Widget> _pages;
  
  @override
  void initState() {
    super.initState();
    _initializePages();
    notificationServices.requestNotificationPermission();
    notificationServices.forgroundMessage();
    notificationServices.firebaseInit(context);
    notificationServices.setupInteractMessage(context);
    notificationServices.isTokenRefresh();    
    _initUnreadMessageCounter();
    
    // Initialize all pages as paused except the first one
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (int i = 1; i < _pageKeys.length; i++) {
        final pageState = _pageKeys[i].currentState;
        if (pageState != null) {
          print('AppFrame: Initializing page at index $i as paused');
          pageState._handlePageInvisible();
        }
      }
    });
  }

  void _initializePages() {
    _pages = <Widget>[
      RefreshablePage(
        key: _pageKeys[0],
        onRefresh: () async {
          print('AppFrame: Refreshing Home Page');
          setState(() {});
        },
        child: LandingHomePage(),
      ),
      RefreshablePage(
        key: _pageKeys[1],
        onRefresh: () async {
          print('AppFrame: Refreshing Library Page');
          setState(() {});
        },
        child: MyLibrary(),
      ),
      RefreshablePage(
        key: _pageKeys[2],
        onRefresh: () async {
          print('AppFrame: Refreshing Maintenance Page');
          setState(() {});
        },
        child: MaintenanceHomeScreen(),
      ),
      RefreshablePage(
        key: _pageKeys[3],
        onRefresh: () async {
          print('AppFrame: Refreshing Add Product Page');
          setState(() {});
        },
        child: AddProductOnboard(),
      ),
      RefreshablePage(
        key: _pageKeys[4],
        onRefresh: () async {
          print('AppFrame: Refreshing Chat Page');
          setState(() {});
        },
        child: const ChatScreen(),
      ),
      RefreshablePage(
        key: _pageKeys[5],
        onRefresh: () async {
          print('AppFrame: Refreshing Community Page');
          setState(() {});
        },
        child: CommunityPage(),
      ),
      RefreshablePage(
        key: _pageKeys[6],
        onRefresh: () async {
          print('AppFrame: Refreshing Profile Page');
          setState(() {});
        },
        child: ProfileScreen(),
      ),
    ];
  }
  
  void _onTabChanged(int index) {
    print('AppFrame: Tab changed from $_selectedIndex to $index');
    
    // Handle page state when switching tabs
    if (_selectedIndex != index) {
      // Pause all other pages
      for (int i = 0; i < _pageKeys.length; i++) {
        if (i != index) {
          final pageState = _pageKeys[i].currentState;
          if (pageState != null) {
            print('AppFrame: Pausing page at index $i');
            pageState._handlePageInvisible();
          }
        }
      }
      
      // Resume the selected page
      final newPageState = _pageKeys[index].currentState;
      if (newPageState != null) {
        print('AppFrame: Resuming page at index $index');
        newPageState._handlePageVisible();
      }
    } else {
      // Refresh the page when tapping the same tab
      print('AppFrame: Refreshing current page');
      final currentPageState = _pageKeys[index].currentState;
      if (currentPageState != null) {
        currentPageState.refresh();
      }
    }

    setState(() {
      _selectedIndex = index;
    });
  }
  
  // Function to navigate to 3D Models page
  void _navigate3DModelsPage() {
    // Pause the current page before navigation
    final currentPageState = _pageKeys[_selectedIndex].currentState;
    if (currentPageState != null) {
      print('AppFrame: Pausing current page before 3D models navigation');
      currentPageState._handlePageInvisible();
    }
    Get.toNamed('/3d_models');
  }
  
  NotificationServices notificationServices = NotificationServices();  
  Stream<int>? _unreadMessageCountStream;

  // Initialize the unread message counter stream
  void _initUnreadMessageCounter() {
    String? userId = FirebaseAuth.instance.currentUser?.uid ?? Data.app.token;
    if (userId != null) {
      _unreadMessageCountStream = FirebaseFirestore.instance
          .collection('chats')
          .where('participants', arrayContains: userId)
          .snapshots()
          .asyncMap((snapshot) async {
            int totalUnread = 0;
            
            for (var doc in snapshot.docs) {
              Map<String, dynamic> chatData = doc.data();
              
              // Sum up unread messages for current user
              if (chatData['unreadCount'] != null && 
                  chatData['unreadCount'][userId] != null) {
                totalUnread += chatData['unreadCount'][userId] as int;
              }
            }
            
            return totalUnread;
          });
    }    
    notificationServices.getDeviceToken().then((value){
      // Device token retrieved
    });
  }
  
  // Helper method to build navigation items with settings icon for selected items
  BottomNavigationBarItem _buildNavigationItem(IconData icon, String label, int index) {
    bool isSelected = _selectedIndex == index;
    
    return BottomNavigationBarItem(
      icon: isSelected
          ? Stack(
              alignment: Alignment.center,
              children: [
                Icon(Icons.settings, size: 52, color: Color(0xFF1976D2).withOpacity(0.2)),
                Icon(icon, size: 20, color: Color(0xFF1976D2)),
              ],
            )
          : Icon(icon, size: 24),
      label: label,
    );
  }
  
  // Special helper for the chat navigation item with badge
  BottomNavigationBarItem _buildChatNavigationItem() {
    bool isSelected = _selectedIndex == 4;
    
    return BottomNavigationBarItem(
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          isSelected
              ? Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(Icons.settings, size: 52, color: Color(0xFF1976D2).withOpacity(0.2)),
                    Icon(Icons.chat, size: 20, color: Color(0xFF1976D2)),
                  ],
                )
              : Icon(Icons.chat, size: 24),
          StreamBuilder<int>(
            stream: _unreadMessageCountStream,
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data! > 0) {
                return Positioned(
                  right: -4,
                  top: -4,
                  child: Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    constraints: BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      snapshot.data! > 99 ? '99+' : snapshot.data!.toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }
              return SizedBox.shrink();
            },
          ),
        ],
      ),
      label: 'Chat',
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        
        // Show confirmation dialog when back button is pressed
        final shouldPop = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Exit Motorsbay?'),
            content: const Text('Are you sure you want to exit the app?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Exit'),
              ),
            ],
          ),
        ) ?? false;
        if (shouldPop && mounted) {
          // Use Navigator to pop if user confirmed exit and widget is still mounted
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: IndexedStack(
          index: _selectedIndex,
          children: _pages,
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 0,
                blurRadius: 10,
                offset: Offset(0, -2),
              ),
            ],
            border: Border(
              top: BorderSide(
                color: Colors.grey.withOpacity(0.3),
                width: 1.0,
              ),
            ),
          ),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onTabChanged,
            selectedItemColor: Color(0xFF1976D2),
            unselectedItemColor: Color(0xFF818181),
            showSelectedLabels: true,
            showUnselectedLabels: false,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            elevation: 0,
            selectedFontSize: 12.0,
            unselectedFontSize: 12.0,
            items: <BottomNavigationBarItem>[
              _buildNavigationItem(Icons.home, 'Home', 0),
              _buildNavigationItem(Icons.library_books, 'Library', 1),
              _buildNavigationItem(Icons.build, 'Repairs', 2),
              BottomNavigationBarItem(
                icon: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Color(0xFF1976D2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.add, color: Colors.white),
                ),
                label: 'Add',
              ),
              _buildChatNavigationItem(),              
              _buildNavigationItem(Icons.people, 'Social', 5),
              _buildNavigationItem(Icons.person, 'Profile', 6),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Pause all pages before disposal
    for (int i = 0; i < _pageKeys.length; i++) {
      final pageState = _pageKeys[i].currentState;
      if (pageState != null) {
        print('AppFrame: Pausing page at index $i during disposal');
        pageState._handlePageInvisible();
      }
    }
    super.dispose();
  }
}

class RefreshablePage extends StatefulWidget {
  final Widget child;
  final Future<void> Function() onRefresh;

  const RefreshablePage({
    Key? key,
    required this.child,
    required this.onRefresh,
  }) : super(key: key);

  @override
  State<RefreshablePage> createState() => _RefreshableState();
}

class _RefreshableState extends State<RefreshablePage> with WidgetsBindingObserver {
  bool _isPageVisible = true;
  bool _isRefreshing = false;
  Key _childKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    print('RefreshablePage: Initialized');
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    print('RefreshablePage: Disposed');
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print('RefreshablePage: App lifecycle state changed to $state');
    if (state == AppLifecycleState.resumed) {
      _handlePageVisible();
    } else if (state == AppLifecycleState.paused) {
      _handlePageInvisible();
    }
  }

  void _handlePageInvisible() {
    print('RefreshablePage: Page becoming invisible');
    if (_isPageVisible) {
      setState(() {
        _isPageVisible = false;
      });
    }
  }

  void _handlePageVisible() {
    print('RefreshablePage: Page becoming visible');
    if (!_isPageVisible) {
      setState(() {
        _isPageVisible = true;
      });
      refresh();
    }
  }

  Future<void> refresh() async {
    print('RefreshablePage: Refreshing page');
    if (!_isRefreshing) {
      setState(() {
        _isRefreshing = true;
        _childKey = UniqueKey(); // Force rebuild immediately
      });
      
      try {
        // Ensure minimum 2 second delay
        final startTime = DateTime.now();
        await widget.onRefresh();
        final elapsedTime = DateTime.now().difference(startTime);
        if (elapsedTime.inMilliseconds < 2000) {
          await Future.delayed(Duration(milliseconds: 2000 - elapsedTime.inMilliseconds));
        }
      } catch (e) {
        print('RefreshablePage: Error during refresh: $e');
      } finally {
        if (mounted) {
          setState(() {
            _isRefreshing = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isPageVisible) {
      print('RefreshablePage: Building while invisible');
      return Container();
    }

    print('RefreshablePage: Building while visible');
    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: refresh,
          child: KeyedSubtree(
            key: _childKey,
            child: widget.child,
          ),
        ),
        if (_isRefreshing)
          Container(
            color: Colors.white.withOpacity(0.9),
            child: const Center(
              child: CustomLoader(
                outerSize: 150,
                innerSize: 50,
                opacity: 0.7,
              ),
            ),
          ),
      ],
    );
  }
}

class GearPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Color(0xFF1976D2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;

    // Draw outer circle
    canvas.drawCircle(center, radius, paint);

    // Draw gear teeth
    final teethCount = 12;
    final toothLength = radius * 0.3;
    final toothWidth = radius * 0.2;

    for (var i = 0; i < teethCount; i++) {
      final angle = (i * 2 * 3.14159) / teethCount;
      final startPoint = Offset(
        center.dx + (radius - toothLength) * cos(angle),
        center.dy + (radius - toothLength) * sin(angle),
      );
      final endPoint = Offset(
        center.dx + (radius + toothLength) * cos(angle),
        center.dy + (radius + toothLength) * sin(angle),
      );

      // Draw tooth
      canvas.drawLine(startPoint, endPoint, paint);

      // Draw tooth sides
      final sideAngle = angle + (3.14159 / teethCount);
      final sidePoint = Offset(
        endPoint.dx + toothWidth * cos(sideAngle),
        endPoint.dy + toothWidth * sin(sideAngle),
      );
      canvas.drawLine(endPoint, sidePoint, paint);
    }

    // Draw inner circle
    canvas.drawCircle(center, radius * 0.3, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
