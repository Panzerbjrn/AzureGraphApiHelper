Describe 'Get-AGActivationUserDetail' {
	BeforeAll {
		. $PSScriptRoot\TestCommon.ps1
		Import-AgahModule
	}

	BeforeEach {
		Clear-AgahModuleState
	}

	It 'is exported' {
		(Get-AgahCommand -Name 'Get-AGActivationUserDetail').Name | Should -Be 'Get-AGActivationUserDetail'
	}

	It 'throws when no token is available' {
		{ Get-AGActivationUserDetail } | Should -Throw 'Please provide access token'
	}
}