import 'dart:async';

import 'package:flutter/material.dart';

import '../utils.dart';

class CalcInputWidget extends StatelessWidget {
  final IconData? icon;
  final String input;
  final VoidCallback? onPressed, onLongPressed, onTouch;
  final bool isDisplay;
  const CalcInputWidget(this.input,
      {super.key,
      this.icon,
      this.onPressed,
      this.onLongPressed,
      this.onTouch,
      this.isDisplay = false});

  @override
  Widget build(BuildContext context) {
    return InkWell(
        splashColor: isDisplay ? Colors.transparent : null,
        highlightColor: isDisplay ? Colors.transparent : null,
        onTap: onPressed,
        onLongPress: onLongPressed,
        onHover: (value) {
          if (onTouch != null) onTouch!();
        },
        child: Container(
          alignment: Alignment.center,
          width: !isDisplay ? double.infinity : null,
          height: !isDisplay ? double.infinity : null,
          child: icon != null
              ? Icon(
                  icon,
                  size: 20,
                  color: Colors.red,
                )
              : Text(
                  input,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: isDisplay ? Colors.white : getTextColor(input),
                      fontSize: isDisplay ? 20 : 22,
                      fontWeight: FontWeight.bold),
                ),
        ));
  }

  Color getTextColor(String char) {
    if (arithmetic.contains(char)) {
      return Colors.blue;
    } else if (decimal.contains(char)) {
      return Colors.white;
    } else if (scientific.contains(char)) {
      return Colors.purple;
    } else {
      return Colors.green;
    }
  }
}

class CursorWidget extends StatefulWidget {
  const CursorWidget({super.key});

  @override
  State<CursorWidget> createState() => _CursorWidgetState();
}

class _CursorWidgetState extends State<CursorWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  bool show = true;
  late Animation<bool> animation;
  Timer? timer;
  @override
  void initState() {
    super.initState();
    Timer.periodic(const Duration(seconds: 1), (timer) {
      this.timer = timer;
      setState(() {
        show = !show;
      });
    });
    // controller = AnimationController(
    //     vsync: this,
    //     duration: const Duration(seconds: 2),
    //     reverseDuration: const Duration(seconds: 2),
    //     lowerBound: 0,
    //     upperBound: 1);
    //     Tween<bool>(begin: false, end: true)
    // controller.forward();
    // //controller.repeat();
    // controller.addStatusListener((status) {
    //   if (status == AnimationStatus.completed) {
    //     controller.reverse();
    //   } else if (status == AnimationStatus.dismissed) {
    //     controller.forward();
    //   }
    // });
  }

  @override
  void dispose() {
    timer?.cancel();
    //controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      height: 20,
      duration: const Duration(seconds: 1),
      child: VerticalDivider(
        thickness: 2,
        color: show ? Colors.blue : Colors.transparent,
        width: 2,
      ),
    );
  }
}
