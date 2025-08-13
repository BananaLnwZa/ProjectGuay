//1.importing dependencies
import express from 'express';
import cors from 'cors';
import mysql from 'mysql2';
import dotenv from 'dotenv';
dotenv.config();

//2.configuring the express app
const app = express();
const PORT = process.env.PORT || 3000;
app.use(express.json()); //ใช้ middleware เพื่อให้สามารถรับข้อมูล JSON ได้
app.use(express.urlencoded({ extended: true })); //เพื่อให้สามารถรับข้อมูลจาก HTML Form ได้
app.use(cors());// อนุญาตให้ API ถูกเรียกจากโดเมนอื่น

// MySQL Connection
const db = mysql.createConnection({
 host: process.env.DB_HOST,
 user: process.env.DB_USER,
 password: process.env.DB_PASSWORD,
 database: process.env.DB_NAME,
 port: Number(process.env.DB_PORT)
});
db.connect();

db.connect((err) => {
  if (err) {
    console.error('❌ MySQL connection failed:', err);
  } else {
    console.log('✅ Connected to MySQL database');
  }
});

//3.defining api endpoint
function query(sql: string, params: any[] = []):
Promise<any> {
 return new Promise((resolve, reject) => {
  db.query(sql, params, (err, results) => {
   if (err) reject(err);
   else resolve(results);
  });
 });
} 
app.get('/', (req, res) => {
  res.send('Hello World!'); //ส่งข้อความ "Hello World!" เมื่อเข้าถึง root path
});

// CREATE - เพิ่มลูกค้าใหม่
app.post('/api/customer', async (req, res) => {
 try {
  const { username, password, firstName, lastName } = req.body;
  const sql = `
   INSERT INTO customer (username, password, firstName, lastName)
   VALUES (?, ?, ?, ?)
  `;

  const result = await query(sql, [username, password, firstName, lastName]);
  res.json({
   status: true,
   message: 'Customer created successfully'
  });

 } catch (err) {
  console.error(err); // แสดง error บน terminal / console

  res.status(500).json({
    status: false,
    message: 'Failed to create customer'
  });
 }
});

//starting the server
app.listen(PORT, () => {
  console.log(`Server is running on http://localhost:${PORT}`); //แสดงข้อความเมื่อเซิร์ฟเวอร์เริ่มทำงาน
});