Function Get-AGGroups{
<#
	.SYNOPSIS
		Retrieves a list of groups via MS Graph API.

	.DESCRIPTION
		Retrieves a list of groups via MS Graph API.

	.EXAMPLE
		$TenantId = "c123456f-a1cd-6fv7-bh73-123r5t6y7u8i9"
		$ClientId = '1a2s3d4d4-dfhg-4567-d5f6-h4f6g7k933ae'
		$ClientSecret = '36._ERF567.6FB.XFGY75D-35TGasdrvk467'
		$AccessToken = Get-AGGraphAccessToken -TenantID $TenantID -ClientID $ClientId -ClientSecret $ClientSecret
		
		Get-AGGroups -AccessToken $AccessToken -DisplayNameStartsWith Az-Cont
		
		This command first gets an access token, which is used to grant access to Graph, and then a list of groups is retrieved.

	.PARAMETER AccessToken
		This is the AccessToken that grants you access to MS Graph.

	.PARAMETER DisplayNameStartsWith
		This is the start of the name of the group(s) you are looking for. If not used, all groups are returned.
		
		Example: for the group "Admin_Desktops" you could use -DisplayNameStartsWith Admin_D

	.PARAMETER UseBetaAPI
		This will force use of the beta version of the API, which sometimes will give more information, and sometimes will be broken.
		As with all other "beta things" use with caution. Or reckless abandon. Be yourself.

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
		[Parameter()][string]$DisplayNameStartsWith,
		[Parameter()][switch]$UseBetaAPI
	)

	BEGIN{
		IF (($AccessToken) -or ($TokenResponse)){
			IF($AccessToken){$Headers = @{Authorization = "Bearer $($AccessToken.access_token)"}}
			IF(!($AccessToken)){$Headers = @{Authorization = "Bearer $($TokenResponse.access_token)"}}
		}
		ELSE {THROW "Please provide access token"}

		IF($UseBetaAPI){$Version = "/beta"}
		Else{$Version = "/v1.0"}

		$URI = $BaseURI + $Version
		
		IF($DisplayNameStartsWith){
			$URI = $URI + "/groups?`$filter=startswith(displayName, '$DisplayNameStartsWith')"
		}
		ELSE{
			$URI = $URI + "/groups"
		}
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
