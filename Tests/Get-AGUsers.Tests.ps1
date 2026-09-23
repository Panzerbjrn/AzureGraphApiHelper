Describe 'Get-AGUsers' {
	BeforeAll {
		. $PSScriptRoot\TestCommon.ps1
		Import-AgahModule
	}

	BeforeEach {
		Clear-AgahModuleState
	}

	It 'is exported' {
		(Get-AgahCommand -Name 'Get-AGUsers').Name  | Should -Be 'Get-AGUsers'
	}

	It 'supports UPN and user type filters' {
		$command = Get-AgahCommand -Name 'Get-AGUsers'
		($command.Parameters.Keys -contains 'UserPrincipalName')  | Should -Be $true
		($command.Parameters.Keys -contains 'UserType')  | Should -Be $true
	}
}