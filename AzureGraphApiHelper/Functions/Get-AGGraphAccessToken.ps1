Function Get-AGGraphAccessToken{
<#
	.SYNOPSIS
		Gets the bearer token needed for Graph REST API calls.

	.DESCRIPTION
		Gets the bearer token needed for Graph REST API calls.

	.EXAMPLE
		$TenantId = "c123456f-a1cd-6fv7-bh73-123r5t6y7u8i9"
		$ClientId = '1a2s3d4d4-dfhg-4567-d5f6-h4f6g7k933ae'
		$ClientSecret = '36._ERF567.6FB.XFGY75D-35TGasdrvk467'

		Get-AGGraphAccessToken -TenantID $TenantID -ClientID $ClientId -ClientSecret $ClientSecret

	.EXAMPLE
		$TenantId = "c123456f-a1cd-6fv7-bh73-123r5t6y7u8i9"
		$ClientId = '1a2s3d4d4-dfhg-4567-d5f6-h4f6g7k933ae'
		$ClientSecret = '36._ERF567.6FB.XFGY75D-35TGasdrvk467'

		$Token = Get-AGGraphAccessToken -TenantID $TenantID -ClientID $ClientId -ClientSecret $ClientSecret

		This example stores the token in a variable that can be used to grant access.

	.PARAMETER TenantID
		This is the Microsoft Entra tenant ID used to request the token.

	.PARAMETER ClientID
		This is the application (client) ID of the app registration or service principal.

	.PARAMETER ClientSecret
		This is the client secret used for the client credentials flow.

	.INPUTS
		None. You cannot pipe input to this function.

	.OUTPUTS
		A token response object containing the Graph access token and expiry metadata.

	.NOTES
		Author:				Lars Panzerbjørn
		Creation Date:		2021.08.11
		The returned token is also stored in module scope for use by other functions in this module.
#>
	[CmdletBinding()]
	param
	(
		[Parameter(Mandatory)][string]$TenantID,
		[Parameter(Mandatory)][string]$ClientID,
		[Parameter(Mandatory)][string]$ClientSecret
	)

	BEGIN{
		$TokenEndpoint = "https://login.microsoftonline.com/$Tenantid/oauth2/v2.0/token"
	}
	PROCESS{
		$Body = @{
			Grant_Type = "client_credentials"
			Scope = "https://graph.microsoft.com/.default"
			Client_Id = $ClientID
			Client_Secret = $ClientSecret
		}

		$InvokeRestMethodSplat = @{
			ContentType = 'application/x-www-form-urlencoded'
			Headers = @{'accept'='application/json'}
			Body = $Body
			Method = 'Post'
			URI = $TokenEndpoint
		}

		$Script:TenantID = $TenantID
		$Script:ClientID = $ClientId
		$Script:ClientSecret = $ClientSecret
		$Script:BaseUri = "https://graph.microsoft.com"
		$Script:TokenResponse = Invoke-RestMethod @InvokeRestMethodSplat
		$Script:Headers = @{Authorization = "Bearer $($tokenResponse.access_token)"}
		$TokenResponse | Add-Member NoteProperty ExpiresOn((Get-Date).AddSeconds($TokenResponse.expires_in))
	}
	END{
		Return $TokenResponse
	}
}
