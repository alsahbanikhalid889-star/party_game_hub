class TopicItem {
  final int id;
  final String title;
  final String hint;
  final List<String> commonWords;

  TopicItem({
    required this.id,
    required this.title,
    required this.hint,
    required this.commonWords,
  });
}

class WordGameBank {
  static final List<TopicItem> topics = [
    TopicItem(
      id: 1,
      title: 'أشياء نجدها داخل المطار',
      hint: 'فكر فيما تراه في صالة السفر أو الطائرة',
      commonWords: ['جواز', 'شنطة', 'طيارة', 'تذكرة', 'جمارك', 'مدرج', 'مقعد', 'مضيف', 'تفتيش', 'بوابة'],
    ),
    TopicItem(
      id: 2,
      title: 'أكلات ومشروبات رمضانية',
      hint: 'أشياء مشهورة على مائدة الإفطار والسحور',
      commonWords: ['سمبوسة', 'شوربة', 'فيمتو', 'تمر', 'لقيمات', 'قمر الدين', 'فول', 'شاي', 'معجنات', 'مهلبية'],
    ),
    TopicItem(
      id: 3,
      title: 'أعطال شائعة في السيارات',
      hint: 'أشياء تجعلك تذهب للميكانيكي أو تقف على الطريق',
      commonWords: ['بنشر', 'بطارية', 'حرارة', 'فرامل', 'بواجي', 'دينامو', 'سير', 'رديتر', 'زيت', 'فيوز'],
    ),
    TopicItem(
      id: 4,
      title: 'مهن تتطلب العمل في الليل',
      hint: 'وظائف يكون أصحابها مستيقظين بينما الناس نيام',
      commonWords: ['طبيب', 'حارس', 'حراسة', 'شرطي', 'طيار', 'سائق', 'ممرض', 'مذيع', 'عامل نظافة', 'صيدلي'],
    ),
    TopicItem(
      id: 5,
      title: 'أشياء تجدها في السوبرماركت',
      hint: 'أقسام ومحتويات التسوق اليومي',
      commonWords: ['عربة', 'كاشير', 'حليب', 'خبز', 'ارز', 'زيت', 'اجبان', 'منظفات', 'بسكويت', 'معلبات'],
    ),
    TopicItem(
      id: 6,
      title: 'أجهزة وأدوات في المطبخ',
      hint: 'أشياء تستخدم للطبخ وإعداد الطعام',
      commonWords: ['ثلاجة', 'فرن', 'ميكروويف', 'سكين', 'ملعقة', 'قدر', 'خلاط', 'صحن', 'طاسة', 'غلاية'],
    ),
    TopicItem(
      id: 7,
      title: 'حيوانات تعيش في الصحراء',
      hint: 'كائنات تتحمل الحرارة وقلة المياه',
      commonWords: ['جمل', 'ضب', 'عقرب', 'ثعبان', 'صقر', 'يربوع', 'ذئب', 'غزال', 'قنفذ', 'ثعلب'],
    ),
    TopicItem(
      id: 8,
      title: 'أشياء تأخذها معك في الرحلات البرية (الكشتة)',
      hint: 'لوازم التخييم وقضاء وقت ممتع في البر',
      commonWords: ['خيمة', 'حطب', 'فحم', 'دلة', 'ابريق', 'فرشة', 'كشاف', 'شواية', 'ماء', 'شاي'],
    ),
    TopicItem(
      id: 9,
      title: 'أشياء نراها في المستشفى',
      hint: 'أشخاص وأدوات وغرف داخل المراكز الطبية',
      commonWords: ['سرير', 'دكتور', 'ممرضة', 'مغذي', 'اسعاف', 'طوارئ', 'اشعة', 'دواء', 'عمليات', 'كمامة'],
    ),
    TopicItem(
      id: 10,
      title: 'أشياء تجعل الشخص يتأخر عن موعده',
      hint: 'أسباب ومواقف شائعة للتعطيل في الصباح',
      commonWords: ['زحمة', 'نوم', 'منبه', 'حادث', 'مفتاح', 'لبس', 'سيارة', 'فطور', 'اتصال', 'كسل'],
    ),
  ];

  static final List<int> _usedTopicIds = [];

  static TopicItem getNextUniqueTopic() {
    // إذا انتهت جميع المواضيع، نعيد تصفير القائمة لنبدأ دورة جديدة
    if (_usedTopicIds.length >= topics.length) {
      _usedTopicIds.clear();
    }

    final available = topics.where((t) => !_usedTopicIds.contains(t.id)).toList()..shuffle();
    final chosen = available.first;
    _usedTopicIds.add(chosen.id);
    return chosen;
  }

  static List<String> getBotPicks(TopicItem topic) {
    List<String> pool = List.from(topic.commonWords)..shuffle();
    return pool.take(3).toList();
  }
}
