<#
# Initializations File Import / Export functions
#>

<#
Purpose: The following action, Import-Ini, will read a traditional INI file into an initializations object

Reqiurements:
	Any typical INI file should be fine.
Use: 
	Assign a new variable to the result of the Import-Ini function with a path input.
Result:
	The value returned from the function will be an object with branches and nodes as specified in the INI file.
#>

function Import-Ini ([string]$FilePath) {
	if ($FilePath.Substring($FilePath.Length -4) -notlike '.ini') {return ''}
	if ($FilePath.Length -le 4) {return ''}
	$OutINI = New-Object PSCustomObject
	$InINI = Get-Content $FilePath
	$CurrentBranch = ''

	foreach ($line in $InINI) {
		if ($line -like '*`[*`]*') {
			$s = [string]$line.Substring(($line.IndexOf('[') + 1),($line.IndexOf(']') - ($line.IndexOf('[') + 1)))
			if ($OutINI.$s -like $null) { $OutINI | Add-Member -MemberType MemberSet -Name $s }
			$CurrentBranch = $s
			$OutINI.$CurrentBranch | Add-Member -MemberType NoteProperty -Name 'TypeSetName' -Value $s
		}
		if ($line -like '*=*') {
			[string]$line.Replace('"','') | Out-Null
			[string]$line.Replace("'",'') | Out-Null
			$s = $line.Split('=')
			$OutINI.$CurrentBranch | Add-Member -MemberType NoteProperty -Name $s[0] -Value $s[1]
		}
	}

	return $OutINI
}

function Export-Ini ([psobject]$InIni, [string]$FilePath) {
	if ($FilePath.Substring($FilePath.Length -4) -notlike '.ini') {return ''}
	if ($FilePath.Length -le 4) {return ''}
	[System.Collections.ArrayList]$IniList=@()
	[System.Collections.ArrayList]$IniSections=@()
	$IniMembers = $InIni.psobject.Members
	foreach ($member in $IniMembers) {if ($member.psobject.TypeNames -eq 'System.Management.Automation.PSMemberSet'){$IniSections.Add($member.TypeSetName) | Out-Null}}
	for ($i = 0; $i -lt $IniSections.Count; $i++) {
		$IniList.Add('['+$IniSections[$i]+']') | Out-Null
		$members = $InIni.($IniSections[$i]).psobject.Members
		foreach ($member in $members) {$IniList.Add($member.Name+'='+$member.value) | Out-Null}
	}
	$IniList -join "`r`n" | Out-File -Encoding ascii $FilePath
}

$TestIni = Import-Ini 'C:\test\Source.ini'
Export-Ini $TestIni 'C:\test\Result.ini'