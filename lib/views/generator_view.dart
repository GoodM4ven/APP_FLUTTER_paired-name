import 'dart:math' as math;

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:paired_name_app/constants/colors.dart';
import 'package:paired_name_app/helpers/size.dart';
import 'package:paired_name_app/widgets/dynamically_sized_text.dart';
import 'package:rive/rive.dart' as rive;
import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:paired_name_app/constants/icons.dart';
import 'package:paired_name_app/helpers/string.dart';
import 'package:paired_name_app/providers/pair_provider.dart';

class GeneratorView extends StatefulWidget {
  const GeneratorView({super.key});

  @override
  State<GeneratorView> createState() => _GeneratorViewState();
}

class _GeneratorViewState extends State<GeneratorView> {
  bool _isBookmarkAnimationVisible = false;
  double _infoButtonOpacity = 0.5;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final pairState = ref.watch(pairProvider);
        final pairNotifier = ref.read(pairProvider.notifier);

        final icon = pairState.bookmarkedPairs.contains(pairState.currentPair)
            ? ConstantIcons.bookmark
            : ConstantIcons.unbookmark;

        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Expanded(
                flex: 2,
                child: RecentlyGeneratedPairsList(),
              ),
              const SizedBox(height: 10),
              PairCard(pair: pairState.currentPair),
              const SizedBox(height: 20),
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth < 300) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildBookmarkButton(context, icon, pairNotifier),
                        const SizedBox(height: 15),
                        ElevatedButton(
                          onPressed: () => pairNotifier.generatePair(),
                          child: const Text('Generate'),
                        ),
                      ],
                    );
                  }

                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildBookmarkButton(context, icon, pairNotifier),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () => pairNotifier.generatePair(),
                        child: const Text('Generate'),
                      ),
                    ],
                  );
                },
              ),
              const Spacer(flex: 1),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: MouseRegion(
                  onEnter: (_) => setState(() => _infoButtonOpacity = 1.0),
                  onExit: (_) => setState(() => _infoButtonOpacity = 0.5),
                  child: GestureDetector(
                    onTapDown: (_) => setState(() => _infoButtonOpacity = 1.0),
                    onTapUp: (_) => setState(() => _infoButtonOpacity = 0.5),
                    onTapCancel: () => setState(() => _infoButtonOpacity = 0.5),
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 350),
                      opacity: _infoButtonOpacity,
                      child: IconButton.outlined(
                        padding: EdgeInsets.zero,
                        icon: const Icon(ConstantIcons.info),
                        onPressed: () {
                          _showWhyDialog(context);
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showWhyDialog(BuildContext context) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: DynamicallySizedText(
            'Why',
            maxLines: 1,
            style: theme.textTheme.bodyMedium!.copyWith(
              fontWeight: FontWeight.w400,
              fontSize: 22,
            ),
          ),
          content: DynamicallySizedText(
            'Generate intriguing name pairs to spark creativity, and bookmark those that inspire an idea to build on it later!',
            maxLines: 4,
            style: theme.textTheme.bodyMedium!.copyWith(
              fontWeight: FontWeight.w400,
              fontSize: 17,
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const DynamicallySizedText(
                'Okay',
                maxLines: 1,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBookmarkButton(
    BuildContext context,
    IconData icon,
    PairNotifier pairNotifier,
  ) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Positioned(
          width: 150,
          height: 150,
          child: AnimatedOpacity(
            opacity: _isBookmarkAnimationVisible ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: const SizedBox(
              width: 150,
              height: 150,
              child: rive.RiveAnimation.asset(
                'assets/rive-animations/sparkle-now.riv',
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
            ),
          ),
        ),
        MouseRegion(
          onEnter: (_) => _setBookmarkAnimationVisibility(true),
          onExit: (_) => _setBookmarkAnimationVisibility(false),
          child: GestureDetector(
            onLongPressStart: (_) => _setBookmarkAnimationVisibility(true),
            onLongPressEnd: (_) => _setBookmarkAnimationVisibility(false),
            child: ElevatedButton.icon(
              onPressed: () {
                if (pairNotifier.toggleBookmark()) {
                  _setBookmarkAnimationVisibility(true);

                  Future.delayed(
                    const Duration(milliseconds: 500),
                    () => _setBookmarkAnimationVisibility(false),
                  );
                }
              },
              icon: Icon(icon),
              label: const Text('Bookmark'),
            ),
          ),
        ),
      ],
    );
  }

  void _setBookmarkAnimationVisibility(bool isVisible) {
    setState(() => _isBookmarkAnimationVisible = isVisible);
  }
}

class RecentlyGeneratedPairsList extends StatefulWidget {
  const RecentlyGeneratedPairsList({super.key});

  @override
  State<RecentlyGeneratedPairsList> createState() =>
      _RecentlyGeneratedPairsListState();
}

class _RecentlyGeneratedPairsListState
    extends State<RecentlyGeneratedPairsList> {
  // ? Needed for the list animation in provider
  final _key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    const double tiltAngle = math.pi / 9;
    const double tiltPerspective = 0.0002;

    return Consumer(builder: (context, ref, child) {
      final pairState = ref.watch(pairProvider);
      final pairNotifier = ref.read(pairProvider.notifier);

      final latestGeneratedPairs = pairState.latestGeneratedPairs;

      pairNotifier.latestGeneratedPairsListKey = _key;

      return Stack(
        children: [
          // * Apply a 3D transformation (tilt) to the entire container
          Transform(
            alignment: FractionalOffset.bottomCenter,
            transform: Matrix4.identity()
              ..setEntry(3, 2, tiltPerspective)
              ..rotateX(-tiltAngle),
            child: ShaderMask(
              // * Fades out the items at the top
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Colors.transparent, Colors.black],
                stops: [0.0, 0.5],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ).createShader(bounds),
              blendMode: BlendMode.dstIn,
              child: AnimatedList(
                key: _key,
                reverse: true,
                padding: const EdgeInsets.only(top: 100),
                physics: const NeverScrollableScrollPhysics(),
                initialItemCount: latestGeneratedPairs.length,
                itemBuilder: (context, index, animation) {
                  final pair = latestGeneratedPairs[index];
                  final icon = pairState.bookmarkedPairs.contains(pair)
                      ? const Icon(ConstantIcons.bookmark, size: 12)
                      : null;

                  return SizeTransition(
                    sizeFactor: animation,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        vertical:
                            HelperSize.hasScreenSafeArea(context) ? 0 : 10,
                      ),
                      child: Center(
                        child: TextButton.icon(
                          onPressed: () => pairNotifier.toggleBookmark(pair),
                          icon: icon,
                          label: Text(
                            pair.asPascalCase,
                            semanticsLabel: pair.asPascalCase,
                            style: const TextStyle(fontSize: 17),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: Container(
                height: 18,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      ConstantColors.pink.withOpacity(0),
                      ConstantColors.pink,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    });
  }
}

class PairCard extends StatelessWidget {
  final WordPair pair;

  const PairCard({
    super.key,
    required this.pair,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    // * Measure the width of the text
    final textPainter = TextPainter(
      text: TextSpan(text: pair.asLowerCase, style: style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();
    final double textWidth = textPainter.width + 70;
    final double maxWidth = MediaQuery.of(context).size.width * 0.8;

    // * Adjust the base font size relative to the available container width
    double containerWidth = textWidth.clamp(100.0, maxWidth);
    double padding = 20.0; // * A consistent padding
    double baseFontSize = (containerWidth - 2 * 10) * 0.15;
    double maxFontSize = theme.textTheme.displayMedium!.fontSize ?? 24.0;
    double dynamicFontSize = baseFontSize.clamp(16.0, maxFontSize);

    return Center(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        width: containerWidth,
        height: math.min(baseFontSize * 3.5, 85),
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 12,
              spreadRadius: 1,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              switchInCurve: Curves.easeInOut,
              switchOutCurve: Curves.easeInOut,
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
              child: Align(
                alignment: Alignment.center,
                key: ValueKey(pair),
                child: MergeSemantics(
                  child: OverflowBox(
                    alignment: Alignment.center,
                    minWidth: 0.0,
                    maxWidth: double.infinity,
                    child: FittedBox(
                      // * Ensures the text scales down to fit within its parent
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            HelperString.toTitleCase(pair.first),
                            style: style.copyWith(
                              fontWeight: FontWeight.w300,
                              fontSize: dynamicFontSize,
                            ),
                            softWrap: false,
                          ),
                          Text(
                            pair.second.toUpperCase(),
                            style: style.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: dynamicFontSize,
                            ),
                            softWrap: false,
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
