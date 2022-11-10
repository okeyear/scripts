
function New_HyperVSwitch ([string]$cidr) {
    ### 创建vSwitch， 用于固定虚拟机的IP地址
    # step1, 输入网段地址， 网关自动计算，会配置为网段的第一个IP
    # $cidr = "172.16.16.0/24"
    # step2, 自动根据cidr计算网关，并创建虚拟交换机
    # 虚拟交换机名称为"net_"加上net，比如 net_172.16.16.0
    # 获取网关
    $net = $cidr.split("/")[0]
    $prefix = $cidr.split("/")[1]
    $ip_tail = $net.split('.')[-1]
    $ip_tail_gateway = [int]$ip_tail + 1
    $gateway = $net -ireplace "${ip_tail}$", $ip_tail_gateway
    # 创建虚拟交换机，等同于在Hyper-V管理器界面中新建虚拟网络交换机
    $SwitchName = "net_$net"
    New-VMSwitch -SwitchName $SwitchName -SwitchType Internal
    # 查看 $SwitchName 的 ifindex，用于后续固定IP和设置网段
    $ifIndex = Get-NetAdapter | Where-Object { $_.Name -like "*$SwitchName*" } | Select-Object -ExpandProperty ifIndex
    # 创建ip，InterfaceIndex参数自行调整为上一步获取到的ifindex。这一步等同于在 控制面版-网卡属性 中设置ip
    New-NetIPAddress -IPAddress $gateway -PrefixLength $prefix  -InterfaceIndex $ifIndex
    # 创建nat网络，这一步是教程中的关键命令，24为子网掩码位数，即：255.255.255.0
    New-NetNat -Name $SwitchName -InternalIPInterfaceAddressPrefix $cidr
    # step3. 虚拟机选择新创建的nat网络， 比如上述建立的虚拟交换机net_172.16.16.0
    ### 删除vSwitch步骤
    # Get-NetNat # 确认获取到的nat只有一个且是你想要删除的
    # Get-NetNat | Where-Object { $_.Name -like "$SwitchName" } | Remove-NetNat #删除nat网络
}

New_HyperVSwitch -cidr "172.16.16.0/24"
