Describe 'Get-AGSPEntraMemberOf' {
	BeforeAll {
		. $PSScriptRoot\TestCommon.ps1
		Import-AgahModule
	}

	It 'is exported' {
		(Get-AgahCommand -Name 'Get-AGSPEntraMemberOf').Name  | Should -Be 'Get-AGSPEntraMemberOf'
	}

	It 'supports both object ID and app ID lookup' {
		$command = Get-AgahCommand -Name 'Get-AGSPEntraMemberOf'
		($command.Parameters.Keys -contains 'ObjectID')  | Should -Be $true
		($command.Parameters.Keys -contains 'AppID')  | Should -Be $true
		($command.Parameters.Keys -contains 'UseBetaAPI')  | Should -Be $true
	}
}