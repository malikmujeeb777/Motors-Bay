# Deploying Firebase Cloud Functions and Firestore Rules

To deploy the updated Firebase cloud functions and Firestore security rules, follow these steps:

## Prerequisites
- Ensure you have the Firebase CLI installed (`npm install -g firebase-tools`)
- Make sure you're logged in to Firebase (`firebase login`)
- Ensure you're in the project directory

## Deploying Firestore Security Rules
```powershell
firebase deploy --only firestore:rules
```

## Deploying Cloud Functions
```powershell
cd functions
npm install
firebase deploy --only functions
```

## Verify Deployment
After deployment, check the Firebase console to ensure:
1. Firestore security rules have been updated
2. Cloud functions are deployed and running properly

## Testing
1. Send a test message between two users
2. Verify that:
   - Notifications are received
   - Unread message badges appear correctly
   - Security rules are enforced properly
