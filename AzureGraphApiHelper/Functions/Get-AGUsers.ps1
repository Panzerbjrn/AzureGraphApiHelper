Function Get-AGUsers{
<#
	.SYNOPSIS
		Retrieves a list of users via MS Graph API.

	.DESCRIPTION
		Retrieves a list of users via MS Graph API.

	.EXAMPLE
		$TenantId = "c123456f-a1cd-6fv7-bh73-123r5t6y7u8i9"
		$ClientId = '1a2s3d4d4-dfhg-4567-d5f6-h4f6g7k933ae'
		$ClientSecret = '36._ERF567.6FB.XFGY75D-35TGasdrvk467'
		$AccessToken = Get-AGGraphAccessToken -TenantID $TenantID -ClientID $ClientId -ClientSecret $ClientSecret
		
		Get-AGUsers -AccessToken $AccessToken
		
		This command first gets an access token, which is used to grant access to Graph, and then a list of users is retrieved.

	.PARAMETER AccessToken
		This is the AccessToken that grants you access to MS Graph.

	.INPUTS
		Input is from command line or called from a script.

	.OUTPUTS
		This will output a list of groups.

	.NOTES
		Author:				Lars Panzerbjørn
		Creation Date:		2021.08.24
#>
	[CmdletBinding()]
	param
	(
		[Parameter()][psobject]$AccessToken,
		[Parameter()][string]$DisplayNameStartsWith
	)

	BEGIN{
		$Version = "/v1.0"
		$URI = $BaseURI + $Version
		$URI = $URI + "/users"
	}
	PROCESS{
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
	}
	END{
		Return $Resources
	}
}
