$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

Describe -Name 'Some Test' {
    It "Can't find LGPO.exe" {
        $result | Should -not $true
    }
}
