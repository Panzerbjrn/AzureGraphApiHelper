Function Renew-AGGraphAccessToken{
<#
	.SYNOPSIS
		This will renew the existing Token if it will expire in 5 minutes or less

	.DESCRIPTION
		This will renew the existing Token if it will expire in 5 minutes or less

	.EXAMPLE
		Renew-AGGraphAccessToken

	.NOTES
		Author:				Lars Panzerbjørn
		Creation Date:		2021.10.19
#>
	IF(!($TokenResponse.ExpiresOn -ge $((Get-Date).AddMinutes(5)))){
		Get-AGGraphAccessToken -TenantID $TenantID -ClientID $ClientId -ClientSecret $ClientSecret
	}
}
