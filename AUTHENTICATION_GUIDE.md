# Authentication System Guide

## Overview
The Pet Care Reminder app now includes a complete authentication system with user login and signup functionality. This ensures that each user's data is secure and personalized.

## Features

### 1. **Login Screen**
- Username and password authentication
- Form validation for proper input
- Password visibility toggle
- Loading state during authentication
- Navigation to signup screen for new users
- Persistent login state using SharedPreferences

### 2. **Sign Up Screen**
- Create new user accounts
- Username, email (optional), and password fields
- Password confirmation validation
- Username uniqueness check
- Form validation with helpful error messages
- Automatic navigation back to login after successful signup

### 3. **Authentication Wrapper**
- Checks login status on app launch
- Automatically routes to login or home screen
- Uses SharedPreferences to maintain login state

### 4. **Logout Functionality**
- Logout button in Settings screen
- Confirmation dialog before logout
- Clears all session data
- Returns to login screen

## File Structure

```
lib/
├── models/
│   └── user.dart                    # User data model
├── database/
│   └── user_db_helper.dart          # SQLite database helper for users
├── screens/
│   ├── login_screen.dart            # Login UI
│   ├── signup_screen.dart           # Sign up UI
│   └── settings_screen.dart         # Updated with logout option
└── main.dart                        # Updated with AuthWrapper
```

## Implementation Details

### User Model (`user.dart`)
```dart
class User {
  final int? id;
  final String username;
  final String password;
  final String? email;
  final DateTime createdAt;
}
```

### Database Schema
The `users` table includes:
- `id`: Auto-incrementing primary key
- `username`: Unique, required field
- `password`: Required field (stored as plain text - consider encryption for production)
- `email`: Optional field
- `created_at`: Timestamp of account creation

### Authentication Flow

#### **First-time User (Sign Up)**
1. User taps "Sign Up" on login screen
2. Fills out registration form
3. System validates input (username format, password strength, etc.)
4. Checks if username already exists
5. Creates new user in database
6. Returns to login screen with success message

#### **Existing User (Login)**
1. User enters username and password
2. System validates credentials against database
3. On success:
   - Saves login state to SharedPreferences
   - Navigates to home screen
   - Shows welcome message
4. On failure:
   - Displays error message
   - Allows retry

#### **Logout**
1. User navigates to Settings screen
2. Taps "Logout" button
3. Confirms action in dialog
4. System clears session data
5. Returns to login screen

## Validation Rules

### Username
- Minimum 3 characters
- Maximum 20 characters
- Only letters, numbers, and underscores allowed
- Must be unique

### Password
- Minimum 6 characters
- Maximum 50 characters
- Must match confirmation password (signup only)

### Email (Optional)
- Must be valid email format if provided
- Pattern: `text@domain.extension`

## Security Considerations

⚠️ **Important**: The current implementation stores passwords as plain text. For production use, consider:

1. **Password Hashing**: Use a package like `crypto` to hash passwords
   ```dart
   import 'package:crypto/crypto.dart';
   import 'dart:convert';
   
   String hashPassword(String password) {
     var bytes = utf8.encode(password);
     var digest = sha256.convert(bytes);
     return digest.toString();
   }
   ```

2. **Secure Storage**: Use `flutter_secure_storage` for sensitive data
3. **Token-based Authentication**: Implement JWT tokens for session management
4. **Password Requirements**: Enforce stronger password policies
5. **Account Recovery**: Add "Forgot Password" functionality

## Usage Examples

### Checking Login Status
```dart
final prefs = await SharedPreferences.getInstance();
final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
final username = prefs.getString('current_user');
```

### Creating a New User
```dart
final newUser = User(
  username: 'john_doe',
  password: 'secure123',
  email: 'john@example.com',
);
await UserDBHelper.insertUser(newUser);
```

### Verifying Credentials
```dart
final user = await UserDBHelper.verifyUser(username, password);
if (user != null) {
  // Login successful
}
```

## Testing the Authentication System

1. **First Run**: App shows login screen
2. **New User**:
   - Tap "Sign Up"
   - Enter username: `testuser`
   - Enter email (optional): `test@example.com`
   - Enter password: `test123`
   - Confirm password: `test123`
   - Tap "Sign Up"
   - See success message
3. **Login**:
   - Enter username: `testuser`
   - Enter password: `test123`
   - Tap "Login"
   - Redirected to home screen
4. **Persistent Login**:
   - Close and reopen app
   - Automatically logged in
5. **Logout**:
   - Navigate to Settings
   - Scroll to bottom
   - Tap "Logout"
   - Confirm in dialog
   - Returned to login screen

## Future Enhancements

- [ ] Email verification
- [ ] Password reset functionality
- [ ] Social login (Google, Facebook)
- [ ] Biometric authentication (fingerprint, face ID)
- [ ] Multi-factor authentication (MFA)
- [ ] Session timeout
- [ ] Account settings (change password, delete account)
- [ ] Profile picture upload
- [ ] Password strength indicator

## Troubleshooting

### Issue: "Username already exists"
**Solution**: Choose a different username or use the existing credentials to login.

### Issue: Login state not persisting
**Solution**: Check that SharedPreferences is properly initialized in `main()`.

### Issue: Database errors
**Solution**: Clear app data or reinstall the app to reset the database.

## API Reference

### UserDBHelper Methods

- `getDb()`: Get database instance
- `insertUser(User user)`: Create new user
- `getUserByUsername(String username)`: Find user by username
- `verifyUser(String username, String password)`: Verify credentials
- `usernameExists(String username)`: Check username availability
- `getAllUsers()`: Get all users (admin only)
- `updateUser(User user)`: Update user information
- `deleteUser(int id)`: Delete user account

---

**Note**: This authentication system is designed for local-only use. For cloud-based authentication, consider integrating Firebase Authentication or a custom backend API.
