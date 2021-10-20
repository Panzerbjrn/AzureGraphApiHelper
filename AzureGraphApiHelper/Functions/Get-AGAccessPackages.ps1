Function Get-AGAccessPackages{
<#
	.SYNOPSIS
		Retrieves a list of Access Packages as defined in entitlement management.

	.DESCRIPTION
		Retrieves a list of Access Packages as defined in entitlement management.

	.EXAMPLE
		Get-AGAccessPackages

	.INPUTS
		Input is from command line or called from a script.

	.OUTPUTS
		This will output a list of apps from InTune via MS Graph

	.NOTES
		Author:				Lars Panzerbjørn
		Creation Date:		2021.10.12
		
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
