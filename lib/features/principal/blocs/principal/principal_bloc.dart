import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:nimbuz_arm_robotic/app/config/env.dart';
import 'package:nimbuz_arm_robotic/core/mqtt/mqtt.dart';
import 'package:nimbuz_arm_robotic/core/mqtt/options.dart';
import 'package:nimbuz_arm_robotic/core/mqtt/robot.dart';
import 'package:nimbuz_arm_robotic/core/robot_arm/models/robot_data.dart';
import 'package:nimbuz_arm_robotic/core/robot_arm/models/robot_event.dart';
import 'package:nimbuz_arm_robotic/core/utils/generator_path.dart';

part 'principal_event.dart';
part 'principal_state.dart';

typedef PrincipalEmitter = Emitter<PrincipalState>;

class PrincipalBloc extends Bloc<PrincipalEvent, PrincipalState> {
  PrincipalBloc({
    required Mqtt mqtt,
  })  : _mqtt = mqtt,
        super(PrincipalState.initial()) {
    on<InitEv>(_onInit);
    on<AddRobotEv>(_onAddRobotEv);
    on<EnableRobotEv>(_onEnableRobotEv);
    on<SendCommandEv>(_onSendCommandEv);
    on<SaveMovesEv>(_onSaveMovesEv);
    on<PlayMovesEv>(_onPlayMovesEv);
    on<ExportMovesEv>(_onExportMovesEv);
    on<ImportMovesEv>(_onImportMovesEv);
    on<ResetMovesEv>(_onResetMovesEv);
  }

  final Mqtt _mqtt;
  Robot robotALL = Robot.all();
  // IAEvent? iaEvent;
  Timer? timer;

  Future<void> _onInit(InitEv ev, PrincipalEmitter emit) async {
    await _mqtt.connect(
      Options(
        host: Env.instance.ws,
        port: Env.instance.port,
        clientId: 'FlutterConf-Arequipa',
      ),
    );
    await _mqtt.subscribeTopic(Topic.human);
    _mqtt.onMessages().listen((robot) {
      add(AddRobotEv(robot));
    });
  }

  Future<void> _onAddRobotEv(AddRobotEv ev, PrincipalEmitter emit) async {
    final newlist = List<Robot>.from(state.robots);
    final search = newlist.indexWhere((el) {
      print('${el.mac}  ${el.enable}');
      return el.mac == ev.robot.mac;
    });
    print('😀 search:$search');
    if (search >= 0) {
      newlist.removeAt(search);
      newlist.add(ev.robot.copyWith(
        enable: true,
      ));
      return;
    }

    if (search == -1) {
      newlist.add(ev.robot);
    }

    // emit(NewRobot(newlist));
    emit(
      state.copyWith(
        status: PrincipalStatus.newAddRobot,
        robots: newlist,
      ),
    );
  }

  Future<void> _onEnableRobotEv(EnableRobotEv ev, PrincipalEmitter emit) async {
    // print(
    //     'entorl${ev.robot.clientID == robotALL.clientID} status:${ev.robot.status}');
    // if (ev.robot.clientID == robotALL.clientID && ev.robot.status) {
    //   final newList = List<Robot>.from(state.robots);
    //   for (var i = 0; i < newList.length; i++) {
    //     newList[i] = newList[i].copyWith(enable: false);
    //   }
    //   robotALL = robotALL.copyWith(enable: !ev.robot.enable);
    //   print('entorl');
    //   emit(NewRobot(newList));

    //   return;
    // }

    if (ev.robot.clientID != robotALL.clientID && ev.robot.status) {
      robotALL = robotALL.copyWith(enable: false);
      final index = state.robots.indexWhere((el) => el.mac == ev.robot.mac);
      if (index >= 0) {
        final newList = List<Robot>.from(state.robots);
        final status = !ev.robot.enable;
        newList[index] = newList.elementAt(index).copyWith(
              enable: status,
            );
        final robot = newList[index];

        emit(
          state.copyWith(
              status: PrincipalStatus.changeStatusRobot,
              robots: newList,
              message:
                  '[Robot] ${robot.name} ${status ? "Actived" : "Disabled"}'),
        );
        // emit(ChangedStatusRobot(newList,
        //     message:
        //         '[Robot] ${robot.name} ${status ? "Actived" : "Disabled"}'));
      }
    }
  }

