. $PSScriptRoot\TestCommon.ps1

Describe 'AzureGraphApiHelper module' {
	BeforeAll {
		Import-AgahModule
	}

	It 'imports from the manifest' {
		(Get-Module AzureGraphApiHelper) | Should Not BeNullOrEmpty
	}

	It 'exports all function files in the Functions folder' {
		$expected = Get-ChildItem (Join-Path $script:ProjectRoot 'AzureGraphApiHelper\Functions\*.ps1') |
			Select-Object -ExpandProperty BaseName |
			Sort-Object
		$actual = Get-Command -Module AzureGraphApiHelper -CommandType Function |
			Select-Object -ExpandProperty Name |
			Sort-Object

		Compare-Object -ReferenceObject $expected -DifferenceObject $actual | Should BeNullOrEmpty
	}
}