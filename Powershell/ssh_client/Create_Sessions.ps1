#
[xml]$xml = Get-Content   "D:\Program Files\confCons.xml"
$XPath = "/Connections/Node"


# Select-Xml -Path $Path -XPath $Xpath | Select-Object -ExpandProperty Node
Select-Xml $xml -XPath $xpath | Foreach { echo $_.Node.ChildNodes.Name}
#    Foreach {$_.Node.SetAttribute('value', $pwd)

$Xml.Connections.Node[0].node[0].Name
$Xml.Connections.Node[0].node[0].Name = "vgc_test"

echo "注意：这里索引是从1开始的，不是0 "
$Xml.SelectNodes("Connections/Node[1]")
$Xml.SelectNodes("Connections/Node[1]/Node[1]")

$Xml.SelectNodes("Connections/Node[2]/Node[last()]")

$xml.SelectSingleNode("Connections/Node[2]/Node[last()]")


$xml.Save($xml)



$doc = [xml]@'
<xml>
    <Section name="BackendStatus">
        <BEName BE="crust" Status="1" />
        <BEName BE="pizza" Status="1" />
        <BEName BE="pie" Status="1" />
        <BEName BE="bread" Status="1" />
        <BEName BE="Kulcha" Status="1" />
        <BEName BE="kulfi" Status="1" />
        <BEName BE="cheese" Status="1" />
    </Section>
</xml>
'@

$doc.xml.Section.BEName

$doc.xml.Section.BEName | ? { $_.Status -eq 1 }


$doc.xml.Section.BEName | ? { $_.Status -eq 1 } | % { $_.BE + " is delicious" }
