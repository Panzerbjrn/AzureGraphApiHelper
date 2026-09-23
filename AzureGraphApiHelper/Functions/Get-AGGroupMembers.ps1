Function Get-AGGroupMembers{
<#
	.SYNOPSIS
		Retrieves a list of members of the specified group via MS Graph API.

	.DESCRIPTION
		Retrieves a list of members of the specified group via MS Graph API.
		You can identify the group by either -DisplayName or -GroupID.

	.EXAMPLE
		$AccessToken = Get-AGGraphAccessToken -TenantID $TenantID -ClientID $ClientId -ClientSecret $ClientSecret
		Get-AGGroupMembers -AccessToken $AccessToken -DisplayName SecurityGroup_01

		This command first gets an access token, which is used to grant access to Graph, and then retrieves the members of the matching group.
		A list of the members of the group is then produced.

	.EXAMPLE
		Get-AGGroupMembers -AccessToken $AccessToken -GroupID "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee"

		This command retrieves members directly by group object ID.

	.PARAMETER AccessToken
		This is the access token that grants you access to Microsoft Graph. If omitted, the function uses the module-scoped token created by Get-AGGraphAccessToken or Get-AGGraphAccessTokenFromAz.

	.PARAMETER DisplayName
		This is the start of the name of the group you are looking for. However, if more than one group is found, an error is returned.

		Example: for the group "Admin_Desktops" you could use -DisplayName Admin_D

	.PARAMETER GroupID
		This is the object ID of the group whose members you want to retrieve.

	.INPUTS
		None. You cannot pipe input to this function.

	.OUTPUTS
		A collection of directory objects representing the group's direct members.

	.NOTES
		Author:				Lars Panzerbjørn
		Creation Date:		2021.08.11
#>
	[CmdletBinding(PositionalBinding=$False)]
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
			IF($AccessToken){
				Write-Verbose "Using provided access token"
				Write-verbose $AccessToken.access_token
				$Headers = @{Authorization = "Bearer $($AccessToken.access_token)"}
			}
			IF(!($AccessToken)){
				Write-Verbose "Using Token Response"
				Write-verbose $TokenResponse.access_token
				$Headers = @{Authorization = "Bearer $($TokenResponse.access_token)"}
			}
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