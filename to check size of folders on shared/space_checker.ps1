$SharedFolder = "\\server\SharedFolder"

Get-ChildItem -Path $SharedFolder -Directory | ForEach-Object {

    $Size = (Get-ChildItem -Path $_.FullName -File -Recurse -ErrorAction SilentlyContinue |
             Measure-Object -Property Length -Sum).Sum

    [PSCustomObject]@{
        Folder = $_.Name
        SizeGB = [math]::Round($Size / 1GB, 2)
    }

} | Sort-Object SizeGB -Descending