// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get errorEmptyEmail => 'Please enter your email address.';

  @override
  String get errorInvalidEmail => 'Enter a valid email address.';

  @override
  String get errorMissingInfoTitle => 'Missing / Invalid Info';

  @override
  String get errorMissingInfoMessage =>
      'Please check the email field and try again.';

  @override
  String get successSentTitle => 'Sent';

  @override
  String successSentMessage(Object email) {
    return 'A password reset link has been sent to $email. Check your inbox and spam folder.';
  }

  @override
  String get errorNetwork => 'Network error. Check your internet connection.';

  @override
  String get errorTooManyRequests =>
      'Too many attempts. Please try again later.';

  @override
  String get errorUserDisabled => 'This account has been disabled.';

  @override
  String get errorGeneric =>
      'The request could not be processed. Please try again later or use another email.';

  @override
  String get errorGeneric2 =>
      'The request could not be processed. Please try again.';

  @override
  String get infoTitle => 'Info';

  @override
  String get back => 'Back';

  @override
  String get forgotPasswordTitle => 'Forgot Password';

  @override
  String get forgotPasswordSubtitle =>
      'We will send a verification link to your email.';

  @override
  String get universityEmailLabel => 'University Email Address';

  @override
  String get universityEmailHint => 'example@samsun.edu.tr';

  @override
  String get forgotPasswordNote =>
      'Check your inbox and spam folder. On corporate emails it may fall into quarantine.';

  @override
  String get sendVerificationButton => 'Send Verification Link';

  @override
  String get help => 'Help';

  @override
  String get helpMessage =>
      'If you didn\'t receive the email, check your spam folder or try again after a few minutes.';

  @override
  String get emailNotReceived => 'Didn\'t receive the email?';

  @override
  String get loginTitleLine1 => 'To Continue';

  @override
  String get loginTitleLine2 => 'Please Sign In.';

  @override
  String get emailLabel => 'Email Address';

  @override
  String get emailHint => 'university@example.edu.tr';

  @override
  String get emailRequired => 'Email is required';

  @override
  String get emailInvalid => 'Enter a valid email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get passwordHint => '••••••••';

  @override
  String get passwordRequired => 'Password is required';

  @override
  String get passwordMinLength => 'At least 6 characters';

  @override
  String get forgotPassword => 'Forgot Password';

  @override
  String get loginButton => 'Login';

  @override
  String get loginErrorTitle => 'Login Failed';

  @override
  String get loginInfoTitle => 'Missing Info';

  @override
  String get loginInfoMessage =>
      'Please fill in your email and password properly.';

  @override
  String get loginErrorWrongCredentials => 'Incorrect email or password.';

  @override
  String get loginErrorNotFound => 'No user found with this email.';

  @override
  String get loginErrorTooMany => 'Too many attempts. Try again later.';

  @override
  String get loginErrorNetwork => 'Network error. Check your connection.';

  @override
  String get loginErrorInvalidEmail => 'Invalid email address.';

  @override
  String loginErrorUnexpected(Object error) {
    return 'Unexpected error occurred: $error';
  }

  @override
  String get ok => 'OK';

  @override
  String get commonBack => 'Back';

  @override
  String get registerTitle => 'Create Account';

  @override
  String get registerSubtitle => 'Sign up now and start chatting';

  @override
  String get nameLabel => 'Full Name';

  @override
  String get nameHint => 'Enter your name';

  @override
  String get btnRegister => 'Register';

  @override
  String get dialogInfoTitle => 'Missing / Invalid Info';

  @override
  String get dialogErrorTitle => 'Registration Failed';

  @override
  String get infoFillForm => 'Please fill all fields correctly.';

  @override
  String get errorEmailDomain => 'Please enter a valid @metu.edu.tr address';

  @override
  String passwordMinChars(Object count) {
    return 'At least $count characters';
  }

  @override
  String get strengthWeak => 'Weak';

  @override
  String get strengthMedium => 'Medium';

  @override
  String get strengthGood => 'Good';

  @override
  String get strengthStrong => 'Strong';

  @override
  String get activeChatsTitle => 'Active Chats';

  @override
  String get noActiveChatsMessage => 'You have no active chats at the moment.';

  @override
  String get archivedChatsTitle => 'Archived Chats';

  @override
  String get noArchivedChatsMessage => 'You don’t have any archived chats yet.';

  @override
  String get friendsListTitle => 'Friends List';

  @override
  String get sortAZ => 'A → Z';

  @override
  String get sortZA => 'Z → A';

  @override
  String get friendRemovedMessage => 'Friend removed from the list.';

  @override
  String get searchFriendsHint => 'Search by name, email or location';

  @override
  String get defaultUserName => 'User';

  @override
  String friendCountLabel(Object count) {
    return '$count friends';
  }

  @override
  String get noFriendsTitle => 'No friends yet.';

  @override
  String get noFriendsSubtitle =>
      'Find users from the search bar and add them as friends.';

  @override
  String get searchHint => 'Search';

  @override
  String get clear => 'Clear';

  @override
  String get profileLoadFailed => 'Profile data could not be loaded.';

  @override
  String get genericError => 'An error occurred. Please try again.';

  @override
  String get unfriendConfirmTitle => 'Remove Friend?';

  @override
  String unfriendConfirmMessage(Object name) {
    return '\"$name\" will be removed from your friends list.';
  }

  @override
  String get unfriendConfirmYes => 'Yes, remove';

  @override
  String get unfriendSuccessTitle => 'Friendship Removed 💔';

  @override
  String get unfriendSuccessMessage =>
      'This person has been removed from your friends list.';

  @override
  String get userDefault => 'User';

  @override
  String get unknown => 'Unknown';

  @override
  String get friendsSection => 'Friends';

  @override
  String get interestsSection => 'Interests';

  @override
  String get noInterests => 'No interests specified';

  @override
  String get unfriendButton => 'Remove Friend';

  @override
  String get sendMessage => 'Send Message';

  @override
  String get cancel => 'Cancel';

  @override
  String get errorTitle => 'Error';

  @override
  String get friendsFetchError =>
      'There was a problem fetching data. Please try again.';

  @override
  String get friendAcceptedTitle => 'Friend Added';

  @override
  String get friendAcceptedMessage => 'The request has been accepted.';

  @override
  String get friendAcceptError => 'The request could not be accepted.';

  @override
  String get friendRejectedTitle => 'Rejected';

  @override
  String get friendRejectedMessage => 'The request has been rejected.';

  @override
  String get friendRejectError => 'The request could not be rejected.';

  @override
  String get friendsSummary => 'Friends';

  @override
  String get requestsSummary => 'Requests';

  @override
  String get friendRequestsTitle => 'Friend Requests';

  @override
  String get noFriendRequests => 'You have no pending requests.';

  @override
  String pendingRequests(Object count) {
    return '$count pending';
  }

  @override
  String get accept => 'Accept';

  @override
  String get reject => 'Reject';

  @override
  String get noFriends => 'You don’t seem to have any friends yet.';

  @override
  String get findFriends => 'Find Friends';

  @override
  String get friendsTitle => 'Friends';

  @override
  String get manageConnections => 'Manage your connections';

  @override
  String get addFriendButton => 'Add Friend';

  @override
  String get searchError => 'An error occurred while searching.';

  @override
  String get selfRequestTitle => 'Not Allowed 🙂';

  @override
  String get selfRequestMessage =>
      'You cannot send a friend request to yourself.';

  @override
  String get requestSentTitle => 'Request Sent';

  @override
  String requestSentMessage(Object name) {
    return 'A friend request was sent to $name.';
  }

  @override
  String get requestFailedTitle => 'Failed';

  @override
  String get requestFailedMessage =>
      'There was a problem sending the request. Please try again.';

  @override
  String get searchUsersTitle => 'Search Users';

  @override
  String get searchButton => 'Search';

  @override
  String get thisIsYou => 'This is you';

  @override
  String get add => 'Add';

  @override
  String get alreadyFriend => 'Already friends';

  @override
  String get pending => 'Pending';

  @override
  String get close => 'Close';

  @override
  String get noResults => 'No results found';

  @override
  String get eventCancelled => 'Event cancelled.';

  @override
  String get cancelFailed => 'Could not cancel';

  @override
  String get error => 'Error';

  @override
  String get sendFailed => 'Send failed';

  @override
  String get createEvent => 'Create Event';

  @override
  String get eventType => 'Event Type';

  @override
  String get eventTypeCoffee => 'Coffee';

  @override
  String get eventTypeMeal => 'Meal';

  @override
  String get eventTypeChat => 'Chat';

  @override
  String get eventTypeStudy => 'Study';

  @override
  String get eventTypeSport => 'Sport';

  @override
  String get eventTypeCinema => 'Cinema';

  @override
  String get select => 'Select';

  @override
  String get dateWeekendOnly => 'Date (only Saturday & Sunday)';

  @override
  String get selectDate => 'Select Date';

  @override
  String get selectDateShort => 'Select date';

  @override
  String get timeSlot => 'Time Slot';

  @override
  String get city => 'City';

  @override
  String get selectCity => 'Select city';

  @override
  String get sending => 'Sending…';

  @override
  String get sendToPool => 'Send to Pool';

  @override
  String get eventSent => 'Event sent to pool.';

  @override
  String get limitReachedTitle => 'Daily limit reached';

  @override
  String get limitReachedMessage => 'You can create up to 3 events today.';

  @override
  String get activeChats => 'Active Chats';

  @override
  String get archivedChats => 'Archived Chats';

  @override
  String get confirmCancelTitle => 'Do you want to cancel the event?';

  @override
  String get confirmCancelMessage => 'This action cannot be undone.';

  @override
  String get confirmCancelOk => 'Yes, cancel';

  @override
  String get noEventsTitle => 'No events yet';

  @override
  String get noEventsMessage =>
      'Create an event now and meet people to spend quality time together.';

  @override
  String get eventButtonLabel => 'Event';

  @override
  String get pendingStatus => 'Pending';

  @override
  String get inboxTitle => 'Inbox';

  @override
  String get inboxMarkAllRead => 'Mark all as read';

  @override
  String get inboxDeleteAll => 'Delete all';

  @override
  String get inboxEmpty => 'No notifications yet 💌';

  @override
  String get timeNow => 'just now';

  @override
  String timeMinutes(Object count) {
    return '$count min ago';
  }

  @override
  String timeHours(Object count) {
    return '$count h ago';
  }

  @override
  String timeDays(Object count) {
    return '$count days ago';
  }

  @override
  String get editProfileTitle => 'Edit Profile';

  @override
  String get editProfileName => 'Name / Username';

  @override
  String get editProfileBirthDate => 'Birth Date';

  @override
  String get editProfileCity => 'City';

  @override
  String get editProfileInterests => 'Interests';

  @override
  String get editProfileSave => 'Save';

  @override
  String get editProfileSaving => 'Saving…';

  @override
  String get birthDateHelp => 'Select Birth Date';

  @override
  String get completeProfile => 'Complete Profile';

  @override
  String get percentSign => '%';

  @override
  String stepCount(Object current, Object total) {
    return 'Step $current / $total';
  }

  @override
  String get languageTitle => 'Language';

  @override
  String get languageSubtitle =>
      'Which language would you like to use the app in?';

  @override
  String get languageSelect => 'Select a language';

  @override
  String get langTurkish => 'Turkish';

  @override
  String get langEnglish => 'English';

  @override
  String get errorSelectLanguage => 'Please select a language';

  @override
  String get genderTitle => 'Gender';

  @override
  String get genderSubtitle => 'How do you identify yourself?';

  @override
  String get genderSelect => 'Select a gender';

  @override
  String get genderFemale => 'Female';

  @override
  String get genderMale => 'Male';

  @override
  String get genderOther => 'Other';

  @override
  String get errorSelectGender => 'Please select a gender';

  @override
  String get infoEditableLater =>
      'You can change this information later in your profile settings.';

  @override
  String get continueButton => 'Continue';

  @override
  String get interestsTitle => 'Interests';

  @override
  String get interestsSubtitle =>
      'Share the passions that color your life. Select at least 5.';

  @override
  String get clearAll => 'Clear all';

  @override
  String minInfoOk(Object count) {
    return 'Great! You selected $count interests.';
  }

  @override
  String minInfoNotEnough(Object remaining) {
    return 'Select at least 5 interests. Remaining: $remaining';
  }

  @override
  String get backButton => 'Back';

  @override
  String get step3Title => 'Location and Birth Date';

  @override
  String get step3Subtitle =>
      'Help us know you better. Your location will appear in Explore, and your age will be used for better matches.';

  @override
  String get locationTitle => 'Location';

  @override
  String get locationSelect => 'Select City';

  @override
  String get birthDateTitle => 'Birth Date';

  @override
  String get birthDateSelect => 'Select Birth Date';

  @override
  String get birthDateHint => 'DD.MM.YYYY';

  @override
  String get formErrorCityAndDate =>
      'You must select a city and birth date to continue.';

  @override
  String get saving => 'Saving…';

  @override
  String get step4Title => 'Your Profile Photo';

  @override
  String get step4Subtitle =>
      'Don’t forget to smile! Your photo is very important for the first impression.';

  @override
  String get photoSource => 'Photo Source';

  @override
  String get gallery => 'Gallery';

  @override
  String get camera => 'Camera';

  @override
  String get photoSelect => 'Select photo';

  @override
  String get step4Hint =>
      'Choose a clear, well-lit photo where your face is visible to be more recognizable.';

  @override
  String get registrationCompleted => 'Registration Completed!';

  @override
  String get registrationCompletedSubtitle =>
      'Your account is ready. Start exploring with joy 🎉';

  @override
  String get startApp => 'Start App';

  @override
  String get skipForNow => 'Skip For Now';

  @override
  String get uploading => 'Uploading…';

  @override
  String get complete => 'Finish';

  @override
  String get welcomeTitle1 => 'Wel';

  @override
  String get welcomeTitle2 => 'come…';

  @override
  String get welcomeSubtitle => '\"Connect,\nchat, have fun\"';

  @override
  String get noAccount => 'Don’t have an account? ';

  @override
  String get registerButton => 'Sign Up';

  @override
  String get googleSignIn => 'Continue with Google';

  @override
  String get profileFriends => 'Friends';

  @override
  String get profileAge => 'Age';

  @override
  String get profileAbout => 'About';

  @override
  String get profileEmail => 'Email';

  @override
  String get profileLocation => 'Location';

  @override
  String get profileNoData => 'No profile data found';

  @override
  String get profileOpenSettings => 'Open Settings';

  @override
  String get profileUnknown => 'Unknown';

  @override
  String friendsCount(Object count) {
    return '$count people';
  }

  @override
  String get friendsEmpty => 'It looks like you don\'t have any friends yet.';

  @override
  String get friendsFind => 'Find Friends';

  @override
  String get friendsSeeAll => 'See all friends';

  @override
  String get interestsEmpty => 'No interests specified';

  @override
  String get settings => 'Settings';

  @override
  String get unknownUser => 'Unknown';

  @override
  String get profileViewsTitle => 'Profile Viewers';

  @override
  String get noDataYet => 'No data yet';

  @override
  String get premiumSoon => 'Premium coming soon to unlock all ✨';

  @override
  String get unlockAll => 'Unlock all';

  @override
  String get justNow => 'just now';

  @override
  String minutesAgo(Object count) {
    return '$count min ago';
  }

  @override
  String hoursAgo(Object count) {
    return '$count h ago';
  }

  @override
  String daysAgo(Object count) {
    return '$count day(s) ago';
  }

  @override
  String weeksAgo(Object count) {
    return '$count week(s) ago';
  }

  @override
  String get settingsTitle => 'Settings';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get privacySection => '🔒 Privacy & Visibility';

  @override
  String get appearanceSection => '🎨 Appearance';

  @override
  String get logout => 'Log Out';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get messagesFromEveryone => 'Receive Messages from Everyone';

  @override
  String get messagesFromEveryoneDesc =>
      'If off, you can only receive messages from people you follow.';

  @override
  String get showInSuggestions => 'Account Suggestions';

  @override
  String get showInSuggestionsDesc =>
      'Your profile will appear in suggestions. Turn off if you don’t want it.';

  @override
  String get followRequestsFromAll => 'Follow Requests (From Everyone)';

  @override
  String get followRequestsFromAllDesc =>
      'If off, only people you follow can send requests.';

  @override
  String get makeAccountPrivate => 'Make Account Private';

  @override
  String get makeAccountPrivateDesc => 'Turn on to make your account private.';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get darkModeDesc => 'Switch app theme to night mode.';

  @override
  String get deleteSurveyTitle => 'Why do you want to delete your account?';

  @override
  String get deleteReason1 => 'The app did not meet my expectations';

  @override
  String get deleteReason2 => 'I receive too many notifications';

  @override
  String get deleteReason3 => 'Privacy concerns';

  @override
  String get deleteReason4 => 'I use another account';

  @override
  String get deleteSurveyNote => 'Any notes you’d like to add?';

  @override
  String get confirmAndDelete => 'Confirm and Delete Account';

  @override
  String get accountNotDeleted =>
      'Account could not be deleted. Please try again.';

  @override
  String get dangerZoneTitle => 'Danger Zone';

  @override
  String get dangerZoneDescription =>
      'If you delete your account, all your data will be permanently removed. This action cannot be undone.';

  @override
  String get deleting => 'Deleting…';

  @override
  String get deleteSheetTitle => 'Before Deleting Account';

  @override
  String get deleteWarning1 => 'This action is permanent and cannot be undone.';

  @override
  String get deleteWarning2 =>
      'All your data including profile and settings will be deleted.';

  @override
  String get deleteReasonOptional => 'Why do you want to delete? (optional)';

  @override
  String get deleteNoteLabel => 'Any note you want to add?';

  @override
  String get deleteNoteHint => 'You can briefly write…';

  @override
  String get deleteConfirmText =>
      'I am sure. I want to permanently delete my account.';

  @override
  String get reasonNotUsing => 'I no longer use the app';

  @override
  String get reasonPrivacy => 'Privacy/Data concerns';

  @override
  String get reasonNotifications => 'Notifications are annoying';

  @override
  String get reasonTechnical => 'I had technical issues';

  @override
  String get reasonOtherApp => 'I switched to another app';

  @override
  String get reasonOther => 'Other';

  @override
  String get splashSubtitle => 'Amazing people are waiting for you!';

  @override
  String get interestYoga => 'Yoga';

  @override
  String get interestRunning => 'Running';

  @override
  String get interestSwimming => 'Swimming';

  @override
  String get interestBasketball => 'Basketball';

  @override
  String get interestFootball => 'Football';

  @override
  String get interestTennis => 'Tennis';

  @override
  String get interestCycling => 'Cycling';

  @override
  String get interestClimbing => 'Rock Climbing';

  @override
  String get interestHiking => 'Hiking';

  @override
  String get interestGym => 'Gym & Fitness';

  @override
  String get interestMartialArts => 'Martial Arts';

  @override
  String get interestGolf => 'Golf';

  @override
  String get interestVolleyball => 'Volleyball';

  @override
  String get interestSkiing => 'Skiing';

  @override
  String get interestSurfing => 'Surfing';

  @override
  String get confirm => 'Confirm';

  @override
  String get testNotificationTitle => 'Test Notification';

  @override
  String get testNotificationBody => 'This is a local fallback';

  @override
  String get countryName => 'Turkey';
}
