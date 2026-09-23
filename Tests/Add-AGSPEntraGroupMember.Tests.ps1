Describe 'Add-AGSPEntraGroupMember' {
	BeforeAll {
		. $PSScriptRoot\TestCommon.ps1
		Import-AgahModule
	}

	It 'is exported' {
		(Get-AgahCommand -Name 'Add-AGSPEntraGroupMember').Name | Should -Be 'Add-AGSPEntraGroupMember'
	}

	It 'supports both service principal and group lookup parameters' {
		$command = Get-AgahCommand -Name 'Add-AGSPEntraGroupMember'
		($command.Parameters.Keys -contains 'ObjectID') | Should -Be $true
		($command.Parameters.Keys -contains 'AppID') | Should -Be $true
		($command.Parameters.Keys -contains 'GroupID') | Should -Be $true
		($command.Parameters.Keys -contains 'DisplayName') | Should -Be $true
	}
}