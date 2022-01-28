$max = 5
for ($i = 1; $i -le $max; $i++) {
    Write-progress -Activity "Counting I" -Status "`$i = $i" -percentcomplete ($i / $max * 100) -id 1
    sleep 1
    for ($j = 1; $j -le $max; $j++) {
        Write-progress -Activity "Counting J" -Status "`$j = $j" -percentcomplete ($j / $max * 100) -ParentID 1
        Start-Sleep 1
    } #end for j
}