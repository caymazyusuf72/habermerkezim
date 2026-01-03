import 'package:flutter/material.dart';
import '../../themes/app_theme.dart';

/// Okuma ilerleme göstergesi widget'ı
class ReadingProgressBar extends StatelessWidget {
  final double progress;
  final Color? color;
  final Color? backgroundColor;
  final double height;
  final bool showPercentage;
  final bool animated;
  final Duration animationDuration;
  final BorderRadius? borderRadius;

  const ReadingProgressBar({
    super.key,
    required this.progress,
    this.color,
    this.backgroundColor,
    this.height = 4,
    this.showPercentage = false,
    this.animated = true,
    this.animationDuration = const Duration(milliseconds: 300),
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progressColor = color ?? theme.colorScheme.primary;
    final bgColor = backgroundColor ?? progressColor.withOpacity(0.2);
    final radius = borderRadius ?? BorderRadius.circular(height / 2);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (showPercentage)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              '${(progress * 100).toInt()}%',
              style: theme.textTheme.bodySmall?.copyWith(
                color: progressColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        Container(
          height: height,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: radius,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  AnimatedContainer(
                    duration: animated ? animationDuration : Duration.zero,
                    curve: Curves.easeOutCubic,
                    width: constraints.maxWidth * progress.clamp(0.0, 1.0),
                    height: height,
                    decoration: BoxDecoration(
                      color: progressColor,
                      borderRadius: radius,
                      boxShadow: [
                        BoxShadow(
                          color: progressColor.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Gradient okuma ilerleme göstergesi
class GradientReadingProgressBar extends StatelessWidget {
  final double progress;
  final List<Color>? gradientColors;
  final Color? backgroundColor;
  final double height;
  final bool showPercentage;
  final bool animated;
  final Duration animationDuration;

  const GradientReadingProgressBar({
    super.key,
    required this.progress,
    this.gradientColors,
    this.backgroundColor,
    this.height = 4,
    this.showPercentage = false,
    this.animated = true,
    this.animationDuration = const Duration(milliseconds: 300),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = gradientColors ?? [
      AppTheme.sageGreen,
      AppTheme.sageGreenLight,
    ];
    final bgColor = backgroundColor ?? colors.first.withOpacity(0.2);
    final radius = BorderRadius.circular(height / 2);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (showPercentage)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              '${(progress * 100).toInt()}%',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.first,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        Container(
          height: height,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: radius,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  AnimatedContainer(
                    duration: animated ? animationDuration : Duration.zero,
                    curve: Curves.easeOutCubic,
                    width: constraints.maxWidth * progress.clamp(0.0, 1.0),
                    height: height,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: colors,
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: radius,
                      boxShadow: [
                        BoxShadow(
                          color: colors.first.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Dairesel okuma ilerleme göstergesi
class CircularReadingProgress extends StatelessWidget {
  final double progress;
  final Color? color;
  final Color? backgroundColor;
  final double size;
  final double strokeWidth;
  final bool showPercentage;
  final bool animated;
  final Duration animationDuration;
  final Widget? child;

  const CircularReadingProgress({
    super.key,
    required this.progress,
    this.color,
    this.backgroundColor,
    this.size = 60,
    this.strokeWidth = 4,
    this.showPercentage = true,
    this.animated = true,
    this.animationDuration = const Duration(milliseconds: 500),
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progressColor = color ?? theme.colorScheme.primary;
    final bgColor = backgroundColor ?? progressColor.withOpacity(0.2);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: 1,
              strokeWidth: strokeWidth,
              valueColor: AlwaysStoppedAnimation<Color>(bgColor),
              backgroundColor: Colors.transparent,
            ),
          ),
          // Progress circle
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: progress.clamp(0.0, 1.0)),
            duration: animated ? animationDuration : Duration.zero,
            curve: Curves.easeOutCubic,
            builder: (context, value, _) {
              return SizedBox(
                width: size,
                height: size,
                child: CircularProgressIndicator(
                  value: value,
                  strokeWidth: strokeWidth,
                  valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                  backgroundColor: Colors.transparent,
                  strokeCap: StrokeCap.round,
                ),
              );
            },
          ),
          // Center content
          if (child != null)
            child!
          else if (showPercentage)
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progress.clamp(0.0, 1.0)),
              duration: animated ? animationDuration : Duration.zero,
              builder: (context, value, _) {
                return Text(
                  '${(value * 100).toInt()}%',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: progressColor,
                    fontWeight: FontWeight.w700,
                    fontSize: size * 0.22,
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

/// Scroll ile senkronize okuma ilerleme göstergesi
class ScrollReadingProgressBar extends StatefulWidget {
  final ScrollController scrollController;
  final Color? color;
  final Color? backgroundColor;
  final double height;
  final bool showAtTop;
  final bool animated;

  const ScrollReadingProgressBar({
    super.key,
    required this.scrollController,
    this.color,
    this.backgroundColor,
    this.height = 3,
    this.showAtTop = true,
    this.animated = true,
  });

  @override
  State<ScrollReadingProgressBar> createState() => _ScrollReadingProgressBarState();
}

class _ScrollReadingProgressBarState extends State<ScrollReadingProgressBar> {
  double _progress = 0;

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_updateProgress);
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_updateProgress);
    super.dispose();
  }

  void _updateProgress() {
    if (!widget.scrollController.hasClients) return;
    
    final maxScroll = widget.scrollController.position.maxScrollExtent;
    final currentScroll = widget.scrollController.offset;
    
    if (maxScroll > 0) {
      setState(() {
        _progress = (currentScroll / maxScroll).clamp(0.0, 1.0);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ReadingProgressBar(
      progress: _progress,
      color: widget.color,
      backgroundColor: widget.backgroundColor,
      height: widget.height,
      animated: widget.animated,
      borderRadius: BorderRadius.zero,
    );
  }
}

/// Segmentli ilerleme göstergesi
class SegmentedProgressBar extends StatelessWidget {
  final int totalSegments;
  final int completedSegments;
  final Color? activeColor;
  final Color? inactiveColor;
  final double height;
  final double spacing;
  final bool animated;

  const SegmentedProgressBar({
    super.key,
    required this.totalSegments,
    required this.completedSegments,
    this.activeColor,
    this.inactiveColor,
    this.height = 4,
    this.spacing = 4,
    this.animated = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final active = activeColor ?? theme.colorScheme.primary;
    final inactive = inactiveColor ?? active.withOpacity(0.2);

    return Row(
      children: List.generate(totalSegments, (index) {
        final isCompleted = index < completedSegments;
        
        return Expanded(
          child: AnimatedContainer(
            duration: animated ? const Duration(milliseconds: 300) : Duration.zero,
            curve: Curves.easeOutCubic,
            height: height,
            margin: EdgeInsets.only(
              right: index < totalSegments - 1 ? spacing : 0,
            ),
            decoration: BoxDecoration(
              color: isCompleted ? active : inactive,
              borderRadius: BorderRadius.circular(height / 2),
              boxShadow: isCompleted
                  ? [
                      BoxShadow(
                        color: active.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ]
                  : null,
            ),
          ),
        );
      }),
    );
  }
}

/// Step ilerleme göstergesi
class StepProgressIndicator extends StatelessWidget {
  final int totalSteps;
  final int currentStep;
  final Color? activeColor;
  final Color? inactiveColor;
  final Color? completedColor;
  final double size;
  final double lineHeight;
  final bool showLabels;
  final List<String>? labels;

  const StepProgressIndicator({
    super.key,
    required this.totalSteps,
    required this.currentStep,
    this.activeColor,
    this.inactiveColor,
    this.completedColor,
    this.size = 32,
    this.lineHeight = 3,
    this.showLabels = false,
    this.labels,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final active = activeColor ?? theme.colorScheme.primary;
    final inactive = inactiveColor ?? theme.colorScheme.outline.withOpacity(0.3);
    final completed = completedColor ?? active;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: List.generate(totalSteps * 2 - 1, (index) {
            // Step circle
            if (index.isEven) {
              final stepIndex = index ~/ 2;
              final isCompleted = stepIndex < currentStep;
              final isActive = stepIndex == currentStep;
              
              return _StepCircle(
                size: size,
                stepNumber: stepIndex + 1,
                isCompleted: isCompleted,
                isActive: isActive,
                activeColor: active,
                inactiveColor: inactive,
                completedColor: completed,
              );
            }
            // Line between steps
            else {
              final lineIndex = index ~/ 2;
              final isCompleted = lineIndex < currentStep;
              
              return Expanded(
                child: Container(
                  height: lineHeight,
                  color: isCompleted ? completed : inactive,
                ),
              );
            }
          }),
        ),
        if (showLabels && labels != null && labels!.length == totalSteps)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: labels!.asMap().entries.map((entry) {
                final isActive = entry.key <= currentStep;
                return Expanded(
                  child: Text(
                    entry.value,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isActive
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.onSurface.withOpacity(0.5),
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}

class _StepCircle extends StatelessWidget {
  final double size;
  final int stepNumber;
  final bool isCompleted;
  final bool isActive;
  final Color activeColor;
  final Color inactiveColor;
  final Color completedColor;

  const _StepCircle({
    required this.size,
    required this.stepNumber,
    required this.isCompleted,
    required this.isActive,
    required this.activeColor,
    required this.inactiveColor,
    required this.completedColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    Color bgColor;
    Color contentColor;
    
    if (isCompleted) {
      bgColor = completedColor;
      contentColor = Colors.white;
    } else if (isActive) {
      bgColor = activeColor;
      contentColor = Colors.white;
    } else {
      bgColor = Colors.transparent;
      contentColor = inactiveColor;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        border: Border.all(
          color: isCompleted || isActive ? bgColor : inactiveColor,
          width: 2,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: activeColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Center(
        child: isCompleted
            ? Icon(
                Icons.check_rounded,
                size: size * 0.5,
                color: contentColor,
              )
            : Text(
                stepNumber.toString(),
                style: TextStyle(
                  fontSize: size * 0.4,
                  fontWeight: FontWeight.w600,
                  color: contentColor,
                ),
              ),
      ),
    );
  }
}