import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  final String username; // TeacherID

  const ProfilePage({Key? key, required this.username}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Reference to the 'teachers' collection in Firestore
    CollectionReference teachers =
        FirebaseFirestore.instance.collection('teachers');

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(40.0), // Set height of AppBar
        child: AppBar(
          title: Text('Teacher Profile'),
          backgroundColor: Colors.lightBlue, // AppBar color
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Query to find the teacher data by TeacherID
        stream: teachers.where('teacherID', isEqualTo: username).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator()); // Loading state
          }

          if (snapshot.hasError) {
            return Center(
                child: Text('Error: ${snapshot.error}')); // Error state
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
                child: Text('No teacher data found')); // No data state
          }

          // Extract teacher data from Firestore
          var teacherData =
              snapshot.data!.docs.first.data() as Map<String, dynamic>;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                // Welcome message with teacher's name

                SizedBox(height: 20),

                // Displaying Teacher's details
                ProfileDetailItem(
                    label: 'address', value: teacherData['address']),
                ProfileDetailItem(label: 'age', value: teacherData['age']),
                ProfileDetailItem(label: 'email', value: teacherData['email']),
                ProfileDetailItem(label: 'Email', value: teacherData['Email']),
                ProfileDetailItem(label: 'fname', value: teacherData['fname']),
                ProfileDetailItem(label: 'Phone', value: teacherData['Phone']),
                ProfileDetailItem(
                    label: 'gender', value: teacherData['gender']),
                ProfileDetailItem(label: 'lname', value: teacherData['lname']),
                ProfileDetailItem(label: 'nic', value: teacherData['nic']),
                ProfileDetailItem(
                    label: 'password', value: teacherData['password']),
                ProfileDetailItem(
                    label: 'qualification',
                    value: teacherData['qualification']),
                ProfileDetailItem(
                    label: 'stream', value: teacherData['stream']),
                ProfileDetailItem(
                    label: 'subjectName', value: teacherData['subjectName']),
                ProfileDetailItem(
                    label: 'teacherID', value: teacherData['teacherID']),
                ProfileDetailItem(
                    label: 'telephone', value: teacherData['telephone']),

                // Add more fields if required
              ],
            ),
          );
        },
      ),
    );
  }
}

// Widget to display each profile detail in a neat row
class ProfileDetailItem extends StatelessWidget {
  final String label;
  final String? value;

  const ProfileDetailItem({Key? key, required this.label, this.value})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Expanded(
            child: Text(
              value ?? 'N/A',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
