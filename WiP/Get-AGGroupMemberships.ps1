Function Get-AGGroupMemberships{
	<#
	.SYNOPSIS
		Retrieves a list of members of the specified group via MS Graph API.

	.DESCRIPTION
		Retrieves a list of members of the specified group via MS Graph API.

	.EXAMPLE
		$AccessToken = Get-AGGraphAccessToken -TenantID $TenantID -ClientID $ClientId -ClientSecret $ClientSecret
		$Groups = Get-AGGroups -AccessToken $AccessToken -DisplayNameStartsWith Az-Cont
		Get-AGGroupMemberships
		
		This command first get an access token, which is used to grant access to Graph, and then a list of groups is retrieved.
		A list of the members of one of those groups is then produced.

	.PARAMETER AccessToken
		This is the AccessToken that grants you access to MS Graph.

	.PARAMETER DisplayNameStartsWith
		This is the start of the name of the group(s) you are looking for. If not used, all groups are returned.
		
		Example: for the group "Admin_Desktops" you could use -DisplayNameStartsWith Admin_D

	.INPUTS
		Input is from command line or called from a script.

	.OUTPUTS
		This will output a list of groups.

	.NOTES
		Author:				Lars Panzerbjørn
		Creation Date:		2021.08.11
#>
	[CmdletBinding()]
	param
	(
		[Parameter(Mandatory)][string]$TenantID,
		[Parameter(Mandatory)][string]$ClientID,
		[Parameter(Mandatory)][string]$ClientSecret
	)

	BEGIN{

}