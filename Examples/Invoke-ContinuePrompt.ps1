function Invoke-ContinuePrompt {
    param (
    )
    $ShouldContinue = $false
    do {
        switch (Read-Host 'Continue? [Y/N]') {
            Y { $ShouldContinue = $true }
            N {
                Write-Output "Exiting"
                exit 1
            }
            Default { Write-Output "Only 'y' or 'n' are valid values." }
        }
    } until ($ShouldContinue)

    Write-Output "Continuing"
}