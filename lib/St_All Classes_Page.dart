import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AllClassesPage extends StatefulWidget {
  final String username;

  const AllClassesPage({Key? key, required this.username}) : super(key: key);

  @override
  _AllClassesPageState createState() => _AllClassesPageState();
}

class _AllClassesPageState extends State<AllClassesPage> {
  String selectedStream = '';
  String selectedClassId = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Classes'),
        backgroundColor: const Color.fromARGB(255, 134, 170, 244),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, ${widget.username}!',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            // Stream filter
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 10),
                labelText: 'Filter by Stream',
              ),
              value: selectedStream.isEmpty ? null : selectedStream,
              items: [
                'Physical Science stream',
                'Science stream',
                'Commerce stream',
                'Arts stream',
                'Technology stream'
              ].map((stream) {
                return DropdownMenuItem<String>(
                  value: stream,
                  child: Text(stream),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedStream = value ?? '';
                });
              },
            ),
            const SizedBox(height: 10),
            // ClassId filter
            TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 10),
                labelText: 'Filter by Class ID',
              ),
              onChanged: (value) {
                setState(() {
                  selectedClassId = value;
                });
              },
            ),
            const SizedBox(height: 20),
            const Text(
              'Available Classes:',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('classes')
                    .where('stream',
                        isEqualTo:
                            selectedStream.isNotEmpty ? selectedStream : null)
                    .where('classId',
                        isEqualTo:
                            selectedClassId.isNotEmpty ? selectedClassId : null)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No classes found.'));
                  }

                  var classes = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: classes.length,
                    itemBuilder: (context, index) {
                      var classData = classes[index];

                      return Card(
                        elevation: 5,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          title: Text(
                            '${classData['subjectId']} - ${classData['stream']}',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text('Class ID: ${classData['classId']}'),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ClassDetailsPage(
                                  classData: classData,
                                  username: widget.username,
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

class ClassDetailsPage extends StatelessWidget {
  final QueryDocumentSnapshot classData;
  final String username;

  const ClassDetailsPage(
      {Key? key, required this.classData, required this.username})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Class Details'),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Image at the top
            Container(
              width: screenWidth,
              height: screenWidth * 0.6, // Aspect ratio of 3:5 (width:height)
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/45.png'),
                  fit: BoxFit.cover, // Ensure image covers the container
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow('Class ID:', classData['classId']),
                      _buildDetailRow('Subject:', classData['subjectId']),
                      _buildDetailRow('Stream:', classData['stream']),
                      _buildDetailRow('Date:', classData['date']),
                      _buildDetailRow('Day:', classData['day']),
                      _buildDetailRow(
                          'Duration:', '${classData['duration']} minutes'),
                      _buildDetailRow(
                          'Introduction:', classData['introduction']),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          minimumSize: Size(double.infinity, 50),
                          padding: EdgeInsets.symmetric(vertical: 16),
                          textStyle: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: () async {
                          // Enroll the user by adding data to ClassEnrollment collection
                          await FirebaseFirestore.instance
                              .collection('ClassEnrollment')
                              .add({
                            'classId': classData['classId'],
                            'date': classData['date'],
                            'day': classData['day'],
                            'duration': classData['duration'],
                            'introduction': classData['introduction'],
                            'stream': classData['stream'],
                            'subjectId': classData['subjectId'],
                            'teacherId': classData[
                                'teacherId'], // Pass the teacherId as username
                            'studentId':
                                username, // Replace with actual StudentID from user
                          });

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Enrolled successfully!')),
                          );
                        },
                        child: const Text('Enroll'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build each detail row with highlighted text
  Widget _buildDetailRow(String label, String value) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.lightBlueAccent.withOpacity(0.1), // Highlight color
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.lightBlueAccent),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '$label',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 18,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
