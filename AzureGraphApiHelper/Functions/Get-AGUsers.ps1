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

	.EXAMPLE
		Get-AGUsers -UPN Lars.Panzerbjrn@centralindustrial.eu

		This command retrieves a single user's details by user principal name.

	.EXAMPLE
		Get-AGUsers -UserType guest

		This command will retrieve a list of guest users.

	.PARAMETER AccessToken
		This is the access token that grants you access to Microsoft Graph. If omitted, the function uses the module-scoped token created by Get-AGGraphAccessToken or Get-AGGraphAccessTokenFromAz.

	.PARAMETER UserPrincipalName
		This is the UserPrincipalName of the user, for example Lars.Panzerbjrn@centralindustrial.eu.
		This would be used if you want to look for a specific user.

	.PARAMETER UserType
		This is the type of user to look for, for example Guest or Member.

	.PARAMETER UseBetaAPI
		This will force use of the beta version of the API, which sometimes will give more information, and sometimes will be broken.
		As with all other "beta things" use with caution. Or reckless abandon. Be yourself.

	.INPUTS
		None. You cannot pipe input to this function.

	.OUTPUTS
		A collection of user objects, or a single user object when -UserPrincipalName is used.

	.NOTES
		Author:				Lars Panzerbjørn
		Creation Date:		2021.08.24
#>
	[CmdletBinding()]
	param
	(
		[Parameter()][psobject]$AccessToken,

		[Parameter()]
		[Alias('UPN')]
		[string]$UserPrincipalName,

		[Parameter()][string]$UserType,

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

		IF($UserPrincipalName){
			$URI = $URI + "/users/$($UserPrincipalName)"
		}
		ELSEIF($UserType){
			$URI = $URI + "/users?`$filter=userType eq '$UserType'"
		}
		ELSE{
			$URI = $URI + "/users"
		}


	}
	PROCESS{
		$Result = Invoke-RestMethod -Uri $URI -Headers $Headers
		IF(!$UserPrincipalName){
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
		Else{
			$Resources = $Result
		}
	}
	END{
		Return $Resources
	}
}
