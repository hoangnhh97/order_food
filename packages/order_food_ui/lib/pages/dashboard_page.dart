import 'package:flutter/material.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _toggleDrawer() {
    if (_scaffoldKey.currentState!.isDrawerOpen) {
      Navigator.of(context).pop();
    } else {
      _scaffoldKey.currentState!.openDrawer();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              child: const Text(
                'Admin Material',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.dashboard),
              title: Text('Dashboard'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.pushNamed(context, '/'); // Navigate to Dashboard
              },
            ),
            ListTile(
              leading: Icon(Icons.pageview),
              title: Text('Ăn Gì Hôm Nay?'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.pushNamed(
                    context, '/list_food_page'); // Navigate to New Page
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: <Widget>[
          Container(
            color: Theme.of(context).colorScheme.primary,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            height: 56.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                IconButton(
                  icon: const Icon(Icons.menu, color: Colors.white),
                  onPressed: _toggleDrawer,
                ),
                const Text(
                  'Dashboard',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                Row(
                  children: <Widget>[
                    IconButton(
                      icon:
                          const Icon(Icons.notifications, color: Colors.white),
                      tooltip: 'Notifications',
                      onPressed: () {
                        // Handle the press
                      },
                    ),
                    IconButton(
                      icon:
                          const Icon(Icons.account_circle, color: Colors.white),
                      tooltip: 'User Account',
                      onPressed: () {
                        // Handle the press
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                'Welcome to the Dashboard',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
