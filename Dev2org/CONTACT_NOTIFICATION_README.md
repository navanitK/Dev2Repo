# Contact Notification System Implementation Guide

## Overview

This implementation provides a comprehensive notification system for Salesforce that alerts Account Managers when their accounts are due for contact moments.

## Components

### 1. Apex Classes

#### ContactNotificationBatch

- **Purpose**: Daily scheduled batch job that identifies accounts due for contact
- **Logic**:
  - Checks for accounts where `EF_LastContactMoment__c` is older than 6 months
  - Only processes accounts where `SnoozeStatus__c` = 'active'
  - Creates a Task for each account (no duplicates)
- **Usage**: Execute as a scheduled job

#### ContactNotificationScheduler

- **Purpose**: Schedules the batch job to run daily
- **Methods**:
  - `scheduleDaily()`: Schedules batch to run at 8 AM daily
  - `unscheduleDaily()`: Removes the scheduled job
- **Setup**: Run `ContactNotificationScheduler.scheduleDaily()` in anonymous Apex

#### ContactNotificationController

- **Purpose**: Provides API for LWC components to retrieve and manage notifications
- **Public Methods**:
  - `getContactNotifications()`: Get all open contact notification tasks for current user
  - `getAccountContactNotifications(accountId)`: Get tasks for a specific account
  - `completeContactNotification(taskId)`: Mark task as completed
  - `getAllContactNotifications()`: Get all open tasks (admin use)

### 2. Lightning Web Components

#### contactNotificationsHome

- **Purpose**: Display all pending contact notification tasks on Sales Home page
- **Location**: Can be added to Lightning Home page
- **Features**:
  - Shows account name, task subject, due date, status
  - "Mark Complete" button for each task
  - Auto-refreshes after completion

#### contactNotificationsAccount

- **Purpose**: Display contact notifications for a specific account on Account record page
- **Location**: Can be added to Account record layout
- **Features**:
  - Shows only tasks related to that account
  - "Mark Complete" button
  - Auto-filters out completed tasks

### 3. Configuration Required

#### Custom Fields

The following custom fields must exist on the Account object:

- **EF_LastContactMoment\_\_c** (Date): Last date the account was contacted
- **SnoozeStatus\_\_c** (Picklist): Values: 'active', 'inactive'

#### Task Subject

All notification tasks use the subject: **"hey contact your customer"**

## Setup Instructions

### Step 1: Create Custom Fields

1. Go to Setup → Object Manager → Account
2. Create field `EF_LastContactMoment__c` (Date)
3. Create field `SnoozeStatus__c` (Picklist with values: 'active', 'inactive')

### Step 2: Deploy Code

1. Deploy all Apex classes to your org
2. Deploy all LWC components to your org

### Step 3: Schedule Batch Job

1. Open Developer Console
2. Execute: `ContactNotificationScheduler.scheduleDaily()`
3. Verify job appears in Setup → Scheduled Jobs

### Step 4: Add Components to Pages

1. **For Home Page**:

   - Edit Sales Home page
   - Add "Contact Notifications" component
   - Save and publish

2. **For Account Record**:
   - Edit Account Record Page
   - Add "Contact Notifications" component
   - Configure for Account object
   - Save and publish

## Business Logic

### Task Creation

- **Trigger**: Daily at 8 AM (configurable)
- **Criteria**:
  - `EF_LastContactMoment__c` < 6 months ago
  - `SnoozeStatus__c` = 'active'
  - No existing open task with same subject
- **Task Details**:
  - Subject: "hey contact your customer"
  - Owner: Account Owner (OwnerId)
  - Related To: Account
  - ActivityDate: Today + 1 day
  - Reminder: Tomorrow at task creation time

### Task Visibility

- **Home Page**: Shows all open contact notification tasks owned by logged-in user
- **Account Record**: Shows all open contact notification tasks for that account
- **Filtering**: Only tasks with subject "hey contact your customer" are shown

### Task Completion

- Users can mark tasks as "Completed" via the component button
- Completed tasks don't appear in notifications anymore
- Completion updates task status to "Completed"

### Snooze Functionality

- When `SnoozeStatus__c` = 'inactive', no new tasks are created
- Already created tasks will remain until manually completed

## Testing

### Run Unit Tests

```apex
// In Developer Console
Test.startTest();
ContactNotificationBatch batch = new ContactNotificationBatch();
Database.executeBatch(batch);
Test.stopTest();
```

### Test Classes Included

- `ContactNotificationBatchTest`: Tests batch logic and duplicate prevention
- `ContactNotificationControllerTest`: Tests API methods
- `LightningLoginFormControllerTest`: (Existing tests)

## Reporting & Monitoring

### View Scheduled Jobs

- Go to Setup → Scheduled Jobs
- Search for "Contact Notification Batch"

### Monitor Batch Execution

- Go to Setup → Apex Batch Jobs
- Look for "ContactNotificationBatch"

### Query Tasks

```apex
SELECT Id, Subject, ActivityDate, Status, OwnerId, Owner.Name, What.Name
FROM Task
WHERE Subject = 'hey contact your customer'
ORDER BY ActivityDate ASC
```

## Troubleshooting

### Tasks Not Creating

1. Verify `EF_LastContactMoment__c` is populated (older than 6 months)
2. Verify `SnoozeStatus__c` = 'active'
3. Check batch job execution in Setup → Scheduled Jobs
4. Check Apex Debug Logs for errors

### Tasks Duplicating

- Batch checks for existing open tasks
- If duplicates exist, contact Salesforce support

### Components Not Showing

1. Verify components are deployed to your org
2. Verify components are added to appropriate pages
3. Check browser console for JavaScript errors
4. Verify user has read access to Task object

## Security

- **CRUD Operations**: Uses `with sharing` in controller (respects org permissions)
- **Account Access**: Users only see tasks for accounts they manage
- **Task Completion**: Only task owner can mark as completed

## Future Enhancements

1. Add email notifications to Account Manager
2. Add recurring task logic (create new task after completion)
3. Add custom notification type (in-app notification)
4. Add frequency configuration per account
5. Add batch email summary report
6. Add metrics/dashboard for contact response rates
