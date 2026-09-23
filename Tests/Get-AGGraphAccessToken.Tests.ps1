Describe 'Get-AGGraphAccessToken' {
	BeforeAll {
		. $PSScriptRoot\TestCommon.ps1
		Import-AgahModule
	}

	BeforeEach {
		Clear-AgahModuleState
	}

	It 'is exported' {
		(Get-AgahCommand -Name 'Get-AGGraphAccessToken').Name  | Should -Be 'Get-AGGraphAccessToken'
	}

	It 'returns a token response with expiry metadata' {
		Mock Invoke-RestMethod {
			[pscustomobject]@{
				access_token = 'token-value'
				expires_in = 3600
			}
		} -ModuleName AzureGraphApiHelper

		$result = Get-AGGraphAccessToken -TenantID 'tenant-id' -ClientID 'client-id' -ClientSecret 'client-secret'

		$result.access_token  | Should -Be 'token-value'
		($result.PSObject.Properties.Name -contains 'ExpiresOn')  | Should -Be $true
	}
}