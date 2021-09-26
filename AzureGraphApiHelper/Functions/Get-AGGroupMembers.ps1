Function Get-AGGroupMembers{
<#
	.SYNOPSIS
		Retrieves a list of members of the specified group via MS Graph API.

	.DESCRIPTION
		Retrieves a list of members of the specified group via MS Graph API.

	.EXAMPLE
		$AccessToken = Get-AGGraphAccessToken -TenantID $TenantID -ClientID $ClientId -ClientSecret $ClientSecret
		Get-AGGroupMembers -AccessToken $AccessToken -DisplayName SecurityGroup_01
		
		This command first get an access token, which is used to grant access to Graph, and then a list of group members is retrieved.
		A list of the members of the group is then produced.

	.PARAMETER AccessToken
		This is the AccessToken that grants you access to MS Graph.

	.PARAMETER DisplayName
		This is the start of the name of the group you are looking for. However, if more than one group is found, an error is returned.
				
		Example: for the group "Admin_Desktops" you could use -DisplayName Admin_D

	.INPUTS
		Input is from command line or called from a script.

	.OUTPUTS
		This will output a list of group members.

	.NOTES
		Author:				Lars Panzerbjørn
		Creation Date:		2021.08.11
#>
	[CmdletBinding()]
	param
	(
		[Parameter(ParameterSetName='DisplayName')]
		[Parameter(ParameterSetName='ID')]
		[Parameter()][psobject]$AccessToken,

		[Parameter(ParameterSetName='DisplayName')]
		[Parameter()][string]$DisplayName,

		[Parameter(ParameterSetName='ID')]
		[Parameter()][string]$GroupID
	)

	BEGIN{
		IF (($AccessToken) -or ($TokenResponse)){
			IF($AccessToken){$Headers = @{Authorization = "Bearer $($AccessToken.access_token)"}}
			IF(!($AccessToken)){$Headers = @{Authorization = "Bearer $($TokenResponse.access_token)"}}
		}
		ELSE {THROW "Please provide access token"}
		$Version = "/v1.0"
	}
	PROCESS{
		IF ("DisplayName" -eq $PSCmdlet.ParameterSetName){
			$ID = (Get-AGGroups -AccessToken $AccessToken -DisplayNameStartsWith $DisplayName).id
			IF($ID.count -lt 1){THROW "There were no groups found"}
			IF($ID.count -gt 1){THROW "More than one group was found"}
		}

		$URI = $BaseURI + $Version + "/groups/" + $ID + "/members"
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
		$Resources
	}
}