import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nimbuz_arm_robotic/core/robot_arm/models/robot_event.dart';
import 'package:nimbuz_arm_robotic/features/principal/bloc/principal_bloc.dart';
import 'package:nimbuz_arm_robotic/shared/widgets/widgets.dart';

class SliderCtrls extends StatelessWidget {
  const SliderCtrls({super.key});

  Future<void> onSendCommand(BuildContext context,
      {required Command command, required double val}) async {
    if (context.mounted) {
      late int newVal;
      // if (command == Command.speed) {
      //   newVal = mapValue(val, 0, 1, 100, 2000);
      // } else {
      newVal = mapValue(val, 0, 1, 0, 180);
      // }
      final robotEvent = RobotEvent(command, newVal);
      context.read<PrincipalBloc>().add(SendCommandEv(robotEvent));
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

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 6,
      child: ListView(
        // mainAxisAlignment: MainAxisAlignment.center,
        // crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // const Label('Perú - Arequipa', type: LabelType.max),
          // VerticalSpace.md,
          _SliderRobot(
            text: 'Gripper',
            unit: '°',
            onChanged: (val) {
              onSendCommand(
                context,
                command: Command.gripper,
                val: val,
              );
            },
          ),
          _SliderRobot(
            text: 'Wrist',
            unit: '°',
            onChanged: (val) {
              onSendCommand(
                context,
                command: Command.wrist,
                val: val,
              );
            },
          ),
          _SliderRobot(
            text: 'Arm',
            unit: '°',
            onChanged: (val) {
              onSendCommand(
                context,
                command: Command.arm,
                val: val,
              );
            },
          ),
          _SliderRobot(
            text: 'Elbow',
            unit: '°',
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
            onChanged: (val) {
              onSendCommand(
                context,
                command: Command.shoulder,
                val: val,
              );
            },
          ),
          _SliderRobot(
            text: 'Speed',
            unit: 'ms',
            min: 100,
            max: 2000,
            onChanged: (val) {
              // onSendCommand(
              //   context,
              //   command: Command.speed,
              //   val: val,
              // );
            },
          ),
        ],
      ),
    );
  }
}

class _SliderRobot extends StatefulWidget {
  const _SliderRobot({
    super.key,
    this.onChanged,
    required this.text,
    required this.unit,
    this.min = 0,
    this.max = 180,
  });
  final void Function(double)? onChanged;
  final String text;
  final String unit;
  final double min;
  final double max;
  @override
  State<_SliderRobot> createState() => _SliderRobotState();
}

class _SliderRobotState extends State<_SliderRobot> {
  double valDefault = 0.0;
  int valLabel = 0;

  @override
  Widget build(BuildContext context) {
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
                  widget.text,
                  type: LabelType.normal,
                ),
                Label(
                  '$valLabel ${widget.unit}',
                  type: LabelType.normal,
                  textAlign: TextAlign.end,
                ),
              ],
            ),
          ),
          Slider(
            value: valDefault,
            inactiveColor: Colors.black,
            activeColor: Colors.red,
            onChanged: (val) {
              setState(() {
                valDefault = val;
                valLabel = mapValue(val, 0.0, 1.0, widget.min, widget.max);
              });
              widget.onChanged?.call(val);
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
