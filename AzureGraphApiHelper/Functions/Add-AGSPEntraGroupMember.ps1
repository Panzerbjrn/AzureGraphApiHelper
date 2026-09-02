Function Add-AGSPEntraGroupMember{
<#
	.SYNOPSIS
		Adds a service principal (SP/App) as a member of an Entra group via MS Graph API.

	.DESCRIPTION
		Adds a service principal (SP/App) as a member of an Entra group via MS Graph API.
		You can identify the service principal by either -ObjectID or -AppID, and the group by either -GroupID or -DisplayName.

	.EXAMPLE
		$AccessToken = Get-AGGraphAccessToken -TenantID $TenantID -ClientID $ClientId -ClientSecret $ClientSecret
		Add-AGSPEntraGroupMember -AccessToken $AccessToken -ObjectID "12345678-1234-1234-1234-123456789abc" -GroupID "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee"

		This command first gets an access token, which is used to grant access to Graph, and then adds the specified service principal to the specified group.

	.EXAMPLE
		Add-AGSPEntraGroupMember -AccessToken $AccessToken -AppID "12345678-1234-1234-1234-123456789abc" -DisplayName "SecurityGroup_01"

		This command looks up the service principal using the Application (Client) ID and the group using display name, then adds the service principal to that group.

	.PARAMETER AccessToken
		This is the AccessToken that grants you access to MS Graph.

	.PARAMETER ObjectID
		This is the Object ID (OID) of the service principal you want to add to the group.
		Either -ObjectID or -AppID must be provided.

	.PARAMETER AppID
		This is the Application (Client) ID of the app registration you want to add to the group.
		The function will look up the corresponding service principal.
		Either -ObjectID or -AppID must be provided.

	.PARAMETER GroupID
		This is the Object ID (OID) of the Entra group you want to add the service principal to.
		Either -GroupID or -DisplayName must be provided.

	.PARAMETER DisplayName
		This is the start of the name of the group you are looking for. However, if more than one group is found, an error is returned.
		Either -GroupID or -DisplayName must be provided.

		Example: for the group "Admin_Desktops" you could use -DisplayName Admin_D

	.INPUTS
		Input is from command line or called from a script.

	.OUTPUTS
		This will output True when the service principal was successfully added to the group.

	.NOTES
		Author:				Lars Panzerbjørn
		Creation Date:		2026.09.02
#>
	[CmdletBinding(DefaultParameterSetName='ObjectIDGroupID')]
	param
	(
		[Parameter(ParameterSetName='ObjectIDGroupID')]
		[Parameter(ParameterSetName='ObjectIDDisplayName')]
		[Parameter(ParameterSetName='AppIDGroupID')]
		[Parameter(ParameterSetName='AppIDDisplayName')]
		[psobject]$AccessToken,

		[Parameter(Mandatory=$true,ParameterSetName='ObjectIDGroupID')]
		[Parameter(Mandatory=$true,ParameterSetName='ObjectIDDisplayName')]
		[string]$ObjectID,

		[Parameter(Mandatory=$true,ParameterSetName='AppIDGroupID')]
		[Parameter(Mandatory=$true,ParameterSetName='AppIDDisplayName')]
		[string]$AppID,

		[Parameter(Mandatory=$true,ParameterSetName='ObjectIDGroupID')]
		[Parameter(Mandatory=$true,ParameterSetName='AppIDGroupID')]
		[string]$GroupID,

		[Parameter(Mandatory=$true,ParameterSetName='ObjectIDDisplayName')]
		[Parameter(Mandatory=$true,ParameterSetName='AppIDDisplayName')]
		[string]$DisplayName
	)

	BEGIN{
		IF (($AccessToken) -or ($TokenResponse)){
			IF($AccessToken){$Headers = @{Authorization = "Bearer $($AccessToken.access_token)"}}
			IF(!($AccessToken)){$Headers = @{Authorization = "Bearer $($TokenResponse.access_token)"}}
		}
		ELSE {THROW "Please provide access token"}

		$Version = "/v1.0"
		$BaseURI = "https://graph.microsoft.com"
	}

	PROCESS{
		IF($PSCmdlet.ParameterSetName -eq "AppIDGroupID" -or $PSCmdlet.ParameterSetName -eq "AppIDDisplayName"){
			Write-Verbose "Looking up service principal with AppID: $AppID"
			$LookupURI = $BaseURI + "/v1.0/servicePrincipals(appId='$AppID')"
			$LookupResult = Invoke-RestMethod -Uri $LookupURI -Headers $Headers

			IF($LookupResult.value){
				$SPObjectID = $LookupResult.value.id
			}
			ELSEIF($LookupResult.id){
				$SPObjectID = $LookupResult.id
			}
			ELSE{
				THROW "No service principal found with AppID: $AppID"
			}
		}
		ELSE{
			$SPObjectID = $ObjectID
		}

		IF("ObjectIDDisplayName" -eq $PSCmdlet.ParameterSetName -or "AppIDDisplayName" -eq $PSCmdlet.ParameterSetName){
			$ResolvedGroupID = (Get-AGGroups -AccessToken $AccessToken -DisplayNameStartsWith $DisplayName).id
			IF($ResolvedGroupID.count -lt 1){THROW "There were no groups found"}
			IF($ResolvedGroupID.count -gt 1){THROW "More than one group was found"}
		}
		ELSE{
			$ResolvedGroupID = $GroupID
		}

		$URI = $BaseURI + $Version + "/groups/$ResolvedGroupID/members/`$ref"
		$Body = @{
			"@odata.id" = "$BaseURI/$Version/directoryObjects/$SPObjectID"
		} | ConvertTo-Json

		Invoke-RestMethod -Uri $URI -Headers $Headers -Method Post -Body $Body -ContentType "application/json"
		$Added = $True
	}
	END{
		Return $Added
	}
}