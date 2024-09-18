import 'dart:math';

import 'package:dotted_decoration/dotted_decoration.dart';
import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:paired_name_app/constants/colors.dart';
import 'package:paired_name_app/constants/icons.dart';
import 'package:paired_name_app/helpers/size.dart';
import 'package:paired_name_app/helpers/string.dart';
import 'package:paired_name_app/providers/pair_provider.dart';
import 'package:paired_name_app/widgets/dynamically_sized_text.dart';
import 'package:wave_divider/wave_divider.dart';

class BookmarksView extends StatefulWidget {
  const BookmarksView({super.key});

  @override
  State<BookmarksView> createState() => _BookmarksViewState();
}

class _BookmarksViewState extends State<BookmarksView>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();

  late final AnimationController _arrowsAnimationController;
  late final Animation<double> _upArrowAnimation;
  late final Animation<double> _downArrowAnimation;

  bool _showTopScrollIndicator = false;
  bool _showBottomScrollIndicator = true;

  @override
  void initState() {
    super.initState();

    _arrowsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    )..repeat(reverse: true);
    _upArrowAnimation = CurvedAnimation(
      parent: _arrowsAnimationController,
      curve: Curves.easeInOutQuad,
    );
    _downArrowAnimation = CurvedAnimation(
      parent: _arrowsAnimationController,
      curve: Curves.easeInOutQuad,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) => _onScroll());
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _arrowsAnimationController.dispose();

    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      final newShowTopScrollIndicator =
          _scrollController.position.extentBefore > 0;
      final newShowBottomScrollIndicator =
          _scrollController.position.extentAfter > 0;

      if (newShowTopScrollIndicator != _showTopScrollIndicator ||
          newShowBottomScrollIndicator != _showBottomScrollIndicator) {
        setState(() {
          _showTopScrollIndicator = newShowTopScrollIndicator;
          _showBottomScrollIndicator = newShowBottomScrollIndicator;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final pairState = ref.watch(pairProvider);
        final pairNotifier = ref.read(pairProvider.notifier);

        final theme = Theme.of(context);

        if (pairState.bookmarkedPairs.isEmpty) {
          return Center(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final double calculatedFontSize = constraints.maxWidth * 0.1;
                final double limitedFontSize = min(calculatedFontSize, 24.5);

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Text(
                    'No bookmarked pairs yet.',
                    style: theme.textTheme.bodySmall!.copyWith(
                      fontSize: limitedFontSize,
                      color: ConstantColors.gray,
                    ),
                  ),
                );
              },
            ),
          );
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            double calculatedFontSize = constraints.maxWidth * 0.08;
            double limitedFontSize = min(calculatedFontSize, 24);
            bool isSmallScreen = MediaQuery.of(context).size.width < 400;

            WidgetsBinding.instance.addPostFrameCallback((_) => _onScroll());

            return Column(
              children: [
                Stack(
                  children: [
                    _buildBookmarksTitle(
                      context,
                      pairState,
                      limitedFontSize,
                      isSmallScreen,
                    ),
                    if (_showTopScrollIndicator)
                      AnimatedBuilder(
                        animation: _upArrowAnimation,
                        builder: (context, child) {
                          return Positioned(
                            bottom: 0 + (10 * _upArrowAnimation.value),
                            left: 0,
                            right: 0,
                            child: const Icon(
                              ConstantIcons.scrollUpward,
                              color: ConstantColors.gray,
                            ),
                          );
                        },
                      ),
                  ],
                ),
                Expanded(
                  child: Stack(
                    children: [
                      NotificationListener<ScrollNotification>(
                        onNotification: (ScrollNotification notification) {
                          if (notification is ScrollStartNotification ||
                              notification is ScrollUpdateNotification ||
                              notification is ScrollEndNotification) {
                            _onScroll();
                          }
                          return true;
                        },
                        child: GridView.builder(
                          padding: const EdgeInsets.only(
                            left: 20,
                            right: 20,
                            bottom: 20,
                            top: 10,
                          ),
                          controller: _scrollController,
                          gridDelegate:
                              SliverGridDelegateWithMaxCrossAxisExtent(
                            mainAxisExtent:
                                HelperSize.isNearMinimumScreen(context)
                                    ? 75
                                    : 50,
                            maxCrossAxisExtent: 400,
                            childAspectRatio: 400 / 75,
                            crossAxisSpacing: 50,
                            mainAxisSpacing: 20,
                          ),
                          itemCount: pairState.bookmarkedPairs.length,
                          itemBuilder: (context, index) {
                            var pair = pairState.bookmarkedPairs[index];
                            return Container(
                              decoration: DottedDecoration(
                                shape: Shape.box,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: ListTile(
                                leading: Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: IconButton(
                                    icon: const Icon(
                                      ConstantIcons.bookmark,
                                      semanticLabel: 'Remove',
                                      size: 25,
                                    ),
                                    color: theme.colorScheme.primary,
                                    onPressed: () => _showDeletionConfirmation(
                                      context,
                                      pair,
                                      pairNotifier,
                                    ),
                                  ),
                                ),
                                title: Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Text(
                                    "${pair.first}${HelperSize.isNearMinimumScreen(context) ? '\n' : ''}${HelperString.toTitleCase(pair.second)}",
                                    softWrap:
                                        HelperSize.isNearMinimumScreen(context),
                                    semanticsLabel: pair.asPascalCase,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      // Top Gradient
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 10, // Adjust height to control gradient size
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                ConstantColors.pink.withOpacity(1),
                                ConstantColors.pink.withOpacity(0),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Bottom Gradient
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 10, // Adjust height to control gradient size
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                ConstantColors.pink.withOpacity(1),
                                ConstantColors.pink.withOpacity(0),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Stack(
                  children: [
                    if (_showBottomScrollIndicator)
                      AnimatedBuilder(
                        animation: _downArrowAnimation,
                        builder: (context, child) {
                          return Positioned(
                            top: 5 + (10 * _downArrowAnimation.value),
                            left: 0,
                            right: 0,
                            child: const Icon(
                              ConstantIcons.scrollDownward,
                              color: ConstantColors.gray,
                            ),
                          );
                        },
                      ),
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 35,
                        bottom: 15.0,
                      ),
                      child: WaveDivider(color: theme.colorScheme.onSurface),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildBookmarksTitle(
    BuildContext context,
    PairState pairState,
    double limitedFontSize,
    bool isSmallScreen,
  ) {
    final theme = Theme.of(context);
    final style = theme.textTheme.headlineMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );
    final bookmarkedPairs = pairState.bookmarkedPairs;

    return Padding(
      padding: EdgeInsets.only(
        bottom: !HelperSize.hasScreenSafeArea(context) ? 17.5 : 40,
      ),
      child: Card(
        elevation: 0,
        margin: !HelperSize.hasScreenSafeArea(context)
            ? const EdgeInsets.symmetric(vertical: 25)
            : const EdgeInsets.only(top: 50),
        color: Colors.transparent,
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: theme.colorScheme.primary,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 15,
          ),
          child: MergeSemantics(
            child: isSmallScreen
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Your',
                            style: style.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w500,
                              fontSize: limitedFontSize,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            '${bookmarkedPairs.length}',
                            style: style.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: limitedFontSize,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Bookmarked ${bookmarkedPairs.length < 2 ? 'Pair' : 'Pairs'}',
                        style: style.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w500,
                          fontSize: limitedFontSize,
                        ),
                      ),
                    ],
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Your',
                        style: style.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w500,
                          fontSize: limitedFontSize,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '${bookmarkedPairs.length}',
                        style: style.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: limitedFontSize,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Bookmarked ${bookmarkedPairs.length < 2 ? 'Pair' : 'Pairs'}',
                        style: style.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w500,
                          fontSize: limitedFontSize,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  void _showDeletionConfirmation(
    BuildContext context,
    WordPair pair,
    PairNotifier pairNotifier,
  ) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const DynamicallySizedText(
            'Confirmation',
            maxLines: 1,
          ),
          content: DynamicallySizedText(
            'Do you want to remove ${pair.asPascalCase} pair?',
            maxLines: 4,
            style: theme.textTheme.bodyMedium!.copyWith(
              fontWeight: FontWeight.w400,
              fontSize: 15,
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const DynamicallySizedText(
                'Cancel',
                maxLines: 1,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();

                pairNotifier.removeFromBookmarks(pair);
              },
              child: const DynamicallySizedText(
                'Confirm',
                maxLines: 1,
              ),
            ),
          ],
        );
      },
    );
  }
}
