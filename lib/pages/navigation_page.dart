import 'package:alumni/pages/about.dart';
import 'package:alumni/pages/profile.dart';
import 'package:flutter/material.dart';

class NavigationPage extends StatefulWidget {
  final String docID;
  const NavigationPage({super.key, required this.docID});

  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

const _navBarItems = [
  BottomNavigationBarItem(
    icon: Icon(
      Icons.person_outline_rounded,
      color: Color.fromARGB(255, 120, 120, 120),
    ),
    activeIcon: Icon(
      Icons.person_rounded,
      color: Color.fromARGB(255, 60, 60, 60),
    ),
    label: 'Profile',

  ),
  BottomNavigationBarItem(
    icon: Icon(
      Icons.info_outline,
      color: Color.fromARGB(255, 120, 120, 120),
    ),
    activeIcon: Icon(
      Icons.info,
      color: Color.fromARGB(255, 60, 60, 60),
    ),
    label: 'About',
  ),
];


class _NavigationPageState extends State<NavigationPage> {
  int _selectedIndex = 0;
  late String documentID;

  @override
  void initState() {
    super.initState();
    documentID = widget.docID;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (documentID.isEmpty && ModalRoute.of(context)?.settings.arguments != null) {
      documentID = ModalRoute.of(context)!.settings.arguments as String;
    }
  }

  //Scrolling through pages

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final bool isSmallScreen = width < 600;
    final bool isLargeScreen = width > 800;

    final pages = [
      ProfileScreen(docID: documentID),
      const About(),
    ];

    return Scaffold(
      bottomNavigationBar: isSmallScreen
          ? BottomNavigationBar(
              backgroundColor: const Color(0xFF0b0a5f),
              unselectedItemColor: const Color.fromARGB(255, 120, 120, 120),
              selectedItemColor: const Color.fromARGB(255, 250, 244, 244),
              selectedLabelStyle: const TextStyle(
                fontSize: 15
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 15
              ),
              items: _navBarItems,
              currentIndex: _selectedIndex,
              onTap: (int index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
            )
          : null,
      body: Row(
        children: <Widget>[
          if (!isSmallScreen)
            NavigationRail(
              backgroundColor: const Color(0xFF0b0a5f),
              //leading start
              leading: Center(
                child: Container(
                  padding: EdgeInsets.all(8),
                  child: Column(
                    children: [
                      Image.network(
                          'https://lh3.googleusercontent.com/d/1CcRXI71dz-jmNoZF_JZ2T0cq9NuyNq6t',
                          scale: 12),
                      const SizedBox(
                        height: 15,
                      ),
                      const Text(
                        'Our Lady of Perpetual Succor College',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color.fromRGBO(255, 255, 248, 1)),
                      ),
                      const Text(
                        'Alumni Tracking System',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color.fromRGBO(240, 240, 240, 1)),
                      ),
                    ],
                  ),
                ),
              ),
              //leading end
              selectedIndex: _selectedIndex,
              onDestinationSelected: (int index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              extended: isLargeScreen,
              destinations: _navBarItems
                  .map((item) => NavigationRailDestination(
                      icon: item.icon,
                      selectedIcon: item.activeIcon,
                      label: Text(
                        item.label!,
                        // TEXT ITO
                        style: TextStyle(
                            color: Color.fromARGB(255, 238, 231, 231),
                            fontSize: 15),
                      )))
                  .toList(),
            ),
          const VerticalDivider(thickness: 1, width: 1),

          // Main Content of the Navigation Bar/Rail (📌📌📌📌📌)
          Expanded(child: pages[_selectedIndex])
        ],
      ),
    );
  }
}

@override
Widget build(BuildContext context) {
  return Scaffold(
    body: Container(),
  );
}
