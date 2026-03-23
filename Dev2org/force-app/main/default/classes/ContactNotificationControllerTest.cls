@isTest
public class ContactNotificationControllerTest {
    
    @testSetup
    static void setupTestData() {
        // Create test account
        Account testAccount = new Account(
            Name = 'Test Account',
            EF_LastContactMoment__c = System.today().addMonths(-7),
            SnoozeStatus__c = 'active'
        );
        insert testAccount;
        
        // Create test tasks
        List<Task> tasks = new List<Task>();
        
        Task completedTask = new Task(
            Subject = 'hey contact your customer',
            WhatId = testAccount.Id,
            Status = 'Completed',
            ActivityDate = System.today()
        );
        tasks.add(completedTask);
        
        Task openTask = new Task(
            Subject = 'hey contact your customer',
            WhatId = testAccount.Id,
            Status = 'Not Started',
            ActivityDate = System.today().addDays(1)
        );
        tasks.add(openTask);
        
        Task otherTask = new Task(
            Subject = 'Other Task',
            WhatId = testAccount.Id,
            Status = 'Not Started',
            ActivityDate = System.today()
        );
        tasks.add(otherTask);
        
        insert tasks;
    }
    
    @isTest
    static void testGetContactNotifications() {
        Test.startTest();
        
        List<Task> tasks = ContactNotificationController.getContactNotifications();
        
        Test.stopTest();
        
        // Should return only open contact notification tasks
        System.debug('Tasks returned: ' + tasks.size());
    }
    
    @isTest
    static void testGetAccountContactNotifications() {
        Account acc = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        
        Test.startTest();
        
        List<Task> tasks = ContactNotificationController.getAccountContactNotifications(acc.Id);
        
        Test.stopTest();
        
        // Should return one open task related to the account
        System.assertEquals(1, tasks.size(), 'Should return one open contact notification task');
        System.assertEquals('hey contact your customer', tasks[0].Subject);
        System.assertNotEquals('Completed', tasks[0].Status);
    }
    
    @isTest
    static void testCompleteContactNotification() {
        Task task = [SELECT Id FROM Task WHERE Subject = 'hey contact your customer' AND Status != 'Completed' LIMIT 1];
        
        Test.startTest();
        
        ContactNotificationController.completeContactNotification(task.Id);
        
        Test.stopTest();
        
        Task updatedTask = [SELECT Status FROM Task WHERE Id = :task.Id];
        System.assertEquals('Completed', updatedTask.Status, 'Task should be marked as completed');
    }
    
    @isTest
    static void testGetAllContactNotifications() {
        Test.startTest();
        
        List<Task> tasks = ContactNotificationController.getAllContactNotifications();
        
        Test.stopTest();
        
        // Should return all open contact notification tasks
        Integer openContactTasks = [SELECT COUNT() FROM Task 
                                    WHERE Subject = 'hey contact your customer' 
                                    AND Status != 'Completed'];
        System.assertEquals(openContactTasks, tasks.size());
    }
}
