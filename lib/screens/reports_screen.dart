import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../providers/auth_provider.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  _ReportsScreenState createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  List<dynamic> _reports = [];
  List<dynamic> _filteredReports = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchReports();
    _searchController.addListener(_filterReports);
  }

  Future<void> _fetchReports() async {
    final userId = Provider.of<AuthProvider>(context, listen: false).userId;
    final token = await Provider.of<AuthProvider>(context, listen: false).getToken();
   
    if (userId == null || token == null) {
      return;
    }

    final response = await http.get(
      Uri.parse('http://10.0.2.2:5000/docs/$userId/get_all'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      setState(() {
        _reports = jsonDecode(response.body);
        _filteredReports = _reports;
      });
    } else {
      throw Exception('Failed to load reports');
    }
  }

  void _filterReports() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredReports = _reports.where((report) {
        final name = report['name'].toLowerCase();
        final agency = report['agency'].toLowerCase();
        final date = report['timestamp'].toLowerCase();
        return name.contains(query) || agency.contains(query) || date.contains(query);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Documents'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredReports.length,
              itemBuilder: (context, index) {
                final report = _filteredReports[index];
                return ListTile(
                  leading: Image.network(
                    report['thumbnail_url'],
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                  title: Text(report['name']),
                  subtitle: Text('Agency: ${report['agency']} - Date: ${report['timestamp']}'),
                  onTap: () {
                    // Handle report tap, e.g., open the document URL
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}