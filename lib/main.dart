import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/ParentMain.dart';
import 'package:flutter_application_1/StudentMain.dart';
import 'package:flutter_application_1/TeacherMain.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "EduSync",
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _login() async {
    String username = _usernameController.text;
    String password = _passwordController.text;

    // Determine the role based on the first two characters of the username
    String role = '';
    CollectionReference dbRef;
    String userIdField, passwordField;

    if (username.startsWith('St')) {
      role = 'Student';
      dbRef = FirebaseFirestore.instance.collection('studentRequests');
      userIdField = 'StudentID';
      passwordField = 'StudentPassword';
    } else if (username.startsWith('Te')) {
      role = 'Teacher';
      dbRef = FirebaseFirestore.instance.collection('teachers');
      userIdField = 'teacherID';
      passwordField = 'password';
    } else if (username.startsWith('Pr')) {
      role = 'Parent';
      dbRef = FirebaseFirestore.instance.collection('studentRequests');
      userIdField = 'ParentID';
      passwordField = 'ParentPassword';
    } else {
      _showError('Invalid username format.');
      return;
    }

    try {
      final querySnapshot =
          await dbRef.where(userIdField, isEqualTo: username).limit(1).get();

      if (querySnapshot.docs.isNotEmpty) {
        final user = querySnapshot.docs.first.data() as Map<String, dynamic>;
        if (user[passwordField] == password) {
          if (role == 'Student') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => StudentDashboard(username: username)),
            );
          } else if (role == 'Teacher') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => TeacherDashboard(username: username)),
            );
          } else if (role == 'Parent') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => ParentDashboard(username: username)),
            );
          }
        } else {
          _showError('Username or password is incorrect.');
        }
      } else {
        _showError('Username or password is incorrect.');
      }
    } catch (e) {
      _showError('Error during login. Please try again.');
    }
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _register() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RegistrationPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Login",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 28,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Full-width image
                Image.asset(
                  "assets/45.png",
                  width: MediaQuery.of(context).size.width, // Full screen width
                  height: 280, // Adjust height as per your requirement
                  fit: BoxFit.cover, // Adjust the image to cover the width
                ),
                SizedBox(height: 120), // Adjust spacing as needed
                // TextField for username
                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: "Email or ID",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                ),
                SizedBox(height: 10),
                // TextField for password
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: "Password",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                  obscureText: true,
                ),
                SizedBox(height: 30),
                // Login button with modern style
                ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color.fromARGB(255, 6, 10, 93), // Dark blue color
                    minimumSize: Size(
                        double.infinity, 60), // Full width and large button
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 5,
                  ),
                  child: Text(
                    "Login",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
                SizedBox(height: 10),
                // Register button with modern style
                ElevatedButton(
                  onPressed: _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(
                        255, 6, 10, 93), // Light blue color
                    minimumSize: Size(
                        double.infinity, 60), // Full width and large button
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 5,
                  ),
                  child: Text(
                    "Register",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _schoolController = TextEditingController();
  final TextEditingController _streamController = TextEditingController();
  final TextEditingController _studentNicController = TextEditingController();
  final TextEditingController _telephoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _academicYearController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _parentNameController = TextEditingController();
  final TextEditingController _parentEmailController = TextEditingController();
  final TextEditingController _parentNicController = TextEditingController();
  final TextEditingController _parentTelController = TextEditingController();

  Future<void> _submitRegistration() async {
    try {
      await FirebaseFirestore.instance.collection('studentRequests').add({
        'AcademicYear': _academicYearController.text,
        'Address': _addressController.text,
        'Age': _ageController.text,
        'Date_Time': DateTime.now().toIso8601String(),
        'Email': _emailController.text,
        'FirstName': _firstNameController.text,
        'Gender': _genderController.text,
        'LastName': _lastNameController.text,
        'ParentEmail': _parentEmailController.text,
        'ParentID':
            'generatedParentID', // Replace with actual ID generation logic
        'ParentNIC': _parentNicController.text,
        'ParentName': _parentNameController.text,
        'ParentPassword':
            'generatedParentPassword', // Replace with actual password generation logic
        'ParentTelephone': _parentTelController.text,
        'School': _schoolController.text,
        'Stream': _streamController.text,
        'StudentID':
            'generatedStudentID', // Replace with actual ID generation logic
        'StudentNIC': _studentNicController.text,
        'StudentPassword':
            'generatedStudentPassword', // Replace with actual password generation logic
        'TelephoneNo': _telephoneController.text,
      });

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Registration Successful"),
          content: Text(
              "Thanks for registering with EduSync! Your username and password will be emailed within 5 days."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("OK"),
            ),
          ],
        ),
      );
    } catch (e) {
      print("Error saving registration data: $e");
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Registration Failed"),
          content: Text("There was an error processing your registration."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildTextField(
      String label, TextEditingController controller, Icon icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          prefixIcon: icon,
          labelText: label,
          filled: true,
          fillColor: Colors.grey[200],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Registration"),
        backgroundColor: Colors.blueAccent,
        leading: BackButton(),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Register Your Details",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(166, 22, 23, 67),
                ),
              ),
              SizedBox(height: 20),
              Card(
                elevation: 2.0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildTextField(
                        "First Name",
                        _firstNameController,
                        Icon(Icons.person),
                      ),
                      _buildTextField(
                        "Last Name",
                        _lastNameController,
                        Icon(Icons.person_outline),
                      ),
                      _buildTextField(
                        "Gender",
                        _genderController,
                        Icon(Icons.wc),
                      ),
                      _buildTextField(
                        "School",
                        _schoolController,
                        Icon(Icons.school),
                      ),
                      _buildTextField(
                        "Stream",
                        _streamController,
                        Icon(Icons.book),
                      ),
                      _buildTextField(
                        "Student NIC",
                        _studentNicController,
                        Icon(Icons.credit_card),
                      ),
                      _buildTextField(
                        "Telephone",
                        _telephoneController,
                        Icon(Icons.phone),
                      ),
                      _buildTextField(
                        "Email",
                        _emailController,
                        Icon(Icons.email),
                      ),
                      _buildTextField(
                        "Academic Year",
                        _academicYearController,
                        Icon(Icons.calendar_today),
                      ),
                      _buildTextField(
                        "Address",
                        _addressController,
                        Icon(Icons.home),
                      ),
                      _buildTextField(
                        "Age",
                        _ageController,
                        Icon(Icons.cake),
                      ),
                      SizedBox(height: 20),
                      Text(
                        "Parent Information",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: const Color.fromARGB(166, 22, 23, 67),
                        ),
                      ),
                      SizedBox(height: 10),
                      _buildTextField(
                        "Parent Name",
                        _parentNameController,
                        Icon(Icons.person),
                      ),
                      _buildTextField(
                        "Parent Email",
                        _parentEmailController,
                        Icon(Icons.email),
                      ),
                      _buildTextField(
                        "Parent NIC",
                        _parentNicController,
                        Icon(Icons.credit_card),
                      ),
                      _buildTextField(
                        "Parent Telephone",
                        _parentTelController,
                        Icon(Icons.phone),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _submitRegistration,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          padding: const EdgeInsets.symmetric(
                              vertical: 15.0, horizontal: 80.0),
                        ),
                        child: Text(
                          "Register",
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
