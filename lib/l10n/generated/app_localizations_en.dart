// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Qurb';

  @override
  String get common_cancel => 'Cancel';

  @override
  String get common_confirm => 'Confirm';

  @override
  String get common_send => 'Send';

  @override
  String get common_retry => 'Try again';

  @override
  String get common_loading => 'Loading…';

  @override
  String get common_loadFailed => 'Couldn\'t load';

  @override
  String get common_save => 'Save';

  @override
  String get common_delete => 'Delete';

  @override
  String get common_close => 'Close';

  @override
  String get common_back => 'Back';

  @override
  String get common_dot => '·';

  @override
  String get splash_tagline => 'Whispers around you';

  @override
  String get welcome_title => 'An anonymous ID, just for you';

  @override
  String get welcome_subtitle =>
      'No name. No photo. Just a number that travels with you.';

  @override
  String get welcome_cta_generate => 'Generate my ID';

  @override
  String get welcome_terms_prefix => 'By continuing you accept the ';

  @override
  String get welcome_terms_link => 'terms';

  @override
  String get welcome_terms_and => ' and ';

  @override
  String get welcome_privacy_link => 'privacy';

  @override
  String get welcome_terms_suffix => '.';

  @override
  String get welcome_generated_title => 'This is your permanent ID';

  @override
  String get welcome_generated_subtitle =>
      'It can\'t be changed. It carries no personal information.';

  @override
  String get welcome_generated_cta => 'Enter Qurb';

  @override
  String get feed_appName => 'Qurb';

  @override
  String get feed_location_riyadh => 'Riyadh';

  @override
  String get feed_filter_near => 'Near you';

  @override
  String get feed_filter_block => 'Neighborhood';

  @override
  String get feed_filter_city => 'City';

  @override
  String get feed_filter_all => 'All';

  @override
  String get feed_empty_title => 'Nothing nearby right now';

  @override
  String get feed_empty_subtitle => 'Be the first to post in your area.';

  @override
  String get feed_error_title => 'Couldn\'t load posts';

  @override
  String get feed_end_marker =>
      '— that\'s everything happening nearby right now —';

  @override
  String get feed_location_needed_title => 'Share your location';

  @override
  String get feed_location_needed_subtitle =>
      'Qurb only shows posts from where you are. Your exact GPS is never stored — only a 100 m grid cell.';

  @override
  String get feed_location_needed_cta => 'Enable location';

  @override
  String get feed_location_denied_subtitle =>
      'Location is required to see what\'s near you. Open device settings to enable it.';

  @override
  String get feed_location_serviceOff_subtitle =>
      'Turn on Location Services on your device, then try again.';

  @override
  String get post_menu_save => 'Save post';

  @override
  String get post_menu_report => 'Report post';

  @override
  String get post_menu_block => 'Block author';

  @override
  String get post_menu_edit => 'Edit post';

  @override
  String get post_menu_delete => 'Delete post';

  @override
  String get post_edit_title => 'Edit post';

  @override
  String get post_edit_save => 'Save';

  @override
  String get post_delete_title => 'Delete this post?';

  @override
  String get post_delete_body =>
      'Your post will be permanently hidden from the feed. This can\'t be undone.';

  @override
  String get post_delete_action => 'Delete';

  @override
  String get post_edited_marker => 'edited';

  @override
  String get whisper_sent_toast => 'Whisper request sent.';

  @override
  String post_block_title(String id) {
    return 'Block #$id?';
  }

  @override
  String get post_block_body =>
      'You won\'t see their posts or comments anymore.';

  @override
  String get post_block_action => 'Block';

  @override
  String post_replies_count(int count) {
    return '$count replies';
  }

  @override
  String get post_whisper_author => 'Whisper to author';

  @override
  String get compose_title => 'New post';

  @override
  String get compose_publish => 'Publish';

  @override
  String get compose_id_hint => 'Your post will only show your ID';

  @override
  String get compose_hint => 'What\'s happening near you?';

  @override
  String get compose_scope_label => 'Where will this be seen?';

  @override
  String get compose_scope_near_label => 'Near';

  @override
  String get compose_scope_near_desc => '500 m';

  @override
  String get compose_scope_block_label => 'Neighborhood';

  @override
  String get compose_scope_block_desc => '2 km';

  @override
  String get compose_scope_city_label => 'City';

  @override
  String get compose_scope_city_desc => 'All of Riyadh';

  @override
  String get compose_tag_label => 'Tag';

  @override
  String get compose_tag_stories => 'stories';

  @override
  String get compose_tag_feelings => 'feelings';

  @override
  String get compose_tag_discussion => 'discussion';

  @override
  String get compose_tag_help => 'help';

  @override
  String get compose_tag_moment => 'moment';

  @override
  String get compose_tag_question => 'question';

  @override
  String get compose_err_rateLimit =>
      'Daily limit reached (10 posts). Try later.';

  @override
  String get compose_err_moderation =>
      'Text rejected — may contain disallowed content or a suspicious link.';

  @override
  String get compose_err_length => 'Text length out of range.';

  @override
  String get compose_err_generic => 'Couldn\'t publish. Check your connection.';

  @override
  String get comments_header => 'Post';

  @override
  String get comments_hint => 'Write your reply…';

  @override
  String get comments_empty_title => 'No comments yet';

  @override
  String get comments_empty_subtitle => 'Be the first to reply.';

  @override
  String get comments_error_title => 'Couldn\'t load comments';

  @override
  String get comments_err_moderation => 'Reply rejected — disallowed content.';

  @override
  String get comments_err_rateLimit => 'Comment limit reached (50/hour).';

  @override
  String get comments_err_generic => 'Couldn\'t send';

  @override
  String get comments_reply => 'Reply';

  @override
  String comments_replying_to(Object id) {
    return 'Replying to #$id';
  }

  @override
  String get comments_cancel_reply => 'Cancel reply';

  @override
  String get whispers_header => 'Whispers';

  @override
  String get whispers_requests_label => 'WHISPER REQUESTS';

  @override
  String get whispers_empty_title => 'No whispers yet';

  @override
  String get whispers_empty_subtitle =>
      'Tap \"Whisper to author\" under any post to start a private chat.';

  @override
  String get whispers_error_title => 'Couldn\'t load whispers';

  @override
  String get whispers_no_messages_yet => 'No messages yet';

  @override
  String get whispers_accept => 'Accept';

  @override
  String get whispers_decline => 'Decline';

  @override
  String whispers_label_with_id(String id) {
    return 'Whisper · #$id';
  }

  @override
  String get whisper_request_title => 'Whisper to author';

  @override
  String get whisper_request_subtitle =>
      'The author will receive a whisper request. You can\'t send messages until they accept.';

  @override
  String get whisper_request_hint => 'Short message (optional)';

  @override
  String get whisper_request_submit => 'Send request';

  @override
  String get whisper_err_cooldown =>
      'The author previously declined — try after 30 days.';

  @override
  String get whisper_err_rateLimit => 'Whisper request limit reached (3/hour).';

  @override
  String get whisper_err_self => 'You can\'t whisper to yourself.';

  @override
  String get whisper_err_generic => 'Couldn\'t send request.';

  @override
  String get thread_empty_title => 'Start with the first word';

  @override
  String get thread_empty_subtitle =>
      'This conversation is between you and them only.';

  @override
  String get thread_error_title => 'Couldn\'t load messages';

  @override
  String get thread_hint => 'Type your whisper…';

  @override
  String get thread_err_moderation => 'Message rejected — disallowed content.';

  @override
  String get thread_err_rateLimit => 'Slow down (60 messages/minute).';

  @override
  String get thread_err_generic => 'Couldn\'t send';

  @override
  String get thread_header_fallback => 'Whisper';

  @override
  String get thread_menu_report_user => 'Report this user';

  @override
  String get thread_menu_block_user => 'Block this user';

  @override
  String get notifs_title => 'Notifications';

  @override
  String get notifs_mark_all_read => 'Mark all read';

  @override
  String get notifs_empty_title => 'No notifications yet';

  @override
  String get notifs_empty_subtitle =>
      'Replies, whispers, and reactions to your posts will appear here.';

  @override
  String get notifs_error_title => 'Couldn\'t load notifications';

  @override
  String get notifs_bucket_today => 'TODAY';

  @override
  String get notifs_bucket_yesterday => 'YESTERDAY';

  @override
  String get notifs_bucket_thisWeek => 'THIS WEEK';

  @override
  String get notifs_bucket_earlier => 'EARLIER';

  @override
  String notifs_human_reply_to_post(String body) {
    return 'replied to your post: \"$body\"';
  }

  @override
  String notifs_human_reply_to_comment(String body) {
    return 'replied to your comment: \"$body\"';
  }

  @override
  String notifs_human_vote_milestone(String body) {
    return 'voted on your post $body';
  }

  @override
  String get notifs_human_whisper_request_default =>
      'started a whisper with you';

  @override
  String notifs_human_tag_trending(String body) {
    return 'tag #$body reached a new peak';
  }

  @override
  String get explore_title => 'Explore';

  @override
  String get explore_hint => 'Search communities, tags, posts…';

  @override
  String get explore_recent => 'RECENT SEARCH';

  @override
  String get explore_communities => 'Communities';

  @override
  String get explore_view_all => 'View all';

  @override
  String get explore_suggested => 'Suggested for you';

  @override
  String get explore_search_error_title => 'Couldn\'t search';

  @override
  String explore_search_empty_title(String q) {
    return 'No results for \"$q\"';
  }

  @override
  String get explore_search_empty_subtitle =>
      'Try another word, a tag, or an ID (#12345).';

  @override
  String explore_members_count(String count) {
    return '$count members';
  }

  @override
  String get explore_recent_q1 => 'fajr cafes';

  @override
  String get explore_recent_q2 => '#stories';

  @override
  String get explore_recent_q3 => 'lost & found';

  @override
  String get explore_recent_q4 => 'rent';

  @override
  String get explore_recent_q5 => 'saturday events';

  @override
  String get explore_communities_error_title => 'Couldn\'t load communities';

  @override
  String get trend_title => 'Local Trend';

  @override
  String get trend_subtitle => 'What people are talking about nearby';

  @override
  String get trend_live => 'LIVE';

  @override
  String get trend_hottest => 'Hottest discussions';

  @override
  String get trend_error_title => 'Couldn\'t load trend';

  @override
  String get trend_empty_title => 'No notable activity';

  @override
  String get trend_empty_subtitle => 'No movement in the last hour near you.';

  @override
  String trend_row_subtitle(int count) {
    return '$count posts · last 30 min';
  }

  @override
  String get trend_pulse_you => 'you';

  @override
  String get profile_header => 'My profile';

  @override
  String get profile_id_caption => 'Your ID in Qurb';

  @override
  String profile_member_since(String month) {
    return 'Member since $month';
  }

  @override
  String get profile_stat_posts => 'posts';

  @override
  String get profile_stat_karma => 'karma';

  @override
  String get profile_stat_bookmarks => 'bookmarks';

  @override
  String get profile_tab_posts => 'Posts';

  @override
  String get profile_tab_comments => 'Comments';

  @override
  String get profile_tab_bookmarks => 'Bookmarks';

  @override
  String get profile_empty_posts_title => 'No posts yet';

  @override
  String get profile_empty_posts_subtitle =>
      'Share a thought, an opinion, or a question.';

  @override
  String get profile_empty_bookmarks_title => 'No bookmarks yet';

  @override
  String get profile_empty_bookmarks_subtitle =>
      'Save posts from the \"more\" menu to read later.';

  @override
  String get profile_empty_comments_title => 'No comments yet';

  @override
  String get profile_empty_comments_subtitle =>
      'Share your thoughts on any post.';

  @override
  String profile_post_meta(int score, int replies) {
    return '$score · $replies replies';
  }

  @override
  String get settings_header => 'Settings';

  @override
  String get settings_identity_title => 'This is your permanent ID';

  @override
  String get settings_identity_subtitle =>
      'It can\'t be changed. It carries no personal information.';

  @override
  String get settings_group_privacy => 'PRIVACY';

  @override
  String get settings_group_appearance => 'APPEARANCE';

  @override
  String get settings_group_notifs => 'NOTIFICATIONS';

  @override
  String get settings_group_about => 'ABOUT QURB';

  @override
  String get settings_row_locationShare => 'Share location';

  @override
  String get settings_row_locationShare_detail =>
      'Required to show nearby posts';

  @override
  String get settings_row_allowStrangers => 'Allow whispers from strangers';

  @override
  String get settings_row_readReceipts => 'Read receipts';

  @override
  String get settings_row_blocklist => 'Blocklist';

  @override
  String get settings_row_blocklist_empty => 'No one blocked';

  @override
  String settings_row_blocklist_count(int count) {
    return '$count blocked';
  }

  @override
  String get settings_row_nightMode => 'Night mode';

  @override
  String get settings_row_allNotifs => 'All notifications';

  @override
  String get settings_row_pulseNotifs => 'Area pulse';

  @override
  String get settings_row_pulseNotifs_detail =>
      'Notify on high activity in your neighborhood';

  @override
  String get settings_row_community => 'Community guidelines';

  @override
  String get settings_row_language => 'Language';

  @override
  String get settings_row_report => 'Report a problem';

  @override
  String get settings_row_signout => 'Sign out';

  @override
  String get settings_row_delete => 'Delete my ID and all my data';

  @override
  String get settings_version => 'QURB · v0.1.0 (build 1)';

  @override
  String get settings_delete_title => 'Delete account permanently?';

  @override
  String get settings_delete_body =>
      'Your ID and all your posts, comments, and conversations will be removed. This can\'t be undone.';

  @override
  String get settings_delete_err =>
      'Couldn\'t delete account. Check your connection and try again.';

  @override
  String get settings_lang_arabic => 'العربية';

  @override
  String get settings_lang_english => 'English';

  @override
  String get settings_lang_sheet_title => 'Language';

  @override
  String get blocks_header => 'Blocklist';

  @override
  String get blocks_empty_title => 'No one blocked';

  @override
  String get blocks_empty_subtitle =>
      'You can block any user from their post menu.';

  @override
  String get blocks_unblock => 'Unblock';

  @override
  String get report_post_title => 'Report post';

  @override
  String get report_comment_title => 'Report comment';

  @override
  String get report_user_title => 'Report user';

  @override
  String get report_message_title => 'Report message';

  @override
  String get report_subtitle =>
      'Our team will review within 24 hours. Your identity stays anonymous.';

  @override
  String get report_reason_spam_title => 'Spam';

  @override
  String get report_reason_spam_desc => 'Ads, repeated links';

  @override
  String get report_reason_harass_title => 'Personal abuse';

  @override
  String get report_reason_harass_desc => 'Harassment, threats, bullying';

  @override
  String get report_reason_fake_title => 'Misinformation';

  @override
  String get report_reason_fake_desc => 'False news or claims';

  @override
  String get report_reason_nsfw_title => 'Inappropriate content';

  @override
  String get report_reason_nsfw_desc => 'Porn, violence';

  @override
  String get report_reason_private_title => 'Privacy violation';

  @override
  String get report_reason_private_desc =>
      'Someone\'s personal info without consent';

  @override
  String get report_reason_other_title => 'Other reason';

  @override
  String get report_reason_other_desc => 'Will be sent for review';

  @override
  String get report_submit => 'Submit report';

  @override
  String get report_err_rateLimit => 'Daily report limit reached (20).';

  @override
  String get report_err_generic => 'Couldn\'t submit report.';

  @override
  String get proximity_near => 'near you';

  @override
  String get proximity_block => 'neighborhood';

  @override
  String get proximity_city => 'Riyadh';

  @override
  String get terms_title => 'Terms of Use';

  @override
  String get terms_intro =>
      'By using Qurb you agree to these terms. Qurb is an anonymous, location-based chat service — following these rules is required to keep your account active.';

  @override
  String get terms_section_acceptance_h => '1. Acceptance';

  @override
  String get terms_section_acceptance_b =>
      'By completing the welcome screen you confirm that you are 13 years of age or older, that you have read the Privacy Policy and Community Guidelines, and that you agree to be bound by them. If you do not agree, close the app and do not use it.';

  @override
  String get terms_section_anonymity_h => '2. Anonymous identity';

  @override
  String get terms_section_anonymity_b =>
      'We do not ask for your name, email, or phone number. Your account is tied to this device only — if you lose or wipe it, you may not be able to recover access. Do not impersonate other users or claim to represent an official entity.';

  @override
  String get terms_section_content_h => '3. Your content';

  @override
  String get terms_section_content_b =>
      'You are solely responsible for what you post. Your posts are shown to users geographically near you. Do not upload content owned by others without permission. You grant us a non-exclusive license to display what you post inside the app, solely to operate the service.';

  @override
  String get terms_section_conduct_h => '4. Prohibited conduct';

  @override
  String get terms_section_conduct_b =>
      'Forbidden: profanity, threats, harassment, hate speech, sharing other people\'s private information (doxxing), explicit sexual content, advertising and fraud, impersonation, and any illegal activity. Violations result in content removal or account ban.';

  @override
  String get terms_section_termination_h => '5. Termination';

  @override
  String get terms_section_termination_b =>
      'We may suspend or delete your account if you violate these terms. You may delete your account at any time from Settings › Delete Account — this permanently removes your posts, comments, and chats.';

  @override
  String get terms_section_disclaimer_h => '6. Disclaimer';

  @override
  String get terms_section_disclaimer_b =>
      'The service is provided \"as is\" without warranty. We are not responsible for content posted by other users. Reliance on any information you see in the app is at your own risk.';

  @override
  String get terms_section_contact_h => '7. Contact';

  @override
  String get terms_section_contact_b =>
      'Questions or to report a violation: Settings › Report a problem.';

  @override
  String get privacy_title => 'Privacy Policy';

  @override
  String get privacy_intro =>
      'Qurb is built around one promise: your identity stays anonymous.';

  @override
  String get privacy_section_identity_h => '1. Your identity';

  @override
  String get privacy_section_identity_b =>
      'When you sign up we generate a 5-digit numeric ID. We never ask for your name, photo, email, or phone number. The ID is the only thing other users see.';

  @override
  String get privacy_section_location_h => '2. Location';

  @override
  String get privacy_section_location_b =>
      'If you grant location permission, your device\'s coordinates are snapped to a 100 m grid before they leave the device. We never store or transmit precise GPS. Other users only see relative distance buckets (near / neighborhood / city) — never raw coordinates.';

  @override
  String get privacy_section_content_h => '3. Your content';

  @override
  String get privacy_section_content_b =>
      'Posts and comments are public to nearby users. Whispers are end-to-end private between two participants. You can delete your account at any time from Settings — this removes all your posts, comments, and conversations.';

  @override
  String get privacy_section_moderation_h => '4. Moderation';

  @override
  String get privacy_section_moderation_b =>
      'We run automated checks on submitted text for profanity, scam patterns, and disallowed links. Content reported by 3+ users in 24 hours is auto-hidden pending review.';

  @override
  String get privacy_section_contact_h => '5. Contact';

  @override
  String get privacy_section_contact_b =>
      'Questions? Use \"Report a problem\" in Settings.';

  @override
  String get community_title => 'Community guidelines';

  @override
  String get community_intro =>
      'Qurb works because people behave well. These are the basic rules.';

  @override
  String get community_do_h => 'Encouraged';

  @override
  String get community_do_1 => 'Share authentic experiences from your area.';

  @override
  String get community_do_2 =>
      'Treat others with respect even in disagreement.';

  @override
  String get community_do_3 => 'Report any content that violates these rules.';

  @override
  String get community_dont_h => 'Not allowed';

  @override
  String get community_dont_1 => 'Profanity, slurs, hate speech.';

  @override
  String get community_dont_2 => 'Personal information of others (doxxing).';

  @override
  String get community_dont_3 => 'Sexual content or graphic violence.';

  @override
  String get community_dont_4 =>
      'Spam, scams, ads, or external links to suspicious sites.';

  @override
  String get community_dont_5 => 'Impersonating real people or organizations.';

  @override
  String get community_consequences_h => 'Consequences';

  @override
  String get community_consequences_b =>
      'Violations may result in auto-hiding the content, restricting your account, or permanent removal.';

  @override
  String get report_issue_title => 'Report a problem';

  @override
  String get report_issue_subtitle =>
      'Found a bug? Got a feature idea? Tell us — read every submission.';

  @override
  String get report_issue_subject_label => 'Topic';

  @override
  String get report_issue_subject_hint => 'Brief title (optional)';

  @override
  String get report_issue_body_label => 'Details';

  @override
  String get report_issue_body_hint => 'Describe the problem or idea…';

  @override
  String get report_issue_submit => 'Send';

  @override
  String get report_issue_success => 'Thanks — we got it.';

  @override
  String get report_issue_err_empty => 'Please write a few words.';

  @override
  String get report_issue_err_generic => 'Couldn\'t send. Try again.';
}
