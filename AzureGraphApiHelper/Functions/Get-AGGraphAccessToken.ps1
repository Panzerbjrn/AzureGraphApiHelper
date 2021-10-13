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
		This is the tenant ID of your Azure subscription.

	.PARAMETER ClientID
		This is the ClientID of the Service Principal

	.PARAMETER ClientSecret
		This is the Client secret that was generated when you secured the Service Principal

	.INPUTS
		Input is from command line or called from a script.

	.OUTPUTS
		This will output an access token that can be used in future API calls.

	.NOTES
		Author:				Lars Panzerbjørn
		Creation Date:		2021.08.11
		
		This token is also stored in the Script scope, and so is automagically available to other functions.
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
		
		$Script:BaseUri = "https://graph.microsoft.com"
		$Script:TokenResponse = Invoke-RestMethod @InvokeRestMethodSplat
		$Script:Headers =@{Authorization = "Bearer $($tokenResponse.access_token)"}
		$TokenResponse | Add-Member NoteProperty ExpiresOn((Get-Date).AddSeconds($TokenResponse.expires_in))
	}
	END{
		Return $TokenResponse
	}
}
