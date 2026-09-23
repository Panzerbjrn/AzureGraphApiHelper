Describe 'Show-AGGraphAccessToken' {
	BeforeAll {
		. $PSScriptRoot\TestCommon.ps1
		Import-AgahModule
	}

	BeforeEach {
		Clear-AgahModuleState
	}

	It 'is exported' {
		(Get-AgahCommand -Name 'Show-AGGraphAccessToken').Name  | Should -Be 'Show-AGGraphAccessToken'
	}

	It 'returns the token stored in module scope' {
		$token = [pscustomobject]@{ access_token = 'token-value' }
		Set-AgahModuleState -State @{ TokenResponse = $token }

		$result = Show-AGGraphAccessToken

		$result.access_token  | Should -Be 'token-value'
	}
}