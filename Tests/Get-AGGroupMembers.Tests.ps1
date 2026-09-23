Describe 'Get-AGGroupMembers' {
	BeforeAll {
		. $PSScriptRoot\TestCommon.ps1
		Import-AgahModule
	}

	BeforeEach {
		Clear-AgahModuleState
	}

	It 'is exported' {
		(Get-AgahCommand -Name 'Get-AGGroupMembers').Name  | Should -Be 'Get-AGGroupMembers'
	}

	It 'supports group lookup by name or ID' {
		$command = Get-AgahCommand -Name 'Get-AGGroupMembers'
		($command.Parameters.Keys -contains 'DisplayName')  | Should -Be $true
		($command.Parameters.Keys -contains 'GroupID')  | Should -Be $true
	}
}