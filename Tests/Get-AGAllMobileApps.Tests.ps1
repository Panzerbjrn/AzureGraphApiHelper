Describe 'Get-AGAllMobileApps' {
	BeforeAll {
		. $PSScriptRoot\TestCommon.ps1
		Import-AgahModule
	}

	BeforeEach {
		Clear-AgahModuleState
		Set-AgahModuleState -State @{
			BaseUri = 'https://graph.microsoft.com'
			Headers = @{ Authorization = 'Bearer token' }
		}
	}

	It 'is exported' {
		(Get-AgahCommand -Name 'Get-AGAllMobileApps').Name | Should -Be 'Get-AGAllMobileApps'
	}

	It 'returns mobile app items from the Graph response' {
		Mock Invoke-RestMethod {
			[pscustomobject]@{
				value = @([pscustomobject]@{ id = 'app-1' })
			}
		} -ModuleName AzureGraphApiHelper

		$result = Get-AGAllMobileApps

		@($result).Count | Should -Be 1
		$result[0].id | Should -Be 'app-1'
	}
}