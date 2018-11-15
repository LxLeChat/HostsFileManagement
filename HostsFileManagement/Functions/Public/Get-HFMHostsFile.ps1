Function Get-HFMHostsfile {
    <#
    .SYNOPSIS
        Get the hosts file of the desired hostname.
    .DESCRIPTION
        Get the hostfile of the desired hostname.
        By default the localhost hosts file is fetched. You can specify a remote computer name.
    .EXAMPLE
        PS C:\> Get-HFMHostsfile
        Return a [HostsFile] object representing the local hosts file.
    .EXAMPLE
        PS C:\> Get-HFMHostsfile -Name Computer1
        Return a [HostsFile] object representing the hosts file of Computer1.
    .EXAMPLE
        PS C:\> "Computer1","Computer2" | Get-HFMHostsfile
        Return an array of [HostsFile] objects representing the hosts file of Computer1 and Computer2.
    .INPUTS
        Input String.
    .OUTPUTS
        Return [HostsFile] Object(s).
    .NOTES
        This cmdlet uses Class.HostsManagement classes, by @StephaneVG
        Fork hist project if you like it: https://github.com/Stephanevg/Class.HostsManagement
        Visit his site, and read his article a boute pratical use of PowerShell Classes: http://powershelldistrict.com/powershell-class/
    #>

    [CmdletBinding(DefaultParameterSetName='Set0')]
    Param
    (
        [Alias("Name")]
        [Parameter(Mandatory=$False,ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True,ParameterSetName='Set1')]
        [String[]]$ComputerName,

        [Alias("FullName")]
        [Parameter(Mandatory=$False,ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True,ParameterSetName='Set2')]
        [System.IO.FileInfo[]]$Path,

        [Switch]$ExcludeComment
    )

    BEGIN{}

    PROCESS{
        Switch ( $PSCmdlet.ParameterSetName ) {

            Set0 {

                $LocalHostPath = [HostsFile]::New()
                $LocalHostPath.ReadHostsFileContent()

                If ( $PSBoundParameters['ExcludeComment'] ) {
                    return $($LocalHostPath.GetEntries() | Where-ObJect EntryType -ne "Comment")
                } Else {
                    return $LocalHostPath.GetEntries()
                }
            }

            Set1 {

                Foreach ( $Computer in $ComputerName ) {

                    If ( Test-Connection -ComputerName $Computer -Quiet -Count 2 ) {
                        $RemoteHostFile = [HostsFile]::New($Computer)
                        $RemoteHostFile.ReadHostsFileContent()
                        If ( $PSBoundParameters['ExcludeComments'] ) {
                            return $($RemoteHostFile.GetEntries() | Where-ObJect EntryType -ne "Comment")
                        } Else {
                            return $RemoteHostFile.GetEntries()
                        }
                    } Else {
                        Throw "Could not reach computer $($Computer)"
                    }
                }

            }

            Set2 {

                Foreach ( $P in $Path ) {
                    If ($PSCmdlet.MyInvocation.ExpectingInput) {
                        $ClassParams.Path = $P.FullName
                    } Else {
                        $ClassParams.Path = (Get-Item (Resolve-Path $P).Path).FullName
                    }
                }

            }

        }

    }

    END{}
}
