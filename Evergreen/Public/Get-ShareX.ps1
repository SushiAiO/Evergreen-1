Function Get-ShareX {
    <#
        .SYNOPSIS
            Returns the available ShareX versions.

        .DESCRIPTION
            Returns the available ShareX versions.

        .NOTES
            Author: Trond Eirik Haavarstein 
            Twitter: @xenappblog
        
        .LINK
            https://github.com/aaronparker/Evergreen

        .EXAMPLE
            Get-ShareX

            Description:
            Returns the released ShareX version and download URI.
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding()]
    Param()

    $res = Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1]
    Write-Verbose -Message $res.Name

    # Query the ShareX repository for releases, keeping the latest release
    $iwcParams = @{
        Uri         = $res.Get.Uri
        ContentType = $res.Get.ContentType
    }
    $Content = Invoke-WebContent @iwcParams
    
    If ($Null -ne $Content) {
        $json = $Content | ConvertFrom-Json
        $releases = $json | Where-Object { $_.prerelease -ne $True }
        $latestRelease = $releases | Select-Object -First 1

        # Build and array of the latest release and download URLs
        ForEach ($release in $latestRelease.assets) {
            $PSObject = [PSCustomObject] @{
                # TODO: use RegEx to extract version number rather than -replace
                Version = ($latestRelease.tag_name -replace "v", "")
                Date    = (ConvertTo-DateTime -DateTime $release.created_at)
                Size    = $release.size
                URI     = $release.browser_download_url
            }
            Write-Output -InputObject $PSObject
        }
    }
}
