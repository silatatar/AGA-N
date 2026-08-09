import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/again_tokens.dart';
import '../../../core/widgets/again_components.dart';
import '../../opening/presentation/opening_atmosphere.dart';
import '../domain/world_chapter.dart';
import '../domain/world_region.dart';

class ChapterIntroPlaceholderScreen extends StatelessWidget {
  const ChapterIntroPlaceholderScreen({
    super.key,
    required this.region,
    required this.chapter,
  });
  final WorldRegion region;
  final WorldChapter chapter;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AgainColors.night950,
    body: OpeningAtmosphere(
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AgainSpacing.lg),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: AgainCard(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        tooltip: 'Bölümlere dön',
                        onPressed: context.pop,
                        icon: const Icon(Icons.arrow_back_rounded),
                      ),
                    ),
                    const Icon(
                      Icons.auto_stories_rounded,
                      size: 58,
                      color: AgainColors.turquoise300,
                    ),
                    const SizedBox(height: AgainSpacing.md),
                    Text(
                      '${chapter.number}. Bölüm · ${chapter.title}',
                      key: const Key('chapter-intro-title'),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(color: AgainColors.gold400),
                    ),
                    const SizedBox(height: AgainSpacing.sm),
                    Text(
                      '${region.title} öğrenme deneyimi bir sonraki fazda başlayacak.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
