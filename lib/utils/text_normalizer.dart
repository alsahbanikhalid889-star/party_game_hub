import 'package:string_similarity/string_similarity.dart';

class TextNormalizer {
  static String normalize(String input) {
    if (input.trim().isEmpty) return '';

    String text = input.trim();

    // إزالة التشكيل
    text = text.replaceAll(RegExp(r'[\u064B-\u065F\u0670]'), '');
    // إزالة التطويل
    text = text.replaceAll('ـ', '');
    // توحيد الألف
    text = text.replaceAll(RegExp(r'[إأآ]'), 'ا');
    // توحيد التاء المربوطة والهاء
    text = text.replaceAll('ة', 'ه');
    // توحيد الياء والألف المقصورة
    text = text.replaceAll('ى', 'ي');

    // حذف "ال" التعريف
    if (text.startsWith('ال') && text.length > 3) {
      text = text.substring(2);
    }

    // إزالة الزوائد الشائعة في نهاية الكلمات لاشتقاق الأصل (حراسة -> حارس / معلمون -> معلم)
    if (text.endsWith('ات') && text.length > 4) {
      text = text.substring(0, text.length - 2);
    } else if (text.endsWith('ون') && text.length > 4) {
      text = text.substring(0, text.length - 2);
    } else if (text.endsWith('ين') && text.length > 4) {
      text = text.substring(0, text.length - 2);
    } else if (text.endsWith('ه') && text.length > 3) {
      text = text.substring(0, text.length - 1);
    }

    return text.trim();
  }

  static bool areWordsMatching(String word1, String word2) {
    String clean1 = normalize(word1);
    String clean2 = normalize(word2);

    if (clean1.isEmpty || clean2.isEmpty) return false;

    // تطابق بعد الاشتقاق
    if (clean1 == clean2) return true;

    // إذا احتوت إحداهما الأخرى (مثلاً: حارس وحراسة)
    if (clean1.contains(clean2) || clean2.contains(clean1)) {
      if ((clean1.length - clean2.length).abs() <= 2) return true;
    }

    // نسبة التشابه للأخطاء الإملائية والسرعة
    double similarity = clean1.similarityTo(clean2);
    return similarity >= 0.70;
  }
}
