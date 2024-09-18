import 'package:flutter/material.dart';
import 'package:paired_name_app/constants/colors.dart';
import 'package:paired_name_app/constants/icons.dart';
import 'package:paired_name_app/helpers/size.dart';
import 'package:paired_name_app/views/bookmarks_view.dart';
import 'package:paired_name_app/views/generator_view.dart';
import 'package:paired_name_app/widgets/less_than_minimum_screens_scaffold_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var selectedViewIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final view =
        selectedViewIndex == 0 ? const GeneratorView() : const BookmarksView();
    final animatedView = ColoredBox(
      // * Background color persistance
      color: theme.colorScheme.surfaceContainerHighest,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: ColoredBox(
              // * Inner color persistance
              color: theme.colorScheme.primaryContainer,
              child: child,
            ),
          );
        },
        child: Container(
          key: ValueKey<int>(selectedViewIndex),
          child: view,
        ),
      ),
    );

    // * Crash for less than minimum screens
    if (HelperSize.isLessThanMinimumScreen(context)) {
      return const LessThanMinimumScreensScaffoldWidget();
    }

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 600) {
            // * Having a bottom navigation bar for mobile screens
            return Column(
              children: [
                Expanded(child: animatedView),
                SizedBox(
                  height: 80,
                  child: BottomNavigationBar(
                    selectedFontSize: 16,
                    unselectedFontSize: 14,
                    selectedIconTheme: const IconThemeData(size: 30),
                    unselectedIconTheme: const IconThemeData(size: 26),
                    items: const [
                      BottomNavigationBarItem(
                        icon: Icon(ConstantIcons.generate),
                        label: 'Generator',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(ConstantIcons.bookmark),
                        label: 'Bookmarks',
                      ),
                    ],
                    currentIndex: selectedViewIndex,
                    onTap: (value) {
                      setState(() => selectedViewIndex = value);
                    },
                  ),
                ),
              ],
            );
          }

          // * Having otherwise a rail navigation bar to the side
          return Row(
            children: [
              // * Respects the device's status bar, for instance
              SafeArea(
                child: NavigationRail(
                  extended: constraints.maxWidth >= 800, // * Responsivity
                  selectedLabelTextStyle: TextStyle(
                    fontSize: 16,
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                  unselectedLabelTextStyle: const TextStyle(
                    fontSize: 14,
                    color: ConstantColors.gray,
                  ),
                  selectedIconTheme: IconThemeData(
                    size: 30,
                    color: theme.colorScheme.primary,
                  ),
                  unselectedIconTheme: const IconThemeData(
                    size: 26,
                    color: ConstantColors.gray,
                  ),
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(ConstantIcons.generate),
                      label: Text('Generator'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(ConstantIcons.bookmark),
                      label: Text('Bookmarks'),
                    ),
                  ],
                  selectedIndex: selectedViewIndex,
                  onDestinationSelected: (value) {
                    setState(() => selectedViewIndex = value);
                  },
                ),
              ),
              Expanded(child: animatedView),
            ],
          );
        },
      ),
    );
  }
}
