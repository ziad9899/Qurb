import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Qurb'**
  String get appName;

  /// No description provided for @common_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get common_cancel;

  /// No description provided for @common_confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get common_confirm;

  /// No description provided for @common_send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get common_send;

  /// No description provided for @common_retry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get common_retry;

  /// No description provided for @common_loading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get common_loading;

  /// No description provided for @common_loadFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load'**
  String get common_loadFailed;

  /// No description provided for @common_save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get common_save;

  /// No description provided for @common_delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get common_delete;

  /// No description provided for @common_close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get common_close;

  /// No description provided for @common_back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get common_back;

  /// No description provided for @common_dot.
  ///
  /// In en, this message translates to:
  /// **'·'**
  String get common_dot;

  /// No description provided for @splash_tagline.
  ///
  /// In en, this message translates to:
  /// **'Whispers around you'**
  String get splash_tagline;

  /// No description provided for @welcome_title.
  ///
  /// In en, this message translates to:
  /// **'An anonymous ID, just for you'**
  String get welcome_title;

  /// No description provided for @welcome_subtitle.
  ///
  /// In en, this message translates to:
  /// **'No name. No photo. Just a number that travels with you.'**
  String get welcome_subtitle;

  /// No description provided for @welcome_cta_generate.
  ///
  /// In en, this message translates to:
  /// **'Generate my ID'**
  String get welcome_cta_generate;

  /// No description provided for @welcome_age_confirm.
  ///
  /// In en, this message translates to:
  /// **'I confirm I am 13 years of age or older, and I agree to the Terms of Use and Community Guidelines.'**
  String get welcome_age_confirm;

  /// No description provided for @welcome_terms_prefix.
  ///
  /// In en, this message translates to:
  /// **'By continuing you accept the '**
  String get welcome_terms_prefix;

  /// No description provided for @welcome_terms_link.
  ///
  /// In en, this message translates to:
  /// **'terms'**
  String get welcome_terms_link;

  /// No description provided for @welcome_terms_and.
  ///
  /// In en, this message translates to:
  /// **' and '**
  String get welcome_terms_and;

  /// No description provided for @welcome_privacy_link.
  ///
  /// In en, this message translates to:
  /// **'privacy'**
  String get welcome_privacy_link;

  /// No description provided for @welcome_terms_suffix.
  ///
  /// In en, this message translates to:
  /// **'.'**
  String get welcome_terms_suffix;

  /// No description provided for @welcome_generated_title.
  ///
  /// In en, this message translates to:
  /// **'This is your permanent ID'**
  String get welcome_generated_title;

  /// No description provided for @welcome_generated_subtitle.
  ///
  /// In en, this message translates to:
  /// **'It can\'t be changed. It carries no personal information.'**
  String get welcome_generated_subtitle;

  /// No description provided for @welcome_generated_cta.
  ///
  /// In en, this message translates to:
  /// **'Enter Qurb'**
  String get welcome_generated_cta;

  /// No description provided for @feed_appName.
  ///
  /// In en, this message translates to:
  /// **'Qurb'**
  String get feed_appName;

  /// No description provided for @feed_location_riyadh.
  ///
  /// In en, this message translates to:
  /// **'Riyadh'**
  String get feed_location_riyadh;

  /// No description provided for @feed_filter_near.
  ///
  /// In en, this message translates to:
  /// **'Near you'**
  String get feed_filter_near;

  /// No description provided for @feed_filter_block.
  ///
  /// In en, this message translates to:
  /// **'Neighborhood'**
  String get feed_filter_block;

  /// No description provided for @feed_filter_city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get feed_filter_city;

  /// No description provided for @feed_filter_all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get feed_filter_all;

  /// No description provided for @feed_empty_title.
  ///
  /// In en, this message translates to:
  /// **'Nothing nearby right now'**
  String get feed_empty_title;

  /// No description provided for @feed_empty_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Be the first to post in your area.'**
  String get feed_empty_subtitle;

  /// No description provided for @feed_error_title.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load posts'**
  String get feed_error_title;

  /// No description provided for @feed_end_marker.
  ///
  /// In en, this message translates to:
  /// **'— that\'s everything happening nearby right now —'**
  String get feed_end_marker;

  /// No description provided for @feed_location_needed_title.
  ///
  /// In en, this message translates to:
  /// **'Share your location'**
  String get feed_location_needed_title;

  /// No description provided for @feed_location_needed_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Qurb only shows posts from where you are. Your exact GPS is never stored — only a 100 m grid cell.'**
  String get feed_location_needed_subtitle;

  /// No description provided for @feed_location_needed_cta.
  ///
  /// In en, this message translates to:
  /// **'Enable location'**
  String get feed_location_needed_cta;

  /// No description provided for @feed_location_denied_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Location is required to see what\'s near you. Open device settings to enable it.'**
  String get feed_location_denied_subtitle;

  /// No description provided for @feed_location_serviceOff_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Turn on Location Services on your device, then try again.'**
  String get feed_location_serviceOff_subtitle;

  /// No description provided for @post_menu_save.
  ///
  /// In en, this message translates to:
  /// **'Save post'**
  String get post_menu_save;

  /// No description provided for @post_menu_report.
  ///
  /// In en, this message translates to:
  /// **'Report post'**
  String get post_menu_report;

  /// No description provided for @post_menu_block.
  ///
  /// In en, this message translates to:
  /// **'Block author'**
  String get post_menu_block;

  /// No description provided for @post_menu_edit.
  ///
  /// In en, this message translates to:
  /// **'Edit post'**
  String get post_menu_edit;

  /// No description provided for @post_menu_delete.
  ///
  /// In en, this message translates to:
  /// **'Delete post'**
  String get post_menu_delete;

  /// No description provided for @post_edit_title.
  ///
  /// In en, this message translates to:
  /// **'Edit post'**
  String get post_edit_title;

  /// No description provided for @post_edit_save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get post_edit_save;

  /// No description provided for @post_delete_title.
  ///
  /// In en, this message translates to:
  /// **'Delete this post?'**
  String get post_delete_title;

  /// No description provided for @post_delete_body.
  ///
  /// In en, this message translates to:
  /// **'Your post will be permanently hidden from the feed. This can\'t be undone.'**
  String get post_delete_body;

  /// No description provided for @post_delete_action.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get post_delete_action;

  /// No description provided for @post_edited_marker.
  ///
  /// In en, this message translates to:
  /// **'edited'**
  String get post_edited_marker;

  /// No description provided for @whisper_sent_toast.
  ///
  /// In en, this message translates to:
  /// **'Whisper request sent.'**
  String get whisper_sent_toast;

  /// No description provided for @post_block_title.
  ///
  /// In en, this message translates to:
  /// **'Block #{id}?'**
  String post_block_title(String id);

  /// No description provided for @post_block_body.
  ///
  /// In en, this message translates to:
  /// **'You won\'t see their posts or comments anymore.'**
  String get post_block_body;

  /// No description provided for @post_block_action.
  ///
  /// In en, this message translates to:
  /// **'Block'**
  String get post_block_action;

  /// No description provided for @post_replies_count.
  ///
  /// In en, this message translates to:
  /// **'{count} replies'**
  String post_replies_count(int count);

  /// No description provided for @post_whisper_author.
  ///
  /// In en, this message translates to:
  /// **'Whisper to author'**
  String get post_whisper_author;

  /// No description provided for @compose_title.
  ///
  /// In en, this message translates to:
  /// **'New post'**
  String get compose_title;

  /// No description provided for @compose_publish.
  ///
  /// In en, this message translates to:
  /// **'Publish'**
  String get compose_publish;

  /// No description provided for @compose_id_hint.
  ///
  /// In en, this message translates to:
  /// **'Your post will only show your ID'**
  String get compose_id_hint;

  /// No description provided for @compose_hint.
  ///
  /// In en, this message translates to:
  /// **'What\'s happening near you?'**
  String get compose_hint;

  /// No description provided for @compose_scope_label.
  ///
  /// In en, this message translates to:
  /// **'Where will this be seen?'**
  String get compose_scope_label;

  /// No description provided for @compose_scope_near_label.
  ///
  /// In en, this message translates to:
  /// **'Near'**
  String get compose_scope_near_label;

  /// No description provided for @compose_scope_near_desc.
  ///
  /// In en, this message translates to:
  /// **'500 m'**
  String get compose_scope_near_desc;

  /// No description provided for @compose_scope_block_label.
  ///
  /// In en, this message translates to:
  /// **'Neighborhood'**
  String get compose_scope_block_label;

  /// No description provided for @compose_scope_block_desc.
  ///
  /// In en, this message translates to:
  /// **'2 km'**
  String get compose_scope_block_desc;

  /// No description provided for @compose_scope_city_label.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get compose_scope_city_label;

  /// No description provided for @compose_scope_city_desc.
  ///
  /// In en, this message translates to:
  /// **'All of Riyadh'**
  String get compose_scope_city_desc;

  /// No description provided for @compose_tag_label.
  ///
  /// In en, this message translates to:
  /// **'Tag'**
  String get compose_tag_label;

  /// No description provided for @compose_tag_stories.
  ///
  /// In en, this message translates to:
  /// **'stories'**
  String get compose_tag_stories;

  /// No description provided for @compose_tag_feelings.
  ///
  /// In en, this message translates to:
  /// **'feelings'**
  String get compose_tag_feelings;

  /// No description provided for @compose_tag_discussion.
  ///
  /// In en, this message translates to:
  /// **'discussion'**
  String get compose_tag_discussion;

  /// No description provided for @compose_tag_help.
  ///
  /// In en, this message translates to:
  /// **'help'**
  String get compose_tag_help;

  /// No description provided for @compose_tag_moment.
  ///
  /// In en, this message translates to:
  /// **'moment'**
  String get compose_tag_moment;

  /// No description provided for @compose_tag_question.
  ///
  /// In en, this message translates to:
  /// **'question'**
  String get compose_tag_question;

  /// No description provided for @compose_err_rateLimit.
  ///
  /// In en, this message translates to:
  /// **'Daily limit reached (10 posts). Try later.'**
  String get compose_err_rateLimit;

  /// No description provided for @compose_err_moderation.
  ///
  /// In en, this message translates to:
  /// **'Text rejected — may contain disallowed content or a suspicious link.'**
  String get compose_err_moderation;

  /// No description provided for @compose_err_length.
  ///
  /// In en, this message translates to:
  /// **'Text length out of range.'**
  String get compose_err_length;

  /// No description provided for @compose_err_generic.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t publish. Check your connection.'**
  String get compose_err_generic;

  /// No description provided for @comments_header.
  ///
  /// In en, this message translates to:
  /// **'Post'**
  String get comments_header;

  /// No description provided for @comments_hint.
  ///
  /// In en, this message translates to:
  /// **'Write your reply…'**
  String get comments_hint;

  /// No description provided for @comments_empty_title.
  ///
  /// In en, this message translates to:
  /// **'No comments yet'**
  String get comments_empty_title;

  /// No description provided for @comments_empty_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Be the first to reply.'**
  String get comments_empty_subtitle;

  /// No description provided for @comments_error_title.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load comments'**
  String get comments_error_title;

  /// No description provided for @comments_err_moderation.
  ///
  /// In en, this message translates to:
  /// **'Reply rejected — disallowed content.'**
  String get comments_err_moderation;

  /// No description provided for @comments_err_rateLimit.
  ///
  /// In en, this message translates to:
  /// **'Comment limit reached (50/hour).'**
  String get comments_err_rateLimit;

  /// No description provided for @comments_err_generic.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t send'**
  String get comments_err_generic;

  /// No description provided for @comments_reply.
  ///
  /// In en, this message translates to:
  /// **'Reply'**
  String get comments_reply;

  /// No description provided for @comments_replying_to.
  ///
  /// In en, this message translates to:
  /// **'Replying to #{id}'**
  String comments_replying_to(Object id);

  /// No description provided for @comments_cancel_reply.
  ///
  /// In en, this message translates to:
  /// **'Cancel reply'**
  String get comments_cancel_reply;

  /// No description provided for @whispers_header.
  ///
  /// In en, this message translates to:
  /// **'Whispers'**
  String get whispers_header;

  /// No description provided for @whispers_requests_label.
  ///
  /// In en, this message translates to:
  /// **'WHISPER REQUESTS'**
  String get whispers_requests_label;

  /// No description provided for @whispers_empty_title.
  ///
  /// In en, this message translates to:
  /// **'No whispers yet'**
  String get whispers_empty_title;

  /// No description provided for @whispers_empty_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap \"Whisper to author\" under any post to start a private chat.'**
  String get whispers_empty_subtitle;

  /// No description provided for @whispers_error_title.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load whispers'**
  String get whispers_error_title;

  /// No description provided for @whispers_no_messages_yet.
  ///
  /// In en, this message translates to:
  /// **'No messages yet'**
  String get whispers_no_messages_yet;

  /// No description provided for @whispers_accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get whispers_accept;

  /// No description provided for @whispers_decline.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get whispers_decline;

  /// No description provided for @whispers_label_with_id.
  ///
  /// In en, this message translates to:
  /// **'Whisper · #{id}'**
  String whispers_label_with_id(String id);

  /// No description provided for @whisper_request_title.
  ///
  /// In en, this message translates to:
  /// **'Whisper to author'**
  String get whisper_request_title;

  /// No description provided for @whisper_request_subtitle.
  ///
  /// In en, this message translates to:
  /// **'The author will receive a whisper request. You can\'t send messages until they accept.'**
  String get whisper_request_subtitle;

  /// No description provided for @whisper_request_hint.
  ///
  /// In en, this message translates to:
  /// **'Short message (optional)'**
  String get whisper_request_hint;

  /// No description provided for @whisper_request_submit.
  ///
  /// In en, this message translates to:
  /// **'Send request'**
  String get whisper_request_submit;

  /// No description provided for @whisper_err_cooldown.
  ///
  /// In en, this message translates to:
  /// **'The author previously declined — try after 30 days.'**
  String get whisper_err_cooldown;

  /// No description provided for @whisper_err_rateLimit.
  ///
  /// In en, this message translates to:
  /// **'Whisper request limit reached (3/hour).'**
  String get whisper_err_rateLimit;

  /// No description provided for @whisper_err_self.
  ///
  /// In en, this message translates to:
  /// **'You can\'t whisper to yourself.'**
  String get whisper_err_self;

  /// No description provided for @whisper_err_generic.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t send request.'**
  String get whisper_err_generic;

  /// No description provided for @thread_empty_title.
  ///
  /// In en, this message translates to:
  /// **'Start with the first word'**
  String get thread_empty_title;

  /// No description provided for @thread_empty_subtitle.
  ///
  /// In en, this message translates to:
  /// **'This conversation is between you and them only.'**
  String get thread_empty_subtitle;

  /// No description provided for @thread_error_title.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load messages'**
  String get thread_error_title;

  /// No description provided for @thread_hint.
  ///
  /// In en, this message translates to:
  /// **'Type your whisper…'**
  String get thread_hint;

  /// No description provided for @thread_err_moderation.
  ///
  /// In en, this message translates to:
  /// **'Message rejected — disallowed content.'**
  String get thread_err_moderation;

  /// No description provided for @thread_err_rateLimit.
  ///
  /// In en, this message translates to:
  /// **'Slow down (60 messages/minute).'**
  String get thread_err_rateLimit;

  /// No description provided for @thread_err_generic.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t send'**
  String get thread_err_generic;

  /// No description provided for @thread_header_fallback.
  ///
  /// In en, this message translates to:
  /// **'Whisper'**
  String get thread_header_fallback;

  /// No description provided for @thread_menu_report_user.
  ///
  /// In en, this message translates to:
  /// **'Report this user'**
  String get thread_menu_report_user;

  /// No description provided for @thread_menu_block_user.
  ///
  /// In en, this message translates to:
  /// **'Block this user'**
  String get thread_menu_block_user;

  /// No description provided for @notifs_title.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifs_title;

  /// No description provided for @notifs_mark_all_read.
  ///
  /// In en, this message translates to:
  /// **'Mark all read'**
  String get notifs_mark_all_read;

  /// No description provided for @notifs_empty_title.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get notifs_empty_title;

  /// No description provided for @notifs_empty_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Replies, whispers, and reactions to your posts will appear here.'**
  String get notifs_empty_subtitle;

  /// No description provided for @notifs_error_title.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load notifications'**
  String get notifs_error_title;

  /// No description provided for @notifs_bucket_today.
  ///
  /// In en, this message translates to:
  /// **'TODAY'**
  String get notifs_bucket_today;

  /// No description provided for @notifs_bucket_yesterday.
  ///
  /// In en, this message translates to:
  /// **'YESTERDAY'**
  String get notifs_bucket_yesterday;

  /// No description provided for @notifs_bucket_thisWeek.
  ///
  /// In en, this message translates to:
  /// **'THIS WEEK'**
  String get notifs_bucket_thisWeek;

  /// No description provided for @notifs_bucket_earlier.
  ///
  /// In en, this message translates to:
  /// **'EARLIER'**
  String get notifs_bucket_earlier;

  /// No description provided for @notifs_human_reply_to_post.
  ///
  /// In en, this message translates to:
  /// **'replied to your post: \"{body}\"'**
  String notifs_human_reply_to_post(String body);

  /// No description provided for @notifs_human_reply_to_comment.
  ///
  /// In en, this message translates to:
  /// **'replied to your comment: \"{body}\"'**
  String notifs_human_reply_to_comment(String body);

  /// No description provided for @notifs_human_vote_milestone.
  ///
  /// In en, this message translates to:
  /// **'voted on your post {body}'**
  String notifs_human_vote_milestone(String body);

  /// No description provided for @notifs_human_whisper_request_default.
  ///
  /// In en, this message translates to:
  /// **'started a whisper with you'**
  String get notifs_human_whisper_request_default;

  /// No description provided for @notifs_human_tag_trending.
  ///
  /// In en, this message translates to:
  /// **'tag #{body} reached a new peak'**
  String notifs_human_tag_trending(String body);

  /// No description provided for @explore_title.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get explore_title;

  /// No description provided for @explore_hint.
  ///
  /// In en, this message translates to:
  /// **'Search communities, tags, posts…'**
  String get explore_hint;

  /// No description provided for @explore_recent.
  ///
  /// In en, this message translates to:
  /// **'RECENT SEARCH'**
  String get explore_recent;

  /// No description provided for @explore_communities.
  ///
  /// In en, this message translates to:
  /// **'Communities'**
  String get explore_communities;

  /// No description provided for @explore_view_all.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get explore_view_all;

  /// No description provided for @explore_suggested.
  ///
  /// In en, this message translates to:
  /// **'Suggested for you'**
  String get explore_suggested;

  /// No description provided for @explore_search_error_title.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t search'**
  String get explore_search_error_title;

  /// No description provided for @explore_search_empty_title.
  ///
  /// In en, this message translates to:
  /// **'No results for \"{q}\"'**
  String explore_search_empty_title(String q);

  /// No description provided for @explore_search_empty_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Try another word, a tag, or an ID (#12345).'**
  String get explore_search_empty_subtitle;

  /// No description provided for @explore_members_count.
  ///
  /// In en, this message translates to:
  /// **'{count} members'**
  String explore_members_count(String count);

  /// No description provided for @explore_recent_q1.
  ///
  /// In en, this message translates to:
  /// **'fajr cafes'**
  String get explore_recent_q1;

  /// No description provided for @explore_recent_q2.
  ///
  /// In en, this message translates to:
  /// **'#stories'**
  String get explore_recent_q2;

  /// No description provided for @explore_recent_q3.
  ///
  /// In en, this message translates to:
  /// **'lost & found'**
  String get explore_recent_q3;

  /// No description provided for @explore_recent_q4.
  ///
  /// In en, this message translates to:
  /// **'rent'**
  String get explore_recent_q4;

  /// No description provided for @explore_recent_q5.
  ///
  /// In en, this message translates to:
  /// **'saturday events'**
  String get explore_recent_q5;

  /// No description provided for @explore_communities_error_title.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load communities'**
  String get explore_communities_error_title;

  /// No description provided for @trend_title.
  ///
  /// In en, this message translates to:
  /// **'Local Trend'**
  String get trend_title;

  /// No description provided for @trend_subtitle.
  ///
  /// In en, this message translates to:
  /// **'What people are talking about nearby'**
  String get trend_subtitle;

  /// No description provided for @trend_live.
  ///
  /// In en, this message translates to:
  /// **'LIVE'**
  String get trend_live;

  /// No description provided for @trend_hottest.
  ///
  /// In en, this message translates to:
  /// **'Hottest discussions'**
  String get trend_hottest;

  /// No description provided for @trend_error_title.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load trend'**
  String get trend_error_title;

  /// No description provided for @trend_empty_title.
  ///
  /// In en, this message translates to:
  /// **'No notable activity'**
  String get trend_empty_title;

  /// No description provided for @trend_empty_subtitle.
  ///
  /// In en, this message translates to:
  /// **'No movement in the last hour near you.'**
  String get trend_empty_subtitle;

  /// No description provided for @trend_row_subtitle.
  ///
  /// In en, this message translates to:
  /// **'{count} posts · last 30 min'**
  String trend_row_subtitle(int count);

  /// No description provided for @trend_pulse_you.
  ///
  /// In en, this message translates to:
  /// **'you'**
  String get trend_pulse_you;

  /// No description provided for @profile_header.
  ///
  /// In en, this message translates to:
  /// **'My profile'**
  String get profile_header;

  /// No description provided for @profile_id_caption.
  ///
  /// In en, this message translates to:
  /// **'Your ID in Qurb'**
  String get profile_id_caption;

  /// No description provided for @profile_member_since.
  ///
  /// In en, this message translates to:
  /// **'Member since {month}'**
  String profile_member_since(String month);

  /// No description provided for @profile_stat_posts.
  ///
  /// In en, this message translates to:
  /// **'posts'**
  String get profile_stat_posts;

  /// No description provided for @profile_stat_karma.
  ///
  /// In en, this message translates to:
  /// **'karma'**
  String get profile_stat_karma;

  /// No description provided for @profile_stat_bookmarks.
  ///
  /// In en, this message translates to:
  /// **'bookmarks'**
  String get profile_stat_bookmarks;

  /// No description provided for @profile_tab_posts.
  ///
  /// In en, this message translates to:
  /// **'Posts'**
  String get profile_tab_posts;

  /// No description provided for @profile_tab_comments.
  ///
  /// In en, this message translates to:
  /// **'Comments'**
  String get profile_tab_comments;

  /// No description provided for @profile_tab_bookmarks.
  ///
  /// In en, this message translates to:
  /// **'Bookmarks'**
  String get profile_tab_bookmarks;

  /// No description provided for @profile_empty_posts_title.
  ///
  /// In en, this message translates to:
  /// **'No posts yet'**
  String get profile_empty_posts_title;

  /// No description provided for @profile_empty_posts_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Share a thought, an opinion, or a question.'**
  String get profile_empty_posts_subtitle;

  /// No description provided for @profile_empty_bookmarks_title.
  ///
  /// In en, this message translates to:
  /// **'No bookmarks yet'**
  String get profile_empty_bookmarks_title;

  /// No description provided for @profile_empty_bookmarks_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Save posts from the \"more\" menu to read later.'**
  String get profile_empty_bookmarks_subtitle;

  /// No description provided for @profile_empty_comments_title.
  ///
  /// In en, this message translates to:
  /// **'No comments yet'**
  String get profile_empty_comments_title;

  /// No description provided for @profile_empty_comments_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Share your thoughts on any post.'**
  String get profile_empty_comments_subtitle;

  /// No description provided for @profile_post_meta.
  ///
  /// In en, this message translates to:
  /// **'{score} · {replies} replies'**
  String profile_post_meta(int score, int replies);

  /// No description provided for @settings_header.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings_header;

  /// No description provided for @settings_identity_title.
  ///
  /// In en, this message translates to:
  /// **'This is your permanent ID'**
  String get settings_identity_title;

  /// No description provided for @settings_identity_subtitle.
  ///
  /// In en, this message translates to:
  /// **'It can\'t be changed. It carries no personal information.'**
  String get settings_identity_subtitle;

  /// No description provided for @settings_group_privacy.
  ///
  /// In en, this message translates to:
  /// **'PRIVACY'**
  String get settings_group_privacy;

  /// No description provided for @settings_group_appearance.
  ///
  /// In en, this message translates to:
  /// **'APPEARANCE'**
  String get settings_group_appearance;

  /// No description provided for @settings_group_notifs.
  ///
  /// In en, this message translates to:
  /// **'NOTIFICATIONS'**
  String get settings_group_notifs;

  /// No description provided for @settings_group_about.
  ///
  /// In en, this message translates to:
  /// **'ABOUT QURB'**
  String get settings_group_about;

  /// No description provided for @settings_row_locationShare.
  ///
  /// In en, this message translates to:
  /// **'Share location'**
  String get settings_row_locationShare;

  /// No description provided for @settings_row_locationShare_detail.
  ///
  /// In en, this message translates to:
  /// **'Required to show nearby posts'**
  String get settings_row_locationShare_detail;

  /// No description provided for @settings_row_allowStrangers.
  ///
  /// In en, this message translates to:
  /// **'Allow whispers from strangers'**
  String get settings_row_allowStrangers;

  /// No description provided for @settings_row_readReceipts.
  ///
  /// In en, this message translates to:
  /// **'Read receipts'**
  String get settings_row_readReceipts;

  /// No description provided for @settings_row_blocklist.
  ///
  /// In en, this message translates to:
  /// **'Blocklist'**
  String get settings_row_blocklist;

  /// No description provided for @settings_row_blocklist_empty.
  ///
  /// In en, this message translates to:
  /// **'No one blocked'**
  String get settings_row_blocklist_empty;

  /// No description provided for @settings_row_blocklist_count.
  ///
  /// In en, this message translates to:
  /// **'{count} blocked'**
  String settings_row_blocklist_count(int count);

  /// No description provided for @settings_row_demoLocation.
  ///
  /// In en, this message translates to:
  /// **'Demo location (Store review)'**
  String get settings_row_demoLocation;

  /// No description provided for @settings_row_demoLocation_detail.
  ///
  /// In en, this message translates to:
  /// **'Pins the location to Riyadh so reviewers see a populated feed. Turn on during App Store / Play review.'**
  String get settings_row_demoLocation_detail;

  /// No description provided for @settings_row_nightMode.
  ///
  /// In en, this message translates to:
  /// **'Night mode'**
  String get settings_row_nightMode;

  /// No description provided for @settings_row_allNotifs.
  ///
  /// In en, this message translates to:
  /// **'All notifications'**
  String get settings_row_allNotifs;

  /// No description provided for @settings_row_pulseNotifs.
  ///
  /// In en, this message translates to:
  /// **'Area pulse'**
  String get settings_row_pulseNotifs;

  /// No description provided for @settings_row_pulseNotifs_detail.
  ///
  /// In en, this message translates to:
  /// **'Notify on high activity in your neighborhood'**
  String get settings_row_pulseNotifs_detail;

  /// No description provided for @settings_row_community.
  ///
  /// In en, this message translates to:
  /// **'Community guidelines'**
  String get settings_row_community;

  /// No description provided for @settings_row_language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settings_row_language;

  /// No description provided for @settings_row_report.
  ///
  /// In en, this message translates to:
  /// **'Report a problem'**
  String get settings_row_report;

  /// No description provided for @settings_row_signout.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get settings_row_signout;

  /// No description provided for @settings_row_delete.
  ///
  /// In en, this message translates to:
  /// **'Delete my ID and all my data'**
  String get settings_row_delete;

  /// No description provided for @settings_version.
  ///
  /// In en, this message translates to:
  /// **'QURB · v0.1.0 (build 1)'**
  String get settings_version;

  /// No description provided for @settings_delete_title.
  ///
  /// In en, this message translates to:
  /// **'Delete account permanently?'**
  String get settings_delete_title;

  /// No description provided for @settings_delete_body.
  ///
  /// In en, this message translates to:
  /// **'Your ID and all your posts, comments, and conversations will be removed. This can\'t be undone.'**
  String get settings_delete_body;

  /// No description provided for @settings_delete_err.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t delete account. Check your connection and try again.'**
  String get settings_delete_err;

  /// No description provided for @settings_lang_arabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get settings_lang_arabic;

  /// No description provided for @settings_lang_english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settings_lang_english;

  /// No description provided for @settings_lang_sheet_title.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settings_lang_sheet_title;

  /// No description provided for @blocks_header.
  ///
  /// In en, this message translates to:
  /// **'Blocklist'**
  String get blocks_header;

  /// No description provided for @blocks_empty_title.
  ///
  /// In en, this message translates to:
  /// **'No one blocked'**
  String get blocks_empty_title;

  /// No description provided for @blocks_empty_subtitle.
  ///
  /// In en, this message translates to:
  /// **'You can block any user from their post menu.'**
  String get blocks_empty_subtitle;

  /// No description provided for @blocks_unblock.
  ///
  /// In en, this message translates to:
  /// **'Unblock'**
  String get blocks_unblock;

  /// No description provided for @report_post_title.
  ///
  /// In en, this message translates to:
  /// **'Report post'**
  String get report_post_title;

  /// No description provided for @report_comment_title.
  ///
  /// In en, this message translates to:
  /// **'Report comment'**
  String get report_comment_title;

  /// No description provided for @report_user_title.
  ///
  /// In en, this message translates to:
  /// **'Report user'**
  String get report_user_title;

  /// No description provided for @report_message_title.
  ///
  /// In en, this message translates to:
  /// **'Report message'**
  String get report_message_title;

  /// No description provided for @report_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Our team will review within 24 hours. Your identity stays anonymous.'**
  String get report_subtitle;

  /// No description provided for @report_reason_spam_title.
  ///
  /// In en, this message translates to:
  /// **'Spam'**
  String get report_reason_spam_title;

  /// No description provided for @report_reason_spam_desc.
  ///
  /// In en, this message translates to:
  /// **'Ads, repeated links'**
  String get report_reason_spam_desc;

  /// No description provided for @report_reason_harass_title.
  ///
  /// In en, this message translates to:
  /// **'Personal abuse'**
  String get report_reason_harass_title;

  /// No description provided for @report_reason_harass_desc.
  ///
  /// In en, this message translates to:
  /// **'Harassment, threats, bullying'**
  String get report_reason_harass_desc;

  /// No description provided for @report_reason_fake_title.
  ///
  /// In en, this message translates to:
  /// **'Misinformation'**
  String get report_reason_fake_title;

  /// No description provided for @report_reason_fake_desc.
  ///
  /// In en, this message translates to:
  /// **'False news or claims'**
  String get report_reason_fake_desc;

  /// No description provided for @report_reason_nsfw_title.
  ///
  /// In en, this message translates to:
  /// **'Inappropriate content'**
  String get report_reason_nsfw_title;

  /// No description provided for @report_reason_nsfw_desc.
  ///
  /// In en, this message translates to:
  /// **'Porn, violence'**
  String get report_reason_nsfw_desc;

  /// No description provided for @report_reason_private_title.
  ///
  /// In en, this message translates to:
  /// **'Privacy violation'**
  String get report_reason_private_title;

  /// No description provided for @report_reason_private_desc.
  ///
  /// In en, this message translates to:
  /// **'Someone\'s personal info without consent'**
  String get report_reason_private_desc;

  /// No description provided for @report_reason_other_title.
  ///
  /// In en, this message translates to:
  /// **'Other reason'**
  String get report_reason_other_title;

  /// No description provided for @report_reason_other_desc.
  ///
  /// In en, this message translates to:
  /// **'Will be sent for review'**
  String get report_reason_other_desc;

  /// No description provided for @report_submit.
  ///
  /// In en, this message translates to:
  /// **'Submit report'**
  String get report_submit;

  /// No description provided for @report_err_rateLimit.
  ///
  /// In en, this message translates to:
  /// **'Daily report limit reached (20).'**
  String get report_err_rateLimit;

  /// No description provided for @report_err_generic.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t submit report.'**
  String get report_err_generic;

  /// No description provided for @proximity_near.
  ///
  /// In en, this message translates to:
  /// **'near you'**
  String get proximity_near;

  /// No description provided for @proximity_block.
  ///
  /// In en, this message translates to:
  /// **'neighborhood'**
  String get proximity_block;

  /// No description provided for @proximity_city.
  ///
  /// In en, this message translates to:
  /// **'Riyadh'**
  String get proximity_city;

  /// No description provided for @terms_title.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use'**
  String get terms_title;

  /// No description provided for @terms_intro.
  ///
  /// In en, this message translates to:
  /// **'By using Qurb you agree to these terms. Qurb is an anonymous, location-based chat service — following these rules is required to keep your account active.'**
  String get terms_intro;

  /// No description provided for @terms_section_acceptance_h.
  ///
  /// In en, this message translates to:
  /// **'1. Acceptance'**
  String get terms_section_acceptance_h;

  /// No description provided for @terms_section_acceptance_b.
  ///
  /// In en, this message translates to:
  /// **'By completing the welcome screen you confirm that you are 13 years of age or older, that you have read the Privacy Policy and Community Guidelines, and that you agree to be bound by them. If you do not agree, close the app and do not use it.'**
  String get terms_section_acceptance_b;

  /// No description provided for @terms_section_anonymity_h.
  ///
  /// In en, this message translates to:
  /// **'2. Anonymous identity'**
  String get terms_section_anonymity_h;

  /// No description provided for @terms_section_anonymity_b.
  ///
  /// In en, this message translates to:
  /// **'We do not ask for your name, email, or phone number. Your account is tied to this device only — if you lose or wipe it, you may not be able to recover access. Do not impersonate other users or claim to represent an official entity.'**
  String get terms_section_anonymity_b;

  /// No description provided for @terms_section_content_h.
  ///
  /// In en, this message translates to:
  /// **'3. Your content'**
  String get terms_section_content_h;

  /// No description provided for @terms_section_content_b.
  ///
  /// In en, this message translates to:
  /// **'You are solely responsible for what you post. Your posts are shown to users geographically near you. Do not upload content owned by others without permission. You grant us a non-exclusive license to display what you post inside the app, solely to operate the service.'**
  String get terms_section_content_b;

  /// No description provided for @terms_section_conduct_h.
  ///
  /// In en, this message translates to:
  /// **'4. Prohibited conduct'**
  String get terms_section_conduct_h;

  /// No description provided for @terms_section_conduct_b.
  ///
  /// In en, this message translates to:
  /// **'Forbidden: profanity, threats, harassment, hate speech, sharing other people\'s private information (doxxing), explicit sexual content, advertising and fraud, impersonation, and any illegal activity. Violations result in content removal or account ban.'**
  String get terms_section_conduct_b;

  /// No description provided for @terms_section_termination_h.
  ///
  /// In en, this message translates to:
  /// **'5. Termination'**
  String get terms_section_termination_h;

  /// No description provided for @terms_section_termination_b.
  ///
  /// In en, this message translates to:
  /// **'We may suspend or delete your account if you violate these terms. You may delete your account at any time from Settings › Delete Account — this permanently removes your posts, comments, and chats.'**
  String get terms_section_termination_b;

  /// No description provided for @terms_section_disclaimer_h.
  ///
  /// In en, this message translates to:
  /// **'6. Disclaimer'**
  String get terms_section_disclaimer_h;

  /// No description provided for @terms_section_disclaimer_b.
  ///
  /// In en, this message translates to:
  /// **'The service is provided \"as is\" without warranty. We are not responsible for content posted by other users. Reliance on any information you see in the app is at your own risk.'**
  String get terms_section_disclaimer_b;

  /// No description provided for @terms_section_contact_h.
  ///
  /// In en, this message translates to:
  /// **'7. Contact'**
  String get terms_section_contact_h;

  /// No description provided for @terms_section_contact_b.
  ///
  /// In en, this message translates to:
  /// **'Questions or to report a violation: Settings › Report a problem.'**
  String get terms_section_contact_b;

  /// No description provided for @privacy_title.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacy_title;

  /// No description provided for @privacy_intro.
  ///
  /// In en, this message translates to:
  /// **'Qurb is built around one promise: your identity stays anonymous.'**
  String get privacy_intro;

  /// No description provided for @privacy_section_identity_h.
  ///
  /// In en, this message translates to:
  /// **'1. Your identity'**
  String get privacy_section_identity_h;

  /// No description provided for @privacy_section_identity_b.
  ///
  /// In en, this message translates to:
  /// **'When you sign up we generate a 5-digit numeric ID. We never ask for your name, photo, email, or phone number. The ID is the only thing other users see.'**
  String get privacy_section_identity_b;

  /// No description provided for @privacy_section_location_h.
  ///
  /// In en, this message translates to:
  /// **'2. Location'**
  String get privacy_section_location_h;

  /// No description provided for @privacy_section_location_b.
  ///
  /// In en, this message translates to:
  /// **'If you grant location permission, your device\'s coordinates are snapped to a 100 m grid before they leave the device. We never store or transmit precise GPS. Other users only see relative distance buckets (near / neighborhood / city) — never raw coordinates.'**
  String get privacy_section_location_b;

  /// No description provided for @privacy_section_content_h.
  ///
  /// In en, this message translates to:
  /// **'3. Your content'**
  String get privacy_section_content_h;

  /// No description provided for @privacy_section_content_b.
  ///
  /// In en, this message translates to:
  /// **'Posts and comments are public to nearby users. Whispers are end-to-end private between two participants. You can delete your account at any time from Settings — this removes all your posts, comments, and conversations.'**
  String get privacy_section_content_b;

  /// No description provided for @privacy_section_moderation_h.
  ///
  /// In en, this message translates to:
  /// **'4. Moderation'**
  String get privacy_section_moderation_h;

  /// No description provided for @privacy_section_moderation_b.
  ///
  /// In en, this message translates to:
  /// **'We run automated checks on submitted text for profanity, scam patterns, and disallowed links. Content reported by 3+ users in 24 hours is auto-hidden pending review.'**
  String get privacy_section_moderation_b;

  /// No description provided for @privacy_section_contact_h.
  ///
  /// In en, this message translates to:
  /// **'5. Contact'**
  String get privacy_section_contact_h;

  /// No description provided for @privacy_section_contact_b.
  ///
  /// In en, this message translates to:
  /// **'Questions? Use \"Report a problem\" in Settings.'**
  String get privacy_section_contact_b;

  /// No description provided for @community_title.
  ///
  /// In en, this message translates to:
  /// **'Community guidelines'**
  String get community_title;

  /// No description provided for @community_intro.
  ///
  /// In en, this message translates to:
  /// **'Qurb works because people behave well. These are the basic rules.'**
  String get community_intro;

  /// No description provided for @community_do_h.
  ///
  /// In en, this message translates to:
  /// **'Encouraged'**
  String get community_do_h;

  /// No description provided for @community_do_1.
  ///
  /// In en, this message translates to:
  /// **'Share authentic experiences from your area.'**
  String get community_do_1;

  /// No description provided for @community_do_2.
  ///
  /// In en, this message translates to:
  /// **'Treat others with respect even in disagreement.'**
  String get community_do_2;

  /// No description provided for @community_do_3.
  ///
  /// In en, this message translates to:
  /// **'Report any content that violates these rules.'**
  String get community_do_3;

  /// No description provided for @community_dont_h.
  ///
  /// In en, this message translates to:
  /// **'Not allowed'**
  String get community_dont_h;

  /// No description provided for @community_dont_1.
  ///
  /// In en, this message translates to:
  /// **'Profanity, slurs, hate speech.'**
  String get community_dont_1;

  /// No description provided for @community_dont_2.
  ///
  /// In en, this message translates to:
  /// **'Personal information of others (doxxing).'**
  String get community_dont_2;

  /// No description provided for @community_dont_3.
  ///
  /// In en, this message translates to:
  /// **'Sexual content or graphic violence.'**
  String get community_dont_3;

  /// No description provided for @community_dont_4.
  ///
  /// In en, this message translates to:
  /// **'Spam, scams, ads, or external links to suspicious sites.'**
  String get community_dont_4;

  /// No description provided for @community_dont_5.
  ///
  /// In en, this message translates to:
  /// **'Impersonating real people or organizations.'**
  String get community_dont_5;

  /// No description provided for @community_consequences_h.
  ///
  /// In en, this message translates to:
  /// **'Consequences'**
  String get community_consequences_h;

  /// No description provided for @community_consequences_b.
  ///
  /// In en, this message translates to:
  /// **'Violations may result in auto-hiding the content, restricting your account, or permanent removal.'**
  String get community_consequences_b;

  /// No description provided for @report_issue_title.
  ///
  /// In en, this message translates to:
  /// **'Report a problem'**
  String get report_issue_title;

  /// No description provided for @report_issue_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Found a bug? Got a feature idea? Tell us — read every submission.'**
  String get report_issue_subtitle;

  /// No description provided for @report_issue_subject_label.
  ///
  /// In en, this message translates to:
  /// **'Topic'**
  String get report_issue_subject_label;

  /// No description provided for @report_issue_subject_hint.
  ///
  /// In en, this message translates to:
  /// **'Brief title (optional)'**
  String get report_issue_subject_hint;

  /// No description provided for @report_issue_body_label.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get report_issue_body_label;

  /// No description provided for @report_issue_body_hint.
  ///
  /// In en, this message translates to:
  /// **'Describe the problem or idea…'**
  String get report_issue_body_hint;

  /// No description provided for @report_issue_submit.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get report_issue_submit;

  /// No description provided for @report_issue_success.
  ///
  /// In en, this message translates to:
  /// **'Thanks — we got it.'**
  String get report_issue_success;

  /// No description provided for @report_issue_err_empty.
  ///
  /// In en, this message translates to:
  /// **'Please write a few words.'**
  String get report_issue_err_empty;

  /// No description provided for @report_issue_err_generic.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t send. Try again.'**
  String get report_issue_err_generic;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
