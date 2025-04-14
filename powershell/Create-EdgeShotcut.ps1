# 用powershell, 在桌面建三个不同的edge快捷方式, 要求用msedge.exe --user-data-dir完全隔离开数据, 名称分别叫做dev, non-prod和prod,  并调整快捷方式的图标, 以便区分



# 定义基础路径
$edgePath = "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
$dataDirBase = "$env:USERPROFILE\EdgeData"
$desktopPath = [Environment]::GetFolderPath("Desktop")
$iconPath = "$env:SystemRoot\System32\SHELL32.dll"  # 系统内置图标库

# 验证 Edge 是否存在
if (-not (Test-Path $edgePath)) {
    Write-Error "Microsoft Edge 未安装在默认路径，请检查安装位置！"
    exit
}

# 创建数据目录
$profiles = "dev", "non-prod", "prod"
foreach ($profile in $profiles) {
    New-Item -Path "$dataDirBase\$profile" -ItemType Directory -Force | Out-Null
}

# 创建快捷方式的函数
function Create-EdgeShortcut {
    param(
        [string]$ProfileName,
        [int]$IconIndex
    )
    
    $shortcutPath = "$desktopPath\$ProfileName.lnk"
    $shell = New-Object -ComObject WScript.Shell
    $shortcut = $shell.CreateShortcut($shortcutPath)
    
    # 设置启动参数
    $shortcut.TargetPath = $edgePath
    $shortcut.Arguments = "--user-data-dir=`"$dataDirBase\$ProfileName`""
    
    # 设置图标
    $shortcut.IconLocation = "$iconPath,$IconIndex"
    
    # 保存设置
    $shortcut.Save()
    Write-Host "已创建快捷方式: $ProfileName (图标索引 $IconIndex)"
}

# 为不同环境创建快捷方式（使用不同的系统图标）
Create-EdgeShortcut -ProfileName "dev"      -IconIndex 44      # 黄色警示图标
Create-EdgeShortcut -ProfileName "non-prod" -IconIndex 43      # 蓝色信息图标
Create-EdgeShortcut -ProfileName "prod"     -IconIndex 16      # 红色停止图标

# 清理 COM 对象
[System.Runtime.Interopservices.Marshal]::ReleaseComObject([System.Runtime.Interopservices.Marshal]::GetActiveObject('WScript.Shell')) | Out-Null
