@{
    # Exclude specific rules you want to turn off
    ExcludeRules = @(
		'PSAvoidUsingWriteHost',    # Turns off Write-Host warnings
		'PSUseDeclaredVarsMoreThanAssignments',
		'PSAvoidUsingCmdletAliases' # Turns off cmdlet alias warnings
	)
	# IncludeRules = @(
	# 	'PSAvoidUsingPlainTextForPassword',
	# 	'PSAvoidUsingConvertToSecureStringWithPlainText'
	# )

    # Optional: Only show Errors and Warnings (hide Information-level messages)
    #Severity = @('Error', 'Warning')
}
