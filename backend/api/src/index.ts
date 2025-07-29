//importing dependencies
import express from 'express';

//configuring the express app
const app = express();
const PORT = process.env.PORT || 3000;

//defining api endpoint
//hello world
app.get('/', (req, res) => {
  res.send('Hello World!'); //ส่งข้อความ "Hello World!" เมื่อเข้าถึง root path
});

//starting the server
app.listen(PORT, () => {
  console.log(`Server is running on http://localhost:${PORT}`); //แสดงข้อความเมื่อเซิร์ฟเวอร์เริ่มทำงาน
});