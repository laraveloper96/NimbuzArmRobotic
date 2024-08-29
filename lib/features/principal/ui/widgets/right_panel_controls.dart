import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nimbuz_arm_robotic/core/robot_arm/models/robot_event.dart';
import 'package:nimbuz_arm_robotic/features/principal/bloc/principal_bloc.dart';
import 'package:nimbuz_arm_robotic/shared/utils/utils.dart';
import 'package:nimbuz_arm_robotic/shared/widgets/widgets.dart';

class RightPanelCtrls extends StatelessWidget {
  const RightPanelCtrls({super.key});

  Future<void> onSendCommand(BuildContext context,
      {required Command command, required int val}) async {
    if (context.mounted) {
      final robotEvent = RobotEvent(command, val);
      context.read<PrincipalBloc>().add(SendCommandEv(robotEvent));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 2,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BtnIcon(
            icon: '🚀',
            label: 'Export Positions',
            onTap: () {},
          ),
          VerticalSpace.sl,
          BtnIcon(
            icon: '💾',
            label: 'Import Positions',
            onTap: () {},
          ),
          VerticalSpace.sl,
          BtnIcon(
            icon: '▶️',
            label: 'Reset Positions',
            onTap: () {
              onSendCommand(context, command: Command.reset, val: 0);
            },
          ),
          // const Spacer(),
          // BtnIcon(
          //   icon: '🎯',
          //   label: 'Set Speed',
          //   onTap: () {
          //     onSendCommand(context, command: Command.speed, val: 1000);
          //   },
          // ),
        ],
      ),
    );
  }
}
