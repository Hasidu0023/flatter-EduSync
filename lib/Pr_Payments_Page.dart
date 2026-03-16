import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PaymentsPage extends StatefulWidget {
  final String username;

  PaymentsPage({required this.username});

  @override
  _PaymentsPageState createState() => _PaymentsPageState();
}

class _PaymentsPageState extends State<PaymentsPage> {
  String studentP = 'Fetching...'; // Placeholder value for the StudentID
  List<Map<String, dynamic>> classEnrollmentData =
      []; // List to hold the class data

  @override
  void initState() {
    super.initState();
    _getStudentID(); // Fetch the StudentID when the widget is initialized
  }

  // Method to fetch the StudentID from Firestore based on ParentID (username)
  Future<void> _getStudentID() async {
    try {
      var querySnapshot = await FirebaseFirestore.instance
          .collection('studentRequests')
          .where('ParentID', isEqualTo: widget.username)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var studentData = querySnapshot.docs.first.data();
        setState(() {
          studentP = studentData['StudentID'];
        });

        // After fetching the StudentID, fetch class enrollment data
        _getClassEnrollmentData();
      } else {
        setState(() {
          studentP = 'StudentID not found';
        });
      }
    } catch (e) {
      setState(() {
        studentP = 'Error fetching StudentID';
      });
    }
  }

  // Method to fetch class enrollment data for the studentP
  Future<void> _getClassEnrollmentData() async {
    try {
      var querySnapshot = await FirebaseFirestore.instance
          .collection('ClassEnrollment')
          .where('studentId', isEqualTo: studentP)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        setState(() {
          classEnrollmentData = querySnapshot.docs
              .map((doc) => doc.data() as Map<String, dynamic>)
              .toList();
        });
      }
    } catch (e) {}
  }

  // Navigate to PaymentDetailsPage with classId
  void _goToPaymentDetailsPage(String classId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentDetailsPage(
          classId: classId,
          studentP: studentP,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Payments Page',
            style: TextStyle(fontSize: 24, color: Colors.lightBlue),
          ),
          SizedBox(height: 20),
          Text(
            'Logged in as: ${widget.username}',
            style: TextStyle(fontSize: 18, color: Colors.black),
          ),
          SizedBox(height: 20),
          Text(
            'Student ID: $studentP',
            style: TextStyle(fontSize: 18, color: Colors.black),
          ),
          SizedBox(height: 20),
          classEnrollmentData.isEmpty
              ? Text(
                  '',
                  style: TextStyle(fontSize: 18, color: Colors.red),
                )
              : Expanded(
                  child: ListView.builder(
                    itemCount: classEnrollmentData.length,
                    itemBuilder: (context, index) {
                      var classData = classEnrollmentData[index];
                      return ListTile(
                        title: Text('Class ID: ${classData['classId']}'),
                        subtitle: Text(
                            'stream: ${classData['']}\nSubject: ${classData['subjectId']}'),
                        onTap: () =>
                            _goToPaymentDetailsPage(classData['classId']),
                      );
                    },
                  ),
                ),
        ],
      ),
    );
  }
}

class PaymentDetailsPage extends StatefulWidget {
  final String classId;
  final String
      studentP; // Pass the studentP (username) value to filter payments

  PaymentDetailsPage({required this.classId, required this.studentP});

  @override
  _PaymentDetailsPageState createState() => _PaymentDetailsPageState();
}

class _PaymentDetailsPageState extends State<PaymentDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  final TextEditingController _expirationDateController =
      TextEditingController();
  final TextEditingController _paymentAmountController =
      TextEditingController();

  String selectedMonth = 'January'; // Default month selection
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

  void _submitPayment() async {
    // Check if the form is valid before submission
    if (_formKey.currentState!.validate()) {
      // Create a new payment entry
      await FirebaseFirestore.instance.collection('payment').add({
        'classId': widget.classId,
        'fullName': _fullNameController.text,
        'cardNumber': _cardNumberController.text,
        'cvv': _cvvController.text,
        'expirationDate': _expirationDateController.text,
        'month': selectedMonth, // Use the selected month
        'paymentAmount': _paymentAmountController.text,
        'username': widget.studentP,
      });

      // Clear the form fields
      _fullNameController.clear();
      _cardNumberController.clear();
      _cvvController.clear();
      _expirationDateController.clear();
      _paymentAmountController.clear();

      // Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment submitted successfully!')),
      );

      // Optionally, you could navigate to another page or refresh data here
    } else {
      // If the form is not valid, show an error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all the fields correctly.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment Details for Class ${widget.classId}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _fullNameController,
                decoration: InputDecoration(labelText: 'Full Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your full name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _cardNumberController,
                decoration: InputDecoration(labelText: 'Card Number'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your card number';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _cvvController,
                decoration: InputDecoration(labelText: 'CVV'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your CVV';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _expirationDateController,
                decoration:
                    InputDecoration(labelText: 'Expiration Date (MM/YY)'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the expiration date';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: selectedMonth,
                decoration: InputDecoration(labelText: 'Select Month'),
                onChanged: (value) {
                  setState(() {
                    selectedMonth = value!;
                  });
                },
                items: months
                    .map((month) => DropdownMenuItem(
                          value: month,
                          child: Text(month),
                        ))
                    .toList(),
                validator: (value) {
                  if (value == null) {
                    return 'Please select a month';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _paymentAmountController,
                decoration: InputDecoration(labelText: 'Payment Amount'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the payment amount';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitPayment,
                child: Text('Submit Payment'),
              ),
              SizedBox(height: 20),
              // Display previous payments (if any)
              FutureBuilder<QuerySnapshot>(
                future: FirebaseFirestore.instance
                    .collection('payment')
                    .where('classId', isEqualTo: widget.classId)
                    .where('username', isEqualTo: widget.studentP)
                    .get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error fetching payment data'));
                  } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                        child: Text('No payments found for this class'));
                  } else {
                    var paymentData = snapshot.data!.docs
                        .map((doc) => doc.data() as Map<String, dynamic>)
                        .toList();
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: paymentData.length,
                      itemBuilder: (context, index) {
                        var payment = paymentData[index];
                        return Card(
                          margin: EdgeInsets.all(8.0),
                          elevation: 4,
                          child: ListTile(
                            title: Text(
                              'Full Name: ${payment['fullName']}',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Card Number: ${payment['cardNumber']}'),
                                Text('CVV: ${payment['cvv']}'),
                                Text(
                                    'Expiration Date: ${payment['expirationDate']}'),
                                Text(
                                    'Payment Amount: ${payment['paymentAmount']}'),
                                Text('Month: ${payment['month']}'),
                                Text('Username: ${payment['username']}'),
                                Text('Class ID: ${payment['classId']}'),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
