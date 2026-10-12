#Requires AutoHotkey v2.0
iniFileName := "wc3rpgToolData.ini"
GroupAdd("WarcraftGroup", "ahk_exe Warcraft III.exe")
GroupAdd("WarcraftGroup", "ahk_exe war3.exe")
GroupAdd("WarcraftGroup", "Warcraft III")
GroupAdd("WarcraftGroup", "魔兽争霸")
GroupAdd("WarcraftGroup", "魔獸爭霸")
WarcraftIII := "ahk_group WarcraftGroup"
ih := InputHook("V", "{Esc}")

KeyWaitAny()
{
    ih.VisibleNonText := false
    ih.KeyOpt("{All}", "E")  ; End
    ih.Start()
    ih.Wait()
    return ih.EndKey  ; Return the key name
}

KeyWaitCombo()
{
    ih.VisibleNonText := false
    ih.KeyOpt("{All}", "E")    ; End
    ; Exclude the modifiers
    ih.KeyOpt("{LCtrl}{RCtrl}{LAlt}{RAlt}{LShift}{RShift}{LWin}{RWin}", "-E")
    ih.Start()
    ErrorLevel := ih.Wait()    ; Store EndReason in ErrorLevel
    return ih.EndMods . ih.EndKey    ; Return a string like <^<+Esc
}

GetInput()
{
    ih := InputHook("V", "{Enter}")
    ih.VisibleNonText := false
    ih.Start()
    ErrorLevel := ih.Wait()
    if (ErrorLevel = "EndKey")
        ErrorLevel .= ":" ih.EndKey
    OutputVar := ih.Input
    return OutputVar
}

ReadableHotkey(hotkey, fullName := false) {
    hotkeyMap1 := Map(
        "<", "L",
        ">", "R")

    hotkeyMap2 := Map(
        "#", "W + ",
        "!", "A + ",
        "^", "C + ",
        "+", "S + "
    )

    hotkeyMap2FullName := Map(
        "#", "Win + ",
        "!", "Alt + ",
        "^", "Ctrl + ",
        "+", "Shift + "
    )

    hotkey := StrUpper(hotkey)
    for key, value in hotkeyMap1 {
        hotkey := StrReplace(hotkey, "$", "")
        hotkey := StrReplace(hotkey, "~", "")
        hotkey := StrReplace(hotkey, key, value)
    }
    for key, value in (fullName ? hotkeyMap2FullName : hotkeyMap2) {
        newHotkey := StrReplace(hotkey, key, value)
        if newHotkey != hotkey {
            hotkey := newHotkey
            break
        }
    }
    return hotkey
}

SelectFolder(initialFolder := "") {
    static CLSID_FileOpenDialog := "{DC1C5A9C-E88A-4dde-A5A1-60F82A20AEF7}"
    static IID_IFileOpenDialog  := "{D57C7288-D4AD-4768-BE02-9D969532D960}"
    static FOS_PICKFOLDERS      := 0x00000020
    static FOS_FORCEFILESYSTEM  := 0x00000040
    static SIGDN_FILESYSPATH    := 0x80058000

    try {
        dialog := ComObject(CLSID_FileOpenDialog, IID_IFileOpenDialog)
        ; 設定僅選取資料夾與檔案系統選項
        ComCall(9, dialog, "UInt", FOS_PICKFOLDERS | FOS_FORCEFILESYSTEM)
        ComCall(17, dialog, "WStr", "選擇 TWRPG 存檔資料夾")

        ; 若已有初始路徑則預設開啟該目錄
        if (initialFolder != "" && DirExist(initialFolder)) {
            pFolderItem := 0
            if !DllCall("shell32\SHCreateItemFromParsingName", "WStr", initialFolder, "Ptr", 0, "Ptr", Buffer(16), "Ptr*", &pFolderItem) {
                ComCall(12, dialog, "Ptr", pFolderItem)
                ObjRelease(pFolderItem)
            }
        }

        ; 顯示新式檔案總管視窗 (支援網址列、常用路徑與路徑貼上)
        hr := ComCall(3, dialog, "Ptr", 0)
        if (hr == 0) {
            pItem := 0
            ComCall(20, dialog, "Ptr*", &pItem)
            if (pItem) {
                pDisplayName := 0
                ComCall(5, pItem, "UInt", SIGDN_FILESYSPATH, "Ptr*", &pDisplayName)
                if (pDisplayName) {
                    selectedPath := StrGet(pDisplayName, "UTF-16")
                    DllCall("ole32\CoTaskMemFree", "Ptr", pDisplayName)
                    ObjRelease(pItem)
                    return selectedPath
                }
                ObjRelease(pItem)
            }
        }
    } catch {
        return DirSelect(initialFolder, 1, "選擇 TWRPG 存檔資料夾")
    }
    return ""
}

GetFileNamesInFolder(path) {
    fileNames := []
    loop files path "\*.txt" {
        fileNames.Push(A_LoopFileName)
    }
    return fileNames
}

ArrayItemExist(item, params*) {
    for index, param in params {
        if param == item {
            return true
        }
    }
    return false
}

Join(sep, params*) {
    if !params || params.Length == 0 {
        return ""
    }

    for index, param in params
        str .= param . sep
    return SubStr(str, 1, -StrLen(sep))
}

ON_EN_SETFOCUS(wParam, lParam, msg, hwnd)
{
    static EM_SETSEL := 0x00B1
    static EN_SETFOCUS := 0x0100
    critical
    if ((wParam >> 16) = EN_SETFOCUS) {
        DllCall("user32\HideCaret", "ptr", lParam)
        DllCall("user32\PostMessage", "ptr", lParam, "uint", EM_SETSEL, "ptr", -1, "ptr", 0)
    }
}

; sendinput
wc3Chat(Text) {
    SendInput("{Enter}")
    SendInput("{Text}" Text)
    SendInput("{Enter}")
}