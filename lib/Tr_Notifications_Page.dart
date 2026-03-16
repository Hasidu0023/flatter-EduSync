import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NotificationsPage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<DocumentSnapshot>> _fetchNotices() async {
    final snapshot = await _firestore.collection('notices').get();
    return snapshot.docs;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<DocumentSnapshot>>(
      future: _fetchNotices(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No notices Found'));
        }

        final notices = snapshot.data!;
        return NotificationsList(notices: notices);
      },
    );
  }
}

class NotificationsList extends StatefulWidget {
  final List<DocumentSnapshot> notices;

  NotificationsList({required this.notices});

  @override
  _NotificationsListState createState() => _NotificationsListState();
}

class _NotificationsListState extends State<NotificationsList> {
  List<DocumentSnapshot> _filteredNotices = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _filteredNotices = widget.notices;
  }

  void _filterNotices(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
      _filteredNotices = widget.notices
          .where(
              (notice) => notice['Title'].toLowerCase().contains(_searchQuery))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            onChanged: _filterNotices,
            decoration: InputDecoration(
              hintText: 'Search notices...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _filteredNotices.length,
            itemBuilder: (context, index) {
              var notice = _filteredNotices[index];
              return Card(
                elevation: 5,
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  contentPadding: EdgeInsets.all(16),
                  title: Text(
                    notice['Title'],
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${notice['Date']} - Posted by ${notice['PostedBy']}',
                    style: TextStyle(color: Color.fromARGB(255, 93, 89, 89)),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NoticeDetailsPage(
                          title: notice['Title'],
                          details: notice['Details'],
                          date: notice['Date'],
                          postedBy: notice['PostedBy'],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class NoticeDetailsPage extends StatelessWidget {
  final String title;
  final String details;
  final String date;
  final String postedBy;

  NoticeDetailsPage({
    required this.title,
    required this.details,
    required this.date,
    required this.postedBy,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Date: $date',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Posted By: $postedBy',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 16),
            Text(
              details,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
