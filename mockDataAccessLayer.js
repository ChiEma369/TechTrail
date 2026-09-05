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

  // ================= 3. NHẬT KÝ THỰC CHIẾN MODULE =================
  // Viết phản hồi nhật ký sau trải nghiệm (UC3.1 / BR3)
  async createJournalEntry({ userId, activityId, interestRating, difficultyLevel, freeComment }) {
    const data = await this._load();
    await this._delay();

    // Ràng buộc nghiệp vụ BR3.2: Mỗi hoạt động chỉ được viết 1 phản hồi
    const existingEntry = data.journal_entries.find(
      entry => entry.user_id === userId && entry.activity_id === activityId
    );
    if (existingEntry) {
      throw new Error("Bạn đã gửi phản hồi cho hoạt động này rồi!");
    }

    const newEntry = {
      id: crypto.randomUUID(),
      user_id: userId,
      activity_id: activityId,
      interest_rating: Number(interestRating),
      difficulty_level: difficultyLevel,
      free_comment: freeComment || "",
      created_at: new Date().toISOString()
    };

    data.journal_entries.push(newEntry);

    // Cập nhật trạng thái trong bảng activity_logs thành 'completed'
    const log = data.activity_logs.find(l => l.user_id === userId && l.activity_id === activityId);
    if (log) {
      log.status = "completed";
    }

    // Tự động tính toán lại IT Profile theo quy tắc BR4.2
    await this._recalculateProfile(userId);

    return newEntry;
  }

  async getJournalHistory(userId) {
    const data = await this._load();
    await this._delay();
    return data.journal_entries.filter(entry => entry.user_id === userId);
  }

  // ================= 4. IT PROFILE MODULE & TÍNH ĐIỂM =================
  // Logic nghiệp vụ BR4.2: Điểm phù hợp = trung bình cộng điểm sao * 2
  async _recalculateProfile(userId) {
    const data = await this._load();
    const userEntries = data.journal_entries.filter(e => e.user_id === userId);

    // Gom điểm theo từng ngách nghề
    const branchScores = {}; // { branchId: [rating1, rating2] }

    for (const entry of userEntries) {
      const activity = data.activities.find(a => a.id === entry.activity_id);
      if (activity && activity.branch_id) {
        if (!branchScores[activity.branch_id]) {
          branchScores[activity.branch_id] = [];
        }
        branchScores[activity.branch_id].push(entry.interest_rating);
      }
    }

    const track_scores = {};
    for (const [bId, ratings] of Object.entries(branchScores)) {
      const avgStar = ratings.reduce((a, b) => a + b, 0) / ratings.length;
      // Quy đổi thang 10: Điểm 10 = điểm TB sao * 2 (mục 3.9.6 báo cáo)
      track_scores[bId] = Number((avgStar * 2).toFixed(1));
    }

    let profile = data.it_profiles.find(p => p.user_id === userId);
    if (!profile) {
      profile = { user_id: userId, track_scores: {}, strengths: [] };
      data.it_profiles.push(profile);
    }
    profile.track_scores = track_scores;
  }

  async getUserProfile(userId) {
    const data = await this._load();
    await this._delay();
    return data.it_profiles.find(p => p.user_id === userId) || null;
  }
}

module.exports = new DataAccessLayer();