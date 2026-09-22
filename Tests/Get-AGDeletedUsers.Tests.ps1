. $PSScriptRoot\TestCommon.ps1

Describe 'Get-AGDeletedUsers' {
	BeforeAll {
		Import-AgahModule
	}

	BeforeEach {
		Clear-AgahModuleState
	}

	It 'is exported' {
		(Get-AgahCommand -Name 'Get-AGDeletedUsers').Name | Should Be 'Get-AGDeletedUsers'
	}

	It 'throws when no token is available' {
		{ Get-AGDeletedUsers } | Should Throw 'Please provide access token'
	}
}