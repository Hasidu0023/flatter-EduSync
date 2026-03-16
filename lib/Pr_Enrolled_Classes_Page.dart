import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EnrolledClassesPage extends StatefulWidget {
  final String username;

  const EnrolledClassesPage({Key? key, required this.username})
      : super(key: key);

  @override
  _EnrolledClassesPageState createState() => _EnrolledClassesPageState();
}

class _EnrolledClassesPageState extends State<EnrolledClassesPage> {
  String studentID = '';
  bool isLoading = true;
  List<DocumentSnapshot> classes = [];

  @override
  void initState() {
    super.initState();
    fetchStudentID();
  }

  Future<void> fetchStudentID() async {
    try {
      // Query Firestore to find the document where ParentID matches the username
      final querySnapshot = await FirebaseFirestore.instance
          .collection('studentRequests')
          .where('ParentID', isEqualTo: widget.username)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Get the StudentID from the document
        setState(() {
          studentID = querySnapshot.docs.first['StudentID'];
        });

        // Fetch the enrolled classes for the StudentID
        fetchClasses();
      } else {
        setState(() {
          studentID = 'Student ID not found';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        studentID = 'Error fetching Student ID';
        isLoading = false;
      });
      print('Error fetching data: $e');
    }
  }

  Future<void> fetchClasses() async {
    try {
      // Query Firestore to fetch classes for the StudentID from ClassEnrollment table
      final classQuerySnapshot = await FirebaseFirestore.instance
          .collection('ClassEnrollment')
          .where('studentId', isEqualTo: studentID)
          .get();

      setState(() {
        classes = classQuerySnapshot.docs;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching classes: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Enrolled Classes'),
        backgroundColor: Colors.lightBlue,
      ),
      body: Center(
        child: isLoading
            ? CircularProgressIndicator()
            : classes.isEmpty
                ? Text('No classes found for Student ID: $studentID')
                : ListView.builder(
                    itemCount: classes.length,
                    itemBuilder: (context, index) {
                      final classData =
                          classes[index].data() as Map<String, dynamic>;
                      final className = classData['classId'] ?? 'Unnamed Class';

                      return ListTile(
                        title: Text(className),
                        onTap: () {
                          // Navigate to class details page when a class is clicked
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ClassDetailsPage(
                                classData: classData,
                                username: widget.username, // Pass the username
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
      ),
    );
  }
}

class ClassDetailsPage extends StatelessWidget {
  final Map<String, dynamic> classData;
  final String username;

  const ClassDetailsPage(
      {Key? key, required this.classData, required this.username})
      : super(key: key);

  void _navigateToChatPage(BuildContext context) {
    // Navigate to the ChatPage when the icon is clicked
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatPage(
          username: username,
          classId: classData['classId'], // Pass the classId variable
        ),
      ),
    );
  }

  void _navigateToPaymentPage(BuildContext context) {
    // Navigate to the PaymentPage when the button is clicked
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentPage(
          classId: classData['classId'], // Pass the classId
          username: username, // Pass the username
        ),
      ),
    );
  }

  void _navigateToAttendancePage(BuildContext context) {
    // Navigate to the AttendancePage when the button is clicked
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AttendancePage(
          classId: classData['classId'], // Pass the classId
          username: username, // Pass the username
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(classData['ClassName'] ?? 'Class Details'),
        backgroundColor: Colors.lightBlue,
        actions: [
          IconButton(
            icon: Icon(Icons.message),
            onPressed: () => _navigateToChatPage(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Class Details',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text('classId: ${classData['classId']}'),
            Text('teacherId: ${classData['teacherId']}'),
            Text('subjectId: ${classData['subjectId']}'),
            Text('date: ${classData['date']}'),
            Text('day: ${classData['day']}'),
            Text('duration: ${classData['duration']}'),
            Text('introduction: ${classData['introduction']}'),
            Text('stream: ${classData['stream']}'),
            Spacer(), // Pushes the buttons to the bottom
            Center(
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () => _navigateToPaymentPage(context),
                    child: Text('Make Payment'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlue,
                      padding:
                          EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    ),
                  ),
                  SizedBox(height: 10), // Space between buttons
                  ElevatedButton(
                    onPressed: () => _navigateToAttendancePage(context),
                    child: Text('Check Attendance'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlue,
                      padding:
                          EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20), // Adds space after the button
          ],
        ),
      ),
    );
  }
}

class AttendancePage extends StatefulWidget {
  final String classId;
  final String username;

  const AttendancePage(
      {Key? key, required this.classId, required this.username})
      : super(key: key);

  @override
  _AttendancePageState createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  String studentp = ''; // Variable to hold the StudentID value
  bool isLoadingStudentID =
      true; // To show a loading indicator while fetching student ID
  bool isLoadingAttendance =
      true; // To show a loading indicator while fetching attendance
  List<Map<String, dynamic>> attendanceRecords =
      []; // List to hold attendance records

  // Date and Time Range filters
  String selectedDate = ''; // Variable to store the input date for filtering
  String startTime = ''; // Start time for filtering
  String endTime = ''; // End time for filtering

  @override
  void initState() {
    super.initState();
    fetchStudentID();
  }

  // Method to fetch the StudentID from Firestore where ParentID = username
  Future<void> fetchStudentID() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('studentRequests')
          .where('ParentID', isEqualTo: widget.username)
          .get();

      if (snapshot.docs.isNotEmpty) {
        var studentData = snapshot.docs.first.data() as Map<String, dynamic>;
        setState(() {
          studentp = studentData['StudentID'] ?? 'Unknown';
          isLoadingStudentID = false; // Stop loading StudentID
        });
        fetchAttendanceRecords(
            studentp); // Fetch attendance after getting the StudentID
      } else {
        setState(() {
          studentp = 'No student found'; // Handle case where no student matches
          isLoadingStudentID = false;
        });
      }
    } catch (e) {
      setState(() {
        studentp = 'Error fetching student';
        isLoadingStudentID = false;
      });
      print('Error fetching StudentID: $e');
    }
  }

  // Method to fetch attendance records where StudentID = studentp and ClassID = classId, with optional filters for Date and Time
  Future<void> fetchAttendanceRecords(String studentID) async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('attendance')
          .where('StudentID', isEqualTo: studentID)
          .where('classId', isEqualTo: widget.classId)
          .get();

      List<Map<String, dynamic>> records = snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      // Apply Date filter
      if (selectedDate.isNotEmpty) {
        records =
            records.where((record) => record['Date'] == selectedDate).toList();
      }

      // Apply Time Range filter
      if (startTime.isNotEmpty && endTime.isNotEmpty) {
        records = records
            .where((record) =>
                record['Time'].compareTo(startTime) >= 0 &&
                record['Time'].compareTo(endTime) <= 0)
            .toList();
      }

      setState(() {
        attendanceRecords = records;
        isLoadingAttendance = false; // Stop loading attendance records
      });
    } catch (e) {
      setState(() {
        attendanceRecords = [];
        isLoadingAttendance = false;
      });
      print('Error fetching attendance records: $e');
    }
  }

  // Method to handle the search button press
  void handleSearch() {
    setState(() {
      isLoadingAttendance = true;
    });
    fetchAttendanceRecords(studentp); // Re-fetch records with filters applied
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Attendance'),
        backgroundColor: Colors.lightBlue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Attendance Details',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text('classId: ${widget.classId}'),
            Text('Username: ${widget.username}'),
            SizedBox(height: 20),

            isLoadingStudentID
                ? Center(
                    child:
                        CircularProgressIndicator()) // Show loading while fetching StudentID
                : Text('Student ID: $studentp'),

            SizedBox(height: 20),

            // Input field for Date filter
            TextField(
              decoration: InputDecoration(
                labelText: 'Filter by Date (YYYY-MM-DD)',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                selectedDate = value;
              },
            ),

            SizedBox(height: 10),

            // Input fields for Time Range filter
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Start Time (HH:MM)',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      startTime = value;
                    },
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'End Time (HH:MM)',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      endTime = value;
                    },
                  ),
                ),
              ],
            ),

            SizedBox(height: 20),

            // Search button to apply filters
            ElevatedButton(
              onPressed: handleSearch,
              child: Text('Search'),
            ),

            SizedBox(height: 20),

            isLoadingAttendance
                ? Center(
                    child:
                        CircularProgressIndicator()) // Show loading while fetching attendance
                : attendanceRecords.isNotEmpty
                    ? Expanded(
                        child: ListView.builder(
                          itemCount: attendanceRecords.length,
                          itemBuilder: (context, index) {
                            var record = attendanceRecords[index];
                            return ListTile(
                              title: Text('Date: ${record['Date']}'),
                              subtitle: Text('Time: ${record['Time']}'),
                              trailing: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text('classId: ${record['classId']}'),
                                  Text('StudentID: ${record['StudentID']}'),
                                ],
                              ),
                            );
                          },
                        ),
                      )
                    : Center(
                        child: Text(
                            'No attendance records found.')), // No records found
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class ChatPage extends StatefulWidget {
  final String username;
  final String classId;

  const ChatPage({
    required this.username,
    required this.classId,
  });

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();

  void _sendMessage() async {
    if (_messageController.text.isEmpty) {
      return;
    }

    await FirebaseFirestore.instance.collection('chat_St_Class').add({
      'Message': _messageController.text,
      'StudentID': widget.username,
      'classId': widget.classId,
      'de': widget.username, // 'de' is also set to username value
      'timestamp': FieldValue.serverTimestamp(), // Optional: Add a timestamp
    });

    _messageController.clear(); // Clear the input field after sending
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat'),
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

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No messages available.'));
                }

                var messages = snapshot.data!.docs;

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
                      // Optionally display who posted the message
                      // subtitle: Text('Posted by: ${messageData['de']}'),
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

  List<Map<String, dynamic>> paymentHistory = [];

  @override
  void initState() {
    super.initState();
    fetchPaymentHistory();
  }

  Future<void> _savePaymentData(BuildContext context) async {
    // Validate inputs
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
      return; // Exit the function if any field is empty
    }

    try {
      // Fetch StudentID from Firestore where ParentID matches username
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('studentRequests')
          .where('ParentID', isEqualTo: widget.username)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        var studentData = snapshot.docs.first.data() as Map<String, dynamic>;
        String studentID = studentData['StudentID'];

        // Prepare payment data with the fetched StudentID
        final paymentData = {
          'classId': widget.classId,
          'username': studentID, // Assign StudentID here
          'paymentAmount': paymentAmountController.text,
          'month': selectedMonth,
          'fullName': fullNameController.text,
          'cardNumber': cardNumberController.text,
          'expirationDate': expirationDateController.text,
          'cvv': cvvController.text,
        };

        // Save payment data to Firestore
        await FirebaseFirestore.instance.collection('payment').add(paymentData);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment Successful!')),
        );

        // Clear form fields
        paymentAmountController.clear();
        fullNameController.clear();
        cardNumberController.clear();
        expirationDateController.clear();
        cvvController.clear();

        // Refresh payment history
        fetchPaymentHistory();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('No matching student found for the provided ParentID.'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Future<void> fetchPaymentHistory() async {
    try {
      // Fetch StudentID from Firestore where ParentID matches username
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('studentRequests')
          .where('ParentID', isEqualTo: widget.username)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        var studentData = snapshot.docs.first.data() as Map<String, dynamic>;
        String studentID = studentData['StudentID'];

        // Fetch payment history where classId and studentID match
        QuerySnapshot paymentSnapshot = await FirebaseFirestore.instance
            .collection('payment')
            .where('classId', isEqualTo: widget.classId)
            .where('username', isEqualTo: studentID)
            .get();

        setState(() {
          paymentHistory = paymentSnapshot.docs
              .map((doc) => doc.data() as Map<String, dynamic>)
              .toList();
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Error fetching payment history: ${e.toString()}')),
      );
    }
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
              // Payment Amount
              TextField(
                controller: paymentAmountController,
                decoration: InputDecoration(
                  labelText: 'Payment Amount',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 20),

              // Select Month
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

              // Full Name
              TextField(
                controller: fullNameController,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),

              // Card Number
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

              // Expiration Date and CVV
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

              // Submit Payment Button
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

              // Payment History
              Text(
                'Payment History',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),

              // Display payment history
              if (paymentHistory.isEmpty)
                Text('No payments found for this class.')
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: paymentHistory.length,
                  itemBuilder: (context, index) {
                    final payment = paymentHistory[index];
                    return ListTile(
                      title: Text('Full Name: ${payment['fullName']}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Month: ${payment['month']}'),
                          Text('Payment Amount: ${payment['paymentAmount']}'),
                        ],
                      ),
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
