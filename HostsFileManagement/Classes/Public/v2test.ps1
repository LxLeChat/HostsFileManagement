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
    $FullQuallifiedName
    $Description
    $EntryType
    $Source

    EntryDescription ($EntryType,$line) {
        $this.Source = $Line
        $this.EntryType = $EntryType
    }
}

Class CommentEntry : EntryDescription {
    
    CommentEntry($EntryType,$line):Base($EntryType,$line){}
    [CommentEntry]ToObject(){
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
    [HostEntry]ToObject(){
        $this.Ipaddress
        $this.HostName
        $this.FullQuallifiedName
        $this.Description
        return $this
    }
}

Class FileContent {
    $Path

    FileContent ($FilePath) {
        $This.Path = $FilePath
    }

    [String[]]RetunrFileContent(){
        Return $(Get-Content -Path $This.Path)
    }
}

Class TransfromToObject : FileContent {

    TransfromToObject ($FilePath):Base($FilePath){}

    [Object[]]TestLines(){
        $zou=@()
        Foreach ( $line in ($This.RetunrFileContent()) ) {
            If ( [Comment]::new($line).TestLine() ) {
                Write-Host "Comment $line"
                $zou+=([CommentEntry]::new("Comment",$line)).ToObject()
            }

            If ( [BlankLine]::new($line).TestLine() ) {
                Write-Host "BlankLine $line"
            }

            If ( [HostLine]::new($line).TestLine() ) {
                Write-Host "HostLine $line"
            }
        }
        return $zou
    }
}

#[ParsedFile]::new('C:\Windows\System32\drivers\etc\hosts').TestLines()