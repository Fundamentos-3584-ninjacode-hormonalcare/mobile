import 'package:flutter/material.dart';
import 'package:jitsi_meet_flutter_sdk/jitsi_meet_flutter_sdk.dart';

class VideoCallPage extends StatefulWidget {
  final String roomName;
  final String displayName;

  const VideoCallPage({
    Key? key,
    required this.roomName,
    required this.displayName,
  }) : super(key: key);

  @override
  State<VideoCallPage> createState() => _VideoCallPageState();
}

class _VideoCallPageState extends State<VideoCallPage> {
  final _jitsiMeet = JitsiMeet();

  @override
  void initState() {
    super.initState();
    _joinMeeting();
  }

  void _joinMeeting() async {
    var options = JitsiMeetConferenceOptions(
      room: widget.roomName,
      configOverrides: {
        "startWithAudioMuted": false,
        "startWithVideoMuted": false,
      },
      userInfo: JitsiMeetUserInfo(
        displayName: widget.displayName,
      ),
    );

    await _jitsiMeet.join(options);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Videollamada"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: const Center(child: Text("Iniciando videollamada...")),
    );
  }
}
