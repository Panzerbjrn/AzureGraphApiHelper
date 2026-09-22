Function New-AGGroup {
<#
    .SYNOPSIS
        Creates a new group via the MS Graph API.

    .DESCRIPTION
        Creates a new group (Microsoft 365 or Security) in Entra ID using the MS Graph API.

    .EXAMPLE
        $TenantId = "c123456f-a1cd-6fv7-bh73-123r5t6y7u8i9"
        $ClientId = '1a2s3d4d4-dfhg-4567-d5f6-h4f6g7k933ae'
        $ClientSecret = '36._ERF567.6FB.XFGY75D-35TGasdrvk467'
        $AccessToken = Get-AGGraphAccessToken -TenantID $TenantID -ClientID $ClientId -ClientSecret $ClientSecret

        New-AGGroup -AccessToken $AccessToken -DisplayName "Project Phoenix" -Description "Group for the Phoenix project team" -MailNickname "proj-phoenix"

        This creates a new Microsoft 365 group named "Project Phoenix" with the specified description and mail nickname.

    .EXAMPLE
        Get-AGGraphAccessTokenFromAz

        New-AGGroup -DisplayName "Project Phoenix" -Description "Group for the Phoenix project team" -MailNickname "proj-phoenix"

        This creates a new security group named "Project Phoenix" with the specified description and mail nickname by using the module-scoped token.

    .EXAMPLE
        New-AGGroup -AccessToken $AccessToken -DisplayName "Project Phoenix M365" -Description "Unified collaboration group" -MailNickname "proj-phoenix-m365" -GroupType Microsoft365

        This creates a new Microsoft 365 group.

    .PARAMETER AccessToken
        This is the access token that grants you access to Microsoft Graph. If omitted, the function uses the module-scoped token created by Get-AGGraphAccessToken or Get-AGGraphAccessTokenFromAz.

    .PARAMETER DisplayName
        The display name for the group. This is required.

    .PARAMETER Description
        An optional description for the group.

    .PARAMETER MailNickname
        The mail alias for the group, unique in your organization. This is required for Microsoft 365 groups and can also be supplied for security groups. It must contain only characters from the ASCII character set 0-127, excluding: @ () \ [] " ; : <> , SPACE.

    .PARAMETER GroupType
        Specifies the type of group to create. Valid values are "Microsoft365" or "Security". The default is "Security".

    .PARAMETER UseBetaAPI
        This will force use of the beta version of the API.

    .INPUTS
        None. You cannot pipe input to this function.

    .OUTPUTS
        The newly created group object returned by Microsoft Graph.

    .NOTES
        Author:              Lars Panzerbjørn
#>
    [CmdletBinding()]
    param
    (
        [Parameter()][psobject]$AccessToken,
        [Parameter(Mandatory)][string]$DisplayName,
        [Parameter()][string]$Description,
        [Parameter()][string]$MailNickname,
        [Parameter()][ValidateSet("Microsoft365", "Security")][string]$GroupType = "Security",
        [Parameter()][switch]$UseBetaAPI
    )

    BEGIN {
		IF (($AccessToken) -or ($TokenResponse)){
			IF($AccessToken){$Headers = @{Authorization = "Bearer $($AccessToken.access_token)";"Content-Type" = "application/json"}}
			IF(!($AccessToken)){$Headers = @{Authorization = "Bearer $($TokenResponse.access_token)";"Content-Type" = "application/json"}}
		}
        ELSE {
            THROW "Please provide access token"
        }

        IF ($UseBetaAPI) { $Version = "/beta" }
        Else { $Version = "/v1.0" }

        $URI = $BaseURI + $Version + "/groups"

        # Build the request body based on group type
        $BodyHash = @{
            displayName = $DisplayName
            mailNickname = $MailNickname
        }

        IF ($Description) {
            $BodyHash.description = $Description
        }

        IF ($GroupType -eq "Microsoft365") {
            $BodyHash.groupTypes = @("Unified")
            $BodyHash.mailEnabled = $True
            $BodyHash.securityEnabled = $True
        }
        ELSE {
            # Security group
            $BodyHash.groupTypes = @()
            $BodyHash.mailEnabled = $False
            $BodyHash.securityEnabled = $True
        }

        $Body = $BodyHash | ConvertTo-Json -Depth 3
    }

    PROCESS {
        Try {
            Write-Verbose "Creating group '$DisplayName' at $URI"
            $Result = Invoke-RestMethod -Method POST -Uri $URI -Headers $Headers -Body $Body
        }
        Catch {
            Write-Error "Failed to create group: $($_.Exception.Message)"
            Throw
        }
    }

    END {
        Return $Result
    }
}