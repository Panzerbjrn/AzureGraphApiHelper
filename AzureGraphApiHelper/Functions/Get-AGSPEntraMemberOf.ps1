Function Get-AGSPEntraMemberOf{
<#
	.SYNOPSIS
		Retrieves the Entra (Azure AD) groups and directory roles that a service principal is a direct member of via MS Graph API.

	.DESCRIPTION
		Retrieves the Entra (Azure AD) groups and directory roles that a service principal is a direct member of via MS Graph API.
		To see transitive memberships (including nested groups), use the -UseBetaAPI switch.

	.EXAMPLE
		$AccessToken = Get-AGGraphAccessToken -TenantID $TenantID -ClientID $ClientId -ClientSecret $ClientSecret
		Get-AGSPEntraMemberOf -AccessToken $AccessToken -ObjectID "12345678-1234-1234-1234-123456789abc"

		This command first gets an access token, which is used to grant access to Graph, and then retrieves the Entra entries (groups and directory roles) that the specified service principal is a direct member of.

	.EXAMPLE
		Get-AGSPEntraMemberOf -AccessToken $AccessToken -AppID "12345678-1234-1234-1234-123456789abc"

		This command uses the Application (Client) ID instead of the Object ID to look up the service principal and retrieve its direct memberships.

	.EXAMPLE
		Get-AGSPEntraMemberOf -AccessToken $AccessToken -ObjectID "12345678-1234-1234-1234-123456789abc" -UseBetaAPI

		This command retrieves transitive memberships (including nested groups) for the specified service principal using the beta endpoint.

	.PARAMETER AccessToken
		This is the AccessToken that grants you access to MS Graph.

	.PARAMETER ObjectID
		This is the Object ID (OID) of the service principal you want to check memberships for.
		Either -ObjectID or -AppID must be provided.

	.PARAMETER AppID
		This is the Application (Client) ID of the app registration you want to check memberships for.
		The function will look up the corresponding service principal.
		Either -ObjectID or -AppID must be provided.

	.PARAMETER UseBetaAPI
		This will force use of the beta version of the API, which uses the /transitiveMemberOf endpoint.
		This shows all groups the service principal is a member of, including nested memberships.
		As with all other "beta things" use with caution. Or reckless abandon. Be yourself.

	.INPUTS
		Input is from command line or called from a script.

	.OUTPUTS
		This will output a list of Entra entries (groups and directory roles) that the service principal is a member of.

#>
	[CmdletBinding(DefaultParameterSetName='AppID')]
	param
	(
		[Parameter(ParameterSetName='ObjectID')]
		[Parameter(ParameterSetName='ObjectIDBeta')]
		[Parameter(ParameterSetName='AppID')]
		[Parameter(ParameterSetName='AppIDBeta')]
		[psobject]$AccessToken,

		[Parameter(Mandatory=$true,ParameterSetName='ObjectID')]
		[Parameter(Mandatory=$true,ParameterSetName='ObjectIDBeta')]
		[string]$ObjectID,

		[Parameter(Mandatory=$true,ParameterSetName='AppID')]
		[Parameter(Mandatory=$true,ParameterSetName='AppIDBeta')]
		[string]$AppID,

		[Parameter(Mandatory=$true,ParameterSetName='ObjectIDBeta')]
		[Parameter(Mandatory=$true,ParameterSetName='AppIDBeta')]
		[switch]$UseBetaAPI
	)

	BEGIN{
		IF (($AccessToken) -or ($TokenResponse)){
			IF($AccessToken){$Headers = @{Authorization = "Bearer $($AccessToken.access_token)"}}
			IF(!($AccessToken)){$Headers = @{Authorization = "Bearer $($TokenResponse.access_token)"}}
		}
		ELSE {THROW "Please provide access token"}

		IF($UseBetaAPI){$Version = "/beta"} Else {$Version = "/v1.0"}

		$BaseURI = "https://graph.microsoft.com"
	}

	PROCESS{
		# If AppID was provided, first look up the service principal to get its Object ID
		IF($PSCmdlet.ParameterSetName -eq "AppID" -or $PSCmdlet.ParameterSetName -eq "AppIDBeta"){
			Write-Verbose "Looking up service principal with AppID: $AppID"
			$LookupURI = $BaseURI + "/v1.0/servicePrincipals(appId='$AppID')"
			$LookupResult = Invoke-RestMethod -Uri $LookupURI -Headers $Headers

			IF($LookupResult.value){
				$OID = $LookupResult.value.id
				Write-Verbose "Found service principal with ObjectID: $OID"
			}
			ELSEIF($LookupResult.id){
				$OID = $LookupResult.id
				Write-Verbose "Found service principal with ObjectID: $OID"
			}
			ELSE{
				THROW "No service principal found with AppID: $AppID"
			}
		}
		ELSEIF($PSCmdlet.ParameterSetName -eq "ObjectID" -or $PSCmdlet.ParameterSetName -eq "ObjectIDBeta"){
			$OID = $ObjectID
		}
		ELSE {
			THROW "Either -ObjectID or -AppID must be provided"
		}

		# Build the appropriate endpoint URI
		IF($UseBetaAPI){
			$ExpandedURI = "/servicePrincipals/$OID/transitiveMemberOf"
		}
		ELSE{
			$ExpandedURI = "/servicePrincipals/$OID/memberOf"
		}

		$URI = $BaseURI + $Version + $ExpandedURI
		Write-Verbose "Querying: $URI"

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
			UNTIL ([string]::IsNullOrEmpty($Result.'@odata.nextLink'))
		}
		Write-Verbose "There are $($Resources.count) resources"
	}
	END{
		Return $Resources
	}
}