const fs = require('fs').promises;
const path = require('path');
const crypto = require('crypto'); // Thư viện có sẵn của Node.js để sinh UUID ngẫu nhiên

const dataPath = path.join(__dirname, 'mockData.json');

class DataAccessLayer {
  constructor() {
    this.cacheData = null; // Cache vào RAM để chạy nhanh và hỗ trợ cập nhật dữ liệu tạm thời
  }

  // Khởi tạo và đọc dữ liệu
  async _load() {
    if (!this.cacheData) {
      const raw = await fs.readFile(dataPath, 'utf-8');
      this.cacheData = JSON.parse(raw);
    }
    return this.cacheData;
  }

  // Giả lập độ trễ mạng (Network Latency) để đội Flutter test thanh Loading/Shimmer
  _delay(ms = 300) {
    return new Promise(resolve => setTimeout(resolve, ms));
  }

  // ================= 1. IT CAREER MAP MODULE =================
  async getAllCareerBranches() {
    const data = await this._load();
    await this._delay();
    return data.career_branches;
  }

  async getCareerBranchById(branchId) {
    const data = await this._load();
    await this._delay();
    return data.career_branches.find(b => b.id === branchId) || null;
  }

  // ================= 2. TRẠM TRẢI NGHIỆM MODULE =================
  async getActivities(branchId = null) {
    const data = await this._load();
    await this._delay();
    if (branchId) {
      return data.activities.filter(act => act.branch_id === branchId);
    }
    return data.activities;
  }

  async getActivityById(activityId) {
    const data = await this._load();
    await this._delay();
    return data.activities.find(act => act.id === activityId) || null;
  }

  // Ghi nhận sinh viên đăng ký tham gia hoạt động (UC2.3 / Bảng activity_logs)
  async registerActivity(userId, activityId) {
    const data = await this._load();
    await this._delay();

    const existingLog = data.activity_logs.find(
      log => log.user_id === userId && log.activity_id === activityId
    );

    if (existingLog) {
      throw new Error("Bạn đã đăng ký hoạt động này trước đó rồi!");
    }

    const newLog = {
      id: crypto.randomUUID(),
      user_id: userId,
      activity_id: activityId,
      status: "in_progress"
    };

    data.activity_logs.push(newLog);
    return newLog;
  }


}

module.exports = new DataAccessLayer();