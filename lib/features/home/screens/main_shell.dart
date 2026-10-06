import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/library_provider.dart';
import 'home_screen.dart';
import '../../heatmap/screens/heatmap_screen.dart';
import '../../history/screens/history_screen.dart';
import '../../settings/screens/settings_screen.dart';

class MainShell extends StatefulWidget {
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedTab = 0;

  late LibraryProvider _libraryProvider;
  bool _providerReady = false;

  // Used to detect when the monitored library changes
  // from "has space" to "full".
  String? _lastMonitoredLibraryId;
  bool? _lastMonitoredWasFull;

  // Prevents the same alert from opening twice.
  bool _alertShowing = false;

  final List<Widget> _screens = [
    HomeScreen(),
    HeatmapScreen(),
    HistoryScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      if (!mounted) return;

      _libraryProvider = context.read<LibraryProvider>();
      _providerReady = true;

      _libraryProvider.addListener(_checkHeadingLibrary);
      _libraryProvider.startListening();
    });
  }

  void _checkHeadingLibrary() {
    if (!mounted) return;

    final provider = _libraryProvider;
    final monitoredLibrary = provider.headingToLibrary;

    // Student is not heading anywhere.
    if (monitoredLibrary == null) {
      _lastMonitoredLibraryId = null;
      _lastMonitoredWasFull = null;
      return;
    }

    final String currentLibraryId = monitoredLibrary.libraryId;
    final bool isFull = !monitoredLibrary.hasSpace;

    // Student has just selected a library.
    // Store its current state as our starting point.
    if (_lastMonitoredLibraryId != currentLibraryId) {
      _lastMonitoredLibraryId = currentLibraryId;
      _lastMonitoredWasFull = isFull;
      return;
    }

    // Detect the exact change:
    // had space before → full now.
    final bool justBecameFull =
        _lastMonitoredWasFull == false && isFull == true;

    _lastMonitoredWasFull = isFull;

    if (!justBecameFull || _alertShowing) {
      return;
    }

    _alertShowing = true;

    // Find the best available alternative using the
    // recommendation logic already built into LibraSpace.
    final alternative = provider.recommendedLibrary;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return AlertDialog(
            icon: const Icon(
              Icons.warning_amber_rounded,
              size: 42,
              color: Colors.orange,
            ),
            title: Text('${monitoredLibrary.title} is now full'),
            content: Text(
              alternative != null
                  ? 'The library filled up while you were on your way.\n\n'
                        '${alternative.title} currently has '
                        '${alternative.freeSeats} seats available.'
                  : 'The library filled up while you were on your way.\n\n'
                        'There are currently no other libraries with free seats.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);

                  provider.stopHeadingTo();

                  setState(() {
                    _selectedTab = 0;
                  });

                  _alertShowing = false;
                },
                child: const Text('View alternatives'),
              ),
            ],
          );
        },
      ).then((_) {
        _alertShowing = false;
      });
    });
  }

  @override
  void dispose() {
    if (_providerReady) {
      _libraryProvider.removeListener(_checkHeadingLibrary);
      _libraryProvider.stopListening();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedTab, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedTab,
        onDestinationSelected: (int newIndex) {
          setState(() => _selectedTab = newIndex);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.local_fire_department_outlined),
            selectedIcon: Icon(Icons.local_fire_department_rounded),
            label: 'Heatmap',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history),
            label: 'History',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outlined),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
