<#
# List Menu Function
#>

<#
Purpose: The following action, PromptForAction, will display a list of options to be selected by a user.

Reqiurements:
	If using an array of arrays, specify the name field to be use for the display otherwise the 0th index will be used.
Use: 
	Input an array of arrays or array of names, display a selection list for a user, then return the array or name selected for use in a script.
Result:
	The value returned from the function will be an array.
	This returned array will have the 'result', then with the selected name or array appended.
	The result will either be OK if a selection is made, Nothing if the prompt is closed etc, and Ingore if it times out.
	There is a timeout option (Default 30 seconds) which when enabled will automatically return the first entry in the input array.
#>

#The following assemblies are used and should be included when incorporating this function into your script
[System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms') | Out-Null
[System.Reflection.Assembly]::LoadWithPartialName('System.Drawing.Font') | Out-Null
[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic') | Out-Null

Function PromptForAction ($OptionList, [int]$NameFieldIfArray, [Switch]$TimeoutEnabled, [int]$Timeout, [int]$FontSize, [int]$Width) {

	if ($FontSize -eq 0) {$FontSize = 20}
	if ($Width -eq 0){$Width = [int]([System.Windows.Forms.SystemInformation]::PrimaryMonitorMaximizedWindowSize.Width * .6)-[int]([System.Windows.Forms.SystemInformation]::PrimaryMonitorMaximizedWindowSize.Width * .6)%10}
	[bool]$CanFitY = (([System.Windows.Forms.SystemInformation]::PrimaryMonitorMaximizedWindowSize.Height) -gt (($OptionList.Count * ($FontSize * 2.5 + 10)) + 40))
	#Determine the vertical size for the form based on the number of applications in the array.
	[Int] $myYSize = ($OptionList.Count * ($FontSize * 2.5 + 10)) + 40
	$Form = New-Object System.Windows.Forms.Form
	$Form.StartPosition = 'CenterScreen'
	$Form.Size = new-object System.Drawing.Size(($Width + 16),$myYSize)
	$Form.Text = 'Select the application to launch.'
	$Form.ShowIcon = $false
	$iCount = 0

	
	#Set the timeout at this level so it persists across ticks.
	if ($Timeout -eq 0) {$ResetTime = (Get-Date) + (New-TimeSpan -Days 65535)}
	#Make the timeout virtually indefinite so that the timer function does not error when there is a zero or disabled timeout
	$ResetTime = (Get-Date) + (New-TimeSpan -Seconds $Timeout)
	#The timer tick
	Function DefautActionTick {
		if (((Get-Date) -ge $ResetTime) -and $TimeoutEnabled) {
			$DefaultActionTimer.Stop()
			$Form.Tag = $OptionList[0] #Sets the action output to be the first item in the list.
			$Form.DialogResult = [System.Windows.Forms.DialogResult]::Ignore #Sets the dialog output to valid
			$Form.close()
		}
	}

	if ($TimeoutEnabled) {
		
		$DefaultActionTimer = New-Object System.Windows.Forms.Timer
		$DefaultActionTimer.Interval = 1000 #Run the tick action every second
		$DefaultActionTimer.Add_Tick({DefautActionTick})
	}

	#Add Buttons dynamically based on the an array passed in - using the Name Field to determine which index is the name if each entry is an array.
	foreach ($Option in $OptionList) {
		$myYOffset = (($FontSize * 2.5 + 10) * $iCount)
		$newButtonFont = New-Object System.Drawing.Font('Callibri',$FontSize,[System.Drawing.FontStyle]::Bold)
		$newButton = New-Object System.Windows.Forms.Button
		if (($Option.GetType() -like '*Array*') -or ($Option.GetType().BaseType -like '*Array*')) {$newButton.Text = $Option[$NameFieldIfArray]}
		else {$newButton.Text = $Option}
		$newButton.Font = $newButtonFont
		$newButton.Size = New-Object System.Drawing.Size($Width,($FontSize * 2.5 + 10))
		$newButton.Location = New-Object System.Drawing.Size(0,$myYOffset)
		$newButton.Tag = $Option
		$newButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
		$newButton.Add_Click({
			$Form.Tag = $this.Tag
			$Form.Close()
		})
		$newButton.TabIndex = $iCount + 1
		$Form.Controls.Add($newButton)
		$iCount ++
	}
	
	if ($TimeoutEnabled) {$DefaultActionTimer.Start()}
	$Form.ShowDialog()

	return $Form.Tag
}

#Example Execution:
$PromptList1 = ('Hello World','Hello Sun','Hello Moon','Hello Stars')
$PromptList2 = (('item1','Albert'),('item2','Marie'),('item3','Bill'),('item4','Stephen'))

Write-Host (PromptForAction -OptionList $PromptList1 -TimeoutEnabled -Timeout 10 -FontSize 30)"- It's a big universe!"

Write-Host (PromptForAction -OptionList $PromptList2 -NameFieldIfArray 1)[2]'is a lovely name.'
