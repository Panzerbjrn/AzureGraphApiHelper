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
		Author:				Lars Panzerbjørn
		Creation Date:		2026.08.27

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
			$AzToken = Get-AzAccessToken -ResourceUrl $ResourceUrl -ErrorAction Stop

			# The token might be in different formats depending on Az module version
			# Extract the actual token string
			if ($AzToken.Token -is [SecureString]) {
				# Convert SecureString to plain text
				$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($AzToken.Token)
				$TokenString = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
				[System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($BSTR)
			}
			else {
				# It's already a string
				$TokenString = $AzToken.Token.ToString()
			}

			# Calculate expiration time
			if ($AzToken.ExpiresOn) {
				$ExpiresOn = $AzToken.ExpiresOn
				if ($ExpiresOn -is [DateTime]) {
					$ExpiresOnDateTime = $ExpiresOn
				}
				else {
					# Try to parse it
					$ExpiresOnDateTime = [DateTime]::Parse($ExpiresOn.ToString())
				}
			}
			else {
				# Default to 1 hour if we can't determine
				$ExpiresOnDateTime = (Get-Date).AddHours(1)
			}

			# Create a token object compatible with existing AG* functions
			$TokenResponse = [PSCustomObject]@{
				access_token = $TokenString
				token_type = "Bearer"
				expires_in = ($ExpiresOnDateTime.ToUniversalTime() - (Get-Date).ToUniversalTime()).TotalSeconds
				expires_on = [DateTimeOffset]::Parse($ExpiresOnDateTime.ToString()).ToUnixTimeSeconds()
				not_before = [DateTimeOffset]::Now.ToUnixTimeSeconds()
				resource = $ResourceUrl
			}

			# Add the ExpiresOn property with the correct date format (matching your original function)
			$TokenResponse | Add-Member -MemberType NoteProperty -Name "ExpiresOn" -Value $ExpiresOnDateTime

			# Store in script scope for other functions to use
			$Script:TenantID = (Get-AzContext).Tenant.Id
			$Script:BaseUri = $ResourceUrl
			$Script:TokenResponse = $TokenResponse
			$Script:Headers = @{Authorization = "Bearer $TokenString"}

			Write-Verbose "Successfully acquired Graph access token. Expires at: $($ExpiresOnDateTime.ToString('yyyy-MM-dd HH:mm:ss'))"
			Write-Verbose "Token starts with: $($TokenString.Substring(0, [Math]::Min(20, $TokenString.Length)))..."
		}
		catch {
			throw "Failed to acquire access token: $_"
		}
	}

	END{
		Return $TokenResponse
	}
}