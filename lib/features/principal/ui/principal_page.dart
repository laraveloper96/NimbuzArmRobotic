import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nimbuz_arm_robotic/core/mqtt/mqtt_impl.dart';
import 'package:nimbuz_arm_robotic/features/principal/bloc/principal_bloc.dart';
import 'package:nimbuz_arm_robotic/features/principal/ui/principal_view.dart';
import 'package:nimbuz_arm_robotic/shared/nav/nav.dart';

class PrincipalPage extends StatelessWidget {
  const PrincipalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PrincipalBloc(
        mqtt: MqttImpl(),
      )..add(InitEv()),
      child: BlocListener<PrincipalBloc, PrincipalState>(
        listener: (context, state) {
          if (state is NewRobot) {
            Nav.toast(context, 'New Robot Detected');
          }
          if (state is ChangedStatusRobot) {
            Nav.toast(context, state.message);
          }

          if (state is Error) {
            Nav.toast(context, 'state.message');
          }
        },
        child: const PrincipalView(),
      ),
    );
  }
}
