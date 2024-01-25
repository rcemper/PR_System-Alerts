Include (Ensemble, EnsConstants)

Class UCDavis.Tasks.DailyProductionAlertsNotifcations Extends %SYS.Task.Definition
{

Property Namespaces As %String(MAXLEN = 512);

Property ToEmail As %String(MAXLEN = 250);

Property FilePathToMonitor As %String(MAXLEN = 512);

Property ErrorThresholdHigh As %Integer;

Property WarnThresholdHigh As %Integer;

Property AlertThresholdHigh As %Integer;

Property ErrorThresholdElevated As %Integer;

Property WarnThresholdElevated As %Integer;

Property AlertThresholdElevated As %Integer;

Property CombinedThresholdHigh As %Integer;

Property CombinedThresholdElevated As %Integer;

Property SuspendThresholdHigh As %Integer;

Property SuspendThresholdElevated As %Integer;

Property QueueThresholdHigh As %Integer;

Property QueueThresholdElevated As %Integer;

/// This method is responsible for executing the task.<br>
/// At the scheduled time, the Task Manager creates an instance of this object,
/// sets any property values using the stored "settings" for the task, and then
/// invokes this method to execute the task.<br>
/// In order to execute a real task, override this method in a subclass.
Method OnTask() As %Status
{
	set ns=$NAMESPACE
	
	Set msg = ##class(%Net.MailMessage).%New()
    set msg.From = "systems.integration@ucdmc.ucdavis.edu"
    for x=1:1:$l(..ToEmail,",") {
    	Do msg.To.Insert($p(..ToEmail,",",x))
    }
   	set tInst = ##class(UCDavis.Rule.FunctionSet).Environment()

    Set msg.Subject=$ZD($H-1)_" Daily Production Status ("_..Namespaces_") ["_tInst_"]"
    Set msg.IsBinary=0
    Set msg.IsHTML=1
    
    do ..GenerateReport(.output,..Namespaces)
    
    do output.Rewind()
    Do msg.TextData.CopyFrom(output)
        
	Set server=##class(%Net.SMTP).%New()
	Set server.smtpserver="smtp.ucdmc.ucdavis.edu"
	Set server.port=25

	Set status=server.Send(msg)
    Quit $$$OK
}

ClassMethod ShowLog(ByRef output As %GlobalCharacterStream, namespaces As %String = "")
{
	new $NAMESPACE
	
	set output=##class(%GlobalCharacterStream).%New()
	
	for tNS=1:1:$L(namespaces,",") {
		set ns=$p(namespaces,",",tNS)			//set ns=$NAMESPACE
		set $NAMESPACE=ns
	 
	 }		
	quit $$$OK
}

Method GenerateReport(ByRef output As %GlobalCharacterStream, namespaces As %String = "") As %Status
{
	#DIM tConfigName
	#DIM tError
	#DIM tCount
	#DIM tAlert
	#DIM tNum
	#DIM tSource
	#DIM tIsError
	
	set tOrigNS=$NAMESPACE
	new $NAMESPACE
	set output=##class(%GlobalCharacterStream).%New()
		
	do ..AddStyle(.output)
			
	do output.Write("<Table id=""t02"">")
	do output.Write("<Table class=""a"">")	
	
	for tNS=1:1:$L(namespaces,",") {
		set tNamespace=$p(namespaces,",",tNS)
		do output.Write("<tr>")
		do ..FindWarnings(.output,tNamespace)
    
    	do ..FindSuspends(.output,tNamespace)
    
    	do ..FindQueues(.output,tNamespace)
    	
    	do ..FindAlerts(.output,tNamespace)
          	
    	do output.Write("</tr>")

	}

	do output.Write("<tr><th class=""break"" colspan=""6"">&nbsp;</th></tr></table>")
   	do output.Write("<td>")	
   	do output.Write("<Table>")

	do ..FindDiskSpace(.output,tOrigNS)   
	
	do ..FolderSpaceUtilization(.output)
	
	do output.Write("</Table>")
	do output.Write("</td>")
    do output.Write("</tr>")
    
    do output.Write("<tr>")
    do output.Write("<td>")	
   	do output.Write("<Table>")
    do ..FindCertificateExpiration(.output)	
	do output.Write("</Table>")
	do output.Write("</td>")
    do output.Write("</tr>")

	do output.Write("<tr>")
    do output.Write("<td>")	
   	do output.Write("<Table>")
	do ..FindX509CertificateExpiration(.output)
	do output.Write("</Table>")
	do output.Write("</td>")
    do output.Write("</tr>")



	do output.Write("</table>")
	
	
	do output.Write("<table id=""t01"">")
	do output.Write("<tr><th class=""ledgend"">"_"Legend"_"</th></tr>")
	do output.Write("<tr><td>Error Threshold High Value: "_..ErrorThresholdHigh_"</td></tr>")
	do output.Write("<tr><td>Error Threshold Warn Value: "_..ErrorThresholdElevated_"</td></tr>")
	do output.Write("<tr><td>Warning Threshold High Value: "_..WarnThresholdHigh_"</td></tr>")
	do output.Write("<tr><td>Warning Threshold Warn Value: "_..WarnThresholdElevated_"</td></tr>")
	do output.Write("<tr><td>Alert Threshold High Value: "_..AlertThresholdHigh_"</td></tr>")
	do output.Write("<tr><td>Alert Threshold Warn Value: "_..AlertThresholdElevated_"</td></tr>")
	do output.Write("<tr><td>Total Threshold High Value: "_..CombinedThresholdHigh_"</td></tr>")
	do output.Write("<tr><td>Total Threshold Warn Value: "_..CombinedThresholdElevated_"</td></tr>")
	do output.Write("<tr><td>Suspend Threshold High Value: "_..SuspendThresholdHigh_"</td></tr>")
	do output.Write("<tr><td>Suspend Threshold Warn Value: "_..SuspendThresholdElevated_"</td></tr>")
	do output.Write("<tr><td>Queued Threshold High Value: "_..QueueThresholdHigh_"</td></tr>")
	do output.Write("<tr><td>Queued Threshold Warn Value: "_..QueueThresholdElevated_"</td></tr>")
	do output.Write("</table>")
}

Method FindWarnings(ByRef output As %Stream, namespaces As %String = "")
{
	//Error Warning Alert Table  
    do output.Write("<td>")	
 	  do output.Write("<Table>")
 	  set tInst = ##class(UCDavis.Rule.FunctionSet).Environment()
  	  set tStart = $zdt($zdt($h-1,-3),3,1)
 	  set tEnd = $zdt($zdt($H-1_",86399",-3),3,1)
 	
 	  for tNS=1:1:$L(namespaces,",") {
		set ns=$p(namespaces,",",tNS)			//set ns=$NAMESPACE
		set $NAMESPACE=ns
		&SQL(DECLARE C1 CURSOR FOR
			 SELECT %EXACT(ConfigName),
			 Count(Case When %External(Type)='Error' THEN (1) ELSE NULL END) as ECount,
			 Count(Case When %External(Type)='Warning' THEN (1) ELSE NULL END) as WCount,
			 Count(Case When %External(Type)='Alert' THEN (1) ELSE NULL END) as ACount,
			 Count(*) as AllCount 
			 INTO :tConfigName, :tECount, :tWCount, :tACount, :tAllCount
			 FROM Ens_Util.Log
			 WHERE %EXTERNAL(Type) in ('Error','Warning','Alert') AND TimeLogged between :tStart and :tEnd
			 GROUP BY ConfigName
			 ORDER BY ConfigName ASC)
	 	&SQL(OPEN C1)
		&SQL(FETCH C1)
		
		
		do output.Write("<tr><th class=""namespace"" colspan=""5"">"_ns_" Error Warning Messages"_"</th></tr>")
		do output.Write("<tr><th class=""configitem"">"_"Configuration Name"_"</th><th class=""value"">"_"Errors"_"</th><th class=""value"">"_"Warnings"_"</th><th class=""value"">"_"Alert"_"</th><th class=""value"">"_"Total"_"</th></tr>")

		While (SQLCODE = 0) {
			
			do output.Write("<tr>")
			do output.Write("<td class=""configitem"">")
			do output.Write("<a href="""_$case(tInst,"TEST":"Http://stratus:9010/csp/healthshare/","DEV":"http://ensemble-dev:9012/csp/healthshare/","PROD":"http://ensemble-prod.ucdmc.ucdavis.edu:9011/csp/healthshare/")_ns_"/EnsPortal.EventLog.zen?SOURCE="_tConfigName_""">")
			do output.Write(tConfigName)
			do output.Write("</a>")
			do output.Write("</td>")
			do output.Write("<td class="""_$s(tECount>..ErrorThresholdHigh:"value-high",tECount>..ErrorThresholdElevated:"value-elevated",1:"value-normal")_""">"_$fnumber(tECount,",")_"</td>")
			do output.Write("<td class="""_$s(tWCount>..WarnThresholdHigh:"value-high",tWCount>..WarnThresholdElevated:"value-elevated",1:"value-normal")_""">"_$fnumber(tWCount,",")_"</td>")
			do output.Write("<td class="""_$s(tACount>..AlertThresholdHigh:"value-high",tACount>..AlertThresholdElevated:"value-elevated",1:"value-normal")_""">"_$fnumber(tACount,",")_"</td>")
			do output.Write("<td class="""_$s(tAllCount>..CombinedThresholdHigh:"value-high",tAllCount>..CombinedThresholdElevated:"value-elevated",1:"value-normal")_""">"_$fnumber(tAllCount,",")_"</td>")
			do output.Write("</tr>")
			&SQL(FETCH C1)
		}
 		&SQL(CLOSE C1)
 		do output.Write("<tr><th class=""break"" colspan=""5"">&nbsp;</th></tr>")
 	   }
	  do output.Write("</table>")
 	 do output.Write("</td>")
}

Method FindAlerts(ByRef output As %Stream, namespaces As %String = "")
{
    //Alert Messages 
    do output.Write("<td>")	 	  
  	  do output.Write("<Table>")	
	  set tInst = ##class(UCDavis.Rule.FunctionSet).Environment()
  	  set tStart = $zdt($zdt($h-1,-3),3,1)
 	  set tEnd = $zdt($zdt($H-1_",86399",-3),3,1)
  	  ;set tStart = $zdate($H-1,3)_" 00:00:00"
 	  ;set tEnd = $zdate($H-1,3)_" 23:59:59"
 	
 	  for tNS=1:1:$L(namespaces,",") {
		set ns=$p(namespaces,",",tNS)			//set ns=$NAMESPACE
		set $NAMESPACE=ns
	
  		    &SQL(DECLARE C1 CURSOR FOR
			SELECT %EXACT(TargetConfigName) As Target,
			 Count(*) as Num 
			 INTO :tTarget, :tNum
			 FROM Ens.MessageHeader
			 WHERE %EXTERNAL(SourceConfigName) = 'Ens.Alert'
			 AND TimeCreated BETWEEN :tStart and :tEnd
			 GROUP BY TargetConfigName
			 ORDER BY Num DESC)
	 		&SQL(OPEN C1)
			&SQL(FETCH C1)
	
			do output.Write("<tr><th class=""namespace"" colspan=""2"">"_ns_" Alert Messages"_"</th></tr>")
			do output.Write("<tr><th class=""configitem"">"_"Target Name"_"</th><th class=""value"">"_"Count"_"</th>")
	
			While (SQLCODE = 0) {
			  do output.Write("<tr>")
			  do output.Write("<td class=""configitem"">")
			  do output.Write("<a href="""_$case(tInst,"TEST":"Http://stratus:9010/csp/healthshare/","DEV":"http://ensemble-dev:9012/csp/healthshare/","PROD":"http://ensemble-prod.ucdmc.ucdavis.edu:9011/csp/healthshare/")_ns_"/EnsPortal.MessageViewer.zen?SOURCEORTARGET="_tTarget_""">")
			  do output.Write(tTarget)
			  do output.Write("</a>")
			  do output.Write("</td>")
			  do output.Write("<td class="""_$s(tNum>..AlertThresholdHigh:"value-high",tNum>..AlertThresholdElevated:"value-elevated",1:"value-normal")_""">"_$fnumber(tNum,",")_"</td>")
			  do output.Write("</tr>")
			  &SQL(FETCH C1)
			}
 		    &SQL(CLOSE C1)
  		    do output.Write("<tr><th class=""break"" colspan=""2"">&nbsp;</th></tr>")
 	    }
 	    
        do output.Write("</Table>")
      do output.Write("</td>")
}

Method FindSuspends(ByRef output As %Stream, namespaces As %String = "")
{
    //Suspended Table 
    do output.Write("<td>")	 	  
  	  do output.Write("<Table>")	
	  set tInst = ##class(UCDavis.Rule.FunctionSet).Environment()
   	  set tStart = $zdt($zdt($h-1,-3),3,1)
 	  set tEnd = $zdt($zdt($H-1_",86399",-3),3,1)
	  ;set tStart = $zdate($H-1,3)_" 00:00:00"
 	  ;set tEnd = $zdate($H-1,3)_" 23:59:59"
 	
 	  for tNS=1:1:$L(namespaces,",") {
		set ns=$p(namespaces,",",tNS)			//set ns=$NAMESPACE
		set $NAMESPACE=ns
	
  		    &SQL(DECLARE C2 CURSOR FOR
			SELECT %EXACT(SourceConfigName) As Source,
			 IsError,
			 Count(*) as Num 
			 INTO :tSource, :tIsError, :tNum
			 FROM Ens.MessageHeader
			 WHERE %EXTERNAL(Status) = 'Suspended'
			 GROUP BY SourceConfigName, IsError
			 ORDER BY Num DESC)
	 		&SQL(OPEN C2)
			&SQL(FETCH C2)
	
			do output.Write("<tr><th class=""namespace"" colspan=""2"">"_ns_" Suspended Messages"_"</th></tr>")
			do output.Write("<tr><th class=""configitem"">"_"Source Name"_"</th><th class=""value"">"_"Count"_"</th>")
	
			While (SQLCODE = 0) {
			  do output.Write("<tr>")
			  do output.Write("<td class=""configitem"">")
			  do output.Write("<a href="""_$case(tInst,"TEST":"http://stratus:9010/csp/healthshare/","DEV":"http://ensemble-dev:9012/csp/healthshare/","PROD":"http://ensemble-prod.ucdmc.ucdavis.edu:9011/csp/healthshare/")_ns_"/EnsPortal.SuspendedMsg.zen?$NAMESPACE="_ns_""">")
			  do output.Write(tSource)
			  do output.Write("</a>")
			  do output.Write("</td>")
			  do output.Write("<td class="""_$s(tNum>..SuspendThresholdHigh:"value-high",tNum>..SuspendThresholdElevated:"value-elevated",1:"value-normal")_""">"_$fnumber(tNum,",")_"</td>")
			  do output.Write("</tr>")
			  &SQL(FETCH C2)
			}
 		    &SQL(CLOSE C2)
  		    do output.Write("<tr><th class=""break"" colspan=""2"">&nbsp;</th></tr>")
 	    }
 	    
        do output.Write("</Table>")
      do output.Write("</td>")
}

Method FindQueues(ByRef output As %Stream, namespaces As %String = "")
{
    //Queued Table
    do output.Write("<td>")	
     do output.Write("<Table>")
  	 set statement=##class(%SQL.Statement).%New()
     set tInst = ##class(UCDavis.Rule.FunctionSet).Environment()
  	 set tStart = $zdt($zdt($h-1,-3),3,1)
 	 set tEnd = $zdt($zdt($H-1_",86399",-3),3,1)
  	 ;set tStart = $zdate($H-1,3)_" 00:00:00"
 	 ;set tEnd = $zdate($H-1,3)_" 23:59:59"
 	
 	 for tNS=1:1:$L(namespaces,",") {
		set ns=$p(namespaces,",",tNS)			//set ns=$NAMESPACE
		set $NAMESPACE=ns
		
		do output.Write("<tr><th class=""namespace"" colspan=""2"">"_ns_" Queued Messages"_"</th></tr>")
		do output.Write("<tr><th class=""configitem"">"_"Configuration Name"_"</th><th class=""value"">"_"Count"_"</th></tr>")
				
		set status=statement.%PrepareClassQuery("Ens.Queue","Enumerate")
        if $$$ISERR(status) { do $system.OBJ.DisplayError(status) }
        set resultset=statement.%Execute()
        k tQueue
        while resultset.%Next() {
                set tName=resultset.%Get("Name")
                set tCount=resultset.%Get("Count")
               If tCount >0 {
                set tQueue($j(tCount,15)_tName)=tName_"|"_tCount}
                }
	        set name=$O(tQueue(""),-1) 
             while name]"" {
	 		     set tFS=tQueue(name)
                 ;write !, $P(tFS,"|",1)_" - "_$P(tFS,"|",2)
                 do output.Write("<tr>")
	             do output.Write("<td class=""configitem"">")
                 do output.Write("<a href="""_$case(tInst,"TEST":"http://stratus:9010/csp/healthshare/","DEV":"http://ensemble-dev:9012/csp/healthshare/","PROD":"http://ensemble-prod.ucdmc.ucdavis.edu:9011/csp/healthshare/")_ns_"/EnsPortal.Queues.zen?QUEUE="_$P(tFS,"|",1)_""">")
				 do output.Write($P(tFS,"|",1))
				 do output.Write("</a>")
				 do output.Write("</td>")
                 do output.Write("<td class="""_$s($P(tFS,"|",2)>..QueueThresholdHigh:"value-high",$P(tFS,"|",2)>..QueueThresholdElevated:"value-elevated",1:"value-normal")_""">"_$fnumber($P(tFS,"|",2),",")_"</td>")
                 do output.Write("</tr>")
                 set name=$O(tQueue(name),-1)
                 }	
		do output.Write("<tr><th class=""break"" colspan=""2"">&nbsp;</th></tr>")
 	   }
	   do output.Write("</Table>")
	  do output.Write("</td>")
}

ClassMethod GetExpiration(certName As %String) As %String
{
	try {
		set ssl=##class(Security.SSLConfigs).%OpenId(certName)
		set cert=ssl.GetCertificate()
		set ret=$ZDTH($SYSTEM.Encryption.X509GetField(cert,"ValidityNotAfter"),6)
	} catch ex {
		;w ex
		s ret=""
	}
	quit ret
}

Method FindCertificateExpiration(ByRef output As %Stream)
{
	//Folder Space Utilization Table
    do output.Write("<tr><th class=""namespace"" colspan=""2"">Certificate Expiration"_"</th></tr>")
	do output.Write("<tr><th class=""configitem"">"_"Certificate Name"_"</th><th class=""value"">"_"Expiration Date"_"</th></tr>")	

	n $NAMESPACE
	s $NAMESPACE="%SYS"

	set statement=##class(%SQL.Statement).%New()
	set status=statement.%PrepareClassQuery("Security.SSLConfigs","Detail")
	if $$$ISERR(status) { do $system.OBJ.DisplayError(status) }
	set resultset=statement.%Execute()
	 while resultset.%Next() {
		set tName=resultset.%Get("Name")
		set tCertificateFile=resultset.%Get("CertificateFile")
		if tCertificateFile]"" {
			s exp=..GetExpiration(tName)
			do output.Write("<tr>")
			do output.Write("<td class=""configitem"">"_tName_"</td>")
			do output.Write("<td class="""_$s(((+exp-+$h)<0):"value-high",((+exp-+$h)<=30):"value-elevated",1:"value-normal")_""">"_$ZD(exp)_"</td>")
			do output.Write("</tr>")
			} 
	 	}
 	do output.Write("<tr><th class=""break"" colspan=""2"">&nbsp;</th></tr>")
}

Method FindX509CertificateExpiration(ByRef output As %Stream)
{
	//Folder Space Utilization Table
    do output.Write("<tr><th class=""namespace"" colspan=""2"">X509 Certificate Expiration"_"</th></tr>")
	do output.Write("<tr><th class=""configitem"">"_"X509 Certificate Name"_"</th><th class=""value"">"_"Expiration Date"_"</th></tr>")	

	n $NAMESPACE
	s $NAMESPACE="%SYS"

	set statement=##class(%SQL.Statement).%New()
	set status=statement.%PrepareClassQuery("%SYS.X509Credentials","ListAll")
	if $$$ISERR(status) { do $system.OBJ.DisplayError(status) }
	set resultset=statement.%Execute()
	while resultset.%Next() {
		set tName=resultset.%Get("Alias")
		set tCertificate=resultset.%Get("Certificate")
		set exp=$ZDTH($SYSTEM.Encryption.X509GetField(tCertificate,"ValidityNotAfter"),6)
		do output.Write("<tr>")
		do output.Write("<td class=""configitem"">"_tName_"</td>")
		do output.Write("<td class="""_$s(((+exp-+$h)<0):"value-high",((+exp-+$h)<=30):"value-elevated",1:"value-normal")_""">"_$ZD(exp)_"</td>")
		do output.Write("</tr>")
	}
 	do output.Write("<tr><th class=""break"" colspan=""2"">&nbsp;</th></tr>")
}

Method FindDiskSpace(ByRef output As %Stream, tOrigNS As %String = "")
{
	//Disk Space Table
  	set statement=##class(%SQL.Statement).%New()
    set tInst = ##class(UCDavis.Rule.FunctionSet).Environment()
  	set tStart = $zdate($H-1,3)_" 00:00:00"
 	set tEnd = $zdate($H-1,3)_" 23:59:59"
 	
 	set $NAMESPACE=tOrigNS
 	 ;for tNS=1:1:$L(namespaces,",") {
	;	set ns=$p(namespaces,",",tNS)			//set ns=$NAMESPACE
	;	set $NAMESPACE=ns
		
		do output.Write("<tr><th class=""namespace"" colspan=""6"">Database Space Utilization"_"</th></tr>")
		do output.Write("<tr><th class=""configitem"">"_"Database Name"_"</th><th class=""value"">"_"Size"_"</th><th class=""value"">"_"Available"_"</th><th class=""value"">"_"% Free"_"</th><th class=""value"">"_"Filesystem Free"_"</th><th class=""value"">"_"Directory"_"</th></tr>")
				
		set statement=##class(%SQL.Statement).%New()
        set status=statement.%PrepareClassQuery("%SYS.DatabaseQuery","FreeSpace")
        if $$$ISERR(status) { do $system.OBJ.DisplayError(status) }
        set resultset=statement.%Execute()
        k tFreespace
        while resultset.%Next() {
	 		set size=resultset.%Get("Size")
	 		set name=resultset.%Get("DatabaseName")
	 		set sizeBytes=..SizeToBytes(size)
	 		set tFreespace(name)=name_"|"_size_"|"_resultset.%Get("Free")_"|"_resultset.%Get("DiskFreeSpace")_"|"_resultset.%Get("Available")_"|"_resultset.%Get("Directory")
 		}
 		;zw tFreespace
 		set tShowDatabases = ..Namespaces _ ",UCDAVIS00"
  		set name=$O(tFreespace(""),1,tFS)
  		while name]"" {
	 		;set tFS=tFreespace(name)
 			if tShowDatabases[$P(tFS,"|",1) {
				;write !, $P(tFS,"|",1)_" - "_$P(tFS,"|",2)
				do output.Write("<tr>")
				do output.Write("<td class=""configitem"">"_$j($P(tFS,"|",1),10)_"</td>")
				do output.Write("<td class=""value"">"_$P(tFS,"|",2)_"</td>")
				do output.Write("<td class=""value"">"_$P(tFS,"|",5)_"</td>")
				do output.Write("<td class=""value"">"_$P(tFS,"|",3)_"</td>")
				do output.Write("<td class=""value"">"_$P(tFS,"|",4)_"</td>")
				do output.Write("<td class=""value"">"_$P(tFS,"|",6)_"</td>")
				do output.Write("</tr>")
				
 			    set tDBM=##class(UCDavis.DatabaseMetrics).%New()
 			    set tDBM.DatabaseName=name
 			    set tDBM.Size=..SizeToBytes($P(tFS,"|",2))
 			    set tDBM.PercentFree=$P(tFS,"|",3)
 			    set tDBM.FileSystemFree=..SizeToBytes($P(tFS,"|",4))
 			    set tDBM.Available=..SizeToBytes($P(tFS,"|",5))
 			    set tDBM.Directory=$P(tFS,"|",6)
 			    set tDBM.MeasureDate=+$H
 			    do tDBM.%Save()
 			}
			set name=$O(tFreespace(name),1,tFS)
  		}
  			
		do output.Write("<tr><th class=""break"" colspan=""6"">&nbsp;</th></tr>")
 	   ;}
}

Method FolderSpaceUtilization(ByRef output As %Stream)
{
	//Folder Space Utilization Table
    do output.Write("<tr><th class=""namespace"" colspan=""4"">Folder Space Utilization"_"</th></tr>")
	do output.Write("<tr><th class=""configitem"">"_"Path"_"</th><th class=""value"">"_"Total Size"_"</th><th class=""value"">"_"Free"_"</th><th class=""value"">"_"% Free"_"</th></tr>")	
       
       for tPath=1:1:$L(..FilePathToMonitor,",") {
	        set tPathName=$p(..FilePathToMonitor,",",tPath)
            set tPathNameFix=$replace(tPathName,"/hs/","/hsexport/")
            set tPercent=""
        	set tGetFileSize=##Class(%Library.File).GetDirectorySpace(tPathNameFix,.free,.total,2)
			set:+total'=0 tPercent=free/total*100
			do output.Write("<tr>")
		      do output.Write("<td class=""configitem"">"_tPathName_"</td>")
			  do output.Write("<td class=""value"">"_total_"GB</td>")
			  do output.Write("<td class=""value"">"_free_"GB</td>")
			  do output.Write("<td class="""_$S($FN(tPercent,,2)<10:"value-high",$FN(tPercent,,2)<20:"value-elevated",1:"value-normal")_""">"_$FN(tPercent,,2)_"</td>")
			  do output.Write("</tr>")
		}
  			
		do output.Write("<tr><th class=""break"" colspan=""6"">&nbsp;</th></tr>")
}

Method AddStyle(ByRef output As %GlobalCharacterStream)
{
	do output.Write("<style>")
	do output.Write("* {box-sizing: border-box;}")
	do output.Write("#t02 .a {vertical-align: top;}")
	do output.Write("table {table-layout:fixed; border-collapse: collapse;}")
	do output.Write("table, th, td {vertical-align: top; border: 1px solid black;padding: 2px 8px;}")
	do output.Write("tr:nth-child(even) {background-color: #e2e2e2;}")
	do output.Write("tr:hover {background-color: #ccc;}")
	do output.Write("th.break {background-color:white;border: 0px solid white;}")
	do output.Write("th {background-color:#022851;color:white;font-family:Arial,Helvetica,sans-serif;}")
	do output.Write("th.namespace {vertical-align: top; background-color:#FFBF00;color:#022851;font-size:20pt;text-align:left;}")
	do output.Write("th.value {vertical-align: top; min-width:75px;}")
	do output.Write("td.value-high {min-width:75px;background-color:#FF6347;}")
	do output.Write("td.EnabledStatusNo {min-width:75px;background-color:#FF6347;text-align: right;}")
	do output.Write("td.value-elevated {min-width:75px;background-color:yellow;}")
	do output.Write("td.value {min-width:75px;color:#022851;}")
	do output.Write("th.configitem {vertical-align: top; min-width:350px;text-align:left}")
	do output.Write("td.value {text-align: right;}")
	do output.Write("td.configitem {font-weight: bold;}")
	do output.Write("#t01 th.ledgend {backgroud-color:#022851;color:white;text-align:left;}")
	do output.Write("</style>")
	quit
}

Method SizeToBytes(size) As %Integer
{
	Try {
		set bytes=(+size)*$case($e(size,*-1,*),"GB":1000000000,"MB":1000000,"KB":1000,1:1)
	}
	Catch ex {
		set bytes=-1
	}
	quit bytes
}

}
