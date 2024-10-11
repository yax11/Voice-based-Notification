import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:voice_based_notification/variables.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:intl/intl.dart';


class HomeContent extends StatefulWidget {
  @override
  _HomeContentState createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  List<dynamic>? notifications; // Make nullable
  late Future<void> _loadNotificationsFuture;

  @override
  void initState() {
    super.initState();
    _loadNotificationsFuture = _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    try {
      String? studentInfoJson = await storage.read(key: 'student_information');
      if (studentInfoJson != null) {
        Map<String, dynamic> studentInfo = json.decode(studentInfoJson);
        String department = studentInfo['department']?.toString() ?? '';
        String year = studentInfo['year']?.toString() ?? '';

        if (department.isEmpty || year.isEmpty) {
          throw Exception('Invalid student information');
        }

        final fetchedNotifications =
            await apiService.fetchNotifications(department, year);

        setState(() {
          notifications = fetchedNotifications;
        });
      } else {
        throw Exception('No student information found');
      }
    } catch (e) {
      print('Error loading notifications: $e');
      throw e; // Re-throw to be caught by FutureBuilder
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _loadNotificationsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error: ${snapshot.error}'),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _loadNotificationsFuture = _loadNotifications();
                    });
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (notifications == null || notifications!.isEmpty) {
          return const Center(child: Text('No notifications available'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: notifications?.length ?? 0,
          itemBuilder: (context, index) {
            final notification =
                notifications![index] as Map<String, dynamic>? ?? {};

            return CustomListItem(
              time: notification['date']?.toString() ?? 'No date',
              title: notification['title']?.toString() ?? 'No title',
              filename: notification['filename']?.toString() ?? '',
            );
          },
        );
      },
    );
  }
}



class CustomListItem extends StatefulWidget {
  final String time;
  final String title;
  final String filename;

  const CustomListItem({
    Key? key,
    required this.time,
    required this.title,
    required this.filename,
  }) : super(key: key);

  @override
  _CustomListItemState createState() => _CustomListItemState();
}

class _CustomListItemState extends State<CustomListItem> {
  final AudioPlayer _audioPlayer = AudioPlayer(); // Using just_audio AudioPlayer
  bool _isPlaying = false;
  bool _isLoading = false;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;

  @override
  void initState() {
    super.initState();

    _audioPlayer.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state.playing;
          if (state.processingState == ProcessingState.completed) {
            _isPlaying = false;
          }
        });
      }
    });

    _audioPlayer.positionStream.listen((position) {
      setState(() {
        _currentPosition = position;
      });
    });

    _audioPlayer.durationStream.listen((duration) {
      setState(() {
        _totalDuration = duration ?? Duration.zero;
      });
    });
  }

  Future<void> _playAudio() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        final directory = await getApplicationDocumentsDirectory();
        final String filePath = '${directory.path}/${widget.filename}';

        print("Checking file path: $filePath");

        final file = File(filePath);

        if (await file.exists()) {
          print('File exists: $filePath');
          await _audioPlayer.setFilePath(filePath);
          await _audioPlayer.play();
        } else {
          print('File not found at: $filePath');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Audio file not found')),
          );
        }
      }
    } catch (e) {
      print('Error playing audio: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error playing audio: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showAudioPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(widget.title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Notification Time: ${_formatDate(widget.time)}'),
              const SizedBox(height: 16.0),
              Slider(
                value: _currentPosition.inSeconds.toDouble(),
                max: _totalDuration.inSeconds.toDouble(),
                onChanged: (value) async {
                  final position = Duration(seconds: value.toInt());
                  await _audioPlayer.seek(position);
                },
              ),
              Text('${_formatDuration(_currentPosition)} / ${_formatDuration(_totalDuration)}'),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(_isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill),
              onPressed: _playAudio,
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  String _formatDate(String time) {
    final dateTime = DateTime.parse(time);
    return DateFormat.yMMMMd().format(dateTime);
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatDate(widget.time),
                  style: TextStyle(
                    fontSize: 14,
                    color: primaryColor.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: _isLoading
                ? SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: primaryColor,
              ),
            )
                : Icon(
              _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
              color: primaryColor,
            ),
            onPressed: () => _showAudioPopup(context),
          ),
        ],
      ),
    );
  }
}
