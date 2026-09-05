const dal = require('./mockDataAccessLayer');

async function testFullFlow() {
  console.log("=== BẮT ĐẦU TEST DATA ACCESS LAYER ===");

  const userId = "a1111111-1111-4111-8111-111111111111"; // Linh Chi
  const aiActivityId = "c3333333-3333-4333-8333-333333333333"; // Hoạt động Python AI

  // 1. Xem danh sách ngách nghề
  const branches = await dal.getAllCareerBranches();
  console.log(`\n1. Lấy danh sách ngách nghề: Thành công (${branches.length} ngách)`);

  // 2. Sinh viên đăng ký tham gia một hoạt động mới (AI)
  console.log("\n2. Đăng ký tham gia hoạt động AI...");
  const registration = await dal.registerActivity(userId, aiActivityId);
  console.log("   -> Đăng ký thành công:", registration);

  // 3. Viết bài nhật ký đánh giá hoạt động này 5 sao
  console.log("\n3. Viết bài nhật ký phản hồi (5 sao, Vừa sức)...");
  const entry = await dal.createJournalEntry({
    userId,
    activityId: aiActivityId,
    interestRating: 5,
    difficultyLevel: "Vừa sức",
    freeComment: "Mô hình CNN rất hay và dễ hiểu!"
  });
  console.log("   -> Tạo phản hồi thành công, ID:", entry.id);

  // 4. Kiểm tra xem điểm IT Profile đã tự động cập nhật ngách AI chưa
  console.log("\n4. Kiểm tra IT Profile sau khi cập nhật...");
  const profile = await dal.getUserProfile(userId);
  console.log("   -> Điểm số các ngách nghề hiện tại (thang 10):", profile.track_scores);

  console.log("\n=== TẤT CẢ TEST ĐÃ CHẠY HOÀN HẢO ===");
}

testFullFlow().catch(console.error);