$script:ProjectRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$script:ManifestPath = Join-Path $script:ProjectRoot 'AzureGraphApiHelper\AzureGraphApiHelper.psd1'

function Import-AgahModule {
	Import-Module $script:ManifestPath -Force -ErrorAction Stop
}

function Get-AgahCommand {
	param(
		[Parameter(Mandatory)]
		[string]$Name
	)

	Get-Command -Module AzureGraphApiHelper -Name $Name -ErrorAction Stop
}

function Set-AgahModuleState {
	param(
		[Parameter(Mandatory)]
		[hashtable]$State
	)

	$module = Get-Module AzureGraphApiHelper -ErrorAction Stop
	& $module {
		param($State)
		foreach ($key in $State.Keys) {
			Set-Variable -Scope Script -Name $key -Value $State[$key]
		}
	} $State
}

function Get-AgahModuleValue {
	param(
		[Parameter(Mandatory)]
		[string]$Name
	)

	$module = Get-Module AzureGraphApiHelper -ErrorAction Stop
	& $module {
		param($Name)
		Get-Variable -Scope Script -Name $Name -ValueOnly -ErrorAction SilentlyContinue
	} $Name
}

function Clear-AgahModuleState {
	param(
		[string[]]$Names = @('TokenResponse', 'Headers', 'BaseUri', 'TenantID', 'ClientID', 'ClientSecret')
	)

	$module = Get-Module AzureGraphApiHelper -ErrorAction Stop
	& $module {
		param($Names)
		foreach ($name in $Names) {
			Remove-Variable -Scope Script -Name $name -ErrorAction SilentlyContinue
		}
	} $Names
}