import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:zego_uikit_prebuilt_video_conference/zego_uikit_prebuilt_video_conference.dart';

Future main() async {
  await dotenv.load(fileName: '.env');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ZEGO MEETING APP',
      home: HomePage(),
    );
  }
}

// Generate userId with 6 digit length
// Generate conferenceId with 10 digit length
final String userId = Random().nextInt(900000 + 100000).toString();
final String randomConferenceId =
    (Random().nextInt(1000000000) * 10 + Random().nextInt(10))
        .toString()
        .padLeft(10, '0');

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final conferenceIdController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: const Color(0xff0046DA),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      fixedSize: Size(MediaQuery.of(context).size.width * 0.4, 50),
    );
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(
              'https://www.zegocloud.com/_nuxt/img/pic_videoconference@2x.c50d1d2.png',
              width: MediaQuery.of(context).size.width * 0.8,
            ),
            Text('Your userId: $userId'),
            const Text('Please test with 2 or more devices'),
            const SizedBox(
              height: 20,
            ),
            TextFormField(
              maxLength: 10,
              keyboardType: TextInputType.number,
              controller: conferenceIdController,
              decoration: const InputDecoration(
                labelText: 'Join a Meeting by Input an Conference ID',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: buttonStyle,
                    child: const Text('Join a Meeting'),
                    onPressed: () => goToMeetingPage(
                      context,
                      conferenceId: conferenceIdController.text,
                    ),
                  ),
                ),
                const SizedBox(
                  width: 16,
                ),
                Expanded(
                  child: ElevatedButton(
                    style: buttonStyle,
                    child: const Text('New Meeting'),
                    onPressed: () => goToMeetingPage(
                      context,
                      conferenceId: randomConferenceId,
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  // Go to Meeting Page
  goToMeetingPage(BuildContext context, {required String conferenceId}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoConferencePage(
          conferenceID: conferenceId,
        ),
      ),
    );
  }
}

class VideoConferencePage extends StatelessWidget {
  final String conferenceID;

  VideoConferencePage({super.key, required this.conferenceID});

  // Read AppID dan AppSign from env file
  // Make sure you replace with your own
  final int appID = int.parse(dotenv.get('ZEGO_APP_ID'));
  final String appSign = dotenv.get('ZEGO_APP_SIGN');

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ZegoUIKitPrebuiltVideoConference(
        appID: appID,
        appSign: appSign,
        conferenceID: conferenceID,
        userID: userId,
        userName: 'user_$userId',
        config: ZegoUIKitPrebuiltVideoConferenceConfig(
          avatarBuilder: (BuildContext context, Size size, ZegoUIKitUser? user,
              Map extraInfo) {
            return user != null
                ? Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: NetworkImage(
                          'https://avatars.githubusercontent.com/u/32432134?v=4',
                        ),
                      ),
                    ),
                  )
                : const SizedBox();
          },
          onLeaveConfirmation: (BuildContext context) async {
            return await showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                return AlertDialog(
                  backgroundColor: Colors.yellow[900]!.withOpacity(0.9),
                  title: const Text("This is your custom dialog",
                      style: TextStyle(color: Colors.white70)),
                  content: const Text(
                      "You can customize this dialog however you like",
                      style: TextStyle(color: Colors.white70)),
                  actions: [
                    ElevatedButton(
                      child: const Text("Cancel",
                          style: TextStyle(color: Colors.white70)),
                      onPressed: () => Navigator.of(context).pop(false),
                    ),
                    ElevatedButton(
                      child: const Text("Exit"),
                      onPressed: () => Navigator.of(context).pop(true),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
