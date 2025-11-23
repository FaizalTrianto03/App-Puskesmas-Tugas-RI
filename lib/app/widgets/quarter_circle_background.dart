import 'package:flutter/material.dart';

class QuarterCircleBackground extends StatelessWidget {
  final Widget child;
  
  const QuarterCircleBackground({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          color: const Color(0xFFF1F9FF),
        ),
        // Use Positioned.fill with IgnorePointer to keep circle fixed behind content
        Positioned.fill(
          child: IgnorePointer(
            child: Stack(
              children: [
                Positioned(
                  bottom: -420,
                  right: -300,
                  child: Container(
                    width: 720,
                    height: 720,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.bottomLeft,
                        end: Alignment.topRight,
                        colors: [
                          const Color(0xFF02B1BA).withOpacity(0.45),
                          const Color(0xFF84F3EE).withOpacity(0.25),
                          const Color(0xFF84F3EE).withOpacity(0.0),
                        ],
                        stops: const [0.0, 0.55, 1.0],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        child,
      ],
    );
  }
}
