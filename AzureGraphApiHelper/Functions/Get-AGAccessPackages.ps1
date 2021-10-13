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
	$Version = "/beta"
	$InvokeRestMethodSplat = @{
		Headers = $Headers
		Uri = "/beta/identityGovernance/entitlementManagement/accessPackages"
		Method = "Get"
	}

	$Result = (Invoke-RestMethod @InvokeRestMethodSplat).Value
	Return $Result
}
