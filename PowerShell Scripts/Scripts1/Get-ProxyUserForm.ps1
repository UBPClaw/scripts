Set-PSDebug -Strict`

trap [Exception] {
  continue
}

function GenerateForm {
[reflection.assembly]::loadwithpartialname("System.Drawing") | Out-Null
[reflection.assembly]::loadwithpartialname("System.Windows.Forms") | Out-Null

$form1 = New-Object System.Windows.Forms.Form
$richTextBox1 = New-Object System.Windows.Forms.RichTextBox
$UserId = New-Object System.Windows.Forms.TextBox
$button1 = New-Object System.Windows.Forms.Button

$handler_button1_Click = {
  $richTextBox1.Text = ''
  $uid = $UserId.Text
  $now = get-date
  $Files = get-childitem \\yukon\f$\isalogs | where-object {($now - $_.LastWriteTime).Days -lt 30}
  Add-Content "c-ip,cs-username,c-agent,date,time,s-computername,cs-referred,r-host,r-ip,r-port,time-taken,cs-bytes,sc-bytes,cs-protocol,s-operation,cs-uri,s-object-source,sc-status" -Path c:\temp\proxytemp.csv
  $Files | Select-String $uid | foreach {$_.line.replace("`t",",")} | add-content -path c:\temp\proxytemp.csv
  Import-Csv c:\temp\proxytemp.csv | select c-ip,cs-username,date,time,r-host,cs-uri | Export-Csv c:\temp\proxy$uid.csv -notype
  Remove-Item c:\temp\proxytemp.csv
  Write-TextBox "Processing is complete please review file c:\temp\proxy$uid.csv"
  }

$handler_form1_Load = {
  $UserID.Select()
}

$form1.Name = 'form1'
$form1.Text = 'Get Proxy Info 1.0'
$form1.BackColor = [System.Drawing.Color]::FromArgb(255,227,227,227)
$form1.DataBindings.DefaultDataSourceUpdateMode = 0
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Width = 428
$System_Drawing_Size.Height = 300
$form1.ClientSize = $System_Drawing_Size

$form1.add_Load($handler_form1_Load)

$richTextBox1.Text = ''
$richTextBox1.TabIndex = 2
$richTextBox1.Name = 'richTextBox1'
$richTextBox1.Font = New-Object System.Drawing.Font("Courier New",10,0,3,0)
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Width = 343
$System_Drawing_Size.Height = 200
$richTextBox1.Size = $System_Drawing_Size
$richTextBox1.DataBindings.DefaultDataSourceUpdateMode = 0
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 40
$System_Drawing_Point.Y = 61
$richTextBox1.Location = $System_Drawing_Point

$form1.Controls.Add($richTextBox1)

$UserId.Text = '<Enter User Id>'
$UserId.Name = 'UserId'
$UserId.TabIndex = 1
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Width = 200
$System_Drawing_Size.Height = 20
$UserId.Size = $System_Drawing_Size
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 40
$System_Drawing_Point.Y = 21
$UserId.Location = $System_Drawing_Point
$UserId.DataBindings.DefaultDataSourceUpdateMode = 0

$form1.Controls.Add($UserId)

$button1.UseVisualStyleBackColor = $True
$button1.Text = 'Process Logs'
$button1.DataBindings.DefaultDataSourceUpdateMode = 0
$button1.TabIndex = 0
$button1.Name = 'button1'
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Width = 100
$System_Drawing_Size.Height = 23
$button1.Size = $System_Drawing_Size
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 280
$System_Drawing_Point.Y = 19
$button1.Location = $System_Drawing_Point
$button1.add_Click($handler_button1_Click)

$form1.Controls.Add($button1)

$form1.ShowDialog()| Out-Null

}

function Write-TextBox {
  param([string]$text)
  $richTextBox1.Text += "$text`n"
}

# Launch the form
GenerateForm

