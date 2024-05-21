# System-Alerts
2024 InterSystems FHIR and Digital Health Interoperability Contest!

## About the Project
This project captures critical InterSystems IRIS for Health integration production information at runtime and will generate an email detailing the data. The information contained in the email includes: counts of messages in Error, Suspended, Queues, and Alerts.  Additionally, the email reports the database file sizing, folder space, and certificate expiration dates. The generated email helps users identify potential issues within a production as well as assisting with deriving trends with issue counts.

## Built With
* InterSystems IRIS for Health
* InterSystems IRIS Studio

## Getting Started:

## Prerequisites
  Install and Configure [InterSystems HealthShare](https://www.intersystems.com/interoperability-platform/) or [InsterSystems IRIS for Health](https://www.intersystems.com/data-platform/)
  
## Installation
1. Install DailyProductionAlertsNotification.cls into a generic namespace and folder. E.g.; User.Tasks.DailyProductionAlertsNotifications
        
![image](https://github.com/SysIntergrationTechTeam/System-Alerts/assets/110857238/83c57ac0-9130-42c9-865b-94291a606220)

2. Create a Scheduled Task in the Management Portal – this task will run the installed class.  Fill in the following fields:
Please refer to the file TaskList for a complete list of fields

![image](https://github.com/SysIntergrationTechTeam/System-Alerts/assets/110857238/4981c03a-af0f-4352-b31c-8e8b4e6308a1)

![image](https://github.com/SysIntergrationTechTeam/System-Alerts/assets/110857238/a6576829-045f-4aa0-9513-0ccc5b1fe6c0)

![image](https://github.com/SysIntergrationTechTeam/System-Alerts/assets/110857238/165697ea-0415-4190-b45d-9b1b4234bbba)

Below is an example of the email detailing the data:

![image](https://github.com/SysIntergrationTechTeam/System-Alerts/assets/110857238/294f9294-e129-4e93-becd-3d4eae22c7f5)
![image](https://github.com/SysIntergrationTechTeam/System-Alerts/assets/110857238/0d320830-0d18-4b91-bcd2-01c37830d7b2)

## Authors and Acknowledgements
[@Darren.Marks](https://community.intersystems.com/user/darren-marks), [@Katie.Bourbeau](https://community.intersystems.com/user/katie-bourbeau), [@Marvin.Asercion](https://community.intersystems.com/user/marvin-asercion), [@Scott.Nathanson](https://community.intersystems.com/user/scott-nathanson), [@Momeena.Ali](https://community.intersystems.com/user/momeena-ali)

## Docker    

### Prerequisites
Make sure you have [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) and [Docker desktop](https://www.docker.com/products/docker-desktop) installed.
### Installation
Clone/git pull the repo into any local directory
```
$ git clone https://github.com/rcemper/PR_System-Alerts.git
```
to build and start the container run     
```
$ docker compose up -d && docker compose logs -f
```
A demo Task is prepared. It is named **docker**    
http://localhost:42773/csp/sys/op/%25CSP.UI.Portal.TaskInfo.zen?$ID1=1000      
It is ready for you to adjust it to your needs.    

To open IRIS Terminal do:   
```
$ docker-compose exec iris iris session iris 
USER>
```
or using **WebTerminal**     
http://localhost:42773/terminal/      

To access IRIS System Management Portal   
http://localhost:42773/csp/sys/UtilHome.csp    

