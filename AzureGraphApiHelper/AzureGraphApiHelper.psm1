#region Script Header
#	Thought for the day:
#	NAME: AzureGraphApiHelper.psm1
#	AUTHOR: Lars Panzerbj�rn
#	CONTACT: lpetersson@hotmail.com / GitHub: Panzerbjrn / Twitter: lpetersson
#	DATE: 2021.07.29
#	VERSION: 0.1 - 2021.07.29 - Module Created with Create-NewModuleStructure by Lars Panzerbj�rn
#
#	SYNOPSIS:
#
#
#	DESCRIPTION:
#	This module will help to make Graph API calls
#
#	REQUIREMENTS:
#
#endregion Script Header

#Requires -Version 4.0

[CmdletBinding()]
param()

Write-Verbose $PSScriptRoot

#Get Functions and Helpers function definition files.
$Functions	= @( Get-ChildItem -Path $PSScriptRoot\Functions\*.ps1 -ErrorAction SilentlyContinue )
$Helpers = @( Get-ChildItem -Path $PSScriptRoot\Helpers\*.ps1 -ErrorAction SilentlyContinue )

#Dot source the files
ForEach ($Import in @($Functions + $Helpers))
{
	Try
	{
		. $Import.Fullname
	}
	Catch
	{
		Write-Error -Message "Failed to Import function $($Import.Fullname): $_"
	}
}

Export-ModuleMember -Function $Functions.Basename

