import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  final String username;

  ProfilePage({Key? key, required this.username}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final CollectionReference parentCollection =
        FirebaseFirestore.instance.collection('studentRequests');

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Page'),
        backgroundColor: Colors.lightBlue,
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Query to filter by ParentID using the username variable
        stream:
            parentCollection.where('ParentID', isEqualTo: username).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            // Improved error handling
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No data found'));
          }

          return ListView(
            children: snapshot.data!.docs.map((doc) {
              Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

              return Card(
                margin: EdgeInsets.all(10),
                child: ListTile(
                  title: Text(
                    '${data['ParentName'] ?? 'N/A'}',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Student Details
                      Text('Student ID: ${data['StudentID'] ?? 'N/A'}'),
                      Text('First Name: ${data['FirstName'] ?? 'N/A'}'),
                      Text('Last Name: ${data['LastName'] ?? 'N/A'}'),
                      Text('Academic Year: ${data['AcademicYear'] ?? 'N/A'}'),
                      Text('Stream: ${data['Stream'] ?? 'N/A'}'),
                      Text('Gender: ${data['Gender'] ?? 'N/A'}'),
                      Text('Age: ${data['Age'] ?? 'N/A'}'),
                      Text('Student NIC: ${data['StudentNIC'] ?? 'N/A'}'),
                      Text('Email: ${data['Email'] ?? 'N/A'}'),
                      Text('Telephone No: ${data['TelephoneNo'] ?? 'N/A'}'),
                      Text('Date Time: ${data['Date_Time'] ?? 'N/A'}'),

                      // Parent Details
                      SizedBox(height: 8),
                      Text('Parent Name: ${data['ParentName'] ?? 'N/A'}'),
                      Text('Parent ID: ${data['ParentID'] ?? 'N/A'}'),
                      Text('Parent NIC: ${data['ParentNIC'] ?? 'N/A'}'),
                      Text('Parent Email: ${data['ParentEmail'] ?? 'N/A'}'),
                      Text(
                          'Parent Telephone: ${data['ParentTelephone'] ?? 'N/A'}'),
                      Text(
                          'Parent Password: ${data['ParentPassword'] ?? 'N/A'}'),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
