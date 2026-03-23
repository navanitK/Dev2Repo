# Contact Notification System - FFLIB Architecture Refactor

## Overview

The Contact Notification System has been refactored to follow the **FFLIB (Apex Enterprise Patterns)** architecture. This provides better separation of concerns, testability, and maintainability.

## Architecture Layers

### 1. **Selectors** - Data Access Layer

Selectors encapsulate all SOQL queries and provide a clean API for accessing data.

#### AccountsSelector

- **Responsibility**: All queries related to Account objects
- **Key Methods**:
  - `selectAccountsDueForContact()` - Get accounts overdue for contact
  - `selectAccountsDueForContactQueryLocator()` - Batch-friendly query locator
  - `selectById(Set<Id> accountIds)` - Get specific accounts by ID
- **File**: [AccountsSelector.cls](force-app/main/default/classes/AccountsSelector.cls)

#### TasksSelector

- **Responsibility**: All queries related to Task objects
- **Key Methods**:
  - `selectOpenContactNotificationTasksByAccountIds()` - Get existing tasks for accounts
  - `selectOpenContactNotificationTasksByUserId()` - Get tasks for a user
  - `selectOpenContactNotificationTasksByAccountId()` - Get tasks for one account
  - `selectOpenContactNotificationTasks()` - Get all open tasks
- **File**: [TasksSelector.cls](force-app/main/default/classes/TasksSelector.cls)

### 2. **Service Layer** - Business Logic

Services contain the core business rules and orchestration logic.

#### ContactNotificationService

- **Responsibility**: All business logic for contact notifications
- **Key Methods**:
  - `createNotificationTasksForDueAccounts()` - Main batch processing method
  - `createContactNotificationTask()` - Factory method for task creation
  - `completeNotificationTask()` - Mark task as complete
  - `getContactNotificationsForUser()` - Get user's notifications
  - `getContactNotificationsForAccount()` - Get account's notifications
  - `getAllOpenContactNotifications()` - Admin reporting
- **Features**:
  - Uses selectors for all data access
  - Contains all validation logic
  - Handles duplicate prevention
  - Custom exception handling
- **File**: [ContactNotificationService.cls](force-app/main/default/classes/ContactNotificationService.cls)

### 3. **Batch Layer** - Scheduled Operations

The batch job delegates to the service layer.

#### ContactNotificationBatch

- **Responsibility**: Batch execution and processing
- **What It Does**:
  1. Calls `AccountsSelector.selectAccountsDueForContactQueryLocator()` to get accounts
  2. Processes accounts through the service layer
  3. Logs completion metrics
- **File**: [ContactNotificationBatch.cls](force-app/main/default/classes/ContactNotificationBatch.cls)

### 4. **Controller Layer** - API/Integration

Controllers provide APIs for LWC components and external systems.

#### ContactNotificationController

- **Responsibility**: Expose service methods via Apex APIs
- **Key Methods** (AuraEnabled):
  - `getContactNotifications()` - Get current user's notifications
  - `getAccountContactNotifications()` - Get account's notifications
  - `completeContactNotification()` - Mark as complete
  - `getAllContactNotifications()` - Admin/reporting API
- **Integration**: Uses `ContactNotificationService` for all business logic
- **File**: [ContactNotificationController.cls](force-app/main/default/classes/ContactNotificationController.cls)

## Data Flow

```
Batch Job
    ↓
ContactNotificationBatch.start()
    ↓
AccountsSelector.selectAccountsDueForContactQueryLocator()
    ↓ (for each batch)
ContactNotificationBatch.execute()
    ↓
ContactNotificationService.createNotificationTasksForDueAccounts()
    ↓ (uses selectors)
[AccountsSelector] + [TasksSelector]
    ↓ (creates)
Task records

---

LWC Component
    ↓
ContactNotificationController.getContactNotifications()
    ↓
ContactNotificationService.getContactNotificationsForUser()
    ↓
TasksSelector.selectOpenContactNotificationTasksByUserId()
    ↓
Returns tasks to component
```

## Benefits of This Architecture

### ✅ Separation of Concerns

- **Selectors**: Only SOQL queries
- **Services**: Only business logic
- **Controllers**: Only API exposure
- **Batch**: Only scheduling/processing

