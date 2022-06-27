import 'main.dart';
import 'package:flutter/material.dart';

class Line extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _LineState();
}

class _LineState extends State<Line> with SingleTickerProviderStateMixin {
  late Animation<double> animation;

  @override
  void initState() {
    super.initState();
    var controller =
        AnimationController(duration: Duration(seconds: 5), vsync: this);

    animation = CurvedAnimation(
        parent: TweenSequence<double>(<TweenSequenceItem<double>>[
          TweenSequenceItem<double>(
            tween: Tween<double>(begin: 0, end: 0),
            weight: 1,
          ),
          TweenSequenceItem<double>(
            tween: Tween<double>(begin: 0, end: 1),
            weight: 1.5,
          ),
        ]).animate(controller)
          ..addListener(() {
            setState(() {});
          }),
        curve: Curves.easeIn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomPaint(
        painter: LinePainter(animation.value),
      ),
    );
  }
}

class LinePainter extends CustomPainter {
  late Paint _paint;
  double _progress;

  LinePainter(this._progress) {
    _paint = Paint()
      ..color = Colors.green
      ..strokeWidth = 8.0;
  }

  @override
  void paint(Canvas canvas, Size size) {
    const arcCenter = Offset(200, 200);
    final arcRect = Rect.fromCircle(center: arcCenter, radius: 100);
    final startAngle = 0.toRadian();
    final sweepAngle = 180.toRadian();
    canvas.drawArc(arcRect, startAngle, sweepAngle, true, _paint);

    /* canvas.drawLine(
        Offset(0.0, 0.0),
        Offset(size.width - size.width * _progress,
            size.height - size.height * _progress),
        _paint); */
  }

  @override
  bool shouldRepaint(LinePainter oldDelegate) {
    return oldDelegate._progress != _progress;
  }
}
