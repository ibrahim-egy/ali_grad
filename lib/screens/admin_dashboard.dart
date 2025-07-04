import 'package:flutter/material.dart';
import 'dispute_list_screen.dart';

class AdminDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard'),
        backgroundColor: Colors.deepPurple,
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: Icon(Icons.people, color: Colors.deepPurple),
              title: Text('Users'),
              subtitle: Text('View and manage all users'),
              onTap: () {
                // TODO: Navigate to users management
              },
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(Icons.assignment, color: Colors.deepPurple),
              title: Text('Tasks'),
              subtitle: Text('View and manage all tasks'),
              onTap: () {
                // TODO: Navigate to tasks management
              },
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(Icons.report, color: Colors.deepPurple),
              title: Text('Disputes'),
              subtitle: Text('View and resolve disputes'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DisputeListScreen()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
} 