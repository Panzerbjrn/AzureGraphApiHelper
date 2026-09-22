Function Renew-AGGraphAccessToken{
<#
	.SYNOPSIS
		Renews the existing Graph access token if it will expire in 5 minutes or less.

	.DESCRIPTION
		Renews the existing Graph access token if it will expire in 5 minutes or less.
		This helper reuses the tenant ID, client ID, and client secret previously stored in module scope by Get-AGGraphAccessToken.

	.EXAMPLE
		Renew-AGGraphAccessToken

		This command refreshes the module-scoped token when it is close to expiry.

	.INPUTS
		None. You cannot pipe input to this function.

	.OUTPUTS
		A token response object when the token is renewed. Otherwise, no output is produced.

	.NOTES
		Author:				Lars Panzerbjørn
		Creation Date:		2021.10.19
#>
	IF(!($TokenResponse.ExpiresOn -ge $((Get-Date).AddMinutes(5)))){
		Get-AGGraphAccessToken -TenantID $TenantID -ClientID $ClientId -ClientSecret $ClientSecret
	}
}
