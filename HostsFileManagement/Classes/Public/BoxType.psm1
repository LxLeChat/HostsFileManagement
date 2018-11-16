Class BoxType{
    [String]GetBoxType(){
        If ( $Null -eq $Global:PSVersionTable.Platfrom ) {
            $Global:PSVersionTable.PSEdition -eq "DeskTop"
            Return "PoshClassic"
        } Else {
            Return $Global:PSVersionTable.Platfrom
        }
    }
}