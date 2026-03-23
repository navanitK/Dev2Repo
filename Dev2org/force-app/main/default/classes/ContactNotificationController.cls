/**
 * Controller for Contact Notification LWC components
 * Uses ContactNotificationService for business logic
 */
public with sharing class ContactNotificationController {
    
    /**
     * Get all contact notification tasks for the current user (from accounts they own)
     */
    @AuraEnabled(cacheable=true)
    public static List<Task> getContactNotifications() {
        return ContactNotificationService.getContactNotificationsForUser(UserInfo.getUserId());
    }
    
    /**
     * Get contact notification tasks for a specific account
     * @param accountId - The Id of the account
     */
    @AuraEnabled(cacheable=true)
    public static List<Task> getAccountContactNotifications(String accountId) {
        return ContactNotificationService.getContactNotificationsForAccount((Id)accountId);
    }
    
    /**
     * Mark a contact notification task as completed
     * @param taskId - The Id of the task to complete
     */
    @AuraEnabled
    public static void completeContactNotification(String taskId) {
        ContactNotificationService.completeNotificationTask((Id)taskId);
    }
    
    /**
     * Get all open contact notification tasks (for admin/reporting)
     */
    @AuraEnabled(cacheable=true)
    public static List<Task> getAllContactNotifications() {
        return ContactNotificationService.getAllOpenContactNotifications();
    }
}
