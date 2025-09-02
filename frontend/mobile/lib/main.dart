// ส่วนที่ 1: การ import libraries และไฟล์ที่เกี่ยวข้อง
import 'package:flutter/material.dart';
import 'package:mobile/src/home.dart';
import 'package:mobile/src/cart.dart';
import 'package:mobile/src/history.dart';
import 'package:mobile/src/account.dart';

// ส่วนที่ 2: Main function คือ จุดเริ่มต้นของแอป
void main() {
  runApp(const MyApp());
}

// ส่วนที่ 3: MyApp คือ StatelessWidget ที่ไม่ต้องเปลี่ยนแปลงค่าหรือสถานนะในระหว่างที่แอปทำงาน
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  //ทำการสร้างและแสดง widgets ของแอปพลิเคชัน (คล้ายกับ return ใน react)
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // ซ่อนแถบ debug
      title: 'Project Guay Demo', // กำหนดชื่อแอปพลิเคชัน
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 243, 220, 126),
        ), // กำหนดสีหลักของแอปพลิเคชัน
      ),
      home: const MyHomePage(
        title: 'Guay',
      ), // กำหนดหน้าหลักและหัวเรื่องของแอปพลิเคชัน
    );
  }
}

// ส่วนที่ 4: MainPage คือ StatefulWidget ซึ่งสามารถเปลี่ยนแปลงค่าหรือสถานะได้
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

// ส่วนที่ 5: _MainPageState คือ state ของ MainPage
class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0; // index ของหน้าใน bottom navigation

  // รายการของหน้าในแต่ละ tab
  final List<Widget> _pages = [
    const HomePage(),
    const CartPage(),
    const HistoryPage(),
    const AccountPage(),
  ];

  // เรียกใช้เมื่อผู้ใช้กดที่แต่ละ tab ใน bottom navigation
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // อัปเดต index ของหน้าเมื่อเปลี่ยน tab
  void setSelectedIndex(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  //ทำการสร้าง widget ของหน้าหลักของแอปพลิเคชัน
  @override
  Widget build(BuildContext context) {
    // Scaffold เป็น widget ที่ให้โครงสร้างพื้นฐานสำหรับ Material Design
    // แอปพลิเคชัน เช่น AppBar, Body, FloatingActionButton เป็นต้น
    return Scaffold(
      body: _pages[_selectedIndex], // แสดงหน้าแต่ละ tab
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // แสดง label ทุกอัน
        items: <BottomNavigationBarItem>[
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex, // tab ที่ถูกเลือกอยู่
        selectedItemColor: const Color.fromARGB(
          255,
          83,
          72,
          51,
        ), // สีของ tab ที่ถูกเลือก
        unselectedItemColor: const Color.fromARGB(
          255,
          158,
          158,
          158,
        ), // สีของ tab ที่ไม่ได้เลือก
        onTap: _onItemTapped, // เมื่อกด tab
      ),
    );
  }
}
