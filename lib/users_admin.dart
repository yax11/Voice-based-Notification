import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'dart:async';
import 'dart:developer' as developer;
import 'variables.dart';

class UsersAdmin extends StatefulWidget {
  @override
  _UsersAdminState createState() => _UsersAdminState();
}

class _UsersAdminState extends State<UsersAdmin> with SingleTickerProviderStateMixin {
  FlutterSoundRecorder? _audioRecorder;
  FlutterSoundPlayer? _audioPlayer;
  bool _isRecording = false;
  bool _isPlaying = false;
  String? _audioFilePath;
  bool _isSending = false;
  String? _usersDepartment;

  late AnimationController _animationController;
  late Animation<double> _animation;

  StreamSubscription? _playerSubscription;
  Duration _playbackPosition = Duration.zero;
  Duration _playbackDuration = Duration.zero;

  // New controllers for title and message
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initAudioHandlers();
    _setupAnimation();
  }

  @override
  void dispose() {
    _audioRecorder?.closeRecorder();
    _audioPlayer?.closePlayer();
    _animationController.dispose();
    _playerSubscription?.cancel();
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _initAudioHandlers() async {
    _audioRecorder = FlutterSoundRecorder();
    _audioPlayer = FlutterSoundPlayer();

    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw RecordingPermissionException('Microphone permission not granted');
    }

    await _audioRecorder?.openRecorder();
    await _audioPlayer?.openPlayer();

    _playerSubscription = _audioPlayer?.onProgress?.listen((event) {
      setState(() {
        _playbackPosition = event.position;
        _playbackDuration = event.duration;
      });
    });
  }

  void _setupAnimation() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _animation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animationController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _animationController.forward();
      }
    });
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      await _stopRecording();
    } else {
      await _startRecording();
    }
  }

  Future<void> _startRecording() async {
    if (await Permission.microphone.isGranted) {
      // Discard previous recording
      if (_audioFilePath != null) {
        File(_audioFilePath!).deleteSync();
      }

      Directory tempDir = await getTemporaryDirectory();
      String path = '${tempDir.path}/audio_notification_${DateTime.now().millisecondsSinceEpoch}.aac';

      await _audioRecorder?.startRecorder(
        toFile: path,
        codec: Codec.aacADTS,
      );

      setState(() {
        _isRecording = true;
        _audioFilePath = path;
        _isPlaying = false;
      });

      _animationController.forward();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Microphone permission is required to record audio')),
      );
    }
  }

  Future<void> _stopRecording() async {
    await _audioRecorder?.stopRecorder();

    setState(() {
      _isRecording = false;
    });

    _animationController.stop();
    _animationController.reset();
  }

  Future<void> _togglePlayback() async {
    if (_isPlaying) {
      await _stopPlayback();
    } else {
      await _startPlayback();
    }
  }

  Future<void> _startPlayback() async {
    if (_audioFilePath != null && !_isRecording) {
      developer.log('Starting playback from: $_audioFilePath');
      await _audioPlayer?.startPlayer(
        fromURI: _audioFilePath!,
        codec: Codec.aacADTS,
        whenFinished: () {
          setState(() {
            _isPlaying = false;
            _playbackPosition = Duration.zero;
          });
        },
      );
      setState(() {
        _isPlaying = true;
      });
    } else {
      developer.log('Cannot start playback. File path: $_audioFilePath, Is recording: $_isRecording');
    }
  }

  Future<void> _stopPlayback() async {
    await _audioPlayer?.stopPlayer();
    setState(() {
      _isPlaying = false;
    });
  }


  Future<void> _sendAudio() async {
    String? studentInfoJson = await storage.read(key: "student_information");

    if (studentInfoJson != null) {
      Map<String, dynamic> information = json.decode(studentInfoJson);
      String? department = information['department'];
      String? year = information["year"];

      if (_titleController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please provide a title for the notification.')),
        );
        return;
      }

      if (_audioFilePath != null && department != null && year != null) {
        setState(() {
          _isSending = true;
        });

        File audioFile = File(_audioFilePath!);
        try {
          await apiService.sendAudio(
            audioFile,
            department,
            year,
            _titleController.text,
            _messageController.text,
          );

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Audio sent successfully!')),
          );
          mounted?Navigator.pop(context):null;
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to send audio: $e')),
          );
        } finally {
          setState(() {
            _isSending = false;
          });
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Missing audio file, department, or year.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Student information not found.')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text('Send Notifications', style: TextStyle(fontSize: 16),),
            Expanded(child: Container()),
            Align(
              child: IconButton(
                style: IconButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 20)
                ),
                onPressed: () {
                  Navigator.pushReplacementNamed(context, "/sendSchedules");
                },
                icon: Container(
                  child: Text("Schedules",style: TextStyle(fontWeight: FontWeight.bold),),
                ),
              ),
            )
          ],
        ),
        backgroundColor: primaryColor,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Title (required)',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  labelText: 'Message (optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 30),
              Center(
                child: GestureDetector(
                  onTap: _toggleRecording,
                  child: AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _isRecording ? _animation.value : 1.0,
                        child: Opacity(
                          opacity: _isRecording ?
                          0.5 + (0.5 * _animationController.value) : 1.0,
                          child: Icon(
                            _isRecording ? Icons.mic : Icons.mic_none,
                            size: 80,
                            color: primaryColor,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              SizedBox(height: 30),
              if (_audioFilePath != null && !_isRecording) ...[
                GestureDetector(
                  onTap: _togglePlayback,
                  child: Icon(
                    _isPlaying ? Icons.pause : Icons.play_arrow,
                    size: 60,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 10),
                if (_isPlaying)
                  LinearProgressIndicator(
                    value: _playbackDuration.inMilliseconds > 0
                        ? _playbackPosition.inMilliseconds / _playbackDuration.inMilliseconds
                        : 0.0,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                  ),
                SizedBox(height: 10),
                Text(
                  '${_playbackPosition.inSeconds}s / ${_playbackDuration.inSeconds}s',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _isSending ? null : _sendAudio,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                  ),
                  child: _isSending
                      ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                      : Text('Send Audio'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

