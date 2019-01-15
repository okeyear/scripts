function Get_SubNet{
    param(
            [Parameter(Mandatory=$true,ValueFromPipeline=$True,HelpMessage="Enter a valid IP:")] $IPAddress,
            [Parameter(Mandatory=$true,ValueFromPipeline=$True,HelpMessage="Enter a valid number:")] $MaskLen
            )
    
Add-Type @"
        public class SubNet {
        public string IP;
        public string Network;
        public string Mask;
        public string BroadCast;
        }
"@
    
        $My = New-Object SubNet
        $My.IP = $IPAddress
    
        # Transfer IP address to binary string: 211.151.113.201 -> 11010011100101110111000111001001
        $IPBin = -join ($IPAddress.Split('.') | ForEach-Object {[System.Convert]::ToString($_,2).PadLeft(8,'0')})
        # Calculate subnet mask
        $Mask = ""
        #Set all $MaskLen bit to 1, other part as 0, total 32 bits
        for($i = 0;$i -lt $MaskLen;$i++){$Mask = $Mask + "1"}
        for($i = 0;$mask.Length -lt 32;$i++){$Mask = $Mask + "0"}
        $My.Mask = -join ([Convert]::ToInt32($mask.Substring(0,8),2),".",[Convert]::ToInt32($mask.Substring(8,8),2),".",[Convert]::ToInt32($mask.Substring(16,8),2),".",[Convert]::ToInt32($mask.Substring(24,8),2))
    
        # Calculate sub network address.
        $net = $IPBin.Substring(0,$MaskLen)
        for($i = 0;$net.Length -lt 32;$i++){$net = $net + "0"}
        $My.Network = -join ([Convert]::ToInt32($net.Substring(0,8),2),".",[Convert]::ToInt32($net.Substring(8,8),2),".",[Convert]::ToInt32($net.Substring(16,8),2),".",[Convert]::ToInt32($net.Substring(24,8),2))
    
        # Calculate broadcast address
        $net = $IPBin.Substring(0,$MaskLen)
        for($i = 0;$net.Length -lt 32;$i++){$net = $net + "1"}
        $My.BroadCast = -join ([Convert]::ToInt32($net.Substring(0,8),2),".",[Convert]::ToInt32($net.Substring(8,8),2),".",[Convert]::ToInt32($net.Substring(16,8),2),".",[Convert]::ToInt32($net.Substring(24,8),2))
    
        return $My
        # $rslt | select IP,Network,Mask,BroadCast
    
    }
    