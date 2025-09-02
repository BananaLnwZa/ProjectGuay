// ส่วนที่ 1: การ import libraries และไฟล์ที่เกี่ยวข้อง
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'login.dart';
import 'register.dart';
import 'api_config.dart';
import '../main.dart';

// ส่วนที่ 4: MainPage คือ StatefulWidget ซึ่งสามารถเปลี่ยนแปลงค่าหรือสถานะได้
class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

// ส่วนที่ 5: _MainPageState คือ state ของ MainPage
class _AccountPageState extends State<AccountPage> {
  // Define primary color
  final Color primaryColor = const Color.fromARGB(255, 232, 212, 132);

  // Define user information
  String _username = '';
  String _firstName = '';
  String _lastName = '';
  String _email = '';
  String _address = '';
  String _mobilePhone = '';
  String _gender = '';
  String _birthdate = '';
  String? _imageUrl;
  bool _isLoading = true;
  bool _isUploading = false;
  bool _isEditing = false;
  bool isUserLoggedIn = false;

  // Define text editing controllers
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _mobilePhoneController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _birthdateController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  // Initialize the state
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    _fetchUserProfile();
  }

  // Check and update login status
  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final int? custID = prefs.getInt('custID');
    final String? token = prefs.getString('token');

    bool loggedIn = false;

    if (custID != null && token != null) {
      try {
        // Check if token is expired
        bool isExpired = JwtDecoder.isExpired(token);
        loggedIn = !isExpired;
      } catch (e) {
        loggedIn = false;
      }
    }

    setState(() {
      isUserLoggedIn = loggedIn;
    });
  }

  // Fetch user profile data
  Future<void> _fetchUserProfile() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final int? custID = prefs.getInt('custID');
      final String? token = prefs.getString('token');

      if (custID == null || token == null) {
        //throw Exception('Customer ID or token is missing');
        setState(() {
          _isLoading = false;
        });
        _showSnackBar('กรุณาเข้าสู่ระบบ');
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.apiEndpoint}/profile/$custID'),
        headers: <String, String>{'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _username = data['username'] ?? '';
          _firstName = data['firstName'] ?? '';
          _lastName = data['lastName'] ?? '';
          _email = data['email'] ?? '';
          _address = data['address'] ?? '';
          _mobilePhone = data['mobilePhone'] ?? '';
          _gender = _mapGender(data['gender'] ?? -1);
          _birthdate = data['birthdate'] ?? '';

          // Update image URL handling with proper caching prevention
          if (data['imageFile'] != null && data['imageFile'].isNotEmpty) {
            // Add timestamp to prevent caching issues
            _imageUrl =
                '${ApiConfig.apiEndpoint}/customer/image/${data['imageFile']}';
          } else {
            _imageUrl = null;
          }
          _isLoading = false;

          // Set the controllers with the fetched data
          _usernameController.text = _username;
          _firstNameController.text = _firstName;
          _lastNameController.text = _lastName;
          _emailController.text = _email;
          _addressController.text = _address;
          _mobilePhoneController.text = _mobilePhone;
          _genderController.text = _gender;
          _birthdateController.text = _birthdate;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        //_showSnackBar('เกิดความผิดพลาดในการโหลดข้อมูล: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showSnackBar('เกิดความผิดพลาด: ${e.toString()}');
    }
  }

  // Update user profile
  Future<void> _updateUserProfile() async {
    setState(() {
      _isLoading = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    int? custID = prefs.getInt('custID');

    if (token != null && custID != null) {
      try {
        final response = await http.put(
          Uri.parse('${ApiConfig.apiEndpoint}/customer/$custID'),
          headers: <String, String>{
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, dynamic>{
            'username': _usernameController.text,
            'firstName': _firstNameController.text,
            'lastName': _lastNameController.text,
            'email': _emailController.text,
            'address': _addressController.text,
            'mobilePhone': _mobilePhoneController.text,
            'gender': _getGenderCode(_genderController.text),
            'birthdate': _birthdateController.text,
          }),
        );

        setState(() {
          _isLoading = false;
        });

        if (response.statusCode == 200) {
          setState(() {
            _isEditing = false;
          });
          _fetchUserProfile();
          _showSnackBar('ปรับปรุงข้อมูลเรียบร้อยแล้ว');
        } else {
          _showSnackBar('ปรับปรุงข้อมูลไม่สำเร็จ: ${response.statusCode}');
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        _showSnackBar('เกิดความผิดพลาด: ${e.toString()}');
      }
    } else {
      setState(() {
        _isLoading = false;
      });
      _showSnackBar('กรุณาเข้าสู่ระบบ');
    }
  }

  // Pick and upload image
  Future<void> _pickAndUploadImage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    int? custID = prefs.getInt('custID');

    if (token == null || custID == null) {
      _showSnackBar('กรุณาเข้าสู่ระบบ');
      return;
    }

    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('เลือกรูปภาพ'),
                onTap: () {
                  Navigator.pop(context, ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('กล้องถ่ายรูป'),
                onTap: () {
                  Navigator.pop(context, ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );

    if (source == null) return;

    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      setState(() {
        _isUploading = true;
      });

      // Create a multipart request
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.apiEndpoint}/customer/image/upload/$custID'),
      );

      // Add the authorization header
      request.headers['Authorization'] = 'Bearer $token';

      // Extract file extension
      String fileName = pickedFile.name;
      String fileExtension = '';
      if (fileName.contains('.')) {
        fileExtension = fileName.split('.').last.toLowerCase();
      } else {
        // Default to jpg if no extension found
        fileExtension = 'jpg';
      }

      // Validate file extension
      List<String> validExtensions = ['jpg', 'jpeg', 'png', 'gif'];
      if (!validExtensions.contains(fileExtension)) {
        setState(() {
          _isUploading = false;
        });
        _showSnackBar(
          'ประเภทไฟล์รูปภาพไม่ถูกต้อง กรุณาเลือกไฟล์ JPG, PNG, หรือ GIF',
        );
        return;
      }

      // Attach the file with proper naming
      request.files.add(
        await http.MultipartFile.fromPath(
          'imageFile',
          pickedFile.path,
          filename: 'profile_$custID.$fileExtension',
        ),
      );

      // Send the request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      setState(() {
        _isUploading = false;
      });

      if (response.statusCode == 200) {
        // Parse response
        final responseData = jsonDecode(response.body);
        if (responseData['status'] == true) {
          _showSnackBar(
            responseData['message'] ?? 'อัปโหลดรูปภาพเรียบร้อยแล้ว',
          );
          _fetchUserProfile();
        } else {
          _showSnackBar(responseData['message'] ?? 'อัปโหลดรูปภาพไม่สำเร็จ');
        }
      } else {
        _showSnackBar('อัปโหลดรูปภาพไม่สำเร็จ: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _isUploading = false;
      });
      _showSnackBar('เกิดความผิดพลาดในการอัปโหลดไฟล์รูปภาพ: ${e.toString()}');
    }
  }

  // Map gender integer to string
  String _mapGender(int gender) {
    switch (gender) {
      case 0:
        return 'ชาย';
      case 1:
        return 'หญิง';
      default:
        return '';
    }
  }

  // Map gender string to integer
  int _getGenderCode(String gender) {
    switch (gender.toLowerCase()) {
      case 'ชาย':
        return 0;
      case 'หญิง':
        return 1;
      default:
        return -1;
    }
  }

  // Define formatted date for birthdate
  String _getFormattedBirthdate() {
    if (_birthdate.isNotEmpty) {
      try {
        return DateFormat('yyyy-MM-dd').format(DateTime.parse(_birthdate));
      } catch (e) {
        return 'รูปแบบวันเกิดไม่ถูกต้อง';
      }
    }
    return '';
  }

  // A user clicks the logout button
  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('custID');
    await prefs.remove('token');
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const MyHomePage(title: 'Project Guay Demo'),
      ),
      (route) => false,
    );
  }

  // A user clicks the register button
  Future<void> _register() async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RegisterPage()),
    );
  }

  // Build profile information item
  Widget _buildProfileInfoItem(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            flex: 6,
            child: Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  // Build profile input field
  Widget _buildProfileInputField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isDatePicker = false,
    bool isGender = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: isGender
          ? DropdownButtonFormField<String>(
              value: controller.text.isEmpty ? 'ไม่ระบุ' : controller.text,
              decoration: InputDecoration(
                labelText: label,
                prefixIcon: Icon(icon, color: primaryColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              items: const [
                DropdownMenuItem(value: 'ชาย', child: Text('ชาย')),
                DropdownMenuItem(value: 'หญิง', child: Text('หญิง')),
                DropdownMenuItem(value: 'ไม่ระบุ', child: Text('ไม่ระบุ')),
              ],
              onChanged: (value) {
                if (value != null) {
                  controller.text = value;
                }
              },
            )
          : TextField(
              controller: controller,
              readOnly: isDatePicker,
              onTap: isDatePicker
                  ? () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: _birthdate.isNotEmpty
                            ? DateTime.tryParse(_birthdate) ?? DateTime.now()
                            : DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: ColorScheme.light(
                                primary: primaryColor,
                                onPrimary: Colors.white,
                                onSurface: Colors.black,
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (pickedDate != null) {
                        setState(() {
                          _birthdateController.text = DateFormat(
                            'yyyy-MM-dd',
                          ).format(pickedDate); // Format the date
                        });
                      }
                    }
                  : null,
              decoration: InputDecoration(
                labelText: label,
                prefixIcon: Icon(icon, color: primaryColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
    );
  }

  // Show a snackbar message
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        //backgroundColor: primaryColor,
        //behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Render UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        foregroundColor: Colors.white,
        backgroundColor: const Color.fromARGB(255, 178, 162, 97),
        elevation: 0,
        actions: [],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
              ),
            )
          : Stack(
              children: [
                // Top background
                Container(height: 120, color: primaryColor),

                // Main content
                SafeArea(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Profile header with avatar
                        Container(
                          margin: const EdgeInsets.only(top: 10),
                          child: Center(
                            child: Column(
                              children: [
                                Stack(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.1,
                                            ),
                                            spreadRadius: 1,
                                            blurRadius: 5,
                                          ),
                                        ],
                                      ),
                                      child: _isUploading
                                          ? CircleAvatar(
                                              radius: 50,
                                              backgroundColor:
                                                  Colors.grey.shade200,
                                              child: CircularProgressIndicator(
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                      Color
                                                    >(primaryColor),
                                              ),
                                            )
                                          : CircleAvatar(
                                              radius: 50,
                                              backgroundColor:
                                                  Colors.grey.shade200,
                                              backgroundImage: _imageUrl != null
                                                  ? NetworkImage(_imageUrl!)
                                                  : null,
                                              child: _imageUrl == null
                                                  ? Icon(
                                                      Icons.person,
                                                      size: 50,
                                                      color: primaryColor,
                                                    )
                                                  : null,
                                            ),
                                    ),
                                    if (!_isEditing && isUserLoggedIn)
                                      Positioned(
                                        bottom: 0,
                                        right: 0,
                                        child: GestureDetector(
                                          onTap: _pickAndUploadImage,
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: primaryColor,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.2),
                                                  spreadRadius: 1,
                                                  blurRadius: 3,
                                                ),
                                              ],
                                            ),
                                            child: const Icon(
                                              Icons.camera_alt,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),

                                if (isUserLoggedIn) ...[
                                  const SizedBox(height: 16),
                                  Text(
                                    '$_firstName $_lastName',
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _username,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),

                        // Profile information or edit form
                        Container(
                          width: MediaQuery.of(context).size.width,
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 10,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: _isEditing
                              ? Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          left: 8,
                                          bottom: 16,
                                        ),
                                        child: Text(
                                          'แก้ไขข้อมูลส่วนตัว',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: primaryColor,
                                          ),
                                        ),
                                      ),
                                      _buildProfileInputField(
                                        _usernameController,
                                        'ชื่อผู้ใช้',
                                        Icons.person,
                                      ),
                                      _buildProfileInputField(
                                        _firstNameController,
                                        'ชื่อ',
                                        Icons.person_outline,
                                      ),
                                      _buildProfileInputField(
                                        _lastNameController,
                                        'นามสกุล',
                                        Icons.person_outline,
                                      ),
                                      _buildProfileInputField(
                                        _emailController,
                                        'อีเมล',
                                        Icons.email,
                                      ),
                                      _buildProfileInputField(
                                        _addressController,
                                        'ที่อยู่',
                                        Icons.home,
                                      ),
                                      _buildProfileInputField(
                                        _mobilePhoneController,
                                        'โทรศัพท์มือถือ',
                                        Icons.phone,
                                      ),
                                      _buildProfileInputField(
                                        _genderController,
                                        'เพศ',
                                        Icons.people,
                                        isGender: true,
                                      ),
                                      _buildProfileInputField(
                                        _birthdateController,
                                        'วันเกิด',
                                        Icons.calendar_today,
                                        isDatePicker: true,
                                      ),

                                      const SizedBox(height: 16),

                                      Row(
                                        children: [
                                          Expanded(
                                            child: ElevatedButton(
                                              onPressed: () {
                                                setState(() {
                                                  _isEditing = false;
                                                });
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Colors.grey.shade200,
                                                foregroundColor: Colors.black87,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 14,
                                                    ),
                                              ),
                                              child: const Text('ยกเลิก'),
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: ElevatedButton(
                                              onPressed: _updateUserProfile,
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: primaryColor,
                                                foregroundColor: Colors.white,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 14,
                                                    ),
                                              ),
                                              child: const Text('บันทึก'),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                )
                              : Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              'ข้อมูลส่วนตัว',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: primaryColor,
                                              ),
                                            ),
                                          ),

                                          if (isUserLoggedIn)
                                            IconButton(
                                              icon: Icon(
                                                Icons.edit,
                                                color: primaryColor,
                                              ),
                                              onPressed: () async {
                                                SharedPreferences prefs =
                                                    await SharedPreferences.getInstance();
                                                final String? token = prefs
                                                    .getString('token');
                                                final int? custID = prefs
                                                    .getInt('custID');
                                                if (token == null ||
                                                    custID == null) {
                                                  _showSnackBar(
                                                    'กรุณาเข้าสู่ระบบ',
                                                  );
                                                  return;
                                                }
                                                setState(() {
                                                  _isEditing = true;
                                                });
                                              },
                                              padding: EdgeInsets.zero,
                                              constraints:
                                                  const BoxConstraints(),
                                            ),
                                        ],
                                      ),
                                    ),
                                    const Divider(height: 1),
                                    _buildProfileInfoItem(
                                      'ชื่อผู้ใช้',
                                      _username,
                                    ),
                                    _buildProfileInfoItem('ชื่อ', _firstName),
                                    _buildProfileInfoItem('นามสกุล', _lastName),
                                    _buildProfileInfoItem('อีเมล', _email),
                                    _buildProfileInfoItem(
                                      'ที่อยู่',
                                      _address.isEmpty ? '' : _address,
                                    ),
                                    _buildProfileInfoItem(
                                      'โทรศัพท์มือถือ',
                                      _mobilePhone.isEmpty ? '' : _mobilePhone,
                                    ),
                                    _buildProfileInfoItem('เพศ', _gender),
                                    _buildProfileInfoItem(
                                      'วันเกิด',
                                      _getFormattedBirthdate(),
                                    ),
                                  ],
                                ),
                        ),

                        const SizedBox(height: 32),
                        // Footer actions (กรณีที่เข้าสู่ระบบแล้ว)
                        if (!_isEditing && isUserLoggedIn)
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            child: ElevatedButton.icon(
                              onPressed: _logout,
                              icon: const Icon(Icons.logout),
                              label: const Text('ออกจากระบบ'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(
                                  255,
                                  226,
                                  211,
                                  137,
                                ),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                minimumSize: const Size(double.infinity, 50),
                              ),
                            ),
                          ),

                        // Footer actions (กรณีที่ยังไม่ได้เข้าสู่ระบบ)
                        if (!_isEditing && !isUserLoggedIn)
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const LoginPage(),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.login),
                                    label: const Text('เข้าสู่ระบบ'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color.fromARGB(
                                        255,
                                        226,
                                        211,
                                        137,
                                      ),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 12,
                                ), // Add spacing between buttons
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed:
                                        _register, // You'll need to create this function
                                    icon: const Icon(Icons.person_add),
                                    label: const Text('สมัครสมาชิก'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.grey,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
