import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AnimatedImage extends StatefulWidget {
  final File imageFile;

  const AnimatedImage({super.key, required this.imageFile});

  @override
  State<AnimatedImage> createState() => _AnimatedImageState();
}

class _AnimatedImageState extends State<AnimatedImage> {
  String? selectedEffect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: Column(
        children: [
          Expanded(
            child: Animate(
              effects: _getSelectedEffect(),
              child: Image.file(widget.imageFile),
            ),
          ),
          const SizedBox(height: 10),
          DropdownButton<String>(
            value: selectedEffect,
            hint: const Text('Animation'),
            items: <String>['Fade In', 'Scale', 'Move Up','Blur','Flip','Rotate']
                .map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                selectedEffect = newValue;
              });
            },
          ),
        ],
      ),
    );
  }

  List<Effect> _getSelectedEffect() {
    switch (selectedEffect) {
      case 'Fade In':
        return [
          FadeEffect(duration: 1000.ms, curve: Curves.easeIn)];
      case 'Scale':
        return [ScaleEffect(begin: const Offset(0, 50), end: const Offset(0, 0), duration: 1000.ms)];
      case 'Move Up':
        return [MoveEffect(begin: const Offset(0, 50), end: const Offset(0, 0), duration: 1000.ms)];
      case 'Blur':
        return [BlurEffect(duration: 1000.ms, curve: Curves.easeIn)];
      case 'Flip':
        return [FlipEffect(duration: 1000.ms, curve: Curves.easeIn)];
      case 'Rotate':
        return [RotateEffect(duration: 1000.ms, curve: Curves.easeIn)
        ];
      default:
        return [];
    }
  }
}
