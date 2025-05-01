import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/thingspeak_service.dart';
import '../utils/lamp_state.dart';
import '/services/firebase_auth_service.dart';
import 'login_screen.dart';
import 'dart:async';

class LampScreen extends StatefulWidget {
  final AuthService _authService = AuthService();
  final String lampName;

  LampScreen({super.key, required this.lampName});

  @override
  _LampScreenState createState() => _LampScreenState();
}

class _LampScreenState extends State<LampScreen> {
  bool isLampOn = false;
  String workingHours = 'Fetching...';
  String errorStatus = 'No';
  bool isLoading = true;
  String errorMessage = '';
  bool showErrorPopup = false;
  Duration todayWorkingDuration = Duration.zero;
  DateTime? lastOnTime;
  int todayDay = DateTime.now().day;

  final ThingSpeakService thingSpeakService = ThingSpeakService();
  late DateTime offStartTime;

  Future<void> _logout() async {
    await widget._authService.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }
  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String hours = twoDigits(d.inHours);
    String minutes = twoDigits(d.inMinutes.remainder(60));
    String seconds = twoDigits(d.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  @override
  void initState() {
    super.initState();
    fetchLampStatus();

    Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted && isLampOn) {
        setState(() {
          todayWorkingDuration += Duration(seconds: 1);
        });
      }
    });
  }

  Future<void> fetchLampStatus() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      bool status = await thingSpeakService.getLampState();
      setState(() {
        isLampOn = status;
        workingHours = "120"; // Replace with actual working hours from API
        errorStatus = "No";   // Replace with actual error status from API
        isLoading = false;
      });

      Provider.of<LampState>(context, listen: false).updateLampState(status);

      if (!isLampOn) {
        offStartTime = DateTime.now();
        checkLampOffDuration();
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching lamp status: $e';
        isLoading = false;
      });
    }
  }

  Future<void> toggleLamp(bool value) async {
    setState(() {
      isLoading = true;
    });

    try {
      await thingSpeakService.updateLampState(value);

      // Check if it's a new day — reset counter
      int nowDay = DateTime.now().day;
      if (nowDay != todayDay) {
        todayWorkingDuration = Duration.zero;
        todayDay = nowDay;
      }

      if (value) {
        lastOnTime = DateTime.now(); // Lamp turned ON
      } else {
        if (lastOnTime != null) {
          todayWorkingDuration += DateTime.now().difference(lastOnTime!);
          lastOnTime = null;
        }
      }

      setState(() {
        isLampOn = value;
        isLoading = false;
      });

      Provider.of<LampState>(context, listen: false).updateLampState(value);

      if (!value) {
        offStartTime = DateTime.now();
        checkLampOffDuration();
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error toggling lamp: $e';
        isLoading = false;
      });
    }
  }

  void checkLampOffDuration() async {
    while (!isLampOn) {
      await Future.delayed(const Duration(seconds: 5));
      final offDuration = DateTime.now().difference(offStartTime).inSeconds;

      if (offDuration >= 135) {
        setState(() {
          showErrorPopup = true;
        });
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const SizedBox(
          height: 40,
          child: Image(image: AssetImage("assets/images/arklite_logo.png")),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: Row(
              children: [
                const Text(
                  "Hi, User",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.logout, color: Colors.white),
                  onPressed: _logout,
                ),
              ],
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 5,
                    offset: const Offset(2, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: isLampOn ? Colors.green : Colors.red,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isLampOn ? "ON" : "OFF",
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Image(
                    image: AssetImage("assets/images/lamp_icon.png"),
                    width: 60,
                    height: 60,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.lampName,
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("OFF", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Switch(
                  value: isLampOn,
                  activeColor: Colors.green,
                  onChanged: (value) => toggleLamp(value),
                ),
                const Text("ON", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            _infoCard("Total Working Hours: ${_formatDuration(todayWorkingDuration)}"),
            const SizedBox(height: 8),
            _infoCard("Error: $errorStatus"),
            if (isLoading) const CircularProgressIndicator(),
            if (errorMessage.isNotEmpty) ...[
              const SizedBox(height: 8),
              _infoCard("Error: $errorMessage", error: true),
            ],
            if (showErrorPopup)
              AlertDialog(
                title: const Text("⚠️ Error"),
                content: const Text("Please check UV lamp is working properly!"
                    "Try restarting the system."),
                actions: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        showErrorPopup = false;
                      });
                    },
                    child: const Text("OK"),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _infoCard(String text, {bool error = false}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: error ? Colors.red.shade100 : Colors.blue.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}
