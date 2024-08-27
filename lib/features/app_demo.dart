import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late MqttServerClient client;
  String message = 'Conectando...';

  @override
  void initState() {
    super.initState();
    client = MqttServerClient.withPort('192.168.18.75', 'flutter_client', 1883);
    client.keepAlivePeriod = 60;
    client.onConnected = onConnected;
    client.onSubscribed = onSubscribed;
    final connMessage = MqttConnectMessage()
        .authenticateAs('username', 'password')
        .withWillTopic('willtopic')
        .withWillMessage('Will message')
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);
    client.connectionMessage = connMessage;
    try {
      connect();
    } catch (e) {
      log('🥲: $e');
    }
  }

  void onConnected() {
    print('😀Connected');
    client.subscribe("topic/test", MqttQos.atLeastOnce);
    // client.subscribe('your_topic', MqttQos.atLeastOnce);
  }

  void onDisconnected() {
    print('Disconnected');
    print('😀client disconnected');
    client.disconnect();
  }

  void onSubscribed(String topic) {
    print('Subscribed to topic $topic');
  }

  void onUnsubscribed(String topic) {
    print('Unsubscribed to topic $topic');
  }

  Future<void> connect() async {
    try {
      final connMess = MqttConnectMessage()
          .authenticateAs("username", "password")
          .withWillTopic('willtopic')
          .withWillMessage('My Will message')
          .startClean() // Non persistent session for testing
          .withWillQos(MqttQos.atLeastOnce);
      client.connectionMessage = connMess;
      print('😀Connecting');
      await client.connect();
    } catch (e) {
      print('😀Exception: $e');
      client.disconnect();
    }
    print("connected");

    client.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
      final recMessage = c![0].payload as MqttPublishMessage;
      final payload =
          MqttPublishPayload.bytesToStringAsString(recMessage.payload.message);

      print('Received message:$payload from topic: ${c[0].topic}');
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('MQTT Flutter'),
        ),
        body: Center(
          child: Text(message),
        ),
      ),
    );
  }
}
