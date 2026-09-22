Function Get-AGAccessPackages{
<#
	.SYNOPSIS
		Retrieves a list of Access Packages as defined in entitlement management.

	.DESCRIPTION
		Retrieves a list of Access Packages as defined in entitlement management.

	.EXAMPLE
		Get-AGGraphAccessTokenFromAz
		Get-AGAccessPackages

		This command uses the current Az login context to populate the module token state and then returns access packages from entitlement management.

	.INPUTS
		None. You cannot pipe input to this function.

	.OUTPUTS
		A collection of access package objects returned by the Microsoft Graph entitlement management beta endpoint.

	.NOTES
		Author:				Lars Panzerbjørn
		Creation Date:		2021.10.12
		This function uses the module-scoped Graph authentication headers populated by Get-AGGraphAccessToken or Get-AGGraphAccessTokenFromAz.
#>
	[CmdletBinding()]
	$Version = "/beta"
	$URI = $BaseURI + $Version
	$URI = $URI + "/identityGovernance/entitlementManagement/accessPackages"

	$InvokeRestMethodSplat = @{
		Headers = $Headers
		Uri = $URI
		Method = "Get"
	}

	$Result = (Invoke-RestMethod @InvokeRestMethodSplat).Value
	Return $Result
}
