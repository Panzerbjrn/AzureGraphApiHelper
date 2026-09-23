Describe 'Get-AGGroups' {
	BeforeAll {
		. $PSScriptRoot\TestCommon.ps1
		Import-AgahModule
	}

	BeforeEach {
		Clear-AgahModuleState
	}

	It 'is exported' {
		(Get-AgahCommand -Name 'Get-AGGroups').Name  | Should -Be 'Get-AGGroups'
	}

	It 'throws when no token is available' {
		{ Get-AGGroups }  | Should -Throw 'Please provide access token'
	}
}