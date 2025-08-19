"use client";
import { useState, FormEvent } from "react";

export default function Register() {
  const [username, setUsername] = useState<string>("");
  const [password, setPassword] = useState<string>("");
  const [firstName, setFirstName] = useState<string>("");
  const [lastName, setLastName] = useState<string>("");

  const handleSubmit = async (e: any) => {
    e.preventDefault();
    
    // Validation
    if (!username || !password || !firstName || !lastName) {
      alert("กรุณากรอกข้อมูลให้ครบทุกช่อง");
      return;
    }
    
    try {
      // ใช้ fetch แทน axios สำหรับ artifact
      const response = await fetch("http://localhost:4000/api/register", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          username,
          password,
          firstName,
          lastName,
        }),
      });
      
      const result = await response.json();
      alert(result.message);
      
      if (result.status === true) {
        // Reset form on success
        setUsername("");
        setPassword("");
        setFirstName("");
        setLastName("");
        // Redirect to home page
        window.location.href = "/";
      }
    } catch (err) {
      console.error("Registration error:", err);
      alert("การสมัครสมาชิกล้มเหลว กรุณาลองใหม่อีกครั้ง");
    }
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-yellow-100 via-amber-50 to-orange-100 p-4 sm:p-6 md:p-8">
      <div className="w-full max-w-sm sm:max-w-md lg:max-w-lg">
        <div className="bg-white/90 backdrop-blur-sm shadow-2xl rounded-3xl p-6 sm:p-8 md:p-10 space-y-4 sm:space-y-6 border border-yellow-200/50 hover:shadow-yellow-200/30 transition-all duration-300">
          {/* Header with cute emoji */}
          <div className="text-center mb-6">
            <div className="text-4xl sm:text-5xl mb-2">🌻</div>
            <h1 className="text-xl sm:text-2xl md:text-3xl font-bold bg-gradient-to-r from-amber-600 to-yellow-600 bg-clip-text text-transparent">
              ระบบซื้อขายออนไลน์
            </h1>
            <p className="text-yellow-600 text-sm sm:text-base mt-2 font-medium">
              สมัครสมาชิกกับเรา 💛
            </p>
          </div>

          {/* Username Input */}
          <div className="relative">
            <input
              type="text"
              placeholder="Username"
              value={username}
              onChange={(e) => setUsername(e.target.value)}
              className="w-full px-4 sm:px-5 py-3 sm:py-4 border-2 border-yellow-200 rounded-2xl focus:outline-none focus:ring-4 focus:ring-yellow-300/50 focus:border-yellow-400 text-gray-800 bg-yellow-50/50 placeholder-yellow-500/70 transition-all duration-200 text-sm sm:text-base"
              required
            />
          </div>

          {/* Password Input */}
          <div className="relative">
            <input
              type="password"
              placeholder="Password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              className="w-full px-4 sm:px-5 py-3 sm:py-4 border-2 border-yellow-200 rounded-2xl focus:outline-none focus:ring-4 focus:ring-yellow-300/50 focus:border-yellow-400 text-gray-800 bg-yellow-50/50 placeholder-yellow-500/70 transition-all duration-200 text-sm sm:text-base"
              required
            />
          </div>

          {/* Name Inputs - Responsive Grid */}
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-3 sm:gap-4">
            <input
              type="text"
              placeholder="ชื่อ"
              value={firstName}
              onChange={(e) => setFirstName(e.target.value)}
              className="w-full px-4 sm:px-5 py-3 sm:py-4 border-2 border-yellow-200 rounded-2xl focus:outline-none focus:ring-4 focus:ring-yellow-300/50 focus:border-yellow-400 text-gray-800 bg-yellow-50/50 placeholder-yellow-500/70 transition-all duration-200 text-sm sm:text-base"
              required
            />
            <input
              type="text"
              placeholder="นามสกุล"
              value={lastName}
              onChange={(e) => setLastName(e.target.value)}
              className="w-full px-4 sm:px-5 py-3 sm:py-4 border-2 border-yellow-200 rounded-2xl focus:outline-none focus:ring-4 focus:ring-yellow-300/50 focus:border-yellow-400 text-gray-800 bg-yellow-50/50 placeholder-yellow-500/70 transition-all duration-200 text-sm sm:text-base"
              required
            />
          </div>

          {/* Submit Button */}
          <button
            type="button"
            onClick={handleSubmit}
            className="w-full bg-gradient-to-r from-yellow-400 to-amber-500 hover:from-yellow-500 hover:to-amber-600 text-white font-semibold py-3 sm:py-4 px-6 rounded-2xl transition-all duration-300 transform hover:scale-[1.02] hover:shadow-lg hover:shadow-yellow-300/50 active:scale-[0.98] text-sm sm:text-base md:text-lg"
          >
            <span className="flex items-center justify-center space-x-2">
              <span>สมัครสมาชิก</span>
              <span className="text-lg">✨</span>
            </span>
          </button>

          {/* Additional cute elements */}
          <div className="text-center pt-4">
            <p className="text-yellow-600/80 text-xs sm:text-sm">
              มีบัญชีอยู่แล้ว? 
              <a href="/customers/login" className="text-amber-600 hover:text-amber-700 font-medium ml-1 hover:underline transition-colors">
                เข้าสู่ระบบ
              </a>
            </p>
          </div>
        </div>

        {/* Decorative elements */}
        <div className="absolute top-10 left-10 text-yellow-400/30 text-6xl animate-pulse hidden md:block">
          🌞
        </div>
        <div className="absolute bottom-10 right-10 text-amber-400/30 text-4xl animate-bounce hidden lg:block">
          🐝
        </div>
      </div>
    </div>
  );
}