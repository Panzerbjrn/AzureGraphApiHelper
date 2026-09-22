Function Get-AGDeletedUsers{
<#
	.SYNOPSIS
		Retrieves deleted Microsoft 365 users via MS Graph API.

	.DESCRIPTION
		Retrieves deleted Microsoft 365 users via MS Graph API.

	.EXAMPLE
		$AccessToken = Get-AGGraphAccessToken -TenantID $TenantID -ClientID $ClientId -ClientSecret $ClientSecret
		$Details = Get-AGDeletedUsers -AccessToken $AccessToken

		This command first gets an access token, which is used to grant access to Graph, and then retrieves deleted users.

	.EXAMPLE
		$Details = Get-AGDeletedUsers

		This command uses the module-scoped token created earlier and then retrieves deleted users.

	.PARAMETER AccessToken
		This is the access token that grants you access to Microsoft Graph. If omitted, the function uses the module-scoped token created by Get-AGGraphAccessToken or Get-AGGraphAccessTokenFromAz.

	.INPUTS
		None. You cannot pipe input to this function.

	.OUTPUTS
		A collection of deleted user objects returned by the Microsoft Graph beta endpoint.

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

		$Version = "/beta"
		$ExpandedURI = "/directory/deleteditems/microsoft.graph.user?`$format=application/json"
		$URI = $BaseURI + $Version + $ExpandedURI
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
			}
			UNTIL ($Result.'@odata.nextLink' -eq $Null)
		}
		Write-Verbose "There are $($Resources.count) resources"

	}
	END{
		Return $Resources
	}
}

