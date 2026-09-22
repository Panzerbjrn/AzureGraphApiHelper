Function Get-AGActivationUserDetail{
<#
	.SYNOPSIS
		Retrieves a list of users and their O365 activation details via MS Graph API.

	.DESCRIPTION
		Retrieves a list of users and their O365 activation details via MS Graph API.

	.EXAMPLE
		$AccessToken = Get-AGGraphAccessToken -TenantID $TenantID -ClientID $ClientId -ClientSecret $ClientSecret
		$Details = Get-AGActivationUserDetail -AccessToken $AccessToken

		This command first gets an access token, which is used to grant access to Graph, and then retrieves the Office 365 activation detail report for users.

	.EXAMPLE
		Get-AGGraphAccessTokenFromAz
		Get-AGActivationUserDetail

		This command uses the current Az login context and then retrieves the Office 365 activation detail report for users.


	.PARAMETER AccessToken
		This is the access token that grants you access to Microsoft Graph. If omitted, the function uses the module-scoped token created by Get-AGGraphAccessToken or Get-AGGraphAccessTokenFromAz.

	.INPUTS
		None. You cannot pipe input to this function.

	.OUTPUTS
		The Office 365 activation user detail report returned by Microsoft Graph.

	.NOTES
		Author:				Lars Panzerbjørn
		Creation Date:		2021.08.23
#>
	[CmdletBinding()]
	param
	(
		[Parameter()][psobject]$AccessToken
	)
	BEGIN{
		IF (($AccessToken) -or ($TokenResponse)){
			IF($AccessToken){$Headers = @{Authorization = "Bearer $($AccessToken.access_token)"}}
			IF(!($AccessToken)){$Headers = @{Authorization = "Bearer $($TokenResponse.access_token)"}}
		}
		ELSE {THROW "Please provide access token"}

		$Version = "/v1.0"
		$ExpandedURI = "/reports/getOffice365ActivationsUserDetail"
		$URI = $BaseURI + $Version + $ExpandedURI
	}
	PROCESS{
		$Result = Invoke-RestMethod -Uri $URI -Headers $Headers
	}
	END{
		Return $Result
	}
}

