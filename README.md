# System-Alerts
2024 InterSystems FHIR and Digital Health Interoperability Contest!

## About the Project
This project captures customized critical InterSystems IRIS for Health production information at runtime and will generate an email detailing the data.  The information contained in the email includes:  counts of messages in Error, Suspended, Queues, and Alerts.  Additionally, the email reports the database file sizing, folder space, and certificate expiration dates.   This email helps users identify immediate issues within a production as well as assisting with deriving trends with issue counts.

## Built With
    InterSystems IRIS for Health
    InterSystems IRIS Studio

## Getting Started:

## Prerequisites
  Install and Configure [InterSystems HealthShare](https://www.intersystems.com/interoperability-platform/) or [InsterSystems IRIS for Health](https://www.intersystems.com/data-platform/)
  
## Installation
    1. Install DailyProductionAlertsNotification.cls into a generic namespace and folder. E.g.; UCDavis.Tasks.DailyProductionAlertsNotifications
        
![image](https://github.com/SysIntergrationTechTeam/System-Alerts/assets/110857238/9c5c155c-9b0e-4fda-b496-910432316692)

    2. Create a Scheduled Task in the Management Portal – this task will run the installed class.  Fill in the following fields:
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

![image](https://github.com/SysIntergrationTechTeam/System-Alerts/assets/110857238/6d32c0c5-f82e-4ec4-9bb7-701146b43c5e)

            u.	often do you want the Task Manager to execute this task?:   Daily, Weekly, Monthly, Monthly (by day), After Another Task Completes, On Demand
            v.	Every ______ days(s):   Number of Times/Days to Run Task.  E.g.; 1 = 1 time per day if Daily was selected for Above Step
            w.	Start Date (mm/dd/ How yyyy) __________ :  Date Task Will First Run
            x.	Run once at this time: ____________ :   Time Report Will Run
            Or
            Run every ___________ Minutes/Hours/ :  

![image](https://github.com/SysIntergrationTechTeam/System-Alerts/assets/110857238/166ffbe5-6a4c-46a6-8640-1d171a83b6cf)

Below is an example of the email detailing the data:

![image](https://github.com/SysIntergrationTechTeam/System-Alerts/assets/110857238/b4a891ec-4bf2-4163-bb64-bdfe82173eb4)
![image](https://github.com/SysIntergrationTechTeam/System-Alerts/assets/110857238/38d623a0-39dd-429b-9855-a5b5e9340076)


