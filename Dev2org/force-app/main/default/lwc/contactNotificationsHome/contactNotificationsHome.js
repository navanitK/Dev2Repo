import { LightningElement, wire } from "lwc";
import { refreshApex } from "@salesforce/apex";
import getContactNotifications from "@salesforce/apex/ContactNotificationController.getContactNotifications";
import completeContactNotification from "@salesforce/apex/ContactNotificationController.completeContactNotification";

const COLUMNS = [
  { label: "Account", fieldName: "accountName", type: "text" },
  { label: "Task Subject", fieldName: "Subject", type: "text" },
  { label: "Due Date", fieldName: "ActivityDate", type: "date" },
  { label: "Status", fieldName: "Status", type: "text" },
  {
    label: "Action",
    type: "button",
    initialWidth: 100,
    typeAttributes: {
      label: "Mark Complete",
      name: "complete",
      title: "Mark as Completed"
    }
  }
];

export default class ContactNotificationsHome extends LightningElement {
  columns = COLUMNS;
  tasks = [];
  isLoading = true;
  errorMessage;
  wiredTasksResult;

  @wire(getContactNotifications)
  wiredTasks(result) {
    this.wiredTasksResult = result;
    const { error, data } = result;

    this.isLoading = false;
    if (data) {
      this.tasks = data.map((task) => ({
        Id: task.Id,
        Subject: task.Subject,
        ActivityDate: task.ActivityDate,
        Status: task.Status,
        accountName: task.What.Name,
        whatId: task.WhatId
      }));
      this.errorMessage = null;
    } else if (error) {
      this.errorMessage = "Error loading notifications";
      console.error("Error:", error);
    }
  }

  handleRowAction(event) {
    const actionName = event.detail.action.name;
    const row = event.detail.row;

    if (actionName === "complete") {
      this.completeTask(row.Id);
    }
  }

  completeTask(taskId) {
    completeContactNotification({ taskId: taskId })
      .then(() => {
        // Refresh the list
        return refreshApex(this.wiredTasks);
      })
      .catch((error) => {
        this.errorMessage = "Error marking task as complete";
        console.error("Error:", error);
      });
  }
}
