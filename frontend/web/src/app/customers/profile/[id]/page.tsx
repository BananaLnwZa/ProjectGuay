"use client";
import { useEffect, useState } from "react";
import { User, Mail, Phone, Calendar, MapPin, LogOut, Edit } from "lucide-react";

// Interface สำหรับข้อมูลลูกค้า
interface Customer {
  custID: number;
  username: string;
  firstName: string;
  lastName: string;
  email: string;
  mobilePhone: string;
  birthdate: string;
  gender: number;
  address: string;
  imageFile: string;
}

export default function UserProfile() {
  const [customer, setCustomer] = useState<Customer | null>(null);
  const [loading, setLoading] = useState(true);

  // Mock ID สำหรับ demo (ในโปรเจคจริงใช้ useParams)
  const id = "1";

  useEffect(() => {
    const fetchProfile = async () => {
      try {
        // Mock token check (ในโปรเจคจริงใช้ localStorage.getItem("token"))
        const token = "mock-token";
        
        if (!token) {
          alert("กรุณาเข้าสู่ระบบก่อน");
          window.location.href = "/login";
          return;
        }

        // ใช้ fetch แทน axios สำหรับ artifact
        const response = await fetch(`http://localhost:4000/api/profile/${id}`, {
          headers: {
            Authorization: `Bearer ${token}`,
          },
        });
        
        const data = await response.json();
        setCustomer(data);
      } catch (error) {
        console.error("Error fetching profile:", error);
        alert("ไม่สามารถโหลดข้อมูลโปรไฟล์ได้");
      } finally {
        setLoading(false);
      }
    };

    fetchProfile();
  }, []);

  const handleLogout = () => {
    // ในโปรเจคจริงใช้ localStorage.removeItem("token")
    alert("ออกจากระบบสำเร็จ");
    window.location.href = "/login";
  };

  if (loading) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-yellow-100 via-amber-50 to-orange-100 flex items-center justify-center p-4">
        <div className="bg-white/90 backdrop-blur-sm rounded-3xl p-8 shadow-xl">
          <div className="flex flex-col items-center space-y-4">
            <div className="animate-spin text-yellow-500 text-4xl">🌻</div>
            <p className="text-yellow-600 font-medium">กำลังโหลดข้อมูล...</p>
          </div>
        </div>
      </div>
    );
  }

  if (!customer) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-yellow-100 via-amber-50 to-orange-100 flex items-center justify-center p-4">
        <div className="bg-white/90 backdrop-blur-sm rounded-3xl p-8 shadow-xl text-center">
          <div className="text-4xl mb-4">😢</div>
          <p className="text-yellow-600 font-medium">ไม่พบข้อมูลผู้ใช้</p>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-yellow-100 via-amber-50 to-orange-100 p-4 sm:p-6 md:p-8">
      <div className="max-w-2xl mx-auto">
        
        {/* Header with Logout Button */}
        <div className="flex justify-between items-center mb-6">
          <h1 className="text-2xl sm:text-3xl md:text-4xl font-bold bg-gradient-to-r from-amber-600 to-yellow-600 bg-clip-text text-transparent">
            โปรไฟล์ของฉัน
          </h1>
          <button
            onClick={handleLogout}
            className="flex items-center space-x-2 bg-amber-500 hover:bg-amber-600 text-white px-4 py-2 rounded-xl transition-all duration-200 text-sm font-medium"
          >
            <LogOut size={16} />
            <span className="hidden sm:inline">ออกจากระบบ</span>
          </button>
        </div>

        {/* Profile Card */}
        <div className="bg-white/90 backdrop-blur-sm shadow-2xl rounded-3xl overflow-hidden border border-yellow-200/50">
          
          {/* Profile Header */}
          <div className="bg-gradient-to-r from-yellow-400 to-amber-500 px-6 sm:px-8 py-8 sm:py-12 text-center relative">
            <div className="absolute top-4 right-4">
              <button className="bg-white/20 hover:bg-white/30 backdrop-blur-sm rounded-full p-2 transition-all duration-200">
                <Edit size={18} className="text-white" />
              </button>
            </div>
            
            {/* Profile Image */}
            <div className="relative mx-auto w-24 h-24 sm:w-32 sm:h-32 mb-4">
              {customer.imageFile ? (
                <img 
                  src={customer.imageFile} 
                  alt="Profile" 
                  className="w-full h-full object-cover rounded-full border-4 border-white shadow-lg"
                />
              ) : (
                <div className="w-full h-full bg-white/20 backdrop-blur-sm rounded-full border-4 border-white shadow-lg flex items-center justify-center">
                  <User size={48} className="text-white" />
                </div>
              )}
            </div>
            
            {/* Name and Username */}
            <h2 className="text-xl sm:text-2xl md:text-3xl font-bold text-white mb-2">
              {customer.firstName} {customer.lastName}
            </h2>
            <p className="text-yellow-100 text-sm sm:text-base font-medium">
              @{customer.username}
            </p>
          </div>

          {/* Profile Details */}
          <div className="p-6 sm:p-8 space-y-6">
            
            {/* Contact Information */}
            <div className="space-y-4">
              <h3 className="text-lg sm:text-xl font-semibold text-amber-700 mb-4 flex items-center">
                <span className="mr-2">📞</span>
                ข้อมูลติดต่อ
              </h3>
              
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <div className="bg-yellow-50/50 rounded-2xl p-4 border border-yellow-200/50">
                  <div className="flex items-center space-x-3">
                    <Mail className="text-amber-500" size={20} />
                    <div>
                      <p className="text-xs text-yellow-600 font-medium">อีเมล</p>
                      <p className="text-gray-800 text-sm sm:text-base">{customer.email || "ไม่ได้ระบุ"}</p>
                    </div>
                  </div>
                </div>
                
                <div className="bg-yellow-50/50 rounded-2xl p-4 border border-yellow-200/50">
                  <div className="flex items-center space-x-3">
                    <Phone className="text-amber-500" size={20} />
                    <div>
                      <p className="text-xs text-yellow-600 font-medium">เบอร์โทร</p>
                      <p className="text-gray-800 text-sm sm:text-base">{customer.mobilePhone || "ไม่ได้ระบุ"}</p>
                    </div>
                  </div>
                </div>
              </div>
            </div>

            {/* Personal Information */}
            <div className="space-y-4">
              <h3 className="text-lg sm:text-xl font-semibold text-amber-700 mb-4 flex items-center">
                <span className="mr-2">👤</span>
                ข้อมูลส่วนตัว
              </h3>
              
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <div className="bg-yellow-50/50 rounded-2xl p-4 border border-yellow-200/50">
                  <div className="flex items-center space-x-3">
                    <Calendar className="text-amber-500" size={20} />
                    <div>
                      <p className="text-xs text-yellow-600 font-medium">วันเกิด</p>
                      <p className="text-gray-800 text-sm sm:text-base">
                        {customer.birthdate ? new Date(customer.birthdate).toLocaleDateString('th-TH') : "ไม่ได้ระบุ"}
                      </p>
                    </div>
                  </div>
                </div>
                
                <div className="bg-yellow-50/50 rounded-2xl p-4 border border-yellow-200/50">
                  <div className="flex items-center space-x-3">
                    <span className="text-amber-500 text-xl">
                      {customer.gender === 0 ? "👨" : "👩"}
                    </span>
                    <div>
                      <p className="text-xs text-yellow-600 font-medium">เพศ</p>
                      <p className="text-gray-800 text-sm sm:text-base">
                        {customer.gender === 0 ? "ชาย" : "หญิง"}
                      </p>
                    </div>
                  </div>
                </div>
              </div>
            </div>

            {/* Address */}
            <div className="space-y-4">
              <h3 className="text-lg sm:text-xl font-semibold text-amber-700 mb-4 flex items-center">
                <span className="mr-2">🏠</span>
                ที่อยู่
              </h3>
              
              <div className="bg-yellow-50/50 rounded-2xl p-4 border border-yellow-200/50">
                <div className="flex items-start space-x-3">
                  <MapPin className="text-amber-500 mt-1" size={20} />
                  <div className="flex-1">
                    <p className="text-xs text-yellow-600 font-medium mb-1">ที่อยู่ปัจจุบัน</p>
                    <p className="text-gray-800 text-sm sm:text-base leading-relaxed">
                      {customer.address || "ไม่ได้ระบุที่อยู่"}
                    </p>
                  </div>
                </div>
              </div>
            </div>

            {/* Action Buttons */}
            <div className="flex flex-col sm:flex-row gap-3 pt-6">
              <button className="flex-1 bg-gradient-to-r from-yellow-400 to-amber-500 hover:from-yellow-500 hover:to-amber-600 text-white font-semibold py-3 px-6 rounded-2xl transition-all duration-300 transform hover:scale-[1.02] hover:shadow-lg hover:shadow-yellow-300/50 flex items-center justify-center space-x-2">
                <Edit size={18} />
                <span>แก้ไขโปรไฟล์</span>
              </button>
              
              <button 
                onClick={() => window.history.back()}
                className="flex-1 bg-amber-100 hover:bg-amber-200 text-amber-700 font-semibold py-3 px-6 rounded-2xl transition-all duration-300 transform hover:scale-[1.02] border border-amber-200"
              >
                กลับ
              </button>
            </div>
          </div>
        </div>

        {/* Decorative elements */}
        <div className="absolute top-10 left-10 text-yellow-400/20 text-6xl animate-pulse hidden lg:block">
          ⭐
        </div>
        <div className="absolute bottom-10 right-10 text-amber-400/20 text-5xl animate-bounce hidden lg:block">
          🌼
        </div>
      </div>
    </div>
  );
}