  Future<void> _onSendCommandEv(SendCommandEv ev, PrincipalEmitter emit) async {
    if (ev.robotEvent.command == Command.none) return;

    // if (_mqtt.isConnect && robotALL.enable) {
    //   print('[MQTT] Message was sended');
    //   await _mqtt.sendMessage(
    //     topic: Topic.move,
    //     clientId: robotALL.clientID,
    //     command: ev.robotEvent.command.name,
    //     value: ev.robotEvent.value,
    //   );
    // }

    if (_mqtt.isConnect) {
      final robotsActive = state.robots.where((e) => e.enable);
      print('[MQTT] Found ${robotsActive.length} Robots Actived');
      for (final robot in robotsActive) {
        print('[MQTT] Message was sended');
        await _mqtt.sendMessage(
          topic: Topic.move,
          clientId: robot.clientID,
          command: ev.robotEvent.command.val,
          value: ev.robotEvent.value,
        );
      }
    }
  }

  Future<void> _onSaveMovesEv(SaveMovesEv ev, PrincipalEmitter emit) async {
    final moves = List.from(state.moves);

    emit(state.copyWith(moves: [...moves, ev.robotEvents]));
  }

  Future<void> _onPlayMovesEv(PlayMovesEv ev, PrincipalEmitter emit) async {
    if (_mqtt.isConnect) {
      final robotsActive = state.robots.where((e) => e.enable);
      if (robotsActive.isEmpty) {
        return;
      }

      for (var listEvent in state.moves) {
        for (var robotEvent in listEvent) {
          await _mqtt.sendMessage(
            topic: Topic.move,
            clientId: robotsActive.first.clientID,
            command: robotEvent.command.val,
            value: robotEvent.value,
          );
          await Future.delayed(const Duration(milliseconds: 2000));
          // }
        }
      }
    }
  }

  Future<void> _onExportMovesEv(ExportMovesEv ev, PrincipalEmitter emit) async {
    final robotsActive = state.robots.where((e) => e.enable);
    if (robotsActive.isEmpty) {
      return;
    }
    print('holis');
    try {
      exportToJsonFile(
        RobotData(
          clientId: robotsActive.first.clientID,
          steps: state.moves,
        ),
      );
    } catch (e) {
      print('holis:$e');
    }
  }

  Future<void> _onImportMovesEv(ImportMovesEv ev, PrincipalEmitter emit) async {
    print('_onImportMovesEv');
    emit(state.copyWith(status: PrincipalStatus.loadingImport));
    try {
      final data = await importFromJsonFile();
      emit(state.copyWith(
          status: PrincipalStatus.successImport, moves: data.steps));
    } catch (e) {
      print('_onImportMovesEvError:$e');
      emit(state.copyWith(
        status: PrincipalStatus.failureImport,
      ));
    }
  }

  Future<void> exportToJsonFile(RobotData data) async {
    final path = await Utils.getFilePath();
    final file = File(path!);

    final Map<String, dynamic> jsonData = {
      'client_id': data.clientId,
      'steps': data.steps
          .map((step) => {'moves': step.map((move) => move.toMap()).toList()})
          .toList(),
    };

    final jsonString = jsonEncode(jsonData);
    await file.writeAsString(jsonString);
  }

  Future<RobotData> importFromJsonFile() async {
    final path = await Utils.openFiles();
    if (path == null) {
      throw Exception('Cannot get path to file ');
    }
    try {
      final file = File(path);
      final jsonString = await file.readAsString();
      final Map<String, dynamic> jsonData = jsonDecode(jsonString);
      debugPrint('okis: $jsonData');

      return RobotData.fromJson(jsonData);
    } catch (e) {
      debugPrint('Error to read file JSON: $e');
      rethrow;
    }
  }

  Future<void> _onResetMovesEv(ResetMovesEv ev, PrincipalEmitter emit) async {
    emit(state.copyWith(moves: []));
  }
}
