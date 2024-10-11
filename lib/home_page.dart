import 'package:flutter/material.dart';
import 'package:voice_based_notification/settings.dart';
import 'package:voice_based_notification/shedules.dart';
import 'package:voice_based_notification/variables.dart';
import 'home_content.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  String? titleBarText = "Home"??"";

  _updateTitle(index){
    Map<int, String?> title = {
      0:"Home",
      1:"Schedules",
      2:"Settings"
    };
    setState(() {
      titleBarText = title[index];
    });
  }

  // List of pages for bottom navigation
  final List<Widget> _pages = [
    HomeContent(),
    SchedulesPage(),
    SettingsPage(),
  ];

  // Function to handle bottom navigation item tap
  void _onItemTapped(int index) {
    _updateTitle(index);
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white, // Use primary color for AppBar
          title: Row(
            children: [
              Container(
                width: 40,
                height:40,
                padding: EdgeInsets.zero,
                decoration: BoxDecoration(
                  color: primaryColor,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: () async{
                    Navigator.pushNamed(context, "/profile",);
                  },
                  icon: const Icon(
                    Icons.person,
                    color: Colors.black, // Icon color
                  ),
                ),
              ),



              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text(titleBarText!),
              ),
              Expanded(child: Container(),
              ),
              Align(
                child: IconButton(
                  style: IconButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: EdgeInsets.symmetric(horizontal: 20)
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, "/courseRep");
                    // print("COURSE REP");
                    // Navigator.pop(context); // Action for the button
                  },
                  icon: Container(
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: const Icon(
                            Icons.admin_panel_settings,
                            color: Colors.black,
                          ),
                        ),
                        Text("Admin",style: TextStyle(fontWeight: FontWeight.bold),)
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        elevation: 0,
        bottom: PreferredSize(
        preferredSize: const Size.fromHeight(0),
        child: Container(
          color: primaryColor, // Transparent background
          child: Container(
            height: 1.0, // Thickness of the bottom border
            color: Colors.transparent, // Color of the bottom border
          ),
        ),
      ),
        ),
        body: _pages[_selectedIndex], // Display the current page
        bottomNavigationBar: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.schedule),
              label: 'Schedules',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
          currentIndex: _selectedIndex, // Set the current index
          selectedItemColor: primaryColor, // Use primary color for selected item
          onTap: _onItemTapped, // Handle tap on items
        ),
      ),
    );
  }
}

