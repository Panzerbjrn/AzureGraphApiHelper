Function Show-AGGraphAccessToken{
<#
	.SYNOPSIS
		Shows the existing Graph access token stored in module scope.

	.DESCRIPTION
		Shows the existing Graph access token stored in module scope if one exists.

	.EXAMPLE
		Show-AGGraphAccessToken

		This command returns the token object currently stored in module scope.

	.INPUTS
		None. You cannot pipe input to this function.

	.OUTPUTS
		The token response object currently stored in module scope, if one exists.

	.NOTES
		Author:				Lars Panzerbjørn
		Creation Date:		2021.08.24
#>
	Return $TokenResponse
}
