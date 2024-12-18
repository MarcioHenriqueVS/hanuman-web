import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../../utils.dart';

class StatsContainers extends StatefulWidget {
  final String title;
  final String? value;
  final double containerWidth;
  final double containerHeight;
  final double maxWidth;
  final bool loading;
  const StatsContainers(
      {super.key,
      required this.title,
      required this.value,
      required this.containerWidth,
      required this.containerHeight,
      required this.maxWidth,
      required this.loading});

  @override
  State<StatsContainers> createState() => _StatsContainersState();
}

class _StatsContainersState extends State<StatsContainers> {
  Widget _buildContainerContent() {
    return Column(
      children: [
        Expanded(
          flex: 1,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.title,
                    style: SafeGoogleFont(
                      'Open Sans',
                      fontSize: 16,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.7),
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.arrow_forward_ios_outlined,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.7),
                      size: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Container(
          height: 0.5,
          width: double.infinity,
          color: Theme.of(context).dividerColor,
        ),
        Expanded(
          flex: 1,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                widget.value ?? '0',
                style: SafeGoogleFont(
                  'Open Sans',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildShimmerEffect() {
    return Shimmer.fromColors(
      baseColor: Theme.of(context).scaffoldBackgroundColor,
      highlightColor: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.8),
      child: _buildContainerContent(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 125),
      child: Container(
        width: widget.containerWidth,
        height: widget.containerHeight,
        margin: EdgeInsets.symmetric(horizontal: widget.maxWidth * 0.01),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
            color: Theme.of(context).dividerColor,
            width: 0.5,
          ),
        ),
        child: widget.value != null
            ? _buildContainerContent()
            : _buildShimmerEffect(),
      ),
    );
  }
}
