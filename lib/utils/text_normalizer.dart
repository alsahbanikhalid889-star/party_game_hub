import 'package:string_similarity/string_similarity.dart';

class TextNormalizer {
  // تنظيف الكلمة وتوحيد الحروف المتشابهة وإزالة أل التعريف
  static String normalize(String input) {
    if (input.trim().isEmpty) return '';

    String text = input.trim();

    // إزالة التشكيل والتنوين
    text = text.replaceAll(RegExp(r'[\u064B-\u065F\u0670]'), '');

    // إزالة التطويل (الكشيدة)
    text = text.replaceAll('ـ', '');

    // توحيد الألف
    text = text.replaceAll(RegExp(r'[إأآ]'), 'ا');

    // توحيد التاء المربوطة والهاء
    text = text.replaceAll('ة', 'ه');

    // توحيد الياء والألف المقصورة
    text = text.replaceAll('ى', 'ي');

    // حذف "أل" التعريف من بداية الكلمة إذا كانت الكلمة أطول من 3 أحرف
    if (text.startsWith('ال') && text.length > 3) {
      text = text.substring(2);
    }

    return text.trim();
  }

  // فحص التطابق أو التقارب الإملائي بين كلمتين
  static bool areWordsMatching(String word1, String word2) {
    String clean1 = normalize(word1);
    String clean2 = normalize(word2);

    if (clean1.isEmpty || clean2.isEmpty) return false;

    // تطابق تام بعد التوحيد
    if (clean1 == clean2) return true;

    // حساب نسبة التشابه إذا كان هناك خطأ بحرف واحد مع السرعة
    double similarity = clean1.similarityTo(clean2);
    return similarity >= 0.78; // نسبة دقيقة تسمح بخطأ حرف واحد
  }
}
