Table of Contents

About the Project
This project captures customized critical InterSystems IRIS for Health production information at runtime and will generate an email detailing the data.  The information contained in the email includes:  counts of messages in Error, Suspended, Queues, and Alerts.  Additionally, the email reports the database file sizing, folder space, and certificate expiration dates.   This email helps users identify immediate issues within a production as well as assisting with deriving trends with issue counts.

Built With
    InterSystems IRIS for Health
    InterSystems IRIS Studio
    

Getting Started:

    Prerequisites
        1.	Install and Configure InterSystems HealthShare or InsterSystems IRIS https://www.intersystems.com/data-platform/
	https://www.intersystems.com/interoperability-platform/

    Installation
        1.	Install DailyProductionAlertsNotification.cls into a generic namespace and folder. E.g.; UCDavis.Tasks.DailyProductionAlertsNotifications
              
        ![Alt text](image.png)
        2.  Create a Scheduled Task in the Management Portal – this task will run the installed class.  Fill in the following fields:
            a.	Task name:  Name for Task
            b.	Description:  Description for Task
            c.	Namespace to run task in:  General Namespace for Task
            d.	Task type:  Name of installed code - DailyProductionAlertsNotifications.cls
            e.	AlertThresholdElevated:  Alert Message Elevated Count Threshold (Message Count Highlighted In Yellow)
            f.	AlertThresholdHigh:  Alert Message High Count Threshold (Message Count Highlighted In Red)
            g.	CombinedThresholdElevated:  Error Warning Message Total Count Elevated Count Threshold (Message Count Highlighted In Yellow)
            h.	CombinedThresholdHigh:  Error Warning Message Total Count High Count Threshold (Message Count Highlighted In Red)
            i.	ErrorThresholdElevated:  Error Message Elevated Count Threshold (Message Count Highlighted In Yellow)
            j.	ErrorThresholdHigh:  Error Message High Count Threshold (Message Count Highlighted In Red)
            k.	FilePathToMonitor:  File Paths to Monitor for the Folder Space Utilization Counts
            l.	Namespaces:  Namespaces for to Include in Reporting
            m.	QueueThresholdElevated:  Queue Message Elevated Counts Threshold (Message Count Highlighted In Yellow)
            n.	QueueThresholdHigh:  Queue Message High Counts Threshold (Message Count Highlighted In Red)
            o.	SuspendThresholdElevated:  Suspend Message Elevated Counts Threshold (Message Count Highlighted In Yellow)
            p.	SuspendThresholdHigh:  Suspend Message High Counts Threshold (Message Count Highlighted In Red)
            q.	ToEmail:  Email(s) Recipient List to Receive Report
            r.	WarnThresholdElevated:  Warning Message Elevated Counts Threshold (Message Count Highlighted In Yellow)
            s.	WarnThresholdHigh:  Warning Message High Counts Threshold (Message Count Highlighted In Red)
            t.	Run task as this user:  User Authorized to Run the Task
        ![Alt text](image-1.png)
            u.	often do you want the Task Manager to execute this task?:   Daily, Weekly, Monthly, Monthly (by day), After Another Task Completes, On Demand
            v.	Every ______ days(s):   Number of Times/Days to Run Task.  E.g.; 1 = 1 time per day if Daily was selected for Above Step
            w.	Start Date (mm/dd/ How yyyy) __________ :  Date Task Will First Run
            x.	Run once at this time: ____________ :   Time Report Will Run
            Or
            Run every ___________ Minutes/Hours/ :  
        ![Alt text](image-2.png)

        Below is an example of the email detailing the data:
        ![Alt text](image-3.png)
        ![Alt text](image-4.png)