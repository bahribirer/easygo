import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('en'),
    Locale('tr'),
  ];

  /// No description provided for @errorEmptyEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email address.'**
  String get errorEmptyEmail;

  /// No description provided for @errorInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address.'**
  String get errorInvalidEmail;

  /// No description provided for @errorMissingInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Missing / Invalid Info'**
  String get errorMissingInfoTitle;

  /// No description provided for @errorMissingInfoMessage.
  ///
  /// In en, this message translates to:
  /// **'Please check the email field and try again.'**
  String get errorMissingInfoMessage;

  /// No description provided for @successSentTitle.
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get successSentTitle;

  /// No description provided for @successSentMessage.
  ///
  /// In en, this message translates to:
  /// **'A password reset link has been sent to {email}. Check your inbox and spam folder.'**
  String successSentMessage(Object email);

  /// No description provided for @errorNetwork.
  ///
  /// In en, this message translates to:
  /// **'Network error. Check your internet connection.'**
  String get errorNetwork;

  /// No description provided for @errorTooManyRequests.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Please try again later.'**
  String get errorTooManyRequests;

  /// No description provided for @errorUserDisabled.
  ///
  /// In en, this message translates to:
  /// **'This account has been disabled.'**
  String get errorUserDisabled;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'The request could not be processed. Please try again later or use another email.'**
  String get errorGeneric;

  /// No description provided for @errorGeneric2.
  ///
  /// In en, this message translates to:
  /// **'The request could not be processed. Please try again.'**
  String get errorGeneric2;

  /// No description provided for @infoTitle.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get infoTitle;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We will send a verification link to your email.'**
  String get forgotPasswordSubtitle;

  /// No description provided for @universityEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'University Email Address'**
  String get universityEmailLabel;

  /// No description provided for @universityEmailHint.
  ///
  /// In en, this message translates to:
  /// **'example@samsun.edu.tr'**
  String get universityEmailHint;

  /// No description provided for @forgotPasswordNote.
  ///
  /// In en, this message translates to:
  /// **'Check your inbox and spam folder. On corporate emails it may fall into quarantine.'**
  String get forgotPasswordNote;

  /// No description provided for @sendVerificationButton.
  ///
  /// In en, this message translates to:
  /// **'Send Verification Link'**
  String get sendVerificationButton;

  /// No description provided for @help.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// No description provided for @helpMessage.
  ///
  /// In en, this message translates to:
  /// **'If you didn\'t receive the email, check your spam folder or try again after a few minutes.'**
  String get helpMessage;

  /// No description provided for @emailNotReceived.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t receive the email?'**
  String get emailNotReceived;

  /// No description provided for @loginTitleLine1.
  ///
  /// In en, this message translates to:
  /// **'To Continue'**
  String get loginTitleLine1;

  /// No description provided for @loginTitleLine2.
  ///
  /// In en, this message translates to:
  /// **'Please Sign In.'**
  String get loginTitleLine2;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailLabel;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'university@example.edu.tr'**
  String get emailHint;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailRequired;

  /// No description provided for @emailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get emailInvalid;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'••••••••'**
  String get passwordHint;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordRequired;

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'At least 6 characters'**
  String get passwordMinLength;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password'**
  String get forgotPassword;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginButton;

  /// No description provided for @loginErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Login Failed'**
  String get loginErrorTitle;

  /// No description provided for @loginInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Missing Info'**
  String get loginInfoTitle;

  /// No description provided for @loginInfoMessage.
  ///
  /// In en, this message translates to:
  /// **'Please fill in your email and password properly.'**
  String get loginInfoMessage;

  /// No description provided for @loginErrorWrongCredentials.
  ///
  /// In en, this message translates to:
  /// **'Incorrect email or password.'**
  String get loginErrorWrongCredentials;

  /// No description provided for @loginErrorNotFound.
  ///
  /// In en, this message translates to:
  /// **'No user found with this email.'**
  String get loginErrorNotFound;

  /// No description provided for @loginErrorTooMany.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Try again later.'**
  String get loginErrorTooMany;

  /// No description provided for @loginErrorNetwork.
  ///
  /// In en, this message translates to:
  /// **'Network error. Check your connection.'**
  String get loginErrorNetwork;

  /// No description provided for @loginErrorInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid email address.'**
  String get loginErrorInvalidEmail;

  /// No description provided for @loginErrorUnexpected.
  ///
  /// In en, this message translates to:
  /// **'Unexpected error occurred: {error}'**
  String loginErrorUnexpected(Object error);

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @commonBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get commonBack;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get registerTitle;

  /// No description provided for @registerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign up now and start chatting'**
  String get registerSubtitle;

  /// No description provided for @nameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get nameLabel;

  /// No description provided for @nameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get nameHint;

  /// No description provided for @btnRegister.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get btnRegister;

  /// No description provided for @dialogInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Missing / Invalid Info'**
  String get dialogInfoTitle;

  /// No description provided for @dialogErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Registration Failed'**
  String get dialogErrorTitle;

  /// No description provided for @infoFillForm.
  ///
  /// In en, this message translates to:
  /// **'Please fill all fields correctly.'**
  String get infoFillForm;

  /// No description provided for @errorEmailDomain.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid @metu.edu.tr address'**
  String get errorEmailDomain;

  /// No description provided for @passwordMinChars.
  ///
  /// In en, this message translates to:
  /// **'At least {count} characters'**
  String passwordMinChars(Object count);

  /// No description provided for @strengthWeak.
  ///
  /// In en, this message translates to:
  /// **'Weak'**
  String get strengthWeak;

  /// No description provided for @strengthMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get strengthMedium;

  /// No description provided for @strengthGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get strengthGood;

  /// No description provided for @strengthStrong.
  ///
  /// In en, this message translates to:
  /// **'Strong'**
  String get strengthStrong;

  /// No description provided for @activeChatsTitle.
  ///
  /// In en, this message translates to:
  /// **'Active Chats'**
  String get activeChatsTitle;

  /// No description provided for @noActiveChatsMessage.
  ///
  /// In en, this message translates to:
  /// **'You have no active chats at the moment.'**
  String get noActiveChatsMessage;

  /// No description provided for @archivedChatsTitle.
  ///
  /// In en, this message translates to:
  /// **'Archived Chats'**
  String get archivedChatsTitle;

  /// No description provided for @noArchivedChatsMessage.
  ///
  /// In en, this message translates to:
  /// **'You don’t have any archived chats yet.'**
  String get noArchivedChatsMessage;

  /// No description provided for @friendsListTitle.
  ///
  /// In en, this message translates to:
  /// **'Friends List'**
  String get friendsListTitle;

  /// No description provided for @sortAZ.
  ///
  /// In en, this message translates to:
  /// **'A → Z'**
  String get sortAZ;

  /// No description provided for @sortZA.
  ///
  /// In en, this message translates to:
  /// **'Z → A'**
  String get sortZA;

  /// No description provided for @friendRemovedMessage.
  ///
  /// In en, this message translates to:
  /// **'Friend removed from the list.'**
  String get friendRemovedMessage;

  /// No description provided for @searchFriendsHint.
  ///
  /// In en, this message translates to:
  /// **'Search by name, email or location'**
  String get searchFriendsHint;

  /// No description provided for @defaultUserName.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get defaultUserName;

  /// No description provided for @friendCountLabel.
  ///
  /// In en, this message translates to:
  /// **'{count} friends'**
  String friendCountLabel(Object count);

  /// No description provided for @noFriendsTitle.
  ///
  /// In en, this message translates to:
  /// **'No friends yet.'**
  String get noFriendsTitle;

  /// No description provided for @noFriendsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Find users from the search bar and add them as friends.'**
  String get noFriendsSubtitle;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchHint;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @profileLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Profile data could not be loaded.'**
  String get profileLoadFailed;

  /// No description provided for @genericError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred. Please try again.'**
  String get genericError;

  /// No description provided for @unfriendConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove Friend?'**
  String get unfriendConfirmTitle;

  /// No description provided for @unfriendConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" will be removed from your friends list.'**
  String unfriendConfirmMessage(Object name);

  /// No description provided for @unfriendConfirmYes.
  ///
  /// In en, this message translates to:
  /// **'Yes, remove'**
  String get unfriendConfirmYes;

  /// No description provided for @unfriendSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Friendship Removed 💔'**
  String get unfriendSuccessTitle;

  /// No description provided for @unfriendSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'This person has been removed from your friends list.'**
  String get unfriendSuccessMessage;

  /// No description provided for @userDefault.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get userDefault;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @friendsSection.
  ///
  /// In en, this message translates to:
  /// **'Friends'**
  String get friendsSection;

  /// No description provided for @interestsSection.
  ///
  /// In en, this message translates to:
  /// **'Interests'**
  String get interestsSection;

  /// No description provided for @noInterests.
  ///
  /// In en, this message translates to:
  /// **'No interests specified'**
  String get noInterests;

  /// No description provided for @unfriendButton.
  ///
  /// In en, this message translates to:
  /// **'Remove Friend'**
  String get unfriendButton;

  /// No description provided for @sendMessage.
  ///
  /// In en, this message translates to:
  /// **'Send Message'**
  String get sendMessage;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @errorTitle.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get errorTitle;

  /// No description provided for @friendsFetchError.
  ///
  /// In en, this message translates to:
  /// **'There was a problem fetching data. Please try again.'**
  String get friendsFetchError;

  /// No description provided for @friendAcceptedTitle.
  ///
  /// In en, this message translates to:
  /// **'Friend Added'**
  String get friendAcceptedTitle;

  /// No description provided for @friendAcceptedMessage.
  ///
  /// In en, this message translates to:
  /// **'The request has been accepted.'**
  String get friendAcceptedMessage;

  /// No description provided for @friendAcceptError.
  ///
  /// In en, this message translates to:
  /// **'The request could not be accepted.'**
  String get friendAcceptError;

  /// No description provided for @friendRejectedTitle.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get friendRejectedTitle;

  /// No description provided for @friendRejectedMessage.
  ///
  /// In en, this message translates to:
  /// **'The request has been rejected.'**
  String get friendRejectedMessage;

  /// No description provided for @friendRejectError.
  ///
  /// In en, this message translates to:
  /// **'The request could not be rejected.'**
  String get friendRejectError;

  /// No description provided for @friendsSummary.
  ///
  /// In en, this message translates to:
  /// **'Friends'**
  String get friendsSummary;

  /// No description provided for @requestsSummary.
  ///
  /// In en, this message translates to:
  /// **'Requests'**
  String get requestsSummary;

  /// No description provided for @friendRequestsTitle.
  ///
  /// In en, this message translates to:
  /// **'Friend Requests'**
  String get friendRequestsTitle;

  /// No description provided for @noFriendRequests.
  ///
  /// In en, this message translates to:
  /// **'You have no pending requests.'**
  String get noFriendRequests;

  /// No description provided for @pendingRequests.
  ///
  /// In en, this message translates to:
  /// **'{count} pending'**
  String pendingRequests(Object count);

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// No description provided for @reject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get reject;

  /// No description provided for @noFriends.
  ///
  /// In en, this message translates to:
  /// **'You don’t seem to have any friends yet.'**
  String get noFriends;

  /// No description provided for @findFriends.
  ///
  /// In en, this message translates to:
  /// **'Find Friends'**
  String get findFriends;

  /// No description provided for @friendsTitle.
  ///
  /// In en, this message translates to:
  /// **'Friends'**
  String get friendsTitle;

  /// No description provided for @manageConnections.
  ///
  /// In en, this message translates to:
  /// **'Manage your connections'**
  String get manageConnections;

  /// No description provided for @addFriendButton.
  ///
  /// In en, this message translates to:
  /// **'Add Friend'**
  String get addFriendButton;

  /// No description provided for @searchError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while searching.'**
  String get searchError;

  /// No description provided for @selfRequestTitle.
  ///
  /// In en, this message translates to:
  /// **'Not Allowed 🙂'**
  String get selfRequestTitle;

  /// No description provided for @selfRequestMessage.
  ///
  /// In en, this message translates to:
  /// **'You cannot send a friend request to yourself.'**
  String get selfRequestMessage;

  /// No description provided for @requestSentTitle.
  ///
  /// In en, this message translates to:
  /// **'Request Sent'**
  String get requestSentTitle;

  /// No description provided for @requestSentMessage.
  ///
  /// In en, this message translates to:
  /// **'A friend request was sent to {name}.'**
  String requestSentMessage(Object name);

  /// No description provided for @requestFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get requestFailedTitle;

  /// No description provided for @requestFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'There was a problem sending the request. Please try again.'**
  String get requestFailedMessage;

  /// No description provided for @searchUsersTitle.
  ///
  /// In en, this message translates to:
  /// **'Search Users'**
  String get searchUsersTitle;

  /// No description provided for @searchButton.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchButton;

  /// No description provided for @thisIsYou.
  ///
  /// In en, this message translates to:
  /// **'This is you'**
  String get thisIsYou;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @alreadyFriend.
  ///
  /// In en, this message translates to:
  /// **'Already friends'**
  String get alreadyFriend;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResults;

  /// No description provided for @eventCancelled.
  ///
  /// In en, this message translates to:
  /// **'Event cancelled.'**
  String get eventCancelled;

  /// No description provided for @cancelFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not cancel'**
  String get cancelFailed;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @sendFailed.
  ///
  /// In en, this message translates to:
  /// **'Send failed'**
  String get sendFailed;

  /// No description provided for @createEvent.
  ///
  /// In en, this message translates to:
  /// **'Create Event'**
  String get createEvent;

  /// No description provided for @eventType.
  ///
  /// In en, this message translates to:
  /// **'Event Type'**
  String get eventType;

  /// No description provided for @eventTypeCoffee.
  ///
  /// In en, this message translates to:
  /// **'Coffee'**
  String get eventTypeCoffee;

  /// No description provided for @eventTypeMeal.
  ///
  /// In en, this message translates to:
  /// **'Meal'**
  String get eventTypeMeal;

  /// No description provided for @eventTypeChat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get eventTypeChat;

  /// No description provided for @eventTypeStudy.
  ///
  /// In en, this message translates to:
  /// **'Study'**
  String get eventTypeStudy;

  /// No description provided for @eventTypeSport.
  ///
  /// In en, this message translates to:
  /// **'Sport'**
  String get eventTypeSport;

  /// No description provided for @eventTypeCinema.
  ///
  /// In en, this message translates to:
  /// **'Cinema'**
  String get eventTypeCinema;

  /// No description provided for @select.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get select;

  /// No description provided for @dateWeekendOnly.
  ///
  /// In en, this message translates to:
  /// **'Date (only Saturday & Sunday)'**
  String get dateWeekendOnly;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get selectDate;

  /// No description provided for @selectDateShort.
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get selectDateShort;

  /// No description provided for @timeSlot.
  ///
  /// In en, this message translates to:
  /// **'Time Slot'**
  String get timeSlot;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// No description provided for @selectCity.
  ///
  /// In en, this message translates to:
  /// **'Select city'**
  String get selectCity;

  /// No description provided for @sending.
  ///
  /// In en, this message translates to:
  /// **'Sending…'**
  String get sending;

  /// No description provided for @sendToPool.
  ///
  /// In en, this message translates to:
  /// **'Send to Pool'**
  String get sendToPool;

  /// No description provided for @eventSent.
  ///
  /// In en, this message translates to:
  /// **'Event sent to pool.'**
  String get eventSent;

  /// No description provided for @limitReachedTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily limit reached'**
  String get limitReachedTitle;

  /// No description provided for @limitReachedMessage.
  ///
  /// In en, this message translates to:
  /// **'You can create up to 3 events today.'**
  String get limitReachedMessage;

  /// No description provided for @activeChats.
  ///
  /// In en, this message translates to:
  /// **'Active Chats'**
  String get activeChats;

  /// No description provided for @archivedChats.
  ///
  /// In en, this message translates to:
  /// **'Archived Chats'**
  String get archivedChats;

  /// No description provided for @confirmCancelTitle.
  ///
  /// In en, this message translates to:
  /// **'Do you want to cancel the event?'**
  String get confirmCancelTitle;

  /// No description provided for @confirmCancelMessage.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone.'**
  String get confirmCancelMessage;

  /// No description provided for @confirmCancelOk.
  ///
  /// In en, this message translates to:
  /// **'Yes, cancel'**
  String get confirmCancelOk;

  /// No description provided for @noEventsTitle.
  ///
  /// In en, this message translates to:
  /// **'No events yet'**
  String get noEventsTitle;

  /// No description provided for @noEventsMessage.
  ///
  /// In en, this message translates to:
  /// **'Create an event now and meet people to spend quality time together.'**
  String get noEventsMessage;

  /// No description provided for @eventButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'Event'**
  String get eventButtonLabel;

  /// No description provided for @pendingStatus.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pendingStatus;

  /// No description provided for @inboxTitle.
  ///
  /// In en, this message translates to:
  /// **'Inbox'**
  String get inboxTitle;

  /// No description provided for @inboxMarkAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get inboxMarkAllRead;

  /// No description provided for @inboxDeleteAll.
  ///
  /// In en, this message translates to:
  /// **'Delete all'**
  String get inboxDeleteAll;

  /// No description provided for @inboxEmpty.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet 💌'**
  String get inboxEmpty;

  /// No description provided for @timeNow.
  ///
  /// In en, this message translates to:
  /// **'just now'**
  String get timeNow;

  /// No description provided for @timeMinutes.
  ///
  /// In en, this message translates to:
  /// **'{count} min ago'**
  String timeMinutes(Object count);

  /// No description provided for @timeHours.
  ///
  /// In en, this message translates to:
  /// **'{count} h ago'**
  String timeHours(Object count);

  /// No description provided for @timeDays.
  ///
  /// In en, this message translates to:
  /// **'{count} days ago'**
  String timeDays(Object count);

  /// No description provided for @editProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfileTitle;

  /// No description provided for @editProfileName.
  ///
  /// In en, this message translates to:
  /// **'Name / Username'**
  String get editProfileName;

  /// No description provided for @editProfileBirthDate.
  ///
  /// In en, this message translates to:
  /// **'Birth Date'**
  String get editProfileBirthDate;

  /// No description provided for @editProfileCity.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get editProfileCity;

  /// No description provided for @editProfileInterests.
  ///
  /// In en, this message translates to:
  /// **'Interests'**
  String get editProfileInterests;

  /// No description provided for @editProfileSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get editProfileSave;

  /// No description provided for @editProfileSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get editProfileSaving;

  /// No description provided for @birthDateHelp.
  ///
  /// In en, this message translates to:
  /// **'Select Birth Date'**
  String get birthDateHelp;

  /// No description provided for @completeProfile.
  ///
  /// In en, this message translates to:
  /// **'Complete Profile'**
  String get completeProfile;

  /// No description provided for @percentSign.
  ///
  /// In en, this message translates to:
  /// **'%'**
  String get percentSign;

  /// No description provided for @stepCount.
  ///
  /// In en, this message translates to:
  /// **'Step {current} / {total}'**
  String stepCount(Object current, Object total);

  /// No description provided for @languageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageTitle;

  /// No description provided for @languageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Which language would you like to use the app in?'**
  String get languageSubtitle;

  /// No description provided for @languageSelect.
  ///
  /// In en, this message translates to:
  /// **'Select a language'**
  String get languageSelect;

  /// No description provided for @langTurkish.
  ///
  /// In en, this message translates to:
  /// **'Turkish'**
  String get langTurkish;

  /// No description provided for @langEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get langEnglish;

  /// No description provided for @errorSelectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Please select a language'**
  String get errorSelectLanguage;

  /// No description provided for @genderTitle.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get genderTitle;

  /// No description provided for @genderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'How do you identify yourself?'**
  String get genderSubtitle;

  /// No description provided for @genderSelect.
  ///
  /// In en, this message translates to:
  /// **'Select a gender'**
  String get genderSelect;

  /// No description provided for @genderFemale.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get genderFemale;

  /// No description provided for @genderMale.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get genderMale;

  /// No description provided for @genderOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get genderOther;

  /// No description provided for @errorSelectGender.
  ///
  /// In en, this message translates to:
  /// **'Please select a gender'**
  String get errorSelectGender;

  /// No description provided for @infoEditableLater.
  ///
  /// In en, this message translates to:
  /// **'You can change this information later in your profile settings.'**
  String get infoEditableLater;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @interestsTitle.
  ///
  /// In en, this message translates to:
  /// **'Interests'**
  String get interestsTitle;

  /// No description provided for @interestsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Share the passions that color your life. Select at least 5.'**
  String get interestsSubtitle;

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get clearAll;

  /// No description provided for @minInfoOk.
  ///
  /// In en, this message translates to:
  /// **'Great! You selected {count} interests.'**
  String minInfoOk(Object count);

  /// No description provided for @minInfoNotEnough.
  ///
  /// In en, this message translates to:
  /// **'Select at least 5 interests. Remaining: {remaining}'**
  String minInfoNotEnough(Object remaining);

  /// No description provided for @backButton.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get backButton;

  /// No description provided for @step3Title.
  ///
  /// In en, this message translates to:
  /// **'Location and Birth Date'**
  String get step3Title;

  /// No description provided for @step3Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Help us know you better. Your location will appear in Explore, and your age will be used for better matches.'**
  String get step3Subtitle;

  /// No description provided for @locationTitle.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get locationTitle;

  /// No description provided for @locationSelect.
  ///
  /// In en, this message translates to:
  /// **'Select City'**
  String get locationSelect;

  /// No description provided for @birthDateTitle.
  ///
  /// In en, this message translates to:
  /// **'Birth Date'**
  String get birthDateTitle;

  /// No description provided for @birthDateSelect.
  ///
  /// In en, this message translates to:
  /// **'Select Birth Date'**
  String get birthDateSelect;

  /// No description provided for @birthDateHint.
  ///
  /// In en, this message translates to:
  /// **'DD.MM.YYYY'**
  String get birthDateHint;

  /// No description provided for @formErrorCityAndDate.
  ///
  /// In en, this message translates to:
  /// **'You must select a city and birth date to continue.'**
  String get formErrorCityAndDate;

  /// No description provided for @saving.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get saving;

  /// No description provided for @step4Title.
  ///
  /// In en, this message translates to:
  /// **'Your Profile Photo'**
  String get step4Title;

  /// No description provided for @step4Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Don’t forget to smile! Your photo is very important for the first impression.'**
  String get step4Subtitle;

  /// No description provided for @photoSource.
  ///
  /// In en, this message translates to:
  /// **'Photo Source'**
  String get photoSource;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @photoSelect.
  ///
  /// In en, this message translates to:
  /// **'Select photo'**
  String get photoSelect;

  /// No description provided for @step4Hint.
  ///
  /// In en, this message translates to:
  /// **'Choose a clear, well-lit photo where your face is visible to be more recognizable.'**
  String get step4Hint;

  /// No description provided for @registrationCompleted.
  ///
  /// In en, this message translates to:
  /// **'Registration Completed!'**
  String get registrationCompleted;

  /// No description provided for @registrationCompletedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your account is ready. Start exploring with joy 🎉'**
  String get registrationCompletedSubtitle;

  /// No description provided for @startApp.
  ///
  /// In en, this message translates to:
  /// **'Start App'**
  String get startApp;

  /// No description provided for @skipForNow.
  ///
  /// In en, this message translates to:
  /// **'Skip For Now'**
  String get skipForNow;

  /// No description provided for @uploading.
  ///
  /// In en, this message translates to:
  /// **'Uploading…'**
  String get uploading;

  /// No description provided for @complete.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get complete;

  /// No description provided for @welcomeTitle1.
  ///
  /// In en, this message translates to:
  /// **'Wel'**
  String get welcomeTitle1;

  /// No description provided for @welcomeTitle2.
  ///
  /// In en, this message translates to:
  /// **'come…'**
  String get welcomeTitle2;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'\"Connect,\nchat, have fun\"'**
  String get welcomeSubtitle;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'Don’t have an account? '**
  String get noAccount;

  /// No description provided for @registerButton.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get registerButton;

  /// No description provided for @googleSignIn.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get googleSignIn;

  /// No description provided for @profileFriends.
  ///
  /// In en, this message translates to:
  /// **'Friends'**
  String get profileFriends;

  /// No description provided for @profileAge.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get profileAge;

  /// No description provided for @profileAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get profileAbout;

  /// No description provided for @profileEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get profileEmail;

  /// No description provided for @profileLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get profileLocation;

  /// No description provided for @profileNoData.
  ///
  /// In en, this message translates to:
  /// **'No profile data found'**
  String get profileNoData;

  /// No description provided for @profileOpenSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get profileOpenSettings;

  /// No description provided for @profileUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get profileUnknown;

  /// No description provided for @friendsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} people'**
  String friendsCount(Object count);

  /// No description provided for @friendsEmpty.
  ///
  /// In en, this message translates to:
  /// **'It looks like you don\'t have any friends yet.'**
  String get friendsEmpty;

  /// No description provided for @friendsFind.
  ///
  /// In en, this message translates to:
  /// **'Find Friends'**
  String get friendsFind;

  /// No description provided for @friendsSeeAll.
  ///
  /// In en, this message translates to:
  /// **'See all friends'**
  String get friendsSeeAll;

  /// No description provided for @interestsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No interests specified'**
  String get interestsEmpty;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @unknownUser.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknownUser;

  /// No description provided for @profileViewsTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile Viewers'**
  String get profileViewsTitle;

  /// No description provided for @noDataYet.
  ///
  /// In en, this message translates to:
  /// **'No data yet'**
  String get noDataYet;

  /// No description provided for @premiumSoon.
  ///
  /// In en, this message translates to:
  /// **'Premium coming soon to unlock all ✨'**
  String get premiumSoon;

  /// No description provided for @unlockAll.
  ///
  /// In en, this message translates to:
  /// **'Unlock all'**
  String get unlockAll;

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'just now'**
  String get justNow;

  /// No description provided for @minutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} min ago'**
  String minutesAgo(Object count);

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} h ago'**
  String hoursAgo(Object count);

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} day(s) ago'**
  String daysAgo(Object count);

  /// No description provided for @weeksAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} week(s) ago'**
  String weeksAgo(Object count);

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @privacySection.
  ///
  /// In en, this message translates to:
  /// **'🔒 Privacy & Visibility'**
  String get privacySection;

  /// No description provided for @appearanceSection.
  ///
  /// In en, this message translates to:
  /// **'🎨 Appearance'**
  String get appearanceSection;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logout;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @messagesFromEveryone.
  ///
  /// In en, this message translates to:
  /// **'Receive Messages from Everyone'**
  String get messagesFromEveryone;

  /// No description provided for @messagesFromEveryoneDesc.
  ///
  /// In en, this message translates to:
  /// **'If off, you can only receive messages from people you follow.'**
  String get messagesFromEveryoneDesc;

  /// No description provided for @showInSuggestions.
  ///
  /// In en, this message translates to:
  /// **'Account Suggestions'**
  String get showInSuggestions;

  /// No description provided for @showInSuggestionsDesc.
  ///
  /// In en, this message translates to:
  /// **'Your profile will appear in suggestions. Turn off if you don’t want it.'**
  String get showInSuggestionsDesc;

  /// No description provided for @followRequestsFromAll.
  ///
  /// In en, this message translates to:
  /// **'Follow Requests (From Everyone)'**
  String get followRequestsFromAll;

  /// No description provided for @followRequestsFromAllDesc.
  ///
  /// In en, this message translates to:
  /// **'If off, only people you follow can send requests.'**
  String get followRequestsFromAllDesc;

  /// No description provided for @makeAccountPrivate.
  ///
  /// In en, this message translates to:
  /// **'Make Account Private'**
  String get makeAccountPrivate;

  /// No description provided for @makeAccountPrivateDesc.
  ///
  /// In en, this message translates to:
  /// **'Turn on to make your account private.'**
  String get makeAccountPrivateDesc;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @darkModeDesc.
  ///
  /// In en, this message translates to:
  /// **'Switch app theme to night mode.'**
  String get darkModeDesc;

  /// No description provided for @deleteSurveyTitle.
  ///
  /// In en, this message translates to:
  /// **'Why do you want to delete your account?'**
  String get deleteSurveyTitle;

  /// No description provided for @deleteReason1.
  ///
  /// In en, this message translates to:
  /// **'The app did not meet my expectations'**
  String get deleteReason1;

  /// No description provided for @deleteReason2.
  ///
  /// In en, this message translates to:
  /// **'I receive too many notifications'**
  String get deleteReason2;

  /// No description provided for @deleteReason3.
  ///
  /// In en, this message translates to:
  /// **'Privacy concerns'**
  String get deleteReason3;

  /// No description provided for @deleteReason4.
  ///
  /// In en, this message translates to:
  /// **'I use another account'**
  String get deleteReason4;

  /// No description provided for @deleteSurveyNote.
  ///
  /// In en, this message translates to:
  /// **'Any notes you’d like to add?'**
  String get deleteSurveyNote;

  /// No description provided for @confirmAndDelete.
  ///
  /// In en, this message translates to:
  /// **'Confirm and Delete Account'**
  String get confirmAndDelete;

  /// No description provided for @accountNotDeleted.
  ///
  /// In en, this message translates to:
  /// **'Account could not be deleted. Please try again.'**
  String get accountNotDeleted;

  /// No description provided for @dangerZoneTitle.
  ///
  /// In en, this message translates to:
  /// **'Danger Zone'**
  String get dangerZoneTitle;

  /// No description provided for @dangerZoneDescription.
  ///
  /// In en, this message translates to:
  /// **'If you delete your account, all your data will be permanently removed. This action cannot be undone.'**
  String get dangerZoneDescription;

  /// No description provided for @deleting.
  ///
  /// In en, this message translates to:
  /// **'Deleting…'**
  String get deleting;

  /// No description provided for @deleteSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Before Deleting Account'**
  String get deleteSheetTitle;

  /// No description provided for @deleteWarning1.
  ///
  /// In en, this message translates to:
  /// **'This action is permanent and cannot be undone.'**
  String get deleteWarning1;

  /// No description provided for @deleteWarning2.
  ///
  /// In en, this message translates to:
  /// **'All your data including profile and settings will be deleted.'**
  String get deleteWarning2;

  /// No description provided for @deleteReasonOptional.
  ///
  /// In en, this message translates to:
  /// **'Why do you want to delete? (optional)'**
  String get deleteReasonOptional;

  /// No description provided for @deleteNoteLabel.
  ///
  /// In en, this message translates to:
  /// **'Any note you want to add?'**
  String get deleteNoteLabel;

  /// No description provided for @deleteNoteHint.
  ///
  /// In en, this message translates to:
  /// **'You can briefly write…'**
  String get deleteNoteHint;

  /// No description provided for @deleteConfirmText.
  ///
  /// In en, this message translates to:
  /// **'I am sure. I want to permanently delete my account.'**
  String get deleteConfirmText;

  /// No description provided for @reasonNotUsing.
  ///
  /// In en, this message translates to:
  /// **'I no longer use the app'**
  String get reasonNotUsing;

  /// No description provided for @reasonPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy/Data concerns'**
  String get reasonPrivacy;

  /// No description provided for @reasonNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications are annoying'**
  String get reasonNotifications;

  /// No description provided for @reasonTechnical.
  ///
  /// In en, this message translates to:
  /// **'I had technical issues'**
  String get reasonTechnical;

  /// No description provided for @reasonOtherApp.
  ///
  /// In en, this message translates to:
  /// **'I switched to another app'**
  String get reasonOtherApp;

  /// No description provided for @reasonOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get reasonOther;

  /// No description provided for @splashSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Amazing people are waiting for you!'**
  String get splashSubtitle;

  /// No description provided for @interestYoga.
  ///
  /// In en, this message translates to:
  /// **'Yoga'**
  String get interestYoga;

  /// No description provided for @interestRunning.
  ///
  /// In en, this message translates to:
  /// **'Running'**
  String get interestRunning;

  /// No description provided for @interestSwimming.
  ///
  /// In en, this message translates to:
  /// **'Swimming'**
  String get interestSwimming;

  /// No description provided for @interestBasketball.
  ///
  /// In en, this message translates to:
  /// **'Basketball'**
  String get interestBasketball;

  /// No description provided for @interestFootball.
  ///
  /// In en, this message translates to:
  /// **'Football'**
  String get interestFootball;

  /// No description provided for @interestTennis.
  ///
  /// In en, this message translates to:
  /// **'Tennis'**
  String get interestTennis;

  /// No description provided for @interestCycling.
  ///
  /// In en, this message translates to:
  /// **'Cycling'**
  String get interestCycling;

  /// No description provided for @interestClimbing.
  ///
  /// In en, this message translates to:
  /// **'Rock Climbing'**
  String get interestClimbing;

  /// No description provided for @interestHiking.
  ///
  /// In en, this message translates to:
  /// **'Hiking'**
  String get interestHiking;

  /// No description provided for @interestGym.
  ///
  /// In en, this message translates to:
  /// **'Gym & Fitness'**
  String get interestGym;

  /// No description provided for @interestMartialArts.
  ///
  /// In en, this message translates to:
  /// **'Martial Arts'**
  String get interestMartialArts;

  /// No description provided for @interestGolf.
  ///
  /// In en, this message translates to:
  /// **'Golf'**
  String get interestGolf;

  /// No description provided for @interestVolleyball.
  ///
  /// In en, this message translates to:
  /// **'Volleyball'**
  String get interestVolleyball;

  /// No description provided for @interestSkiing.
  ///
  /// In en, this message translates to:
  /// **'Skiing'**
  String get interestSkiing;

  /// No description provided for @interestSurfing.
  ///
  /// In en, this message translates to:
  /// **'Surfing'**
  String get interestSurfing;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @testNotificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Test Notification'**
  String get testNotificationTitle;

  /// No description provided for @testNotificationBody.
  ///
  /// In en, this message translates to:
  /// **'This is a local fallback'**
  String get testNotificationBody;

  /// No description provided for @countryName.
  ///
  /// In en, this message translates to:
  /// **'Turkey'**
  String get countryName;

  /// No description provided for @verifyEmailTitle.
  ///
  /// In en, this message translates to:
  /// **'Verification Email Sent'**
  String get verifyEmailTitle;

  /// No description provided for @verifyEmailMessage.
  ///
  /// In en, this message translates to:
  /// **'Please check your inbox and verify your account.'**
  String get verifyEmailMessage;

  /// No description provided for @verifyEmailResent.
  ///
  /// In en, this message translates to:
  /// **'Verification email has been resent.'**
  String get verifyEmailResent;

  /// No description provided for @btnCheckVerification.
  ///
  /// In en, this message translates to:
  /// **'Check Verification'**
  String get btnCheckVerification;

  /// No description provided for @btnResendEmail.
  ///
  /// In en, this message translates to:
  /// **'Resend Email'**
  String get btnResendEmail;

  /// No description provided for @verifyEmailNotYet.
  ///
  /// In en, this message translates to:
  /// **'Your account has not been verified yet.'**
  String get verifyEmailNotYet;
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
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
