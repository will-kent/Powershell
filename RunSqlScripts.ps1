<# 
.SYNOPSIS 
    Processes Sql Scripts in a folder
.DESCRIPTION 
	Processes Sql Scripts in a folder - option to run all scripts in a folder or just a single script
.EXAMPLE
    .\RunSqlScripts.ps1
#>

function Show-Menu
{
	param([string]$title,
	[string]$num,
	[string]$filename)

	if ($title -eq "Main Menu")
	{
		Write-Host "====$title====" -ForegroundColor Yellow

		Write-Host "1: Press '1' to Process all Sql Scripts"
		Write-Host "2: Press '2' to Select Sql Scripts"
		Write-Host "3: Press 'Q' to Quit"
	}

	if($title -eq "Script Menu")
	{
		Write-Host "Press $num to process $filename"
	}
}

function Process-All ($folder)
{
	if (!(Get-Module -Name sqlps))
    {
        Write-Host 'Loading SQLPS Module' -ForegroundColor DarkYellow
        Push-Location
        Import-Module sqlps -DisableNameChecking
        Pop-Location
    }

	$Server = "localhost"
	$Username = ""
	$Pword = ""
	$scripts = Get-ChildItem $folder | Where-Object {$_.Extension -eq ".sql"}
  
	foreach ($s in $scripts)
		{
			Write-Host "Running Script : " $s.Name -BackgroundColor DarkGreen -ForegroundColor White
			$script = $s.FullName
			Invoke-Sqlcmd -ServerInstance $Server -InputFile $script
		}
}

function Process-Selected ($folder)
{
	Clear-Host
	$Server = "localhost"
	$files = Get-ChildItem -Path $folder | Where-Object {$_.Extension -eq ".sql"}
	$fileChoices = @()

	for ($i=0; $i -lt $files.Count; $i++)
	{
		#$fileChoices += [System.Management.Automation.Host.ChoiceDescription]("$($files[$i].Name) &$($i+1)")
		Show-Menu -title 'Script Menu' -num $i -filename $files[$i].Name
	}

	Write-Host "Press Q to quit"

	$selection = Read-Host "Please select an option"
	
	if ($selection -eq "q")
	{
		Write-Host 'Leaving process' -ForegroundColor Green
		return
	}

	$script = $files[$selection].FullName

	# do something more useful here...
	Write-Host "Running Script : " $script -BackgroundColor DarkGreen -ForegroundColor White
	Invoke-Sqlcmd -ServerInstance $Server -InputFile $script
}

do 
{
	Clear-Host
	Show-Menu -title 'Main Menu'
	$selection = Read-Host "Please select an option"
	switch($selection)
	{
		"1" 
		{
			$Option = "ALL"
		}
		"2"
		{
			$Option = "SELECT"
		}
		"q"
		{
			Write-Host 'Leaving process' -ForegroundColor Green
			return
		}
		default
		{
			Write-Warning 'Invalid selection'
			$Option = "INVALID"
			pause
		}
	}
} while ($Option -eq "INVALID")

$localScriptRoot = Get-Location

if ($Option -eq "ALL")
{
	Process-All($localScriptRoot)
}
elseif ($Option -eq "SELECT")
{
	Process-Selected($localScriptRoot)
}
else
{
	Write-Host "I am just a computer so go easy. Tell me what to do."
}

