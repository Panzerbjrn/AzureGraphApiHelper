Function Get-AGDeletedUsers{
<#
	.SYNOPSIS
		Retrieves a list of delete O365 users via MS Graph API.

	.DESCRIPTION
		Retrieves a list of delete O365 users via MS Graph API.

	.EXAMPLE
		$AccessToken = Get-AGGraphAccessToken -TenantID $TenantID -ClientID $ClientId -ClientSecret $ClientSecret
		$Details = Get-AGDeletedUsers -AccessToken $AccessToken
		
		This command first get an access token, which is used to grant access to Graph, and then a list of deleted users is retrieved.
		
	.EXAMPLE
		$Details = Get-AGDeletedUsers
		
		This command uses an existing access token, and then a list of deleted users is retrieved.
		
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