### ✅ Testability

- Mock selectors easily
- Test business logic independently
- Isolate database queries
- Test edge cases without complex setup

### ✅ Reusability

- Services can be called from multiple places (batch, controller, flow, trigger, etc.)
- Selectors can be composed for complex queries
- No code duplication

### ✅ Maintainability

- Query changes → Update one selector
- Business rule changes → Update one service
- Easy to add caching strategies
- Easy to add logging/monitoring

### ✅ Scalability

- Add new queries without touching existing code
- Add new services without modifying selectors
- Easy to optimize queries (indexes, etc.)

## Usage Examples

### Example 1: Creating Notifications

```apex
// From batch job or anywhere
Integer tasksCreated = ContactNotificationService.createNotificationTasksForDueAccounts();
System.debug('Created ' + tasksCreated + ' tasks');
```

### Example 2: Getting User's Notifications

```apex
// From LWC controller
List<Task> tasks = ContactNotificationService.getContactNotificationsForUser(userId);
```

### Example 3: Adding Custom Query Logic

```apex
// Simply add a new method to TasksSelector
public List<Task> selectHighPriorityContactTasks() {
    return (List<Task>) Database.query(
        newQueryFactory()
            .setCondition('Subject = :subject AND Priority = \'High\' AND Status != \'Completed\'')
            .toSOQL()
    );
}
```

## Setup Note: FFLIB Application Factory

If using the full FFLIB pattern with `Application` factory:

1. **Register Selectors in Application Factory**:

```apex
// In your Application factory setup
Application.Selector.setMock(new AccountsSelectorMock());
Application.Selector.setMock(new TasksSelectorMock());
```

2. **Current Setup** (Simplified):
   The current implementation uses direct instantiation:

```apex
AccountsSelector selector = AccountsSelector.newInstance();
```

To upgrade to full FFLIB with Application factory, uncomment the factory pattern:

```apex
// Application.Selector.newInstance(Account.SObjectType)
```

## Testing Strategy

### Unit Tests

- [AccountsSelectorTest.cls](force-app/main/default/classes/AccountsSelectorTest.cls) - Query validation
- [ContactNotificationServiceTest.cls](force-app/main/default/classes/ContactNotificationServiceTest.cls) - Business logic
- [ContactNotificationBatchTest_FFLIB.cls](force-app/main/default/classes/ContactNotificationBatchTest_FFLIB.cls) - Batch processing

### Test Coverage

- ✅ Account selection logic
- ✅ Duplicate prevention
- ✅ Task creation
- ✅ Task completion
- ✅ Snooze handling
- ✅ User/Account filtering

## Files Changed

### New Files

- `AccountsSelector.cls` - Account data access
- `TasksSelector.cls` - Task data access
- `ContactNotificationService.cls` - Business logic
- `ContactNotificationServiceTest.cls` - Service tests
- `AccountsSelectorTest.cls` - Selector tests

### Modified Files

- `ContactNotificationBatch.cls` - Refactored to use service
- `ContactNotificationController.cls` - Refactored to use service
- `ContactNotificationBatchTest_FFLIB.cls` - Updated for new architecture

## Future Enhancements

1. **Add Domain Classes**: Create Account and Task domain classes for advanced business logic
2. **Add Unit of Work Pattern**: Batch operations with transaction management
3. **Add Logging Service**: Centralized logging and monitoring
4. **Add Cache Layer**: Query result caching in selectors
5. **Add Trigger Handlers**: Use selectors in triggers for consistency
6. **Add Security Layer**: Additional sharing/permission checks

## Migration Guide

If migrating existing code:

1. **Replace direct SOQL with selectors**:

   ```apex
   // Old
   List<Account> accounts = [SELECT ... FROM Account WHERE ...];

   // New
   AccountsSelector selector = AccountsSelector.newInstance();
   List<Account> accounts = selector.selectAccountsDueForContact();
   ```

2. **Use service for business logic**:

   ```apex
   // Old
   insert taskList;

   // New
   ContactNotificationService.createNotificationTasksForDueAccounts();
   ```

3. **Leverage cacheability in controllers**:
   ```apex
   // Selectors and services automatically leverage cacheable=true
   ```
