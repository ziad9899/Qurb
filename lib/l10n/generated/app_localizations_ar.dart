// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'قُرب';

  @override
  String get common_cancel => 'إلغاء';

  @override
  String get common_confirm => 'تأكيد';

  @override
  String get common_send => 'إرسال';

  @override
  String get common_retry => 'حاول مجدداً';

  @override
  String get common_loading => 'جاري التحميل…';

  @override
  String get common_loadFailed => 'تعذّر التحميل';

  @override
  String get common_save => 'حفظ';

  @override
  String get common_delete => 'حذف';

  @override
  String get common_close => 'إغلاق';

  @override
  String get common_back => 'رجوع';

  @override
  String get common_dot => '·';

  @override
  String get splash_tagline => 'همسات من حولك';

  @override
  String get welcome_title => 'معرّف مجهول، خاص بك';

  @override
  String get welcome_subtitle => 'بدون اسم. بدون صورة. فقط رقم يرافقك.';

  @override
  String get welcome_cta_generate => 'ولّد معرّفي';

  @override
  String get welcome_terms_prefix => 'بمتابعتك توافق على ';

  @override
  String get welcome_terms_link => 'الشروط';

  @override
  String get welcome_terms_and => ' و';

  @override
  String get welcome_privacy_link => 'الخصوصية';

  @override
  String get welcome_terms_suffix => '.';

  @override
  String get welcome_generated_title => 'هذا هو معرفك الدائم';

  @override
  String get welcome_generated_subtitle =>
      'لا يمكن تغييره. لا يحتوي على معلومات شخصية.';

  @override
  String get welcome_generated_cta => 'ادخل قُرب';

  @override
  String get feed_appName => 'قُرب';

  @override
  String get feed_location_riyadh => 'الرياض';

  @override
  String get feed_filter_near => 'قريب منك';

  @override
  String get feed_filter_block => 'الحي';

  @override
  String get feed_filter_city => 'المدينة';

  @override
  String get feed_filter_all => 'الكل';

  @override
  String get feed_empty_title => 'لا منشورات قريبة منك الآن';

  @override
  String get feed_empty_subtitle => 'كن أوّل من ينشر شيئاً في منطقتك.';

  @override
  String get feed_error_title => 'تعذّر تحميل المنشورات';

  @override
  String get feed_end_marker => '— هذا كل ما يحدث قريباً منك الآن —';

  @override
  String get feed_location_needed_title => 'شارك موقعك';

  @override
  String get feed_location_needed_subtitle =>
      'قُرب يعرض المنشورات من مكانك فقط. لا نُخزّن إحداثياتك الدقيقة — فقط خلية شبكية بـ 100م.';

  @override
  String get feed_location_needed_cta => 'تفعيل الموقع';

  @override
  String get feed_location_denied_subtitle =>
      'الموقع ضروري لعرض ما حولك. افتح إعدادات الجهاز لتفعيله.';

  @override
  String get feed_location_serviceOff_subtitle =>
      'فعّل خدمات الموقع على جهازك ثم أعد المحاولة.';

  @override
  String get post_menu_save => 'حفظ المنشور';

  @override
  String get post_menu_report => 'الإبلاغ عن المنشور';

  @override
  String get post_menu_block => 'حظر الناشر';

  @override
  String get post_menu_edit => 'تعديل المنشور';

  @override
  String get post_menu_delete => 'حذف المنشور';

  @override
  String get post_edit_title => 'تعديل المنشور';

  @override
  String get post_edit_save => 'حفظ';

  @override
  String get post_delete_title => 'حذف هذا المنشور؟';

  @override
  String get post_delete_body =>
      'سيُخفى منشورك من قائمة المنشورات نهائياً. لا يمكن التراجع.';

  @override
  String get post_delete_action => 'حذف';

  @override
  String get post_edited_marker => 'معدَّل';

  @override
  String get whisper_sent_toast => 'تم إرسال طلب الهمس.';

  @override
  String post_block_title(String id) {
    return 'حظر #$id؟';
  }

  @override
  String get post_block_body => 'لن ترى منشوراته أو تعليقاته بعد الآن.';

  @override
  String get post_block_action => 'حظر';

  @override
  String post_replies_count(int count) {
    return '$count رد';
  }

  @override
  String get post_whisper_author => 'همس للناشر';

  @override
  String get compose_title => 'منشور جديد';

  @override
  String get compose_publish => 'نشر';

  @override
  String get compose_id_hint => 'سيظهر منشورك مع معرفك فقط';

  @override
  String get compose_hint => 'ما الذي يحدث قريباً منك؟';

  @override
  String get compose_scope_label => 'أين سيُرى منشورك؟';

  @override
  String get compose_scope_near_label => 'قريب';

  @override
  String get compose_scope_near_desc => '500م';

  @override
  String get compose_scope_block_label => 'الحي';

  @override
  String get compose_scope_block_desc => '2كم';

  @override
  String get compose_scope_city_label => 'المدينة';

  @override
  String get compose_scope_city_desc => 'كل الرياض';

  @override
  String get compose_tag_label => 'الوسم';

  @override
  String get compose_tag_stories => 'حكايات';

  @override
  String get compose_tag_feelings => 'مشاعر';

  @override
  String get compose_tag_discussion => 'نقاش';

  @override
  String get compose_tag_help => 'مساعدة';

  @override
  String get compose_tag_moment => 'لحظة';

  @override
  String get compose_tag_question => 'سؤال';

  @override
  String get compose_err_rateLimit =>
      'وصلت للحدّ اليومي (10 منشورات). جرّب لاحقاً.';

  @override
  String get compose_err_moderation =>
      'تم رفض النص — قد يحوي محتوى غير مسموح أو رابطاً مشبوهاً.';

  @override
  String get compose_err_length => 'طول النص خارج الحدود.';

  @override
  String get compose_err_generic => 'تعذّر النشر. تحقق من اتصالك.';

  @override
  String get comments_header => 'منشور';

  @override
  String get comments_hint => 'اكتب ردك…';

  @override
  String get comments_empty_title => 'لا تعليقات بعد';

  @override
  String get comments_empty_subtitle => 'كن أوّل من يردّ.';

  @override
  String get comments_error_title => 'تعذّر تحميل التعليقات';

  @override
  String get comments_err_moderation => 'تم رفض الرد — محتوى غير مسموح.';

  @override
  String get comments_err_rateLimit => 'وصلت لحدّ التعليقات (50/ساعة).';

  @override
  String get comments_err_generic => 'تعذّر الإرسال';

  @override
  String get comments_reply => 'ردّ';

  @override
  String comments_replying_to(Object id) {
    return 'ترد على #$id';
  }

  @override
  String get comments_cancel_reply => 'إلغاء الرد';

  @override
  String get whispers_header => 'همس';

  @override
  String get whispers_requests_label => 'طلبات هَمس';

  @override
  String get whispers_empty_title => 'لا همسات بعد';

  @override
  String get whispers_empty_subtitle =>
      'اضغط «همس للناشر» تحت أي منشور لبدء محادثة خاصة.';

  @override
  String get whispers_error_title => 'تعذّر تحميل الهمسات';

  @override
  String get whispers_no_messages_yet => 'لا رسائل بعد';

  @override
  String get whispers_accept => 'قبول';

  @override
  String get whispers_decline => 'رفض';

  @override
  String whispers_label_with_id(String id) {
    return 'همس · #$id';
  }

  @override
  String get whisper_request_title => 'همس للناشر';

  @override
  String get whisper_request_subtitle =>
      'سيستلم الناشر طلب همس. لن تستطيع إرسال رسائل قبل أن يقبل.';

  @override
  String get whisper_request_hint => 'رسالة قصيرة (اختياري)';

  @override
  String get whisper_request_submit => 'إرسال طلب';

  @override
  String get whisper_err_cooldown =>
      'الناشر رفض طلباً سابقاً — حاول بعد 30 يوماً.';

  @override
  String get whisper_err_rateLimit => 'وصلت لحدّ طلبات الهمس (3/ساعة).';

  @override
  String get whisper_err_self => 'لا يمكنك إرسال همس لنفسك.';

  @override
  String get whisper_err_generic => 'تعذّر إرسال الطلب.';

  @override
  String get thread_empty_title => 'ابدأ بالكلمة الأولى';

  @override
  String get thread_empty_subtitle => 'هذه المحادثة بينك وبين الطرف الآخر فقط.';

  @override
  String get thread_error_title => 'تعذّر تحميل الرسائل';

  @override
  String get thread_hint => 'اكتب همسك…';

  @override
  String get thread_err_moderation => 'تم رفض الرسالة — محتوى غير مسموح.';

  @override
  String get thread_err_rateLimit => 'تمهّل قليلاً (60 رسالة/دقيقة).';

  @override
  String get thread_err_generic => 'تعذّر الإرسال';

  @override
  String get thread_header_fallback => 'همس';

  @override
  String get thread_menu_report_user => 'الإبلاغ عن هذا المستخدم';

  @override
  String get thread_menu_block_user => 'حظر هذا المستخدم';

  @override
  String get notifs_title => 'الإشعارات';

  @override
  String get notifs_mark_all_read => 'علِّم الكل كمقروء';

  @override
  String get notifs_empty_title => 'لا إشعارات بعد';

  @override
  String get notifs_empty_subtitle =>
      'الردود والهمسات وتفاعلات منشوراتك ستظهر هنا.';

  @override
  String get notifs_error_title => 'تعذّر تحميل الإشعارات';

  @override
  String get notifs_bucket_today => 'اليوم';

  @override
  String get notifs_bucket_yesterday => 'أمس';

  @override
  String get notifs_bucket_thisWeek => 'هذا الأسبوع';

  @override
  String get notifs_bucket_earlier => 'أقدم';

  @override
  String notifs_human_reply_to_post(String body) {
    return 'ردّ على منشورك: \"$body\"';
  }

  @override
  String notifs_human_reply_to_comment(String body) {
    return 'ردّ على تعليقك: \"$body\"';
  }

  @override
  String notifs_human_vote_milestone(String body) {
    return 'صوّت لمنشورك $body';
  }

  @override
  String get notifs_human_whisper_request_default => 'بدأ همساً معك';

  @override
  String notifs_human_tag_trending(String body) {
    return 'وسم #$body وصل لذروة جديدة';
  }

  @override
  String get explore_title => 'استكشف';

  @override
  String get explore_hint => 'ابحث عن مجتمعات، وسوم، منشورات…';

  @override
  String get explore_recent => 'آخر البحث';

  @override
  String get explore_communities => 'المجتمعات';

  @override
  String get explore_view_all => 'عرض الكل';

  @override
  String get explore_suggested => 'مقترح لك';

  @override
  String get explore_search_error_title => 'تعذّر البحث';

  @override
  String explore_search_empty_title(String q) {
    return 'لا نتائج لـ \"$q\"';
  }

  @override
  String get explore_search_empty_subtitle =>
      'جرّب كلمة أخرى، أو وسماً، أو معرّفاً (#12345).';

  @override
  String explore_members_count(String count) {
    return '$count عضو';
  }

  @override
  String get explore_recent_q1 => 'كافيهات الفجر';

  @override
  String get explore_recent_q2 => '#حكايات';

  @override
  String get explore_recent_q3 => 'مفقودات';

  @override
  String get explore_recent_q4 => 'إيجار';

  @override
  String get explore_recent_q5 => 'فعاليات السبت';

  @override
  String get explore_communities_error_title => 'تعذّر تحميل المجتمعات';

  @override
  String get trend_title => 'الترند المحلي';

  @override
  String get trend_subtitle => 'ما يتحدث عنه الناس قريباً منك';

  @override
  String get trend_live => 'مباشر';

  @override
  String get trend_hottest => 'أكثر النقاشات حرارة';

  @override
  String get trend_error_title => 'تعذّر تحميل الترند';

  @override
  String get trend_empty_title => 'لا نشاط ملحوظ';

  @override
  String get trend_empty_subtitle => 'لا حركة في الساعة الأخيرة قريباً منك.';

  @override
  String trend_row_subtitle(int count) {
    return '$count منشور · آخر 30 دقيقة';
  }

  @override
  String get trend_pulse_you => 'أنت';

  @override
  String get profile_header => 'ملفي';

  @override
  String get profile_id_caption => 'معرفك في قُرب';

  @override
  String profile_member_since(String month) {
    return 'عضو منذ $month';
  }

  @override
  String get profile_stat_posts => 'منشور';

  @override
  String get profile_stat_karma => 'كارما';

  @override
  String get profile_stat_bookmarks => 'محفوظات';

  @override
  String get profile_tab_posts => 'منشوراتي';

  @override
  String get profile_tab_comments => 'تعليقاتي';

  @override
  String get profile_tab_bookmarks => 'محفوظاتي';

  @override
  String get profile_empty_posts_title => 'لا منشورات بعد';

  @override
  String get profile_empty_posts_subtitle => 'انشر همّاً، رأياً، أو سؤالاً.';

  @override
  String get profile_empty_bookmarks_title => 'لا محفوظات بعد';

  @override
  String get profile_empty_bookmarks_subtitle =>
      'احفظ المنشورات من قائمة «المزيد» لقراءتها لاحقاً.';

  @override
  String get profile_empty_comments_title => 'لا تعليقات بعد';

  @override
  String get profile_empty_comments_subtitle => 'شاركْ رأيك في أي منشور.';

  @override
  String profile_post_meta(int score, int replies) {
    return '$score · $replies ردود';
  }

  @override
  String get settings_header => 'الإعدادات';

  @override
  String get settings_identity_title => 'هذا هو معرفك الدائم';

  @override
  String get settings_identity_subtitle =>
      'لا يمكن تغييره. لا يحتوي على معلومات شخصية.';

  @override
  String get settings_group_privacy => 'الخصوصية';

  @override
  String get settings_group_appearance => 'المظهر';

  @override
  String get settings_group_notifs => 'الإشعارات';

  @override
  String get settings_group_about => 'عن قُرب';

  @override
  String get settings_row_locationShare => 'مشاركة الموقع';

  @override
  String get settings_row_locationShare_detail =>
      'ضرورية لإظهار المنشورات القريبة';

  @override
  String get settings_row_allowStrangers => 'السماح بهمس من الغرباء';

  @override
  String get settings_row_readReceipts => 'إيصالات القراءة';

  @override
  String get settings_row_blocklist => 'قائمة الحظر';

  @override
  String get settings_row_blocklist_empty => 'لا أحد محظور';

  @override
  String settings_row_blocklist_count(int count) {
    return '$count معرف محظور';
  }

  @override
  String get settings_row_nightMode => 'الوضع الليلي';

  @override
  String get settings_row_allNotifs => 'جميع الإشعارات';

  @override
  String get settings_row_pulseNotifs => 'نبض المنطقة';

  @override
  String get settings_row_pulseNotifs_detail => 'إشعار عند نشاط مرتفع في حيك';

  @override
  String get settings_row_community => 'معايير المجتمع';

  @override
  String get settings_row_language => 'اللغة';

  @override
  String get settings_row_report => 'الإبلاغ عن مشكلة';

  @override
  String get settings_row_signout => 'تسجيل الخروج';

  @override
  String get settings_row_delete => 'حذف معرفي وكل بياناتي';

  @override
  String get settings_version => 'QURB · v0.1.0 (build 1)';

  @override
  String get settings_delete_title => 'حذف الحساب نهائياً؟';

  @override
  String get settings_delete_body =>
      'سيُحذف معرفك وكل منشوراتك وتعليقاتك ومحادثاتك. لا يمكن التراجع.';

  @override
  String get settings_delete_err =>
      'تعذّر حذف الحساب. تحقّق من اتصالك وحاول مجدداً.';

  @override
  String get settings_lang_arabic => 'العربية';

  @override
  String get settings_lang_english => 'English';

  @override
  String get settings_lang_sheet_title => 'اللغة';

  @override
  String get blocks_header => 'قائمة الحظر';

  @override
  String get blocks_empty_title => 'لا أحد محظور';

  @override
  String get blocks_empty_subtitle => 'يمكنك حظر أي مستخدم من قائمة منشوره.';

  @override
  String get blocks_unblock => 'إلغاء الحظر';

  @override
  String get report_post_title => 'الإبلاغ عن منشور';

  @override
  String get report_comment_title => 'الإبلاغ عن تعليق';

  @override
  String get report_user_title => 'الإبلاغ عن مستخدم';

  @override
  String get report_message_title => 'الإبلاغ عن رسالة';

  @override
  String get report_subtitle =>
      'سيُراجع الفريق البلاغ خلال 24 ساعة. هويتك تبقى مجهولة تماماً.';

  @override
  String get report_reason_spam_title => 'محتوى مزعج';

  @override
  String get report_reason_spam_desc => 'إعلانات، روابط متكررة';

  @override
  String get report_reason_harass_title => 'إساءة شخصية';

  @override
  String get report_reason_harass_desc => 'تحرش، تهديد، تنمر';

  @override
  String get report_reason_fake_title => 'معلومات مضللة';

  @override
  String get report_reason_fake_desc => 'أخبار كاذبة أو ادعاءات';

  @override
  String get report_reason_nsfw_title => 'محتوى غير لائق';

  @override
  String get report_reason_nsfw_desc => 'إباحية، عنف';

  @override
  String get report_reason_private_title => 'كشف خصوصية';

  @override
  String get report_reason_private_desc => 'معلومات شخص بدون إذن';

  @override
  String get report_reason_other_title => 'سبب آخر';

  @override
  String get report_reason_other_desc => 'سيرسل للمراجعة';

  @override
  String get report_submit => 'إرسال البلاغ';

  @override
  String get report_err_rateLimit => 'وصلت لحدّ البلاغات اليومي (20).';

  @override
  String get report_err_generic => 'تعذّر إرسال البلاغ.';

  @override
  String get proximity_near => 'قريب منك';

  @override
  String get proximity_block => 'الحي';

  @override
  String get proximity_city => 'الرياض';

  @override
  String get terms_title => 'شروط الاستخدام';

  @override
  String get terms_intro =>
      'باستخدامك تطبيق قُرب فإنك توافق على هذه الشروط. قُرب خدمة محادثة مجهولة قائمة على الموقع — التزامك بهذه القواعد ضروري لاستمرار حسابك.';

  @override
  String get terms_section_acceptance_h => '١. القبول';

  @override
  String get terms_section_acceptance_b =>
      'بإكمال شاشة الترحيب تُؤكّد أن عمرك ١٣ سنة فأكثر، وأنك قرأت سياسة الخصوصية ومعايير المجتمع، وتقبل الالتزام بهما. إذا لم توافق، أغلق التطبيق ولا تستعمله.';

  @override
  String get terms_section_anonymity_h => '٢. الهوية المجهولة';

  @override
  String get terms_section_anonymity_b =>
      'لا نطلب اسماً ولا بريداً ولا رقم هاتف. حسابك مربوط بهذا الجهاز فقط — إذا فقدته أو مسحت بياناته فقد لا تستطيع استرجاعه. لا تنتحل شخصية مستخدم آخر ولا تدّعي أنك جهة رسمية.';

  @override
  String get terms_section_content_h => '٣. المحتوى';

  @override
  String get terms_section_content_b =>
      'أنت المسؤول الوحيد عمّا تنشره. منشوراتك تظهر للمستخدمين القريبين منك جغرافياً. لا ترفع محتوى مملوكاً لآخرين بدون إذنهم. تمنحنا ترخيصاً غير حصري لعرض ما تنشره داخل التطبيق فقط لتشغيل الخدمة.';

  @override
  String get terms_section_conduct_h => '٤. السلوك الممنوع';

  @override
  String get terms_section_conduct_b =>
      'ممنوع: السباب، التهديد، التحرش، خطاب الكراهية، نشر معلومات خاصة لشخص آخر (doxxing)، المحتوى الجنسي الصريح، الإعلانات والاحتيال، انتحال الشخصيات، وأي نشاط غير قانوني. مخالفة هذه البنود تؤدي لإخفاء المحتوى أو حظر الحساب.';

  @override
  String get terms_section_termination_h => '٥. إنهاء الحساب';

  @override
  String get terms_section_termination_b =>
      'يحق لنا تعليق أو حذف حسابك في حال مخالفة هذه الشروط. ويحق لك حذف حسابك متى أردت من «الإعدادات ‹ حذف الحساب» — وعندها تُحذَف منشوراتك وتعليقاتك ومحادثاتك بشكل دائم.';

  @override
  String get terms_section_disclaimer_h => '٦. إخلاء المسؤولية';

  @override
  String get terms_section_disclaimer_b =>
      'نقدّم الخدمة «كما هي» بدون ضمانات. لسنا مسؤولين عن المحتوى الذي ينشره مستخدمون آخرون. اعتمادك على أي معلومة تظهر في التطبيق يكون على مسؤوليتك.';

  @override
  String get terms_section_contact_h => '٧. التواصل';

  @override
  String get terms_section_contact_b =>
      'للاستفسارات أو الإبلاغ عن مخالفة: «الإعدادات ‹ الإبلاغ عن مشكلة».';

  @override
  String get privacy_title => 'سياسة الخصوصية';

  @override
  String get privacy_intro => 'قُرب مبنيّ على وعد واحد: هويتك تبقى مجهولة.';

  @override
  String get privacy_section_identity_h => '١. هويتك';

  @override
  String get privacy_section_identity_b =>
      'عند التسجيل نُولّد لك معرّفاً رقمياً من 5 خانات. لا نطلب اسمك أو صورتك أو بريدك أو رقم هاتفك. هذا المعرّف هو الوحيد الذي يراه المستخدمون الآخرون.';

  @override
  String get privacy_section_location_h => '٢. الموقع';

  @override
  String get privacy_section_location_b =>
      'إذا أذنت بمشاركة الموقع، تُربط إحداثيات جهازك إلى خلية شبكية بدقة 100م قبل أن تغادر الجهاز. لا نخزّن أو نُرسل GPS دقيقاً أبداً. المستخدمون الآخرون يرون نطاقات نسبية فقط (قريب/الحي/المدينة) — ولا يرون الإحداثيات الخام.';

  @override
  String get privacy_section_content_h => '٣. محتواك';

  @override
  String get privacy_section_content_b =>
      'المنشورات والتعليقات علنية للمستخدمين القريبين. الهمسات خاصة بين الطرفين فقط. يمكنك حذف حسابك في أي وقت من الإعدادات — هذا يحذف كل منشوراتك وتعليقاتك ومحادثاتك.';

  @override
  String get privacy_section_moderation_h => '٤. الإشراف';

  @override
  String get privacy_section_moderation_b =>
      'نُجري فحوصات تلقائية على النصوص للكشف عن السباب وأنماط الاحتيال والروابط غير المسموحة. المحتوى الذي يُبلَّغ عنه من 3 مستخدمين أو أكثر خلال 24 ساعة يُخفى تلقائياً بانتظار المراجعة.';

  @override
  String get privacy_section_contact_h => '٥. التواصل';

  @override
  String get privacy_section_contact_b =>
      'أسئلة؟ استخدم «الإبلاغ عن مشكلة» في الإعدادات.';

  @override
  String get community_title => 'معايير المجتمع';

  @override
  String get community_intro =>
      'قُرب يعمل لأن الناس تتصرف باحترام. هذه هي القواعد الأساسية.';

  @override
  String get community_do_h => 'مُشجَّع';

  @override
  String get community_do_1 => 'مشاركة تجارب حقيقية من منطقتك.';

  @override
  String get community_do_2 => 'احترام الآخرين حتى عند الاختلاف.';

  @override
  String get community_do_3 => 'الإبلاغ عن أي محتوى يخالف هذه القواعد.';

  @override
  String get community_dont_h => 'غير مسموح';

  @override
  String get community_dont_1 => 'السباب، الإهانات، خطاب الكراهية.';

  @override
  String get community_dont_2 => 'نشر معلومات شخصية للآخرين (doxxing).';

  @override
  String get community_dont_3 => 'محتوى جنسي أو عنف صريح.';

  @override
  String get community_dont_4 => 'إعلانات، احتيال، روابط لمواقع مشبوهة.';

  @override
  String get community_dont_5 => 'انتحال شخصية أشخاص أو منظمات حقيقية.';

  @override
  String get community_consequences_h => 'العواقب';

  @override
  String get community_consequences_b =>
      'المخالفات قد تؤدي لإخفاء المحتوى تلقائياً، تقييد حسابك، أو الحذف الدائم.';

  @override
  String get report_issue_title => 'الإبلاغ عن مشكلة';

  @override
  String get report_issue_subtitle =>
      'وجدت خللاً؟ عندك فكرة ميزة؟ أخبرنا — نقرأ كل بلاغ.';

  @override
  String get report_issue_subject_label => 'الموضوع';

  @override
  String get report_issue_subject_hint => 'عنوان مختصر (اختياري)';

  @override
  String get report_issue_body_label => 'التفاصيل';

  @override
  String get report_issue_body_hint => 'صف المشكلة أو الفكرة…';

  @override
  String get report_issue_submit => 'إرسال';

  @override
  String get report_issue_success => 'شكراً — استلمنا بلاغك.';

  @override
  String get report_issue_err_empty => 'اكتب بضع كلمات على الأقل.';

  @override
  String get report_issue_err_generic => 'تعذّر الإرسال. حاول مجدداً.';
}
