Describe 'Get-AGDeletedUsers' {
	BeforeAll {
		. $PSScriptRoot\TestCommon.ps1
		Import-AgahModule
	}

	BeforeEach {
		Clear-AgahModuleState
	}

	It 'is exported' {
		(Get-AgahCommand -Name 'Get-AGDeletedUsers').Name  | Should -Be 'Get-AGDeletedUsers'
	}

	It 'throws when no token is available' {
		{ Get-AGDeletedUsers }  | Should -Throw 'Please provide access token'
	}
}