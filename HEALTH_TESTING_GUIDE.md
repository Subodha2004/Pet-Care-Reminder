# Pet Health & Medical Records - Testing Guide

## 🧪 Quick Testing Instructions

### Prerequisites
1. Ensure all dependencies are installed:
   ```bash
   flutter pub get
   ```

2. Run the application:
   ```bash
   flutter run
   ```

## 📱 Testing Flow

### Step 1: Access Health Dashboard
1. Launch the app
2. Navigate to an existing pet's profile (or create a new pet)
3. Look for the blue **"Health & Medical Records"** card
4. Tap the card to open the Pet Health Dashboard

### Step 2: Test Vaccinations Tab
1. Select the **"Vaccines"** tab (first tab)
2. Tap the **"+ Add Vaccination"** button (or from empty state)
3. Fill in the form:
   - Vaccine Name: "Rabies" ✓ Required
   - Date Given: Select a past date
   - Next Due Date: Select a future date (try 20 days from now to see "Due Soon")
   - Batch Number: "ABC123" (optional)
   - Veterinarian: "Dr. Smith" (optional)
   - Clinic: "Main Street Vet" (optional)
   - Notes: "Annual vaccination" (optional)
4. Tap **Save**
5. Verify the vaccination card appears with:
   - Orange "Due soon" status (if next due within 30 days)
   - Green "Up to date" status (if due date > 30 days away)
   - Red "Overdue" status (if next due date has passed)

**Edge Cases to Test:**
- Add vaccination without next due date (should show up to date)
- Add vaccination with past due date (should show overdue)
- Try attaching a document (will show "coming soon" for now)
- Edit an existing vaccination
- Delete a vaccination

### Step 3: Test Medical Records Tab
1. Select the **"Medical"** tab (second tab)
2. Tap **"+ Add Medical Record"**
3. Fill in the form:
   - Visit Type: Select "Checkup" from dropdown ✓ Required
   - Visit Date: Select any date
   - Diagnosis: "Healthy checkup" (optional)
   - Treatment: "None required" (optional)
   - Prescription: "None" (optional)
   - Veterinarian: "Dr. Smith" (optional)
   - Clinic: "Main Street Vet" (optional)
   - Cost: "50.00" (optional)
   - Notes: "All good!" (optional)
4. Tap **Save**
5. Verify different visit types show different colors:
   - Checkup = Green
   - Emergency = Red
   - Surgery = Orange
   - Dental = Purple

**Edge Cases to Test:**
- Try each visit type to see color changes
- Add record with cost tracking
- Edit and delete records

### Step 4: Test Weight Tracking Tab
1. Select the **"Weight"** tab (third tab)
2. Add multiple weight records to see the graph:
   - First entry: Weight: 10, Unit: kg, Date: 30 days ago
   - Second entry: Weight: 10.5, Unit: kg, Date: 20 days ago
   - Third entry: Weight: 11, Unit: kg, Date: 10 days ago
   - Fourth entry: Weight: 11.2, Unit: kg, Date: today
3. Verify:
   - **Weight summary card** shows current weight and total change
   - **Graph appears** showing the trend line
   - Tap on data points to see tooltips
   - Weight history list shows all entries

