﻿#Generated Form Function
function GenerateForm {
########################################################################
# Code Generated By: SAPIEN Technologies PrimalForms 2009 v1.0.0.0
# Generated On: 11/12/2008 4:11 PM
# Generated By: bd0794
########################################################################

#region Import the Assembles
[reflection.assembly]::loadwithpartialname("System.Drawing") | Out-Null
[reflection.assembly]::loadwithpartialname("System.Windows.Forms") | Out-Null
#endregion

#region Generated Form Objects
$form1 = New-Object System.Windows.Forms.Form
$richTextBox1 = New-Object System.Windows.Forms.RichTextBox
$listBox1 = New-Object System.Windows.Forms.ListBox
#endregion Generated Form Objects

#----------------------------------------------
#Generated Event Script Blocks
#----------------------------------------------
#Provide Custom Code for events specified in PrimalForms.
$handler_listBox1_SelectedIndexChanged= 
{
if ($listBox1.SelectedItem -eq "SCRATCH POOL")
{
$richtextbox1.text = ""
$gSlots = psexec \\gremlin "D:\program files\veritas\volmgr\bin\vmquery" -p 4|
	where-object {$_-match "robot slot:"}|
	ForEach-Object {$_-replace "robot ",""}|
	ForEach-Object {$_-replace "            ",""}|
	ForEach-Object {$_-replace "Slot:",""}|
	Foreach-object {$_+"`n"} | Sort-Object
	$l1="          ------------------------------------------------------------------------------------------------------------------------------`n"
	$l2="                              There is/are " + " " + $gSlots.count + " " + "Tape(s) Available in the Scratch Pool`n"
	$l3="          ------------------------------------------------------------------------------------------------------------------------------`n`n"
	$l4="SLOTS`n"
	$l5="------------`n"
    $richTextBox1.Text = $l1 + $l2 + $l3 + $l4 + $l5 + $gSlots 
}

Elseif ($listBox1.SelectedItem -eq "VOLUME POOLS")
{
$richtextbox1.text = ""
$poolNum = psexec \\gremlin "D:\program files\veritas\volmgr\bin\vmpool" -list_all |
	Where-Object { $_-match "pool number" } |
	ForEach-Object {$_-replace "pool number:  ",""}
	$poolNum.count

	$poolname = psexec \\gremlin "D:\program files\veritas\volmgr\bin\vmpool" -list_all |
	Where-Object { $_-match "pool name" } |
	ForEach-Object {$_-replace "pool name:  ",""}
	
		$i = 0 
		Write-Host   Pool Number and Name
		Write-Host "--------------------------"
 		$Vpools = $(while ($i -le $poolNum.count) {$poolNum[$i]+" "+$poolname[$i];$i++}) |
		Foreach-object {$_+"`n"}
 
 
 		$richTextBox1.Text = $Vpools
}


Elseif ($listBox1.SelectedItem -eq "DAILY BUPS")
{
$richtextbox1.font = "courier"
$richtextbox1.text = ""
$CurDate = Get-Date -F M/dd/yyyy
$DOW = ((get-date).dayofweek.toString())
$Schedule = gc \\gremlin\d$\bkd_logs\schedules\DAILYBUPSCHED.txt | Sort-Object |
	Where-Object {$_-match $DOW} |
	Where-Object {$_-notmatch "000:00:00"}
	
	$tempPol = New-Object string[] 4
	
	
	foreach ($Policy in $Schedule)
			{
				for ($i =0;$i -lt 4;$i++) 
				{
	 					$tempPol[$i] = $Policy.split(",",[StringSplitOptions]::RemoveEmptyEntries)[$i]							
				}
						$pout = "{0,-41} {1,-7} {2,-5} {3,-5} "-f $tempPol[0],$tempPol[1],$tempPol[2],$tempPol[3] 
						$richTextBox1.Text = $richTextBox1.Text + $pout + "`n" 
						 
						
					}
					$richTextBox1.Text = $richTextBox1.Text + "`n" + "There are" + " " + $Schedule.count + " " + "Scheduled Backups for" + " " + $CurDate
					}
					
					
					
Elseif ($listBox1.SelectedItem -eq "DAILY BUPS Monday")	
{
	
$richtextbox1.font = "courier"
$richtextbox1.text = ""				
$Schedule = gc \\gremlin\d$\bkd_logs\schedules\DAILYBUPSCHED.txt | Sort-Object |
	Where-Object {$_-match "Monday"} |
	Where-Object {$_-notmatch "000:00:00"}
	
	$tempPol = New-Object string[] 4
	
	
	foreach ($Policy in $Schedule)
			{
				for ($i =0;$i -lt 4;$i++) 
				{
	 					$tempPol[$i] = $Policy.split(",",[StringSplitOptions]::RemoveEmptyEntries)[$i]							
				}
						$pout = "{0,-41} {1,-7} {2,-5} {3,-5} "-f $tempPol[0],$tempPol[1],$tempPol[2],$tempPol[3]  
						$richTextBox1.Text = $richTextBox1.Text + $pout + "`n"
						 
						
					}
					$richTextBox1.Text = $richTextBox1.Text + "`n" + "There are" + " " + $Schedule.count + " " + "Scheduled Backups for" + " " + "Monday"
}



Elseif ($listBox1.SelectedItem -eq "DAILY BUPS Tuesday")	
{
	
$richtextbox1.font = "courier"
$richtextbox1.text = ""				
$Schedule = gc \\gremlin\d$\bkd_logs\schedules\DAILYBUPSCHED.txt | Sort-Object |
	Where-Object {$_-match "Tuesday"} |
	Where-Object {$_-notmatch "000:00:00"}
	
	$tempPol = New-Object string[] 4
	
	
	foreach ($Policy in $Schedule)
			{
				for ($i =0;$i -lt 4;$i++) 
				{
	 					$tempPol[$i] = $Policy.split(",",[StringSplitOptions]::RemoveEmptyEntries)[$i]							
				}
						$pout = "{0,-41} {1,-7} {2,-5} {3,-5} "-f $tempPol[0],$tempPol[1],$tempPol[2],$tempPol[3]  
						$richTextBox1.Text = $richTextBox1.Text + $pout + "`n"
						 
						
					}
					$richTextBox1.Text = $richTextBox1.Text + "`n" + "There are" + " " + $Schedule.count + " " + "Scheduled Backups for" + " " + "Tuesday"
}

Elseif ($listBox1.SelectedItem -eq "DAILY BUPS Wednesday")	
{
	
$richtextbox1.font = "courier"
$richtextbox1.text = ""				
$Schedule = gc \\gremlin\d$\bkd_logs\schedules\DAILYBUPSCHED.txt | Sort-Object |
	Where-Object {$_-match "Wednesday"} |
	Where-Object {$_-notmatch "000:00:00"}
	
	$tempPol = New-Object string[] 4
	
	
	foreach ($Policy in $Schedule)
			{
				for ($i =0;$i -lt 4;$i++) 
				{
	 					$tempPol[$i] = $Policy.split(",",[StringSplitOptions]::RemoveEmptyEntries)[$i]							
				}
						$pout = "{0,-41} {1,-7} {2,-5} {3,-5} "-f $tempPol[0],$tempPol[1],$tempPol[2],$tempPol[3]  
						$richTextBox1.Text = $richTextBox1.Text + $pout + "`n"
						 
						
					}
					$richTextBox1.Text = $richTextBox1.Text + "`n" + "There are" + " " + $Schedule.count + " " + "Scheduled Backups for" + " " + "Wednesday"
}
	
	
	
	
	Elseif ($listBox1.SelectedItem -eq "DAILY BUPS Thursday")	
{
	
$richtextbox1.font = "courier"
$richtextbox1.text = ""				
$Schedule = gc \\gremlin\d$\bkd_logs\schedules\DAILYBUPSCHED.txt | Sort-Object |
	Where-Object {$_-match "Thursday"} |
	Where-Object {$_-notmatch "000:00:00"}
	
	$tempPol = New-Object string[] 4
	
	
	foreach ($Policy in $Schedule)
			{
				for ($i =0;$i -lt 4;$i++) 
				{
	 					$tempPol[$i] = $Policy.split(",",[StringSplitOptions]::RemoveEmptyEntries)[$i]							
				}
						$pout = "{0,-41} {1,-7} {2,-5} {3,-5} "-f $tempPol[0],$tempPol[1],$tempPol[2],$tempPol[3]  
						$richTextBox1.Text = $richTextBox1.Text + $pout + "`n"
						 
						
					}
					$richTextBox1.Text = $richTextBox1.Text + "`n" + "There are" + " " + $Schedule.count + " " + "Scheduled Backups for" + " " + "Thursday"
}
	
	
	
	
	
	Elseif ($listBox1.SelectedItem -eq "DAILY BUPS Friday")	
{
	
$richtextbox1.font = "courier"
$richtextbox1.text = ""				
$Schedule = gc \\gremlin\d$\bkd_logs\schedules\DAILYBUPSCHED.txt | Sort-Object |
	Where-Object {$_-match "Friday"} |
	Where-Object {$_-notmatch "000:00:00"}
	
	$tempPol = New-Object string[] 4
	
	
	foreach ($Policy in $Schedule)
			{
				for ($i =0;$i -lt 4;$i++) 
				{
	 					$tempPol[$i] = $Policy.split(",",[StringSplitOptions]::RemoveEmptyEntries)[$i]							
				}
						$pout = "{0,-41} {1,-7} {2,-5} {3,-5} "-f $tempPol[0],$tempPol[1],$tempPol[2],$tempPol[3]  
						$richTextBox1.Text = $richTextBox1.Text + $pout + "`n"
						 
						
					}
					$richTextBox1.Text = $richTextBox1.Text + "`n" + "There are" + " " + $Schedule.count + " " + "Scheduled Backups for" + " " + "Friday"
}
	
	
	
	Elseif ($listBox1.SelectedItem -eq "DAILY BUPS Saturday")	
{
	
$richtextbox1.font = "courier"
$richtextbox1.text = ""				
$Schedule = gc \\gremlin\d$\bkd_logs\schedules\DAILYBUPSCHED.txt | Sort-Object |
	Where-Object {$_-match "Saturday"} |
	Where-Object {$_-notmatch "000:00:00"}
	
	$tempPol = New-Object string[] 4
	
	
	foreach ($Policy in $Schedule)
			{
				for ($i =0;$i -lt 4;$i++) 
				{
	 					$tempPol[$i] = $Policy.split(",",[StringSplitOptions]::RemoveEmptyEntries)[$i]							
				}
						$pout = "{0,-41} {1,-7} {2,-5} {3,-5} "-f $tempPol[0],$tempPol[1],$tempPol[2],$tempPol[3]  
						$richTextBox1.Text = $richTextBox1.Text + $pout + "`n"
						 
						
					}
					$richTextBox1.Text = $richTextBox1.Text + "`n" + "There are" + " " + $Schedule.count + " " + "Scheduled Backups for" + " " + "Saturday"
}
	
	
	Elseif ($listBox1.SelectedItem -eq "DAILY BUPS Sunday")	
{
	
$richtextbox1.font = "courier"
$richtextbox1.text = ""				
$Schedule = gc \\gremlin\d$\bkd_logs\schedules\DAILYBUPSCHED.txt | Sort-Object |
	Where-Object {$_-match "Sunday"} |
	Where-Object {$_-notmatch "000:00:00"}
	
	$tempPol = New-Object string[] 4
	
	
	foreach ($Policy in $Schedule)
			{
				for ($i =0;$i -lt 4;$i++) 
				{
	 					$tempPol[$i] = $Policy.split(",",[StringSplitOptions]::RemoveEmptyEntries)[$i]							
				}
						$pout = "{0,-41} {1,-7} {2,-5} {3,-5} "-f $tempPol[0],$tempPol[1],$tempPol[2],$tempPol[3]  
						$richTextBox1.Text = $richTextBox1.Text + $pout + "`n"
						 
						
					}
					$richTextBox1.Text = $richTextBox1.Text + "`n" + "There are" + " " + $Schedule.count + " " + "Scheduled Backups for" + " " + "Sunday"
}
	
	
}
#----------------------------------------------
#region Generated Form Code
$form1.Name = 'form1'
$form1.Text = 'NBU MGMT CONSOLE'
$form1.DataBindings.DefaultDataSourceUpdateMode = 0
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Width = 1060
$System_Drawing_Size.Height = 757
$form1.ClientSize = $System_Drawing_Size

$richTextBox1.Text = ''
$richTextBox1.TabIndex = 1
$richTextBox1.Name = 'richTextBox1'
$richTextBox1.BackColor = [System.Drawing.Color]::FromArgb(255,191,205,219)
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Width = 925
$System_Drawing_Size.Height = 680
$richTextBox1.Size = $System_Drawing_Size
$richTextBox1.DataBindings.DefaultDataSourceUpdateMode = 0
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 138
$System_Drawing_Point.Y = 51
$richTextBox1.Location = $System_Drawing_Point

$form1.Controls.Add($richTextBox1)

$listBox1.Items.Add('SCRATCH POOL')|Out-Null
$listBox1.Items.Add('VOLUME POOLS')|Out-Null
$listBox1.Items.Add('DAILY BUPS')|Out-Null
$listBox1.Items.Add('DAILY BUPS Monday')|Out-Null
$listBox1.Items.Add('DAILY BUPS Tuesday')|Out-Null
$listBox1.Items.Add('DAILY BUPS Wednesday')|Out-Null
$listBox1.Items.Add('DAILY BUPS Thursday')|Out-Null
$listBox1.Items.Add('DAILY BUPS Friday')|Out-Null
$listBox1.Items.Add('DAILY BUPS Saturday')|Out-Null
$listBox1.Items.Add('DAILY BUPS Sunday')|Out-Null
$listBox1.DataBindings.DefaultDataSourceUpdateMode = 0
$listBox1.Name = 'listBox1'
$listBox1.FormattingEnabled = $True
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Width = 150
$System_Drawing_Size.Height = 680
$listBox1.Size = $System_Drawing_Size
$listBox1.TabIndex = 0
$listBox1.BackColor = [System.Drawing.Color]::FromArgb(255,255,255,225)
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 12
$System_Drawing_Point.Y = 51
$listBox1.Location = $System_Drawing_Point
$listBox1.add_SelectedIndexChanged($handler_listBox1_SelectedIndexChanged)

$form1.Controls.Add($listBox1)

#endregion Generated Form Code

#Show the Form
$form1.ShowDialog()| Out-Null

} #End Function

#Call the Function
GenerateForm
