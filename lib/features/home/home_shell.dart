import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// Bottom navigation around the four main tabs, with the QR scanner in the
/// middle where it is easiest to reach.
class HomeShell extends StatelessWidget {
  const HomeShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  static const _scanIndex = 2;

  @override
  Widget build(BuildContext context) {
    // The scanner is a full screen pushed on top, not a tab, so the bar has
    // one more item than there are tabs.
    final selected = shell.currentIndex < _scanIndex
        ? shell.currentIndex
        : shell.currentIndex + 1;

    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selected,
        onDestinationSelected: (index) {
          if (index == _scanIndex) {
            context.push('/scan');
            return;
          }
          final branch = index < _scanIndex ? index : index - 1;
          shell.goBranch(branch, initialLocation: branch == shell.currentIndex);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(icon: Icon(Icons.search), label: 'Browse'),
          NavigationDestination(
            icon: Icon(Icons.qr_code_scanner),
            label: 'Scan',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border),
            selectedIcon: Icon(Icons.favorite),
            label: 'Saved',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Account',
          ),
        ],
      ),
    );
  }
}
