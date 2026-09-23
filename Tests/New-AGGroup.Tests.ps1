Describe 'New-AGGroup' {
	BeforeAll {
		. $PSScriptRoot\TestCommon.ps1
		Import-AgahModule
	}

	It 'is exported' {
		(Get-AgahCommand -Name 'New-AGGroup').Name  | Should -Be 'New-AGGroup'
	}

	It 'requires a display name and exposes the group type switch' {
		$command = Get-AgahCommand -Name 'New-AGGroup'
		($command.Parameters.Keys -contains 'DisplayName')  | Should -Be $true
		($command.Parameters.Keys -contains 'GroupType')  | Should -Be $true
	}
}