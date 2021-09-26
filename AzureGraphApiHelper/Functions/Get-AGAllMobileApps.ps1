Function Get-AGAllMobileApps{
<#
	.SYNOPSIS
		Retrieves a list of apps as defined in InTune.

	.DESCRIPTION
		Retrieves a list of apps as defined in InTune.

	.EXAMPLE
		Get-AGAllMobileApps

	.INPUTS
		Input is from command line or called from a script.

	.OUTPUTS
		This will output a list of apps from InTune via MS Graph

	.NOTES
		Author:				Lars Panzerbjørn
		Creation Date:		2021.09.26
		
		This token is also stored in the Script scope, and so is automagically available to other functions.
#>
	$Version = "/beta"
	$InvokeRestMethodSplat = @{
		Headers = $Headers
		Uri = "$BaseUri$Version/deviceAppManagement/mobileApps?`$filter=(microsoft.graph.managedApp/appAvailability%20eq%20null%20or%20microsoft.graph.managedApp/appAvailability%20eq%20%27lineOfBusiness%27%20or%20isAssigned%20eq%20true)&`$orderby=displayName&"
		Method = "Get"
	}

	$Result = (Invoke-RestMethod @InvokeRestMethodSplat).Value
	Return $Result
}
