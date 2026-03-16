import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AssignmentsPage extends StatelessWidget {
  final String username;

  const AssignmentsPage({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enrolled Classes'),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, $username',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Your Enrolled Classes:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('ClassEnrollment')
                    .where('studentId', isEqualTo: username)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                        child: Text('No Enrolled classes found.'));
                  }

                  final classes = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: classes.length,
                    itemBuilder: (context, index) {
                      final classData =
                          classes[index].data() as Map<String, dynamic>;
                      final className = classData['classId'] ?? 'Unknown Class';
                      final stream = classData['stream'] ?? 'Unknown Stream';
                      final date = classData['date'] ?? 'No Date';

                      return Card(
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16.0),
                          title: Text(
                            className,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 8),
                              Text(
                                'Stream: $stream',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black54,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Date: $date',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios,
                              color: Colors.lightBlue),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ClassDetailPage(
                                  classData: classData,
                                  username: username,
                                ),
                              ),
                            );
                          },
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
}

class ClassDetailPage extends StatelessWidget {
  final Map<String, dynamic> classData;
  final String username;

  const ClassDetailPage({
    super.key,
    required this.classData,
    required this.username,
  });

  // Method to log attendance to Firestore
  Future<void> _logAttendance(String studentId, String classId) async {
    final DateTime now = DateTime.now();
    final String formattedDate = "${now.year}-${now.month}-${now.day}";
    final String formattedTime = "${now.hour}:${now.minute}:${now.second}";

    await FirebaseFirestore.instance.collection('attendance').add({
      'StudentID': studentId,
      'classId': classId,
      'Date': formattedDate,
      'Time': formattedTime,
    });
  }

  Future<Map<String, dynamic>> _fetchClassAccessData(String classId) async {
    final doc = await FirebaseFirestore.instance
        .collection('Class_access_areas.')
        .doc(classId)
        .get();

    return doc.data() ?? {};
  }

  Widget _buildLinkSection(String title, List<String> links) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        for (var link in links)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    link,
                    style: TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final Uri url = Uri.parse(link);
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url,
                          mode: LaunchMode.externalApplication);
                    } else {}
                  },
                  child: Text('Launch'),
                ),
              ],
            ),
          ),
        SizedBox(height: 10),
      ],
    );
  }

  // Method to launch Google URL
  Future<void> _launchGoogle() async {
    final Uri googleUrl = Uri.parse('https://www.google.com');
    if (await canLaunchUrl(googleUrl)) {
      await launchUrl(googleUrl, mode: LaunchMode.externalApplication);
    } else {
      print("Could not launch $googleUrl");
    }
  }

  @override
  Widget build(BuildContext context) {
    final classId = classData['classId'] ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text('${classData['classId'] ?? 'Class Detail'}'),
        backgroundColor: Colors.lightBlue,
        actions: [
          IconButton(
            icon: Icon(Icons.chat), // Chat icon
            onPressed: () {
              // Navigate to the chat page and pass the values
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatPage(
                    username: username,
                    classId: classId,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Username: $username',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'Class ID: ${classData['classId'] ?? 'N/A'}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text('Stream: ${classData['stream'] ?? 'N/A'}'),
              SizedBox(height: 10),
              Text('Subject ID: ${classData['subjectId'] ?? 'N/A'}'),
              SizedBox(height: 10),
              Text('Teacher ID: ${classData['teacherId'] ?? 'N/A'}'),
              SizedBox(height: 10),
              Text('Date: ${classData['date'] ?? 'N/A'}'),
              SizedBox(height: 10),
              Text('Day: ${classData['day'] ?? 'N/A'}'),
              SizedBox(height: 10),
              Text('Duration: ${classData['duration'] ?? 'N/A'}'),
              SizedBox(height: 10),
              Text(
                  'Introduction: ${classData['introduction'] ?? 'No Introduction'}'),
              SizedBox(height: 20),
              FutureBuilder<Map<String, dynamic>>(
                future: _fetchClassAccessData(classId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Text('No additional information available');
                  } else {
                    final accessData = snapshot.data!;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLinkSection(
                          'Zoom Links',
                          List<String>.from(accessData['zoom links'] ?? []),
                        ),
                        _buildLinkSection(
                          'Tutorials Links',
                          List<String>.from(
                              accessData['tutorials links'] ?? []),
                        ),
                        _buildLinkSection(
                          'Video Links',
                          List<String>.from(accessData['video links'] ?? []),
                        ),
                        _buildLinkSection(
                          'Other Links',
                          List<String>.from(accessData['other links'] ?? []),
                        ),
                      ],
                    );
                  }
                },
              ),
              SizedBox(height: 20),
              // Live Stream Button
              ElevatedButton(
                onPressed: () async {
                  // Log attendance before navigating to the Live Stream page
                  await _logAttendance(username, classId);

                  // Navigate to LiveStreamPage
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LiveStreamPage(
                        username: username,
                        classId: classId,
                      ),
                    ),
                  );
                },
                child: Text('Join Live Stream'),
              ),
              SizedBox(height: 20),
              // Google Button
              ElevatedButton(
                onPressed: _launchGoogle, // Call the method to launch Google
                child: Text('Launch Google'),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () {
            // Navigate to PaymentPage
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PaymentPage(
                  classId: classId,
                  username: username,
                ),
              ),
            );
          },
          child: Text('Proceed to Payment'),
        ),
      ),
    );
  }
}

