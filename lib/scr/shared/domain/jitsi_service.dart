import 'package:jitsi_meet_flutter_sdk/jitsi_meet_flutter_sdk.dart';

class JitsiService {
  final _jitsiMeet = JitsiMeet();

  Future<void> joinMeeting({
    required String room,
    String? displayName,
    String? email,
    bool audioMuted = false,
    bool videoMuted = false,
  }) async {
    var options = JitsiMeetConferenceOptions(
      room: room,
      configOverrides: {
        "startWithAudioMuted": audioMuted,
        "startWithVideoMuted": videoMuted,
        "subject": "Consulta Médica",
      },
      userInfo: JitsiMeetUserInfo(
        displayName: displayName,
        email: email,
      ),
    );

    await _jitsiMeet.join(options);
  }

  void hangUp() {
    _jitsiMeet.leave();
  }
}
