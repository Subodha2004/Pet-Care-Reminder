# 🔄 Recurring Reminders & Smart Scheduling Guide

## Overview

The Pet Care Reminder app now features a comprehensive recurring reminder system with smart scheduling capabilities. This upgrade transforms the app from a simple one-time reminder tool into a powerful pet care management system.

---

## ✨ New Features

### 1. **Recurring Reminder Patterns**

#### **Daily Reminders**
- Perfect for regular activities like feeding, medication, or walks
- Repeats every day at the specified time
- Example: "Feed Buddy at 8:00 AM every day"

#### **Weekly Reminders**
- Choose specific days of the week
- Great for grooming, vet visits, or special activities
- Multiple weekday selection support
- Example: "Walk Max every Monday, Wednesday, and Friday at 6:00 PM"

#### **Monthly Reminders**
- Set reminders for specific day of the month
- Ideal for monthly check-ups, flea treatments, or nail trimming
- Automatically handles months with different day counts
- Example: "Vet check-up on the 15th of every month"

#### **Custom Intervals**
- Create your own recurring pattern
- Choose any interval: every X days, weeks, or months
- Maximum flexibility for unique pet care routines
- Examples:
  - "Every 3 days" for specific medication schedules
  - "Every 2 weeks" for grooming appointments
  - "Every 2 months" for special treatments

---

### 2. **Smart Scheduling**

#### **Start Date**
- Schedule reminders to begin on a specific future date
- Useful for puppy/kitten care schedules that change over time
- Optional - defaults to starting immediately

#### **End Date**
- Set an expiration date for temporary reminders
- Perfect for medication courses or temporary care routines
- Optional - reminders continue indefinitely if not set

#### **Next Scheduled Calculation**
- Automatic calculation of the next occurrence
- Displays upcoming reminder time in the card
- Updates automatically after each trigger

#### **Last Triggered Tracking**
- System tracks when reminders were last completed
- Helps maintain accurate scheduling
- Prevents duplicate notifications

---

### 3. **Snooze Functionality**

#### **Flexible Snooze Durations**
- **5 minutes** - Quick delay for immediate tasks
- **15 minutes** - Short postponement
- **30 minutes** - Half-hour delay
- **1 hour** - Standard snooze
- **2 hours** - Extended delay
- **1 day** - Postpone to tomorrow

#### **Snooze Counter**
- Tracks how many times a reminder has been snoozed
- Helps identify reminders that may need rescheduling
- Visual indicator on snoozed reminders

#### **Snooze Management**
- Easy to clear snooze status
- Snoozed reminders show orange badge
- Snooze automatically clears when reminder triggers

---

### 4. **Pet Integration**

#### **Link to Specific Pets**
- Associate reminders with individual pets
- Filter reminders by pet (coming soon)
- Helps manage multiple pets' care routines

#### **Auto-Adjust for Pet Age**
- **Smart frequency adjustments** based on pet's age
- Puppies/kittens may need more frequent feeding
- Adult pets transition to standard schedules
- Senior pets may need different care frequencies
- Future enhancement: Automatic schedule adaptation

---

## 📱 How to Use

### Creating a Recurring Reminder

1. **Tap the "Add Reminder" button** (floating action button with gradient)

2. **Fill in Basic Information**
   - **Title**: Give your reminder a descriptive name (e.g., "Feed Buddy", "Walk Max")
   - **Description**: Add optional details about the task
   - **Link to Pet**: Optionally select which pet this reminder is for

3. **Set the Time**
   - Tap the time selector
   - Choose when the reminder should trigger

4. **Choose Recurrence Pattern**
   - **One-time**: For single-occurrence reminders
   - **Daily**: Repeats every day
   - **Weekly**: Choose specific weekdays
   - **Monthly**: Select day of month
   - **Custom**: Set your own interval

5. **Configure Pattern-Specific Options**

   **For Weekly:**
   - Select one or more weekdays
   - Example: Mon, Wed, Fri for regular activities

   **For Monthly:**
   - Enter day of month (1-31)
   - System handles months with fewer days automatically

   **For Custom:**
   - Enter interval value (e.g., "3")
   - Choose unit: Days, Weeks, or Months

6. **Advanced Options (Optional)**
   - **Start Date**: When to begin the recurring schedule
   - **End Date**: When to stop recurring
   - **Auto-adjust for age**: Enable smart adjustments based on pet age

7. **Save the Reminder**
   - Tap the checkmark icon
   - Reminder is created with calculated next occurrence

---

### Managing Existing Reminders

#### **Snooze a Reminder**
1. Tap the **"Snooze" button** on any reminder card
2. Select duration from the bottom sheet
3. Reminder will be delayed and show orange "Snoozed" badge

#### **View Recurrence Information**
- Recurrence pattern displayed under the time
- Icon: 🔄 with description (e.g., "Every day", "Every Mon, Wed, Fri")
- Next scheduled time calculated automatically

#### **Delete a Reminder**
1. Tap the **"Delete" button**
2. Confirm deletion in the dialog
3. Reminder removed permanently

---

## 🏗️ Technical Architecture

### Database Schema

The new reminder system uses an enhanced database table with these fields:

```sql
CREATE TABLE reminders (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL,
  description TEXT,
  time TEXT NOT NULL,
  isActive INTEGER DEFAULT 1,
  petId INTEGER,
  recurrencePattern INTEGER DEFAULT 0,
  customIntervalValue INTEGER,
  customIntervalUnit INTEGER,
  weekdays TEXT,
  dayOfMonth INTEGER,
  startDate TEXT,
  endDate TEXT,
  lastTriggered TEXT,
  nextScheduled TEXT,
  snoozedUntil TEXT,
  snoozeCount INTEGER DEFAULT 0,
  autoAdjustForAge INTEGER DEFAULT 0,
  ageAdjustmentRule TEXT
)
```

