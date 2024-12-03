import 'package:flutter/material.dart';
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
  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.containerWidth,
      height: widget.containerHeight,
      margin: EdgeInsets.symmetric(horizontal: widget.maxWidth * 0.01),
      decoration: BoxDecoration(
        //color: Colors.black,
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(5),
        //cor da borda
        border: Border.all(
          color: Colors.grey[800]!,
          width: 0.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(0.0),
        child: Column(
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
                          color: Colors.grey,
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.arrow_forward_ios_outlined,
                          color: Colors.grey,
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
              color: Colors.grey[800],
            ),
            Expanded(
              flex: 1,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: widget.value != null
                      ? Text(
                          widget.value!,
                          style: SafeGoogleFont(
                            'Open Sans',
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        )
                      : CircularProgressIndicator(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
