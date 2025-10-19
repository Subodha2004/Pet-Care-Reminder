// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Pet Care Reminder';

  @override
  String get homeScreenTitle => 'Pet Care Reminder';

  @override
  String get addReminder => 'Add Reminder';

  @override
  String get searchReminders => 'Search your reminders...';

  @override
  String get noRemindersYet => 'No reminders yet';

  @override
  String get tapToAddFirstReminder =>
      'Tap the + button to add your first reminder';

  @override
  String get keepPetHappy => 'Keep your pet happy and healthy!';

  @override
  String get upcomingReminders => 'Upcoming Reminders';

  @override
  String get settings => 'Settings';

  @override
  String get theme => 'Theme';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get system => 'System';

  @override
  String get textSize => 'Text Size';

  @override
  String get small => 'Small';

  @override
  String get medium => 'Medium';

  @override
  String get large => 'Large';

  @override
  String get extraLarge => 'Extra Large';

  @override
  String get highContrast => 'High Contrast Mode';

  @override
  String get voiceCommands => 'Voice Commands';

  @override
  String get hapticFeedback => 'Haptic Feedback';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get spanish => 'Spanish';

  @override
  String get logout => 'Logout';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get areYouSureLogout => 'Are you sure you want to logout?';

  @override
  String get snooze => 'Snooze';

  @override
  String get snoozeReminder => 'Snooze Reminder';

  @override
  String get minutes => 'minutes';

  @override
  String get hours => 'hours';

  @override
  String get days => 'days';

  @override
  String get smartSuggestions => 'Smart Suggestions';

  @override
  String get gamification => 'Gamification';

  @override
  String get activityHistory => 'Activity History';

  @override
  String get viewPets => 'View Pets';

  @override
  String get quickAdd => 'Quick Add';

  @override
  String get all => 'All';

  @override
  String get save => 'Save';

  @override
  String get title => 'Title';

  @override
  String get description => 'Description';

  @override
  String get date => 'Date';

  @override
  String get time => 'Time';

  @override
  String get category => 'Category';

  @override
  String get recurrence => 'Recurrence';

  @override
  String get none => 'None';

  @override
  String get daily => 'Daily';

  @override
  String get weekly => 'Weekly';

  @override
  String get monthly => 'Monthly';

  @override
  String get yearly => 'Yearly';

  @override
  String get pets => 'Pets';

  @override
  String get health => 'Health';

  @override
  String get feeding => 'Feeding';

  @override
  String get grooming => 'Grooming';

  @override
  String get exercise => 'Exercise';

  @override
  String get medical => 'Medical';

  @override
  String get other => 'Other';

  @override
  String get voiceCommandButton => 'Voice Command';

  @override
  String get listening => 'Listening...';

  @override
  String get didNotUnderstand =>
      'Sorry, I didn\'t understand that. Please try again.';

  @override
  String addReminderVoice(Object time, Object title) {
    return 'Add a reminder for $time about $title';
  }

  @override
  String get accessibility => 'Accessibility';

  @override
  String get screenReaderSupport => 'Screen Reader Support';

  @override
  String get adjustableTextSizes => 'Adjustable Text Sizes';

  @override
  String get rightToLeftSupport => 'Right-to-Left Language Support';
}
