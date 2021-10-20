Function Get-AGAccessPackageAssignments{
<#
	.SYNOPSIS
		Retrieves a list of Access Package Assignments as defined in entitlement management.

	.DESCRIPTION
		Retrieves a list of Access Package Assignments as defined in entitlement management.

	.EXAMPLE
		Get-AGAccessPackageAssignments

	.INPUTS
		Input is from command line or called from a script.

	.OUTPUTS
		This will output a list of Access Package Assignments as defined in entitlement management

	.NOTES
		Author:				Lars Panzerbjørn
		Creation Date:		2021.10.19

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
