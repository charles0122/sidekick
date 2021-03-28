import 'package:sidekick/components/atoms/cache_size_display.dart';
import 'package:sidekick/components/atoms/typography.dart';
import 'package:sidekick/providers/installed_versions.provider.dart';
import 'package:sidekick/providers/fvm_console_provider.dart';
import 'package:sidekick/providers/flutter_projects_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class Console extends HookWidget {
  final List<ConsoleLine> lines;
  final bool expand;
  final bool processing;
  final Function() onExpand;
  const Console({
    this.lines,
    this.expand = false,
    this.processing = false,
    this.onExpand,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final output = useProvider(combinedConsoleProvider);
    final lines = useState<List<String>>(['']);
    final installedList = useProvider(installedVersionsProvider);
    final projects = useProvider(projectsProvider.state);

    useValueChanged(output, (_, __) {
      lines.value.insert(0, output.data.value);
      if (lines.value.length > 100) {
        lines.value.removeAt(lines.value.length - 1);
      }
    });

    return AnimatedCrossFade(
      duration: const Duration(milliseconds: 250),
      crossFadeState:
          processing ? CrossFadeState.showSecond : CrossFadeState.showFirst,
      firstChild: Container(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.black45
            : const Color(0xFFF5F5F5),
        height: 40,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(width: 20),
            installedList.isNotEmpty
                ? Caption('${installedList.length} Versions')
                : const Caption('Versions'),
            const SizedBox(width: 20),
            const CacheSizeDisplay(),
            const SizedBox(width: 20),
            projects.loading
                ? const Caption('Loading Projects...')
                : Caption('${projects.list.length} Projects'),
            const SizedBox(width: 20),
          ],
        ),
      ),
      secondChild: GestureDetector(
        onTap: onExpand,
        child: Container(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.black45
              : const Color(0xFFF5F5F5),
          height: expand ? 160 : 40,
          constraints: expand
              ? const BoxConstraints(maxHeight: 160)
              : const BoxConstraints(maxHeight: 40),
          child: Stack(
            children: [
              AnimatedCrossFade(
                duration: const Duration(milliseconds: 250),
                crossFadeState: expand
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                firstChild: Container(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      StdoutText(lines.value.first),
                    ],
                  ),
                ),
                secondChild: Scrollbar(
                  child: ListView.builder(
                    shrinkWrap: true,
                    reverse: true,
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                    itemBuilder: (context, index) {
                      final line = lines.value[index];
                      if (line == OutputType.stdout) {
                        return StdoutText(
                          lines.value[index],
                          key: Key(lines.value[index]),
                        );
                      } else {
                        return StdoutText(
                          lines.value[index],
                          key: Key(lines.value[index]),
                        );
                      }
                    },
                    itemCount: lines.value.length,
                  ),
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: Row(
                  children: [
                    const SpinKitFadingFour(color: Colors.cyan, size: 15),
                    IconButton(
                      onPressed: null,
                      icon: expand
                          ? const Icon(MdiIcons.chevronDown)
                          : const Icon(MdiIcons.chevronUp),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
