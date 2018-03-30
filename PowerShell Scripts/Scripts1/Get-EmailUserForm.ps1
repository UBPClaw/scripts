Set-PSDebug -Strict`

trap [Exception] {
  continue
}

function GenerateForm {
[reflection.assembly]::loadwithpartialname("System.Drawing") | Out-Null
[reflection.assembly]::loadwithpartialname("System.Windows.Forms") | Out-Null

$form1 = New-Object System.Windows.Forms.Form
$richTextBox4 = New-Object System.Windows.Forms.RichTextBox
$endDate = New-Object System.Windows.Forms.TextBox
$beginDate = New-Object System.Windows.Forms.TextBox
$userID = New-Object System.Windows.Forms.TextBox
$button1 = New-Object System.Windows.Forms.Button

$handler_button1_Click = {
  $richTextBox4.Text = ''
  $uid = $userID.Text
  $bdate = $beginDate.Text
  $edate = $endDate.Text
  $now = get-date
  $Files = get-childitem \\a4\A4.LOG | where-object {($_.LastWriteTime).Date -ge $bdate -and ($_.LastWriteTime).Date -lt $edate}
  Add-Content "Date,Time,client-ip,Client-hostname,Partner-Name,Server-hostname,server-IP,Recipient-Address,Event-ID,MSGID,Priority,Recipient-Report-Status,total-bytes,Number-Recipients,Origination-Time,Encryption,service-Version,Linked-MSGID,Message-Subject,Sender-Address" -Path c:\temp\emailtemp.csv
  $Files | Select-String $uid | foreach {$_.line.replace("`t",",")} | add-content -path c:\temp\emailtemp.csv
  Import-Csv c:\temp\emailtemp.csv | Where {$_."Event-ID" -eq "1028" -or $_."Event-ID" -eq "1020"} | select Origination-Time,Sender-Address,Recipient-Address,Message-Subject,total-bytes | Export-Csv c:\temp\email_$uid.csv -notype
  Remove-Item c:\temp\emailtemp.csv
  Write-TextBox "Processing is complete please review file c:\temp\email_$uid.csv"
  }

$handler_form1_Load = {
  $userID.Select()
}

$form1.Name = 'form1'
$form1.Text = 'Get Email Info 1.0'
$form1.DataBindings.DefaultDataSourceUpdateMode = 0
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Width = 423
$System_Drawing_Size.Height = 264
$form1.ClientSize = $System_Drawing_Size

$form1.add_Load($handler_form1_Load)

$richTextBox4.Text = ''
$richTextBox4.TabIndex = 4
$richTextBox4.Name = 'richTextBox4'
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Width = 406
$System_Drawing_Size.Height = 160
$richTextBox4.Size = $System_Drawing_Size
$richTextBox4.DataBindings.DefaultDataSourceUpdateMode = 0
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 9
$System_Drawing_Point.Y = 92
$richTextBox4.Location = $System_Drawing_Point

$form1.Controls.Add($richTextBox4)

$endDate.Text = '<Enter End Date>'
$endDate.TabIndex = 3
$endDate.Name = 'endDate'
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Width = 190
$System_Drawing_Size.Height = 23
$endDate.Size = $System_Drawing_Size
$endDate.DataBindings.DefaultDataSourceUpdateMode = 0
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 225
$System_Drawing_Point.Y = 51
$endDate.Location = $System_Drawing_Point

$form1.Controls.Add($endDate)

$beginDate.Text = '<Enter Start Date>'
$beginDate.TabIndex = 2
$beginDate.Name = 'beginDate'
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Width = 190
$System_Drawing_Size.Height = 23
$beginDate.Size = $System_Drawing_Size
$beginDate.DataBindings.DefaultDataSourceUpdateMode = 0
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 9
$System_Drawing_Point.Y = 51
$beginDate.Location = $System_Drawing_Point

$form1.Controls.Add($beginDate)

$userID.Text = '<Enter User Email>'
$userID.TabIndex = 1
$userID.Name = 'userID'
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Width = 190
$System_Drawing_Size.Height = 23
$userID.Size = $System_Drawing_Size
$userID.DataBindings.DefaultDataSourceUpdateMode = 0
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 9
$System_Drawing_Point.Y = 12
$userID.Location = $System_Drawing_Point

$form1.Controls.Add($userID)

$button1.UseVisualStyleBackColor = $True
$button1.Text = 'Process Logs'
$button1.DataBindings.DefaultDataSourceUpdateMode = 0
$button1.TabIndex = 0
$button1.Name = 'button1'
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Width = 89
$System_Drawing_Size.Height = 23
$button1.Size = $System_Drawing_Size
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 326
$System_Drawing_Point.Y = 10
$button1.Location = $System_Drawing_Point
$button1.add_Click($handler_button1_Click)

$form1.Controls.Add($button1)


$form1.ShowDialog()| Out-Null

}

function Write-TextBox {
  param([string]$text)
  $richTextBox4.Text += "$text`n"
}

# Launch the form
GenerateForm

