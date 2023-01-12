# 创建5个独立的Edge浏览器快捷方式， 通过 msedge.exe --user-data-dir=[path] 启动, 隔离
# 适用于测试：比如同一个网站， 要登录不同的账号
# 可选安装不同浏览器， 每个浏览器登录一个账号

# create Num chromeEdge shotcut
$num = 1..5
foreach ($n in $num) {
    # Step #1 Define source file location of Google
    $SourceFilePath = "C:\Program Files\Google\Chrome\Application\chrome.exe“

    # Step #2: Define shortcut file location and name of shortcut file.
    $ShortcutPath = "$HOME\Desktop\Chrome0$n.lnk"

    # Step 3: Create new WScript.Shell object and assign it to variable
    # 通过New-Object这个Cmdlet来创建了一个COM组件，组件的类是WScript.Shell
    $WScriptObj = New-Object -ComObject ("WScript.Shell")

    # Step #4: Create Shortcut using shortcut path specified in Step 2
    $shortcut = $WscriptObj.CreateShortcut($ShortcutPath)

    # Step #5: Add Target Path or other relevant arguments to shortcut variable
    $shortcut.TargetPath = $SourceFilePath

    # specal args for store userdata
    mkdir "$HOME\Chrome0$n"
    $shortcut.Arguments = " --user-data-dir=`"$HOME\Chrome0$n`"" 
    $shortcut.WorkingDirectory = "C:\Program Files\Google\Chrome\Application"
    $shortcut.Description = "Chrome0$n for TUI-APPROVAL-PRELIVE-LIVE"
    # Step #6: Use Save() method
    $shortcut.Save()
}
