
Class HostEntry {
    $EntryType
    $Ipaddress
    $HostName
    $FqDn
    $Description

    HostEntry ($z,$a,$b,$c,$d) {
        $this.EntryType = $z
        $this.Ipaddress = $a
        $this.HostName = $b
        $this.FqDn =$c
        $this.Description = $d
    }

}

Class RawHostFile {

    Static [HostEntry]TestEntry($x){
    $t = ""
        Switch -regex ($x) {

            '^\s*$' {    
                $t = [HostEntry]::new([HostEntryType]::BlankLine,'','','','')
                Break;
             }

            '^#' {
                $t = [HostEntry]::new([HostEntryType]::CommentLine,'','','',($x -replace '^#','').trim())
                Break;
            }

            '^[^#\s]' {
                $Ipaddress=$HostName=$FqDn=$Description=$null
                $x -match "^(?<IpAddress>(\d{1,3}\.){3}\d{1,3})\s+(?<Hostname>([aA-zZ\d\.]+))\s+(?<fqdn>([aA-zZ\d\.]+))?\s*#?(?<Description>(.+))?"
                If ( $null -ne $matches.IpAddress ) { $Ipaddress = $matches.IpAddress }
                If ( $null -ne $matches.Hostname ) { $HostName = $matches.Hostname }
                If ( $null -ne $matches.FqDn ) { $FqDn = $matches.FqDn }
                If ( $null -ne $matches.Description ) { $Description = ($matches.Description).Trim() }
                $t = [HostEntry]::new([HostEntryType]::HostLine,$Ipaddress,$HostName,$FqDn,$Description)
                Break;
            }

        }
        return $t
    }

    Static [string]ConvertToLine ([HostEntry]$x) {
        $c = ""
        Switch ($x.EntryType) {

            "BlankLine" {
                $c = ""
                Break;
            }

            "CommentLine" {
                $c = "#" + $x.Description
                Break;
            }

            "HostLine" {
                $c = $x.IpAddress + " " + $x.Hostname
                If ( $x.FqDN ) { $c = $c + " " + $x.FqDN }
                If ( $x.Description ) { $c = $c + " #" + $x.description }
                Break; 
            }

        }

        return $c
    }

}

Class HostFile {
    $Path
    [System.Collections.Generic.List[HostEntry]]$Entry = @()

    HostFile ($HostFilePath) {
        $this.Path = $HostFilePath
    }

    [System.Collections.Generic.List[HostEntry]]Parse () {
        $Content = Get-Content -path $this.path
        Foreach ( $line in $Content ) {
            $this.Entry.Add([RawHostFile]::TestEntry($line))
        }

        Return $this.Entry
    }

    Save ($path) {
        
        Foreach ( $entry in $this.Entry ) {
            [RawHostFile]::ConvertToLine($entry) | out-file -FilePath $path -Append
        }
    
    }

    AddEntry ([HostEntry[]]$a) {

        Foreach ( $e in $a ) {
            $this.Entry.add($e)
        }

    }

}


## utilisation d'un prédicat....
## https://www.automatedops.com/blog/2017/02/06/working-with-the-collection-extension-methods-2-of-3/
#$file.Entry.FindAll({param($s) $s.Hostnme -eq 'dc01'})


<#
$file = [HostFile]::new('C:\temp\hosts.txt')
$file.Parse()
#[returnline]::ConvertToLine($file.Entry[0]) | Out-File c:\temp\hosts2.txt
$file.Save('c:\temp\host2.txt')


[HostEntry[]]$array = @(
    [HostEntry]::new([HostEntryType]::BlankLine,'','','',''),
    [HostEntry]::new([HostEntryType]::CommentLine,'','','','BEGIN New bloc entries'),
    [HostEntry]::new([HostEntryType]::HostLine,'127.0.0.10','tata','','new line tata'),
    [HostEntry]::new([HostEntryType]::HostLine,'127.0.0.11','tete','','new line tete'),
    [HostEntry]::new([HostEntryType]::HostLine,'127.0.0.12','titi','','new line titi'),
    [HostEntry]::new([HostEntryType]::CommentLine,'','','','END New bloc entries')
)

$file.AddEntry($array)
#>
