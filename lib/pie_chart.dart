import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:tester/colors.dart';

import 'package:get/get.dart';
import 'package:tester/getcontoller.dart';

/// A colored piece of the [RallyPieChart].
class RallyPieChartSegment {
  const RallyPieChartSegment({
    required this.color,
    required this.value,
  });

  final Color color;
  final double value;
}

/// The max height and width of the [RallyPieChart].
const pieChartMaxSize = 300.0;

List<RallyPieChartSegment> buildSegmentsFromAccountItems(
    List<AccountData> items) {
  return List<RallyPieChartSegment>.generate(
    items.length,
    (i) {
      return RallyPieChartSegment(
        color: RallyColors.accountColor(i),
        value: items[i].primaryAmount,
      );
    },
  );
}

List<RallyPieChartSegment> buildSegmentsFromBillItems(List<BillData> items) {
  return List<RallyPieChartSegment>.generate(
    items.length,
    (i) {
      return RallyPieChartSegment(
        color: RallyColors.billColor(i),
        value: items[i].primaryAmount,
      );
    },
  );
}

List<RallyPieChartSegment> buildSegmentsFromBudgetItems(
    List<BudgetData> items) {
  return List<RallyPieChartSegment>.generate(
    items.length,
    (i) {
      return RallyPieChartSegment(
        color: RallyColors.budgetColor(i),
        value: items[i].primaryAmount - items[i].amountUsed,
      );
    },
  );
}

/// An animated circular pie chart to represent pieces of a whole, which can
/// have empty space.
class RallyPieChart extends StatefulWidget {
  const RallyPieChart({
    required this.heroLabel,
    required this.segments,
  });

  final String heroLabel;

  final List<RallyPieChartSegment> segments;

  @override
  State<RallyPieChart> createState() => _RallyPieChartState();
}

class _RallyPieChartState extends State<RallyPieChart>
    with SingleTickerProviderStateMixin {
  getcontroller gtc = Get.put(getcontroller());
  @override
  void initState() {
    super.initState();

    gtc.controller = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    );

    gtc.animation = CurvedAnimation(
        parent: TweenSequence<double>(<TweenSequenceItem<double>>[
          TweenSequenceItem<double>(
            tween: Tween<double>(begin: 0, end: 0),
            weight: 1,
          ),
          TweenSequenceItem<double>(
            tween: Tween<double>(begin: 0, end: 1),
            weight: 1.5,
          ),
        ]).animate(gtc.controller),
        curve: Curves.decelerate);

    gtc.controller.forward();
  }

  @override
  void dispose() {
    gtc.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: _AnimatedRallyPieChart(
        animation: gtc.animation,
        centerLabel: widget.heroLabel,
        segments: widget.segments,
      ),
    );
  }
}

class _AnimatedRallyPieChart extends AnimatedWidget {
  const _AnimatedRallyPieChart({
    required this.animation,
    required this.centerLabel,
    required this.segments,
  }) : super(listenable: animation);

  final Animation<double> animation;
  final String centerLabel;

  final List<RallyPieChartSegment> segments;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final labelTextStyle = textTheme.bodyText2!.copyWith(
      fontSize: 14,
    );

    return LayoutBuilder(builder: (context, constraints) {
      return DecoratedBox(
        decoration: _RallyPieChartOutlineDecoration(
          maxFraction: animation.value,
        ),
        child: Container(
          height: constraints.maxHeight,
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                centerLabel,
                style: labelTextStyle,
              ),
              Text(400.toString())
              /* SelectableText(
                usdWithSignFormat(context).format(centerAmount),
                style: headlineStyle,
              ), */
            ],
          ),
        ),
      );
    });
  }
}

class _RallyPieChartOutlineDecoration extends Decoration {
  const _RallyPieChartOutlineDecoration({
    required this.maxFraction,
  });

  final double maxFraction;

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _RallyPieChartOutlineBoxPainter(
      maxFraction: maxFraction,
    );
  }
}

class _RallyPieChartOutlineBoxPainter extends BoxPainter {
  _RallyPieChartOutlineBoxPainter({
    required this.maxFraction,
  });

  final double maxFraction;
  static const double wholeRadians = 2 * math.pi;
  static const double spaceRadians = wholeRadians / 180;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    // Create two padded reacts to draw arcs in: one for colored arcs and one for
    // inner bg arc.
    const strokeWidth = 4.0;
    final outerRadius = math.min(
          configuration.size!.width,
          configuration.size!.height,
        ) /
        2;
    final outerRect = Rect.fromCircle(
      center: configuration.size!.center(offset),
      radius: outerRadius - strokeWidth * 2,
    );
    final innerRect = Rect.fromCircle(
      center: configuration.size!.center(offset),
      radius: outerRadius - strokeWidth * 4,
    );

    final paint = Paint()..color = Colors.red;
    final paint2 = Paint()..color = Colors.amber;
    final paint3 = Paint()..color = Colors.indigo;
    final paint4 = Paint()..color = Colors.green;
    final sweepAngle = _calculateSweepAngle(0.5 * math.pi, 0.5);

    canvas.drawArc(outerRect, 0, sweepAngle, true, paint);
    canvas.drawArc(outerRect, 0.5 * math.pi, sweepAngle, true, paint2);
    canvas.drawArc(outerRect, math.pi, sweepAngle, true, paint3);
    canvas.drawArc(outerRect, 1.5 * math.pi, sweepAngle, true, paint4);
    final bgPaint = Paint()..color = Colors.white;
    canvas.drawArc(innerRect, 0, 2 * math.pi, true, bgPaint);
  }

  double _calculateAngle(double amount, double offset) {
    return maxFraction * (0.5 * math.pi);
  }

  double _calculateSweepAngle(double total, double offset) =>
      _calculateAngle((2 * math.pi), offset);
}

class BillData {
  const BillData({
    required this.name,
    required this.primaryAmount,
    required this.dueDate,
    this.isPaid = false,
  });

  /// The display name of this entity.
  final String name;

  /// The primary amount or value of this entity.
  final double primaryAmount;

  /// The due date of this bill.
  final String dueDate;

  /// If this bill has been paid.
  final bool isPaid;
}

class AccountData {
  const AccountData({
    required this.name,
    required this.primaryAmount,
    required this.accountNumber,
  });

  /// The display name of this entity.
  final String name;

  /// The primary amount or value of this entity.
  final double primaryAmount;

  /// The full displayable account number.
  final String accountNumber;
}

class BudgetData {
  const BudgetData({
    required this.name,
    required this.primaryAmount,
    required this.amountUsed,
  });

  /// The display name of this entity.
  final String name;

  /// The primary amount or value of this entity.
  final double primaryAmount;

  /// Amount of the budget that is consumed or used.
  final double amountUsed;
}