**Edge Cases to Test:**
- Try different units (kg, lbs, g)
- Add weight with notes
- Single entry (graph won't show)
- Delete weight records

### Step 5: Test Medications Tab
1. Select the **"Meds"** tab (fourth tab)
2. Test the filter buttons:
   - Tap "Active" to see only active medications
   - Tap "All" to see all medications
3. Add a medication:
   - Medication Name: "Heartgard" ✓ Required
   - Dosage: "10mg" ✓ Required
   - Frequency: "Once daily" (use autocomplete) ✓ Required
   - Start Date: Today
   - End Date: 30 days from now (optional)
   - Prescribed By: "Dr. Smith" (optional)
   - Notes: "Give with food" (optional)
4. Verify:
   - Medication shows as "Active" (green)
   - Dosage information card displays correctly

**Edge Cases to Test:**
- Add medication without end date (should stay active)
- Add medication with past end date (should show expired)
- Test autocomplete for frequency and method
- Filter between active and all medications

### Step 6: Test Conditions Tab
1. Select the **"Conditions"** tab (fifth tab)
2. Test the filter buttons:
   - Tap "All" to see all conditions
   - Tap "Allergies" to filter allergies only
   - Tap "Chronic" to filter chronic conditions
3. Add an allergy:
   - Condition Type: Select "Allergy" ✓ Required
   - Name: "Pollen" ✓ Required
   - Severity: Select "Moderate" (optional)
   - Treatment: "Antihistamines" (optional)
   - Diagnosed Date: Select a date (optional)
   - Notes: "Seasonal allergy" (optional)
4. Verify:
   - Severity badge shows correct color (Mild=Green, Moderate=Orange, Severe=Red)
   - Condition type badge appears
   - Filter works correctly

**Edge Cases to Test:**
- Different condition types (Allergy, Chronic, Hereditary, etc.)
- All severity levels
- Condition without severity
- Filter functionality

### Step 7: Test Vet Contacts Tab
1. Select the **"Vets"** tab (sixth tab)
2. Add a vet contact:
   - Clinic Name: "Main Street Veterinary Clinic" ✓ Required
   - Veterinarian Name: "Dr. Jane Smith" (optional)
   - Phone: "+1234567890" (optional)
   - Email: "info@mainstreetvet.com" (optional)
   - Address: "123 Main St, City, State" (optional)
   - Specialization: "General" (optional)
   - Set as Primary Vet: Toggle ON
   - Notes: "24/7 emergency service" (optional)
3. Verify:
   - Primary vet shows blue "Primary Vet" badge
   - Phone number is clickable (tap to call)
   - Email is clickable (tap to email)

**Edge Cases to Test:**
- Multiple vet contacts
- Primary vet designation
- Quick actions (phone/email) - may require actual device
- Edit and delete vet contacts

### Step 8: Test Health Summary
1. After adding records in various tabs, go back to the dashboard
2. Verify the **Health Summary Card** at the top shows:
   - Vaccines count (blue)
   - Active Meds count (orange)
   - Visits count (green)
   - Conditions count (red)
3. Numbers should update as you add/delete records

## 🎨 Visual Testing Checklist

### Color Verification
- [ ] Vaccination status colors (green/orange/red)
- [ ] Medical visit type colors
- [ ] Medication status colors
- [ ] Condition severity colors
- [ ] Primary vet badge color
- [ ] Health summary icon colors

### Layout Verification
- [ ] Empty states display correctly with icons and text
- [ ] Cards render properly on different screen sizes
- [ ] Forms fit in dialogs without scrolling issues
- [ ] Graph displays correctly in weight tab
- [ ] Tab bar is scrollable on small screens
- [ ] Health summary card layout is balanced

### Navigation Verification
- [ ] Pet profile → Health dashboard navigation works
- [ ] Tab switching works smoothly
- [ ] Dialog opening/closing works
- [ ] Back navigation maintains state
- [ ] Popup menus work (edit/delete options)

## 🔄 Data Persistence Testing

### Test Database Operations
1. Add records in each tab
2. Close the app completely
3. Reopen the app
4. Navigate back to health dashboard
5. Verify all records are still present

### Test CRUD Operations
- **Create:** Add new records in each tab ✓
- **Read:** View records in list/card format ✓
- **Update:** Edit existing records ✓
- **Delete:** Remove records and verify they're gone ✓

## 📊 Graph Testing (Weight Tab)

### Scenarios to Test
1. **No data:** Empty state should show
2. **Single entry:** List shows, but no graph
3. **Two entries:** Graph appears with line
4. **Multiple entries:** Full graph with all points
5. **Touch interaction:** Tap points to see tooltips
6. **Different time ranges:** Test various date spans

### What to Verify
- [ ] X-axis shows dates correctly
- [ ] Y-axis shows weights correctly
- [ ] Line connects all points
- [ ] Gradient fill appears under line
- [ ] Tooltips show on tap
- [ ] Graph scales appropriately

## 🚨 Error Testing

### Form Validation
1. Try to save forms without required fields
2. Verify error messages appear
3. Check that forms won't submit with invalid data

### Edge Cases
1. Enter very large numbers for weight/cost
2. Try special characters in text fields
3. Select dates far in past/future
4. Add many records (test performance)
5. Rapidly switch between tabs

## 📱 Device Testing

### Screen Sizes
- [ ] Small phones (< 5 inches)
- [ ] Medium phones (5-6 inches)
- [ ] Large phones (> 6 inches)
- [ ] Tablets

### Orientations
- [ ] Portrait mode
- [ ] Landscape mode (if applicable)

## ✅ Acceptance Criteria

All features should:
- [ ] Display correctly without layout issues
- [ ] Save data persistently
- [ ] Allow editing and deleting
- [ ] Show appropriate empty states
- [ ] Use correct color coding
- [ ] Provide smooth navigation
- [ ] Validate user input
- [ ] Update summary counts
- [ ] Handle errors gracefully

## 🐛 Known Limitations

1. **Document Viewing:** Tapping "View Document/Certificate" shows "coming soon" message
2. **URL Launcher:** Phone/email quick actions may not work on emulators (need real device)
3. **File Picker:** May require additional permissions on Android/iOS

## 📝 Testing Notes Template

Use this template to document your testing:

```
Date: ___________
Tester: ___________

Feature: Vaccinations Tab
Status: ☐ Pass  ☐ Fail  ☐ Needs Work
Notes: ______________________________

Feature: Medical Records Tab
Status: ☐ Pass  ☐ Fail  ☐ Needs Work
Notes: ______________________________

Feature: Weight Tracking Tab
Status: ☐ Pass  ☐ Fail  ☐ Needs Work
Notes: ______________________________

Feature: Medications Tab
Status: ☐ Pass  ☐ Fail  ☐ Needs Work
Notes: ______________________________

Feature: Conditions Tab
Status: ☐ Pass  ☐ Fail  ☐ Needs Work
Notes: ______________________________

Feature: Vet Contacts Tab
Status: ☐ Pass  ☐ Fail  ☐ Needs Work
Notes: ______________________________

Feature: Health Summary
Status: ☐ Pass  ☐ Fail  ☐ Needs Work
Notes: ______________________________

Overall Assessment: ___________________
```

## 🎯 Success Indicators

The feature is working correctly if:
1. All tabs load without errors
2. Forms can add, edit, and delete records
3. Data persists across app restarts
4. Visual indicators (colors, badges) display correctly
5. Graph renders in weight tab (with 2+ entries)
6. Health summary shows accurate counts
7. No crashes or freezes during normal use

## 🔧 Troubleshooting

### Common Issues

**Issue:** Graph doesn't appear in weight tab
**Solution:** Need at least 2 weight entries for graph to show

**Issue:** Phone/email quick actions don't work
**Solution:** May need real device; emulators may not support url_launcher

**Issue:** File picker doesn't open
**Solution:** Check device permissions for file access

**Issue:** Database errors on first launch
**Solution:** Ensure `pet_health_db_helper.dart` is properly initialized

**Issue:** Health summary shows zeros
**Solution:** Add records in tabs first, summary updates on navigation back

## 📞 Support

For issues or questions:
1. Check the detailed feature guide: `PET_HEALTH_FEATURE_GUIDE.md`
2. Review model definitions in `lib/models/pet_health.dart`
3. Check database operations in `lib/database/pet_health_db_helper.dart`
4. Verify tab implementations in `lib/screens/health_tabs/`

---

Happy Testing! 🎉
