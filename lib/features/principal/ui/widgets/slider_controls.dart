import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nimbuz_arm_robotic/core/robot_arm/models/robot_event.dart';
import 'package:nimbuz_arm_robotic/core/utils/debouncer.dart';
import 'package:nimbuz_arm_robotic/features/principal/blocs/principal/principal_bloc.dart';
import 'package:nimbuz_arm_robotic/features/principal/blocs/sliders/slider_controls_bloc.dart';
import 'package:nimbuz_arm_robotic/shared/widgets/widgets.dart';

class SliderCtrls extends StatelessWidget {
  const SliderCtrls({
    super.key,
    required this.debouncer,
  });

  final Debouncer debouncer;

  Future<void> onSendCommand(BuildContext context,
      {required Command command,
      required double val,
      double maxVal = 180}) async {
    if (context.mounted) {
      late int newVal;
      newVal = mapValue(val, 0, 1, 0, maxVal);
      final robotEvent = RobotEvent(command: command, value: newVal);
      context.read<SliderControlsBloc>().add(SendValueEv(robotEvent));
      debouncer.run(
        () {
          context.read<PrincipalBloc>().add(SendCommandEv(robotEvent));
        },
      );
    }
  }

  int mapValue(double value, double fromSource, double toSource,
      double fromTarget, double toTarget) {
    return ((value - fromSource) /
                (toSource - fromSource) *
                (toTarget - fromTarget) +
            fromTarget)
        .round();
  }

  double mapAngleToValue({
    required int angle,
    int maxValue = 180,
  }) {
    // Asegúrate de que el ángulo esté dentro del rango esperado (0-180)
    if (angle < 0 || angle > maxValue) {
      throw RangeError('Angle must be between 0 and $maxValue');
    }

    // Mapea el ángulo al rango 0-1
    double mappedValue = angle / maxValue;
    return mappedValue;
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 6,
      child: BlocBuilder<SliderControlsBloc, SliderControlsState>(
        builder: (context, state) {
          return ListView(
            // mainAxisAlignment: MainAxisAlignment.center,
            // crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // const Label('Perú - Arequipa', type: LabelType.max),
              // VerticalSpace.md,
              _SliderRobot(
                text: 'Gripper',
                unit: '°',
                val: mapAngleToValue(
                    angle: state.gripperValue.value, maxValue: 90),
                max: 90,
                onChanged: (val) {
                  onSendCommand(context,
                      command: Command.gripper, val: val, maxVal: 90);
                },
              ),
              _SliderRobot(
                text: 'Wrist Pitch',
                unit: '°',
                val: mapAngleToValue(angle: state.wristPitchValue.value),
                onChanged: (val) {
                  onSendCommand(
                    context,
                    command: Command.wristPitch,
                    val: val,
                  );
                },
              ),
              _SliderRobot(
                text: 'Wrist Roll',
                unit: '°',
                val: mapAngleToValue(angle: state.wristRollValue.value),
                onChanged: (val) {
                  onSendCommand(
                    context,
                    command: Command.wristRoll,
                    val: val,
                  );
                },
              ),
              _SliderRobot(
                text: 'Elbow',
                unit: '°',
                val: mapAngleToValue(angle: state.elbowValue.value),
                onChanged: (val) {
                  onSendCommand(
                    context,
                    command: Command.elbow,
                    val: val,
                  );
                },
              ),
              _SliderRobot(
                text: 'Shoulder',
                unit: '°',
                val: mapAngleToValue(angle: state.shoulderValue.value),
                onChanged: (val) {
                  onSendCommand(
                    context,
                    command: Command.shoulder,
                    val: val,
                  );
                },
              ),
              _SliderRobot(
                text: 'Waist',
                unit: '°',
                val: mapAngleToValue(angle: state.waistValue.value),
                onChanged: (val) {
                  onSendCommand(
                    context,
                    command: Command.waist,
                    val: val,
                  );
                },
              ),
              // _SliderRobot(
              //   text: 'Speed',
              //   unit: 'ms',
              //   min: 100,
              //   max: 2000,
              //   onChanged: (val) {
              //     // onSendCommand(
              //     //   context,
              //     //   command: Command.speed,
              //     //   val: val,
              //     // );
              //   },
              // ),
            ],
          );
        },
      ),
    );
  }
}

class _SliderRobot extends StatelessWidget {
  const _SliderRobot({
    this.onChanged,
    required this.val,
    required this.text,
    required this.unit,
    this.max = 180,
    this.min = 0,
  });
  final void Function(double)? onChanged;
  final String text;
  final String unit;
  final double min;
  final double val;
  final double max;

//   @override
//   State<_SliderRobot> createState() => _SliderRobotState();
// }

// class _SliderRobotState extends State<_SliderRobot> {
//   // double valDefault = 0.0;
//   int valLabel = 0;

  @override
  Widget build(BuildContext context) {
    final valDisplay = mapValue(val, 0.0, 1.0, min, max);
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: 24,
              right: 24,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Label(
                  text,
                  type: LabelType.normal,
                ),
                Label(
                  '$valDisplay $unit',
                  type: LabelType.normal,
                  textAlign: TextAlign.end,
                ),
              ],
            ),
          ),
          Slider(
            value: val,
            inactiveColor: Colors.black,
            activeColor: Colors.red,
            onChanged: (val) {
              // setState(() {
              // valDefault = val;
              // valLabel = mapValue(val, 0.0, 1.0, min, max);
              // });
              // widget.
              onChanged?.call(val);
            },
          ),
        ],
      ),
    );
  }

  int mapValue(double value, double fromSource, double toSource,
      double fromTarget, double toTarget) {
    return ((value - fromSource) /
                (toSource - fromSource) *
                (toTarget - fromTarget) +
            fromTarget)
        .round();
  }
}
