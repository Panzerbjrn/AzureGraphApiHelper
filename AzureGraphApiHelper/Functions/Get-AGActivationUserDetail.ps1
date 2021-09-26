Function Get-AGActivationUserDetail{
<#
	.SYNOPSIS
		Retrieves a list of users and their O365 activation details via MS Graph API.

	.DESCRIPTION
		Retrieves a list of users and their O365 activation details via MS Graph API.

	.EXAMPLE
		$AccessToken = Get-AGGraphAccessToken -TenantID $TenantID -ClientID $ClientId -ClientSecret $ClientSecret
		$Details = Get-AGActivationUserDetail -AccessToken $AccessToken
		
		This command first get an access token, which is used to grant access to Graph, and then a list of groups is retrieved.
		A list of the users and their activation details is produced.
		

	.PARAMETER AccessToken
		This is the AccessToken that grants you access to MS Graph.

	.INPUTS
		Input is from command line or called from a script.

	.OUTPUTS
		This will output a list of groups.

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
		Return $Resources
	}
}
