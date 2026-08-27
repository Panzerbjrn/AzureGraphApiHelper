Function Get-AGGraphAccessTokenFromAz {
<#
	.SYNOPSIS
		Gets the bearer token needed for Graph REST API calls using Az module authentication.

	.DESCRIPTION
		Gets the bearer token needed for Graph REST API calls using the currently
		logged in Azure context from the Az module. This eliminates the need for
		TenantID, ClientID, and ClientSecret.

	.EXAMPLE
		$Token = Get-AGGraphAccessTokenFromAz

		This example gets a token using the current Az context and stores it in a variable.

	.EXAMPLE
		$Token = Get-AGGraphAccessTokenFromAz
		Get-AGGroups -AccessToken $Token -DisplayNameStartsWith Az-Cont

		This example gets a token and then uses it to retrieve groups.

	.PARAMETER ResourceUrl
		The resource URL for which to get an access token. Defaults to "https://graph.microsoft.com".

	.INPUTS
		Input is from command line or called from a script.

	.OUTPUTS
		This will output an access token object compatible with other AG* functions.

	.NOTES
		Requires the Az module to be installed and authenticated.
		The token is also stored in the Script scope, making it available to other functions.
#>
	[CmdletBinding()]
	param(
		[Parameter()][string]$ResourceUrl = "https://graph.microsoft.com"
	)

	BEGIN{
		# Check if Az module is available
		if (-not (Get-Module -ListAvailable -Name Az.Accounts)) {
			throw "Az.Accounts module is not installed. Please install it using: Install-Module -Name Az.Accounts"
		}

		# Check if we're logged in
		try {
			$null = Get-AzContext -ErrorAction Stop
		}
		catch {
			throw "Not logged into Azure. Please run Connect-AzAccount first."
		}
	}

	PROCESS{
		try {
			# Get the token from Az module
			$Token = Get-AzAccessToken -ResourceUrl $ResourceUrl -ErrorAction Stop

			# Calculate expiration time
			$ExpiresOn = (Get-Date).AddSeconds($Token.ExpiresOn.ToUniversalTime().Subtract((Get-Date).ToUniversalTime()).TotalSeconds)

			# Create a token object compatible with existing AG* functions
			$TokenResponse = [PSCustomObject]@{
				access_token = $Token.Token
				token_type = "Bearer"
				expires_in = $Token.ExpiresOn.ToUniversalTime().Subtract((Get-Date).ToUniversalTime()).TotalSeconds
				expires_on = [DateTimeOffset]::Parse($Token.ExpiresOn.ToString()).ToUnixTimeSeconds()
				not_before = [DateTimeOffset]::Now.ToUnixTimeSeconds()
				resource = $ResourceUrl
			}

			# Add the ExpiresOn property with the correct date format (matching your original function)
			$TokenResponse | Add-Member -MemberType NoteProperty -Name "ExpiresOn" -Value $ExpiresOn

			# Store in script scope for other functions to use
			$Script:TenantID = (Get-AzContext).Tenant.Id
			$Script:BaseUri = $ResourceUrl
			$Script:TokenResponse = $TokenResponse
			$Script:Headers = @{Authorization = "Bearer $($TokenResponse.access_token)"}

			Write-Verbose "Successfully acquired Graph access token. Expires at: $($ExpiresOn.ToString('yyyy-MM-dd HH:mm:ss'))"
		}
		catch {
			throw "Failed to acquire access token: $_"
		}
	}

	END{
		Return $TokenResponse
	}
}