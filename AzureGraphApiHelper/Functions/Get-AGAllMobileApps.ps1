Function Get-AGAllMobileApps{
<#
	.SYNOPSIS
		Retrieves a list of apps as defined in Intune.

	.DESCRIPTION
		Retrieves mobile apps as defined in Intune.

	.EXAMPLE
		Get-AGGraphAccessTokenFromAz
		Get-AGAllMobileApps

		This command uses the current Az login context to populate the module token state and then returns Intune mobile apps.

	.INPUTS
		None. You cannot pipe input to this function.

	.OUTPUTS
		A collection of Intune mobile app objects returned by the Microsoft Graph beta endpoint.

	.NOTES
		Author:				Lars Panzerbjørn
		Creation Date:		2021.09.26
		This function uses the module-scoped Graph authentication headers populated by Get-AGGraphAccessToken or Get-AGGraphAccessTokenFromAz.
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
