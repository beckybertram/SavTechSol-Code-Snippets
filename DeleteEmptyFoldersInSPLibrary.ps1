$siteUrl = "https://[tenant].sharepoint.com/sites/Site"
$libraryUrl = "Shared%20Documents"
$libraryName = "Documents"
 
Connect-PnPOnline -Url $siteUrl
$web = Get-PnPWeb
$context = Get-PnPContext
$folder = Get-PnPFolder -RelativeUrl $libraryUrl
$folders_list=@()
 
Function GetAllSubFolders([Microsoft.SharePoint.Client.Folder]$folder, [Microsoft.SharePoint.Client.ClientContext] $context)
{
    $files = $folder.Files
    $context.Load($folder.Files)
    $context.Load($folder.Folders)
    $context.Load($folder.ParentFolder)
    $context.ExecuteQuery()

    foreach($subFolder in $folder.Folders)
    {
        GetAllSubFolders $subFolder $context
    }
    
    if ($folder.Files.Count -eq 0 -and $folder.Folders.Count -eq 0 -and (($folder.Name -notmatch 'Document') -and ($folder.Name -notmatch $libraryName )))
    {
        $path = $folder.ParentFolder.ServerRelativeUrl.Substring($web.ServerRelativeUrl.Length)    
        Write-Host "Removing folder " $folder.ServerRelativeUrl.Substring($web.ServerRelativeUrl.Length)   
        Remove-PnPFolder -Folder $path -Name $folder.Name -Recycle -Force
        $folders_list += $folder.Name + ", " + $folder.ServerRelativeUrl
    }

    return $folders_list
}
cls
Write-Host "Looking for empty folders. Please wait..."
$folders_list = GetAllSubFolders $folder $context
Write-Host $libraryName 'Complete'
