import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EnrolledClassesPage extends StatefulWidget {
  final String username;

  // Constructor to accept username
  EnrolledClassesPage({required this.username});

  @override
  _EnrolledClassesPageState createState() => _EnrolledClassesPageState();
}

class _EnrolledClassesPageState extends State<EnrolledClassesPage> {
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Enrolled Classes'),
        backgroundColor: Colors.blue,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Icon(Icons.search),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search by Class ID',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder(
              // Query to fetch classes where teacherId equals the username
              stream: FirebaseFirestore.instance
                  .collection('classes')
                  .where('teacherId', isEqualTo: widget.username)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                // Check for errors or loading state
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                // Filter classes based on the search query
                final filteredClasses = snapshot.data?.docs.where((doc) {
                  final classId = doc.id.toLowerCase();
                  return classId.contains(_searchQuery.toLowerCase());
                }).toList();

                // Check if there is any data
                if (filteredClasses == null || filteredClasses.isEmpty) {
                  return Center(
                      child: Text('No classes found for $widget.username.'));
                }

                // Display the list of classes
                return ListView(
                  children: filteredClasses.map((doc) {
                    // Extract class data from Firestore document
                    Map<String, dynamic> classData =
                        doc.data() as Map<String, dynamic>;

                    return ListTile(
                      title: Text(classData['className'] ?? 'No class name'),
                      subtitle: Text('Class ID: ${doc.id}'),
                      onTap: () {
                        // Navigate to PaymentPage and pass classId
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PaymentPage(classId: doc.id),
                          ),
                        );
                      },
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class PaymentPage extends StatefulWidget {
  final String classId;

  PaymentPage({required this.classId});

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final TextEditingController _usernameController = TextEditingController();

  String _selectedMonth = 'All'; // Default value for dropdown
  String _usernameQuery = '';

  // List of months for dropdown
  final List<String> _months = [
    'All',
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
    'December'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment for ${widget.classId}'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          // Container to control the size of the DropdownButton
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              width: double.infinity, // Adjust width as needed
              child: DropdownButton<String>(
                value: _selectedMonth,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedMonth = newValue ?? 'All';
                  });
                },
                isExpanded: true, // Expands to fill the container
                items: _months.map<DropdownMenuItem<String>>((String month) {
                  return DropdownMenuItem<String>(
                    value: month,
                    child: Text(month),
                  );
                }).toList(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Search by Username',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    _usernameController.clear();
                    setState(() {
                      _usernameQuery = '';
                    });
                  },
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _usernameQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('payment')
                  .where('classId', isEqualTo: widget.classId)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                // Check for errors or loading state
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                // Filter payments based on search queries
                final filteredPayments = snapshot.data?.docs.where((doc) {
                  final paymentData = doc.data() as Map<String, dynamic>;
                  final month = paymentData['month'] ?? '';
                  final username = paymentData['username'] ?? '';

                  return (_selectedMonth == 'All' ||
                          month.toLowerCase() ==
                              _selectedMonth.toLowerCase()) &&
                      (username
                              .toLowerCase()
                              .contains(_usernameQuery.toLowerCase()) ||
                          _usernameQuery.isEmpty);
                }).toList();

                // Check if there is any data
                if (filteredPayments == null || filteredPayments.isEmpty) {
                  return Center(child: Text('No payment records found.'));
                }

                // Display the list of payments
                return ListView(
                  children: filteredPayments.map((doc) {
                    final paymentData = doc.data() as Map<String, dynamic>;

                    return ListTile(
                      title: Text(
                          'Full Name: ${paymentData['fullName'] ?? 'N/A'}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Month: ${paymentData['month'] ?? 'N/A'}'),
                          Text(
                              'Payment Amount: ${paymentData['paymentAmount'] ?? 'N/A'}'),
                          Text(
                              'StudentID: ${paymentData['username'] ?? 'N/A'}'),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
