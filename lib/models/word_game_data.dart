import 'dart:math';

class TopicItem {
  final String title;
  final String hint;
  final List<String> commonWords;

  TopicItem({
    required this.title,
    required this.hint,
    required this.commonWords,
  });
}

class WordGameBank {
  static final List<TopicItem> topics = [
    TopicItem(
      title: 'أشياء نجدها داخل المطار',
      hint: 'فكر فيما تراه في صالة السفر أو الطائرة',
      commonWords: ['جواز', 'شنطة', 'طيارة', 'تذكرة', 'جمارك', 'مدرج', 'مقعد'],
    ),
    TopicItem(
      title: 'أكلات ومشروبات رمضانية',
      hint: 'أشياء مشهورة على مائدة الإفطار',
      commonWords: ['سمبوسة', 'شوربة', 'فيمتو', 'تمر', 'لقيمات', 'قمر الدين'],
    ),
    TopicItem(
      title: 'أعطال شائعة في السيارات',
      hint: 'أشياء تجعلك تذهب للميكانيكي أو تقف على الطريق',
      commonWords: ['بنشر', 'بطارية', 'حرارة', 'فرامل', 'بواجي', 'دينامو'],
    ),
    TopicItem(
      title: 'أشياء تجدها في السوبرماركت',
      hint: 'أقسام ومحتويات التسوق اليومي',
      commonWords: ['عربة', 'كاشير', 'حليب', 'خبز', 'أرز', 'زيت', 'أجبان'],
    ),
    TopicItem(
      title: 'مهن تتطلب العمل في الليل',
      hint: 'وظائف يكون أصحابها مستيقظين بينما الناس نيام',
      commonWords: ['طبيب', 'حارس', 'شرطي', 'طيار', 'سائق', 'ممرض'],
    ),
  ];

  static TopicItem getRandomTopic() {
    final random = Random();
    return topics[random.nextInt(topics.length)];
  }

  // محاكاة اختيار البوت لـ 3 كلمات شائعة
  static List<String> getBotPicks(TopicItem topic) {
    List<String> pool = List.from(topic.commonWords)..shuffle();
    return pool.take(3).toList();
  }
}
