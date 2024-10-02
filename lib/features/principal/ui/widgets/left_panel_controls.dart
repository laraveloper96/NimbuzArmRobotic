import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nimbuz_arm_robotic/core/mqtt/robot.dart';
import 'package:nimbuz_arm_robotic/core/robot_arm/models/robot_event.dart';
import 'package:nimbuz_arm_robotic/features/principal/blocs/principal/principal_bloc.dart';
import 'package:nimbuz_arm_robotic/features/principal/blocs/sliders/slider_controls_bloc.dart';
import 'package:nimbuz_arm_robotic/shared/utils/utils.dart';
import 'package:nimbuz_arm_robotic/shared/widgets/widgets.dart';

class LeftPanelCtrls extends StatelessWidget {
  const LeftPanelCtrls({super.key});

  Future<void> onSendCommand(BuildContext context,
      {required Command command, required int val}) async {
    if (context.mounted) {
      final robotEvent = RobotEvent(command: command, value: val);
      context.read<PrincipalBloc>().add(SendCommandEv(robotEvent));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 2,
      child: BlocBuilder<PrincipalBloc, PrincipalState>(
          buildWhen: (previous, current) => current.status.isNewAddRobot,
          builder: (context, state) {
            // final robotAll = context.read<PrincipalBloc>().robotALL;

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // BtnIcon(
                //   icon: '🚀',
                //   label: 'Connect',
                //   onTap: () {},
                // ),
                const _Robots(),
                VerticalSpace.sl,
                BtnIcon(
                  icon: '💾',
                  label: 'Save Position',
                  onTap: () {
                    final moves =
                        context.read<SliderControlsBloc>().state.currentMoves;
                    context.read<PrincipalBloc>().add(SaveMovesEv(moves));
                  },
                ),
                VerticalSpace.sl,
                BtnIcon(
                  icon: '▶️',
                  label: 'Play Moves',
                  onTap: () {
                    context.read<PrincipalBloc>().add(const PlayMovesEv());
                  },
                ),
                VerticalSpace.sl,
                BtnIcon(
                  icon: '♻️',
                  label: 'Reset Moves',
                  onTap: () {
                    context.read<PrincipalBloc>().add(const ResetMovesEv());
                  },
                ),
                // VerticalSpace.sl,
                // BtnIcon(
                //   icon: '✋🏻',
                //   label: 'Stop Moves',
                //   onTap: () {
                //     onSendCommand(context, command: Command.stop, val: 0);
                //   },
                // ),
              ],
            );
          }),
    );
  }
}

class _Robots extends StatelessWidget {
  const _Robots();

  Future<void> robotToggle(BuildContext context, Robot robot) async {
    if (context.mounted) {
      context.read<PrincipalBloc>().add(EnableRobotEv(robot));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PrincipalBloc, PrincipalState>(
      buildWhen: (previous, current) =>
          current.status.isNewAddRobot || current.status.isChangeStatusRobot,
      builder: (context, state) {
        return Column(
          children: [
            ...state.robots.map((e) {
              return Padding(
                padding: const EdgeInsets.only(
                  top: 12,
                ),
                child: BtnRobot(
                  icon: '🦾',
                  label: e.name,
                  status: e.status,
                  enable: e.enable,
                  onTap: () => robotToggle(context, e),
                ),
              );
            }),
          ],
        );
      },
    );
  }
}
