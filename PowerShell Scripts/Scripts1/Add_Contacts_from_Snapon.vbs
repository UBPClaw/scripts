On Error Resume Next

' Input File. Format is Displayname, First Name, Last Name, Email Address
strFileInput = "C:\Workdir\snapon gal\SOTGAL\test.csv"

' Log File.
strFileOutput = "C:\Workdir\snapon gal\SOTGAL\test.log"


' Define Named Constants.
Const For_Reading = 1
Const For_Writing = 2
Const For_Appending = 8
Const ADS_PROPERTY_CLEAR = 1
Const ADS_PROPERTY_UPDATE = 2
Const ADS_PROPERTY_APPEND = 3
Const ADS_PROPERTY_DELETE = 4

' Create a Script Runtime FileSystemObject.	
Set objFSO = CreateObject("Scripting.FileSystemObject")

' Run Input File through GetInput Function.
strInput = GetInput(strFileInput)

' Get contact info by breaking input stream into array at line breaks.
arrUserRecords = Split(strInput, vbCrLf)

' Check to see if the output file exists. If so, open it for appending.
' If not, create it and open it for writing.
If objFSO.FileExists(strFileOutput) Then
  Set objOutputFile = objFSO.OpenTextFile (strFileOutput, FOR_APPENDING)
Else
  Set objOutputFile = objFSO.CreateTextFile(strFileOutput)
End If
If Err <> 0 Then
  Wscript.Echo "Unable to open " & strFileOutput & " for output."
  WScript.Quit
End If

' Write header for Log file.
objOutputFile.WriteLine "----------------------------------------"
objOutputFile.WriteLine "Script start time: " & Time & " " & Date
objOutputFile.WriteLine "----------------------------------------"

' Loop through Array breaking variable info at ,
For Each strUserRecords In arrUserRecords
	arrUserContacts = Split(strUserRecords, ",")
		strName = arrUserContacts(0)
		strFirstName = arrUserContacts(1)
		strLastName = arrUserContacts(2)
		strExternalEmail = arrUserContacts(3)
		strContainer = "CN=SnapOn,CN=Users"
		
' Clear any errors
	Err.Clear
		
' Connect to Container
	Set objRootDSE = GetObject("LDAP://rootDSE")
	If strContainer = "" Then
  	Set objContainer = GetObject("LDAP://" & _
	    objRootDSE.Get("defaultNamingContext"))
	Else
	  Set objContainer = GetObject("LDAP://" & strContainer & "," & _
	    objRootDSE.Get("defaultNamingContext"))
	End If

' Create Contact	
	Set objContact = objContainer.Create("contact", "cn=" & strName)
	objContact.Put "givenName", strFirstName
	objContact.Put "sn", strLastName
	objContact.Put "displayName", strName
	objContact.Put "mail", strExternalEmail
	objContact.SetInfo
	
' MailEnable Contact
	Set objRecip = objContact
	FwdAddress = "smtp:" & strExternalEmail
	objRecip.MailEnable FwdAddress
	objContact.SetInfo

' Log results
	If Err.Number <> 0 Then
		objOutputFile.WriteLine "FAILED:  " & strName
	Else
		objOutputFile.WriteLine "SUCCESS: " & strName
			
	End If
Next

' Close Log file
objOutputFile.WriteLine "----------------------------------------"
objOutputFile.WriteLine "Script stop time: " & Time & " " & Date
objOutputFile.WriteLine "----------------------------------------"
objOutputFile.Close

'******************************************************************************

Function GetInput(strFileInput)

If objFSO.FileExists(strFileInput) Then
  Set objInputFile = objFSO.GetFile(strFileInput)
  If objInputFile.Size > 0 Then
    Set objInputFile = objFSO.OpenTextFile(strFileInput, FOR_READING)
    strInputStream = objInputFile.ReadAll
    objInputFile.Close
    GetInput = strInputStream
  Else
    Wscript.Echo strFileInput & " is empty."
    WScript.Quit
  End If
Else
  WScript.Echo strFileInput & " does not exist on this computer."
  WScript.Quit
End If

End Function

'******************************************************************************