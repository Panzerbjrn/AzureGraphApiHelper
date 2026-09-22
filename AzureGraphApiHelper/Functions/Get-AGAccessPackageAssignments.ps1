Function Get-AGAccessPackageAssignments{
<#
	.SYNOPSIS
		Retrieves a list of Access Package Assignments as defined in entitlement management.

	.DESCRIPTION
		Retrieves a list of Access Package Assignments as defined in entitlement management.

	.EXAMPLE
		Get-AGGraphAccessTokenFromAz
		Get-AGAccessPackageAssignments

		This command uses the current Az login context to populate the module token state and then returns access package assignments from entitlement management.

	.INPUTS
		None. You cannot pipe input to this function.

	.OUTPUTS
		A collection of access package assignment objects returned by the Microsoft Graph entitlement management beta endpoint.

	.NOTES
		Author:				Lars Panzerbjørn
		Creation Date:		2021.10.19
		This function uses the module-scoped Graph authentication headers populated by Get-AGGraphAccessToken or Get-AGGraphAccessTokenFromAz.

#>
	[CmdletBinding()]
	$Version = "/beta"
	$URI = $BaseURI + $Version
	$URI = $URI + "/identityGovernance/entitlementManagement/accessPackageAssignments"

	$InvokeRestMethodSplat = @{
		Headers = $Headers
		Uri = $URI
		Method = "Get"
	}

	$Result = Invoke-RestMethod -Uri $URI -Headers $Headers
	$Resources = $Result.value
	IF (!([string]::IsNullOrEmpty($Result.'@odata.nextLink'))){
		$Page = 1
		DO{
			Write-Verbose "Page $($Page)"
			$URI = $Result.'@odata.nextLink'
			$Result = Invoke-RestMethod -Uri $URI -Headers $Headers
			$Resources += $Result.value
			Write-Verbose "There are $($Resources.count) resources"
			$Page++
			#Sleep -s 1
		}
		UNTIL ($Result.'@odata.nextLink' -eq $Null)
	}
	Write-Verbose "There are $($Resources.count) resources"

	Return $Resources
}
