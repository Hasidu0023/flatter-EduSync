import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AllClassesPage extends StatelessWidget {
  final String username;

  const AllClassesPage({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All Classes'),
        backgroundColor: Colors.lightBlue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, $username',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Here are all the classes you are teaching:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('classes')
                    .where('teacherId', isEqualTo: username)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('No classes found.'));
                  }

                  final classes = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: classes.length,
                    itemBuilder: (context, index) {
                      final classData =
                          classes[index].data() as Map<String, dynamic>;
                      final classId = classData['classId'] ?? 'Unknown';
                      final subjectId = classData['subjectId'] ?? 'No Subject';

                      return ListTile(
                        title: Text('Class ID: $classId'),
                        subtitle: Text('Subject: $subjectId'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ClassDetailsPage(
                                classData: classData,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ClassDetailsPage extends StatelessWidget {
  final Map<String, dynamic> classData;

  const ClassDetailsPage({super.key, required this.classData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(classData['classId'] ?? 'Class Details'),
        backgroundColor: Colors.lightBlue,
        actions: [
          IconButton(
            icon: Icon(Icons.chat),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MessagePage(
                    username:
                        'YourUsername', // Replace with the actual username
                    classId: classData['classId'] ?? 'Unknown',
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Class ID: ${classData['classId'] ?? 'Unknown'}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text('Date: ${classData['date'] ?? 'No Date'}'),
            Text('Day: ${classData['day'] ?? 'No Day'}'),
            Text('Duration: ${classData['duration'] ?? 'No Duration'}'),
            Text(
                'Introduction: ${classData['introduction'] ?? 'No Introduction'}'),
            Text('Stream: ${classData['stream'] ?? 'No Stream'}'),
            Text('Subject ID: ${classData['subjectId'] ?? 'No Subject'}'),
            Text('Teacher ID: ${classData['teacherId'] ?? 'No Teacher'}'),
            SizedBox(height: 20),
            _buildLinkBox(context, 'Zoom Links', classData['classId']),
            SizedBox(height: 10),
            _buildLinkBox(context, 'Tutorials Links', classData['classId']),
            SizedBox(height: 10),
            _buildLinkBox(context, 'Video Links', classData['classId']),
            SizedBox(height: 10),
            _buildLinkBox(context, 'Other Links', classData['classId']),
            SizedBox(height: 20),

            // New button to check attendance
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AttendancePage(
                      classId: classData['classId'] ??
                          'Unknown', // Passing classId to AttendancePage
                    ),
                  ),
                );
              },
              child: Text('Check Attendance'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLinkBox(BuildContext context, String linkType, String classId) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                LinksManagementPage(linkType: linkType, classId: classId),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.lightBlue.shade100,
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade400,
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            linkType,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}

// Define the AttendancePage where classId is passed

class AttendancePage extends StatefulWidget {
  final String classId;

  const AttendancePage({super.key, required this.classId});

  @override
  _AttendancePageState createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  String? studentId;
  String? date;
  TimeOfDay? startTime;
  TimeOfDay? endTime;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Attendance for ${widget.classId}'),
        backgroundColor: Colors.lightBlue,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                // Search by StudentID
                TextField(
                  decoration:
                      InputDecoration(labelText: 'Search by Student ID'),
                  onChanged: (value) {
                    setState(() {
                      studentId = value.isNotEmpty ? value : null;
                    });
                  },
                ),
                // Search by Date
                TextField(
                  decoration: InputDecoration(labelText: 'Search by Date'),
                  onChanged: (value) {
                    setState(() {
                      date = value.isNotEmpty ? value : null;
                    });
                  },
                ),
                // Search by Time Range
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration:
                            InputDecoration(labelText: 'Start Time (HH:mm)'),
                        onChanged: (value) {
                          setState(() {
                            startTime = _parseTime(value);
                          });
                        },
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        decoration:
                            InputDecoration(labelText: 'End Time (HH:mm)'),
                        onChanged: (value) {
                          setState(() {
                            endTime = _parseTime(value);
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getFilteredAttendanceStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                      child: Text(
                          'No attendance records found for Class ID: ${widget.classId}'));
                }

                // Build a list of attendance details
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var attendanceData = snapshot.data!.docs[index];
                    return ListTile(
                      title: Text('Student ID: ${attendanceData['StudentID']}'),
                      subtitle: Text(
                          'Date: ${attendanceData['Date']}, Time: ${attendanceData['Time']}'),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Stream<QuerySnapshot> _getFilteredAttendanceStream() {
    var query = FirebaseFirestore.instance
        .collection('attendance')
        .where('classId', isEqualTo: widget.classId);

    if (studentId != null && studentId!.isNotEmpty) {
      query = query.where('StudentID', isEqualTo: studentId);
    }

    if (date != null && date!.isNotEmpty) {
      query = query.where('Date', isEqualTo: date);
    }

    if (startTime != null && endTime != null) {
      query = query
          .where('Time', isGreaterThanOrEqualTo: _formatTime(startTime!))
          .where('Time', isLessThanOrEqualTo: _formatTime(endTime!));
    }

    return query.snapshots();
  }

  TimeOfDay? _parseTime(String timeStr) {
    try {
      final parts = timeStr.split(':');
      if (parts.length == 2) {
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        return TimeOfDay(hour: hour, minute: minute);
      }
    } catch (e) {
      // Handle parsing error
    }
    return null;
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}

class LinksManagementPage extends StatefulWidget {
  final String linkType;
  final String classId;

  const LinksManagementPage(
      {super.key, required this.linkType, required this.classId});

  @override
  _LinksManagementPageState createState() => _LinksManagementPageState();
}

class _LinksManagementPageState extends State<LinksManagementPage> {
  TextEditingController _linkController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.linkType),
        backgroundColor: Colors.lightBlue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('Class_access_areas.')
                    .doc(widget.classId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  var data = snapshot.data!.data() as Map<String, dynamic>?;
                  var links =
                      (data?[widget.linkType.toLowerCase()] as List<dynamic>?)
                              ?.map((e) => e as String)
                              .toList() ??
                          [];

                  return ListView.builder(
                    itemCount: links.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(links[index]),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            _deleteLink(index, links);
                          },
                        ),
                        onTap: () {
                          _showEditDialog(links[index], index);
                        },
                      );
                    },
                  );
                },
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                _showAddDialog();
              },
              child: Text('Add New ${widget.linkType}'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddDialog() {
    _linkController.clear();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add ${widget.linkType}'),
          content: TextField(
            controller: _linkController,
            decoration: InputDecoration(hintText: 'Enter link here'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _addLink(_linkController.text);
                Navigator.pop(context);
              },
              child: Text('Add'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _showEditDialog(String currentLink, int index) {
    _linkController.text = currentLink;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit ${widget.linkType}'),
          content: TextField(
            controller: _linkController,
            decoration: InputDecoration(hintText: 'Enter new link here'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _updateLink(_linkController.text, currentLink, index);
                Navigator.pop(context);
              },
              child: Text('Update'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _addLink(String newLink) async {
    if (newLink.isNotEmpty) {
      var classAccessRef = FirebaseFirestore.instance
          .collection('Class_access_areas.')
          .doc(widget.classId);

      // Retrieve the current document snapshot
      var docSnapshot = await classAccessRef.get();

      // Check if document exists
      if (docSnapshot.exists) {
        var data = docSnapshot.data() as Map<String, dynamic>?;

        // Get existing links or initialize as an empty list if not present
        var existingLinks =
            (data?[widget.linkType.toLowerCase()] as List<dynamic>?)
                    ?.map((e) => e as String)
                    .toList() ??
                [];

        // Add the new link
        existingLinks.add(newLink);

        // Update the Firestore document
        await classAccessRef.update({
          widget.linkType.toLowerCase(): existingLinks,
        });
      } else {
        // If the document does not exist, create it with the new link
        await classAccessRef.set({
          widget.linkType.toLowerCase(): [newLink],
        });
      }
    }
  }

  void _updateLink(String newLink, String oldLink, int index) async {
    if (newLink.isNotEmpty) {
      var classAccessRef = FirebaseFirestore.instance
          .collection('Class_access_areas.')
          .doc(widget.classId);

      var docSnapshot = await classAccessRef.get();
      var data = docSnapshot.data() as Map<String, dynamic>?;

      var existingLinks =
          (data?[widget.linkType.toLowerCase()] as List<dynamic>?)
                  ?.map((e) => e as String)
                  .toList() ??
              [];

      existingLinks[index] = newLink;

      await classAccessRef.update({
        widget.linkType.toLowerCase(): existingLinks,
      });
    }
  }

  void _deleteLink(int index, List<String> links) async {
    var classAccessRef = FirebaseFirestore.instance
        .collection('Class_access_areas.')
        .doc(widget.classId);

    links.removeAt(index);

    await classAccessRef.update({
      widget.linkType.toLowerCase(): links,
    });
  }
}

class MessagePage extends StatelessWidget {
  final String username;
  final String classId;

  const MessagePage({super.key, required this.username, required this.classId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Messages'),
        backgroundColor: Colors.lightBlue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Username: $username'),
            Text('Class ID: $classId'),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('chat_St_Class')
                    .where('classId', isEqualTo: classId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('No messages found.'));
                  }

                  final messages = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message =
                          messages[index].data() as Map<String, dynamic>;
                      final documentId = messages[index].id;
                      return ListTile(
                        title: Text(message['Message'] ?? 'No message content'),
                        subtitle: Text(
                            'Posted by: ${message['StudentID'] ?? 'Unknown'}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () => _showEditDialog(
                                  context, documentId, message['Message']),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () =>
                                  _showDeleteDialog(context, documentId),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(
      BuildContext context, String messageId, String currentMessage) {
    final TextEditingController messageController =
        TextEditingController(text: currentMessage);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Message'),
          content: TextField(
            controller: messageController,
            decoration: InputDecoration(hintText: 'Add your reply here'),
            maxLines: 3,
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                final newMessageText = messageController.text.trim();
                if (newMessageText.isNotEmpty) {
                  await _updateMessage(
                      messageId, currentMessage, newMessageText, context);
                }
                Navigator.of(context).pop();
              },
              child: Text('Update'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateMessage(String messageId, String currentMessage,
      String newMessageText, BuildContext context) async {
    try {
      final messageDocRef =
          FirebaseFirestore.instance.collection('chat_St_Class').doc(messageId);

      final updatedMessage =
          '$currentMessage\n\nTeacher Responses \n$newMessageText';

      await messageDocRef.update({
        'Message': updatedMessage,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Message updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating message: $e')),
      );
      print('Error updating message: $e');
    }
  }

  void _showDeleteDialog(BuildContext context, String messageId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Message'),
          content: Text('Are you sure you want to delete this message?'),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                await _deleteMessage(messageId, context);
                Navigator.of(context).pop();
              },
              child: Text('Delete'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteMessage(String messageId, BuildContext context) async {
    try {
      final messageDocRef =
          FirebaseFirestore.instance.collection('chat_St_Class').doc(messageId);

      await messageDocRef.delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Message deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting message: $e')),
      );
      print('Error deleting message: $e');
    }
  }
}
