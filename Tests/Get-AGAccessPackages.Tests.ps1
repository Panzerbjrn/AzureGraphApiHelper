. $PSScriptRoot\TestCommon.ps1

Describe 'Get-AGAccessPackages' {
	BeforeAll {
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
		(Get-AgahCommand -Name 'Get-AGAccessPackages').Name | Should Be 'Get-AGAccessPackages'
	}

	It 'returns access package items from the Graph response' {
		Mock Invoke-RestMethod {
			[pscustomobject]@{
				value = @([pscustomobject]@{ id = 'package-1' })
			}
		} -ModuleName AzureGraphApiHelper

		$result = Get-AGAccessPackages

		@($result).Count | Should Be 1
		$result[0].id | Should Be 'package-1'
	}
}