// LiveStreamPage

class LiveStreamPage extends StatelessWidget {
  final String username;
  final String classId;

  const LiveStreamPage({
    super.key,
    required this.username,
    required this.classId,
  });

  Future<List<Map<String, dynamic>>> _fetchZoomMeetings() async {
    // Query Firestore for zoom meetings where ZoomClassID matches the classId
    final querySnapshot = await FirebaseFirestore.instance
        .collection('zoomMeetings')
        .where('ZoomClassID', isEqualTo: classId)
        .get();

    // Return list of meetings
    return querySnapshot.docs.map((doc) => doc.data()).toList();
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      // If URL cannot be launched, show a SnackBar with error message
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Live Stream'),
        backgroundColor: Colors.lightBlue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Username: $username',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Class ID: $classId',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _fetchZoomMeetings(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No Zoom meetings available'));
                } else {
                  // Display Zoom meeting details
                  final meetings = snapshot.data!;
                  return Expanded(
                    child: ListView.builder(
                      itemCount: meetings.length,
                      itemBuilder: (context, index) {
                        final meeting = meetings[index];
                        return Card(
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            title: Text(
                                'Meeting Date: ${meeting['MeetingDate'] ?? 'N/A'}'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    'Meeting Time: ${meeting['MeetingTime'] ?? 'N/A'}'),
                                Text(
                                    'Zoom Class ID: ${meeting['ZoomClassID'] ?? 'N/A'}'),
                                GestureDetector(
                                  onTap: () async {
                                    final String? meetingLink =
                                        meeting['MeetingLink'];
                                    if (meetingLink != null &&
                                        meetingLink.isNotEmpty) {
                                      await _launchUrl(meetingLink);
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              'Meeting link is not available'),
                                        ),
                                      );
                                    }
                                  },
                                  child: Text(
                                    'Meeting Link: ${meeting['MeetingLink'] ?? 'N/A'}',
                                    style: TextStyle(
                                      color: Colors.blue,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Payment Page
class PaymentPage extends StatefulWidget {
  final String classId;
  final String username;

  PaymentPage({required this.classId, required this.username});

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final TextEditingController paymentAmountController = TextEditingController();
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController expirationDateController =
      TextEditingController();
  final TextEditingController cvvController = TextEditingController();

  String selectedMonth = 'January';

  final List<String> months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  // Save payment data to Firestore
  void _savePaymentData(BuildContext context) {
    if (paymentAmountController.text.isEmpty ||
        fullNameController.text.isEmpty ||
        cardNumberController.text.isEmpty ||
        expirationDateController.text.isEmpty ||
        cvvController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill in all fields before submitting.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final paymentData = {
      'classId': widget.classId,
      'username': widget.username,
      'paymentAmount': paymentAmountController.text,
      'month': selectedMonth,
      'fullName': fullNameController.text,
      'cardNumber': cardNumberController.text,
      'expirationDate': expirationDateController.text,
      'cvv': cvvController.text,
    };

    FirebaseFirestore.instance.collection('payment').add(paymentData);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment Successful!')),
    );

    Navigator.pop(context);
  }

  // Fetch payment history
  Stream<QuerySnapshot> _getPaymentHistory() {
    return FirebaseFirestore.instance
        .collection('payment')
        .where('classId', isEqualTo: widget.classId)
        .where('username', isEqualTo: widget.username)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment Page'),
        backgroundColor: Colors.lightBlue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Payment form
              TextField(
                controller: paymentAmountController,
                decoration: InputDecoration(
                  labelText: 'Payment Amount',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: selectedMonth,
                decoration: InputDecoration(
                  labelText: 'Select Month',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    selectedMonth = value!;
                  });
                },
                items: months
                    .map((month) => DropdownMenuItem(
                          child: Text(month),
                          value: month,
                        ))
                    .toList(),
              ),
              SizedBox(height: 20),
              TextField(
                controller: fullNameController,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: cardNumberController,
                decoration: InputDecoration(
                  labelText: 'Card Number',
                  hintText: '1234 5678 9012 3456',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: expirationDateController,
                      decoration: InputDecoration(
                        labelText: 'Expiration Date',
                        hintText: 'MM/YY',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.datetime,
                    ),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: TextField(
                      controller: cvvController,
                      decoration: InputDecoration(
                        labelText: 'CVV/CVC',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: () => _savePaymentData(context),
                  child: Text('Submit Payment'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlue,
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  ),
                ),
              ),
              SizedBox(height: 30),

              // Payment history section
              Text(
                'Payment History',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              StreamBuilder<QuerySnapshot>(
                stream: _getPaymentHistory(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Text('No payment history found.');
                  }

                  final payments = snapshot.data!.docs;

                  return ListView.builder(
                    shrinkWrap: true, // Important to fit inside column
                    physics:
                        NeverScrollableScrollPhysics(), // Disable scrolling
                    itemCount: payments.length,
                    itemBuilder: (context, index) {
                      var paymentData =
                          payments[index].data() as Map<String, dynamic>;
                      return ListTile(
                        title: Text(paymentData['fullName']),
                        subtitle: Text(
                          'Month: ${paymentData['month']}, Amount: \$${paymentData['paymentAmount']}',
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ChatPage extends StatefulWidget {
  final String username;
  final String classId;

  const ChatPage({
    Key? key,
    required this.username,
    required this.classId,
  }) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();

  // Function to send the message to Firestore
  void _sendMessage() async {
    if (_messageController.text.isEmpty) {
      return;
    }

    // Add the message to the chat_St_Class collection
    await FirebaseFirestore.instance.collection('chat_St_Class').add({
      'Message': _messageController.text,
      'StudentID': widget.username,
      'classId': widget.classId,
      'de': widget.username, // 'de' is also set to username value
      'timestamp': FieldValue.serverTimestamp(), // Optional: Add a timestamp
    });

    // Clear the text field after sending the message
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat Page'),
        backgroundColor: Colors.lightBlue,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chat_St_Class')
                  .where('StudentID', isEqualTo: widget.username)
                  .where('classId', isEqualTo: widget.classId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No messages found'));
                }

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    var messageData =
                        messages[index].data() as Map<String, dynamic>?;

                    if (messageData == null) {
                      return ListTile(
                        title: Text('No message data available'),
                      );
                    }

                    String message = messageData['Message'] ?? 'No message';

                    return ListTile(
                      title: Text(message),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Enter your message',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
