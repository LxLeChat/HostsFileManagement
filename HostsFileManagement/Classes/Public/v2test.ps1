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

Class EntryDescription{
    $Ipaddress
    $HostName
    $Description
    $EntryType
    $Source

    EntryDescription ($EntryType,$line) {
        $this.Source = $Line
        $this.EntryType = $EntryType
    }

    EntryDescription(){}
}

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

Class BlankLineEntry : EntryDescription {

    BlankLineEntry($EntryType,$line):Base($EntryType,$line){}
    [BlankLineEntry]ToObject(){
        return $this
    }
}

Class HostEntry : EntryDescription {
    
    HostEntry($EntryType,$line):Base($EntryType,$line){}

    HostEntry($a,$b,$c):Base(){
        $this.Ipaddress = $a
        $this.HostName = $b
        $this.Description = $c
        $this.EntryType = "HostEntry"
    }

    [HostEntry]ToObject(){
        $this.source -match "^(?<IpAddress>(\d{1,3}\.){3}\d{1,3})\s+(?<Hostname>([aA-zZ\.]+))\s+#(?<Description>(.+))"
        $this.Ipaddress = $matches.IpAddress
        $this.HostName = $matches.Hostname
        $this.Description = ($matches.Description).Trim()
        return $this
    }

}

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
        $this.Content | Out-File -FilePath $BackupPath
    }
}

Class TransfromToObject : FileContent {
    $FileAsBojects

    TransfromToObject ($FilePath):Base($FilePath){}

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
        #return $zou
    }

    AddEntry([HostEntry]$a) {
        write-host "hostentry"
        $this.FileAsBojects.Add($a)
    }

    AddEntry([CommentEntry]$a) {
        write-host "commententry"
        $this.FileAsBojects.Add($a)
    }

    AddEntry([BlankLineEntry]$a) {
        write-host "blanklineentry"
        $this.FileAsBojects.Add($a)
    }
}


#$x = [TransfromToObject]::new('C:\Windows\System32\drivers\etc\hosts')
#$z = $x.ConvertToObject()
#$z.add()