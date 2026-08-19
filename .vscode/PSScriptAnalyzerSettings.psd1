#https://chat.deepseek.com/a/chat/s/c4d23b6e-4a59-4cd2-9880-8c85f83aa6b1
@{
    # Exclude specific rules you want to turn off
    ExcludeRules = @(
		# 'PSAvoidUsingAliases',      # Turns off alias warnings (like 'rm' vs 'Remove-Item')
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
