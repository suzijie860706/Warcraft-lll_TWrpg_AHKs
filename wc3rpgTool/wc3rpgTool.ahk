#Requires AutoHotkey v2.0
#SingleInstance Force
#Include Helper.ahk
#Include LoaderTab.ahk
#Include ToolTab.ahk
#Include HotStringTab.ahk
#Include HotkeysTab.ahk
#Include Settings.ahk

ProcessSetPriority "High"
SetKeyDelay IniRead(iniFileName, "SettingsTab", "keyDelay", 10)
ListLines false

version := "v1.4.4"
toolEnabled := false
toolEnableHistory := false
chatting := false
showMainGui := false
activeIconPath := A_ScriptDir "\app_active.ico"
inactiveIconPath := A_ScriptDir "\app_inactive.ico"

;force run as admin
if not A_IsAdmin {
    try {
        if A_IsCompiled
            Run '*RunAs "' A_ScriptFullPath '" /restart'
        else
            Run '*RunAs "' A_AhkPath '" /restart "' A_ScriptFullPath '"'
    }
    ExitApp
}

;GUI
MainGui := Gui()
MainGui.Title := "wc3rpgTool " version
mainStatusBar := MainGui.AddStatusBar()
Tab3 := MainGui.AddTab3("x0 y0 W580 H580 -Theme -TabStop Choose1", ["讀檔器", "改鍵工具", "快捷文字", "快捷鍵說明", "設定"])
loader := LoaderTab(MainGui, Tab3)
tool := ToolTab(MainGui, Tab3)
hs := HotStringTab(MainGui, Tab3)
hotkeys := HotkeyTab(MainGui, Tab3)
Settings(MainGui, Tab3)
updateAppStatus()
if IniRead(iniFileName, "SettingsTab", "enableToolonStartCheckbox", false) {
    toggleTool()
}
if !IniRead(iniFileName, "SettingsTab", "hideMainCheckbox", false) {
    MainGui.Show("W580 H608")
    showMainGui := true
}

; 自訂系統匣選單 (移除 AHK 原生開發者除錯視窗，改為點擊直接叫回主介面)
A_TrayMenu.Delete()
A_TrayMenu.Add("顯示 / 隱藏主視窗 (F8)", (*) => showHideMainGui())
A_TrayMenu.Default := "顯示 / 隱藏主視窗 (F8)"
A_TrayMenu.ClickCount := 1
A_TrayMenu.Add("切換改鍵開關", (*) => toggleTool())
A_TrayMenu.Add()
A_TrayMenu.Add("重新載入腳本 (Reload)", (*) => Reload())
A_TrayMenu.Add("完全結束程式 (Exit)", (*) => ExitApp())

MainGui.OnEvent("Close", onCloseGui)


; events
onCloseGui(GuiObj) {
    ExitApp
}

; functions
updateAppStatus() {
    global
    hkToggle := IniRead(A_ScriptDir "\HotkeysConfig.ini", "Hotkeys", "ToggleTool", "F2")
    if chatting {
        mainStatusBar.SetText("  💬 聊天打字中 (改鍵已自動暫停)  |  切換快捷鍵: [ " hkToggle " ]")
    } else if toolEnabled {
        mainStatusBar.SetText("  🔴 改鍵輔助：已啟用 (Active)  |  切換快捷鍵: [ " hkToggle " ]")
        if FileExist(activeIconPath) {
            try {
                hIcon := DllCall("LoadImage", "ptr", 0, "str", activeIconPath, "uint", 1, "int", 32, "int", 32, "uint", 0x00000010, "ptr")
                if (hIcon != 0) {
                    SendMessage(0x0080, 1, hIcon, MainGui.Hwnd)
                    SendMessage(0x0080, 0, hIcon, MainGui.Hwnd)
                }
                TraySetIcon(activeIconPath)
            }
        }
    } else {
        mainStatusBar.SetText("  ⚪ 改鍵輔助：已停用 (Inactive)  |  切換快捷鍵: [ " hkToggle " ]")
        if FileExist(inactiveIconPath) {
            try {
                hIcon := DllCall("LoadImage", "ptr", 0, "str", inactiveIconPath, "uint", 1, "int", 32, "int", 32, "uint", 0x00000010, "ptr")
                if (hIcon != 0) {
                    SendMessage(0x0080, 1, hIcon, MainGui.Hwnd)
                    SendMessage(0x0080, 0, hIcon, MainGui.Hwnd)
                }
                TraySetIcon(inactiveIconPath)
            }
        }
    }
    try A_IconTip := "wc3rpgTool " version " - " (chatting ? "打字中 (改鍵暫停)" : (toolEnabled ? "改鍵輔助：已啟用" : "改鍵輔助：已停用"))
}

toggleTool(hk := "") {
    global
    toolEnabled := !toolEnabled
    chatting := false
    updateAppStatus()
    try tool.updateHotkeys()
    try hs.updateHotStrings()
}

showHideMainGui(hk := "") {
    global
    showMainGui := !showMainGui
    if showMainGui {
        ; reload loader tab
        loader.updateFileList()
        Tab3.Choose(1)
        MainGui.Show("W580 H608")
    } else {
        MainGui.Hide()
    }
}

pauseGame(hk := "") {
    SendInput("{f10}{m}{f10}")
}

; common hotkeys
#HotIf WinActive("ahk_id " MainGui.Hwnd)
; hide main gui with Esc
$~Esc::
{
    global
    showMainGui := false
    MainGui.Hide()

}
#HotIf

; wc3 hotkeys
#HotIf WinActive(WarcraftIII)
$~+Enter::    ; Shift Enter
$~NumpadEnter::    ; numpad Enter
$~Enter::    ; Regular Enter
{
    global
    if !IniRead(iniFileName, "SettingsTab", "autoToggleToolCheckbox", true) {
        return
    }
    chatting := !chatting
    updateAppStatus()
}

; 取消聊天 (Esc)
$~Esc::
{
    global
    if chatting {
        chatting := false
        updateAppStatus()
    }
}
#HotIf