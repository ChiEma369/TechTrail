import 'package:flutter_test/flutter_test.dart';
import 'package:techtrail_mobile/main.dart';

void main() {
  testWidgets('Khởi chạy TechTrailApp và kiểm tra hiển thị tiêu đề', (WidgetTester tester) async {
    await tester.pumpWidget(const TechTrailApp());

    expect(find.text('TechTrail Mobile'), findsOneWidget);
    expect(find.text('Dự án sẵn sàng phát triển từ đầu'), findsOneWidget);
  });
}
