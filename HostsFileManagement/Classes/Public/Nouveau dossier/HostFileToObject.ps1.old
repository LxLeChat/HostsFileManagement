## décrit un test
Class TestEntry {
    $Entry
    TestEntry($line){
        $this.entry = $line
    }
}

Class Comment:TestEntry {

    Comment($Entry):base($Entry){}

    [Bool]TestLine(){
        return $this.Entry -match '^#'
    }
}

Class BlankLine:TestEntry {

    BlankLine($Entry):base($Entry){}

    [Bool]TestLine(){
        return $this.Entry -match '^\s*$'
    }
}

Class HostLine:TestEntry {

    HostLine($Entry):base($Entry){}

    [Bool]TestLine(){
        return $this.Entry -notmatch '^(#.*|\s*)$'
    }
}

##décrit une entrée
Class EntryDescription{
    $Ipaddress
    $HostName
    $FqDn
    $Description
    $EntryType
    $Source

    EntryDescription ($EntryType,$line) {
        $this.Source = $Line
        $this.EntryType = $EntryType
    }

    EntryDescription(){}
}

## entrée de type comment
Class CommentEntry : EntryDescription {
    
    CommentEntry($EntryType,$line):Base($EntryType,$line){}

    CommentEntry($a):Base(){
        $this.Description = $a
        $this.EntryType = "Comment"
    }

    [CommentEntry]ToObject(){
        $this.Description = ($this.source.replace("#","")).trim()
        return $this
    }
}

## entrée de type blankline
Class BlankLineEntry : EntryDescription {

    BlankLineEntry($EntryType,$line):Base($EntryType,$line){}
    [BlankLineEntry]ToObject(){
        return $this
    }
}

## entrée de type host
Class HostEntry : EntryDescription {
    
    HostEntry($EntryType,$line):Base($EntryType,$line){}

    HostEntry($a,$b,$c,$d):Base(){
        $this.Ipaddress = $a
        $this.HostName = $b
        $this.Fqdn = $c
        $this.Description = $d
        $this.EntryType = "HostEntry"
    }

    [HostEntry]ToObject(){
        $this.source -match "^(?<IpAddress>(\d{1,3}\.){3}\d{1,3})\s+(?<Hostname>([aA-zZ\d\.]+))\s+(?<fqdn>([aA-zZ\d\.]+))?\s*#?(?<Description>(.+))?"
        If ( $null -ne $matches.IpAddress ) { $this.Ipaddress = $matches.IpAddress }
        If ( $null -ne $matches.Hostname ) { $this.HostName = $matches.Hostname }
        If ( $null -ne $matches.FqDn ) { $this.FqDn = $matches.FqDn }
        If ( $null -ne $matches.Description ) { $this.Description = ($matches.Description).Trim() }
        return $this
    }

}

## décrit le contenu d"un fichier, retourne son contenu et le backup
Class FileContent {
    $Path
    $Content

    FileContent ($FilePath) {
        $This.Path = $FilePath
    }

    FileContent(){}

    [String[]]RetunrFileContent(){
        $this.Content = $(Get-Content -Path $This.Path)
        Return $this.Content
    }

    BackupFile($BackupPath){
        Copy-Item -Path $this.Path -Destination $BackupPath
    }

}

## extension, qui permet de transformer le contenu du fichier en objet
## ajouter des entrée à l objet
## sauvegarder l objet
Class HostFileToObject : FileContent {
    $FileAsBojects

    HostFileToObject ($FilePath):Base($FilePath){}

    ConvertToObject(){
        $zou = new-object -TypeName System.Collections.ArrayList
        Foreach ( $line in ($This.RetunrFileContent()) ) {

            If ( [Comment]::new($line).TestLine() ) {
                $zou.add(([CommentEntry]::new("CommentEntry",$line)).ToObject())
            }

            If ( [BlankLine]::new($line).TestLine() ) {
                $zou.add(([BlankLineEntry]::new("BlankEntry",$line)).ToObject())
            }

            If ( [HostLine]::new($line).TestLine() ) {
                $zou.add(([HostEntry]::new("HostEntry",$line)).ToObject())
            }

        }
        $this.FileAsBojects = $zou
    }

    AddEntry([HostEntry]$a) {
        write-host "Add hostentry"
        $this.FileAsBojects.Add($a)
    }

    AddEntry([CommentEntry]$a) {
        write-host "Add commententry"
        $this.FileAsBojects.Add($a)
    }

    AddEntry([BlankLineEntry]$a) {
        write-host "Add blanklineentry"
        $this.FileAsBojects.Add($a)
    }

    SaveFile(){
        $this.Content | Out-File -FilePath $this.Path
    }
}


#$x = [TransfromToObject]::new('C:\Windows\System32\drivers\etc\hosts')
#$z = $x.ConvertToObject()
#$z.add()