Describe 'Get-AGAccessPackageAssignments' {
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
		(Get-AgahCommand -Name 'Get-AGAccessPackageAssignments').Name | Should -Be 'Get-AGAccessPackageAssignments'
	}

	It 'returns assignment items from the Graph response' {
		Mock Invoke-RestMethod {
			[pscustomobject]@{
				value = @([pscustomobject]@{ id = 'assignment-1' })
			}
		} -ModuleName AzureGraphApiHelper

		$result = Get-AGAccessPackageAssignments

		@($result).Count | Should -Be 1
		$result[0].id | Should -Be 'assignment-1'
	}
}