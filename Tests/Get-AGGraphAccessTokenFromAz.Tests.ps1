. $PSScriptRoot\TestCommon.ps1

Describe 'Get-AGGraphAccessTokenFromAz' {
	BeforeAll {
		Import-AgahModule
	}

	BeforeEach {
		Clear-AgahModuleState
	}

	It 'is exported' {
		(Get-AgahCommand -Name 'Get-AGGraphAccessTokenFromAz').Name | Should Be 'Get-AGGraphAccessTokenFromAz'
	}

	It 'builds a token object from the current Az context' {
		Mock Get-Module { [pscustomobject]@{ Name = 'Az.Accounts' } } -ModuleName AzureGraphApiHelper
		Mock Get-AzContext {
			[pscustomobject]@{
				Tenant = [pscustomobject]@{ Id = 'tenant-id' }
			}
		} -ModuleName AzureGraphApiHelper
		Mock Get-AzAccessToken {
			[pscustomobject]@{
				Token = 'token-value'
				ExpiresOn = (Get-Date).AddMinutes(30)
			}
		} -ModuleName AzureGraphApiHelper

		$result = Get-AGGraphAccessTokenFromAz

		$result.access_token | Should Be 'token-value'
		$result.resource | Should Be 'https://graph.microsoft.com'
	}
}