### Models

#### **Reminder Model** (`lib/models/reminder.dart`)
- Comprehensive reminder representation
- Built-in recurrence logic
- Next occurrence calculation
- Snooze management
- Pet age adjustment support

#### **Enums**
- `RecurrencePattern`: none, daily, weekly, monthly, custom
- `IntervalUnit`: days, weeks, months

### Database Helper

**ReminderDBHelper** (`lib/database/reminder_db_helper.dart`)
- CRUD operations for reminders
- Snooze functionality
- Trigger tracking
- Search capabilities
- Batch scheduling updates

### UI Components

**AddEditReminderScreen** (`lib/screens/add_edit_reminder_screen.dart`)
- Modern, intuitive interface
- Pattern-specific configuration
- Pet selection
- Date pickers
- Validation

---

## 🎨 UI Enhancements

### Reminder Cards Show:
- ✅ **Recurrence icon and description** - Easily see the pattern
- ⏰ **Next scheduled time** - Know when it's coming up
- 😴 **Snooze status** - Visual indicator for snoozed reminders
- 🟢 **Active/inactive badge** - Quick status check
- 🐾 **Smart icons** - Context-aware icons based on reminder type

### Action Buttons:
- **Snooze** - Orange button for postponing
- **Notify** - Primary color for setting notifications
- **Delete** - Red button for removal

---

## 💡 Use Cases & Examples

### Example 1: Daily Feeding Schedule
```
Title: "Feed Buddy - Morning"
Time: 8:00 AM
Recurrence: Daily
Description: "Dry food, 1 cup"
```

### Example 2: Weekly Grooming
```
Title: "Brush Max's Fur"
Time: 7:00 PM
Recurrence: Weekly (Mon, Thu)
Description: "Full body brushing session"
```

### Example 3: Monthly Vet Visit
```
Title: "Vet Check-up"
Time: 10:00 AM
Recurrence: Monthly (Day 15)
Pet: Link to your pet
Description: "Regular health check-up"
```

### Example 4: Medication Course
```
Title: "Antibiotic Dose"
Time: 9:00 AM, 9:00 PM
Recurrence: Custom (Every 12 hours)
Start Date: Today
End Date: 7 days from now
Description: "Complete full course"
```

### Example 5: Puppy Feeding Schedule
```
Title: "Feed Luna - Breakfast"
Time: 7:00 AM
Recurrence: Daily
Pet: Luna (2 months old)
Auto-adjust for age: ON
Description: "Will adjust frequency as Luna grows"
```

---

## 🔮 Future Enhancements

### Planned Features:
1. **Notification Integration**
   - Push notifications at scheduled times
   - Notification history
   - Custom notification sounds

2. **Smart Recommendations**
   - AI-suggested care routines based on pet type and age
   - Seasonal reminder adjustments
   - Health trend analysis

3. **Multi-Pet Management**
   - Filter view by pet
   - Group reminders for multiple pets
   - Pet-specific dashboards

4. **Calendar View**
   - Monthly calendar with all reminders
   - Week view for planning
   - Export to external calendars

5. **Reminder Templates**
   - Pre-configured reminder sets for common scenarios
   - Import/export reminder configurations
   - Share templates with other users

6. **Analytics & Insights**
   - Completion rate tracking
   - Most snoozed reminders
   - Care routine consistency scores

---

## 🐛 Troubleshooting

### Reminder not showing up?
- Check if the reminder is active (green badge)
- Verify the next scheduled time
- Ensure start date hasn't been set to future

### Snooze not working?
- Web version has limited snooze support
- Make sure you're on mobile platform
- Check that reminder isn't already snoozed

### Recurrence pattern not calculating correctly?
- For monthly reminders on day 29-31, system uses last day of month when applicable
- Weekly patterns require at least one weekday selected
- Custom intervals must be positive numbers

---

## 📝 Best Practices

1. **Use Descriptive Titles**
   - Include pet name and activity
   - Makes searching easier

2. **Set Appropriate Recurrence**
   - Daily for routine care
   - Weekly for regular activities
   - Custom for medication schedules

3. **Link to Pets**
   - Better organization
   - Enables future pet-specific features
   - Allows age-based adjustments

4. **Use Snooze Wisely**
   - Don't rely on snooze for regular rescheduling
   - If frequently snoozed, consider changing the time

5. **Review Regularly**
   - Update reminders as pet ages
   - Remove completed medication courses
   - Adjust frequencies as needed

---

## 🎯 Benefits

### For Pet Owners:
- ✅ **Never forget important care tasks**
- ✅ **Reduce manual reminder creation**
- ✅ **Maintain consistent care routines**
- ✅ **Manage multiple pets effectively**
- ✅ **Adapt to changing pet needs**

### For Pet Health:
- ✅ **Consistent feeding schedules**
- ✅ **Regular medication compliance**
- ✅ **Timely vet appointments**
- ✅ **Proper grooming maintenance**
- ✅ **Age-appropriate care adjustments**

---

## 🚀 Getting Started

1. Open the Pet Care Reminder app
2. Tap the **"Add Reminder"** button
3. Create your first recurring reminder
4. Watch it appear in your list with recurrence info
5. Try snoozing it to see the feature in action
6. Enjoy automated pet care management!

---

## 📞 Support

For questions, issues, or feature requests:
- Check the in-app help section
- Review this guide
- Contact support team

---

**Happy Pet Care! 🐾**

*Version 2.0 - Recurring Reminders Update*
*Last Updated: October 2025*
