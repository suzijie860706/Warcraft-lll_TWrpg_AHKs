#Requires AutoHotkey v2.0
#Include Helper.ahk

class MapTab {
    sortAsc := false

    __New(MainGui, Tab) {
        ; init tab
        Tab.UseTab(5)
        Tab.OnEvent("Change", onChangeTab)

        ; drag and drop map
        MainGUI.OnEvent("DropFiles", dropMap)

        ; info
        MainGui.AddGroupBox("Section w550", "說明 (Info)")
        MainGui.AddText("xp+20 yp+25", "可將新地圖 (.w3x) 拖曳至此處自動匯入")

        ; settings
        MainGui.AddGroupBox("Section xs ys y+30 w550 h80", "地圖目錄設定 (Settings)")
        MainGui.AddText("xp+20 yp+25", "地圖資料夾路徑:")
        mapFolder := MainGui.AddEdit("w350 ReadOnly -TabStop", "")
        MainGui.AddButton("x+20 w60 -TabStop", "瀏覽...").OnEvent("Click", selectMapFolder)
        MainGui.AddButton("x+20 w60 -TabStop", "開啟目錄").OnEvent("Click", openMapFolder)
        
        ; maps
        MainGui.AddGroupBox("Section xs ys y+30 w550 h370", "地圖清單 (Maps)")
        MainGui.AddText("xp+20 yp+20", "地圖名稱過濾:")
        filter := MainGui.AddEdit("w350", "twrpg")
        filter.OnEvent("Change", onChangeMapFilter)
        mapList := MainGui.AddListView("yp+30 w510 h280 SortDesc -TabStop", ["地圖名稱", "建立日期", "Hidden Date", "大小 (MB)"])
        mapList.OnEvent("ColClick", onClickCol)

        ; init variables
        mapFolder.Text := IniRead(iniFileName, "MapTab", "mapFolder", A_MyDocuments "\Warcraft III\Maps\Download")
        filter.Text := IniRead(iniFileName, "MapTab", "filter", "twrpg")
        updateMapList(filter.text)

        ; fix admin drop files
        WM_COPYDATA := 0x4A
        WM_COPYGLOBALDATA := 0x0049
        WM_DROPFILES := 0x233
        MSGFLT_ALLOW := 1
        DllCall("ChangeWindowMessageFilterEx", "Ptr", MainGui.Hwnd, "UInt", WM_COPYDATA, "UInt", MSGFLT_ALLOW, "Ptr", 0)
        DllCall("ChangeWindowMessageFilterEx", "Ptr", MainGui.Hwnd, "UInt", WM_COPYGLOBALDATA, "UInt", MSGFLT_ALLOW, "Ptr", 0)
        DllCall("ChangeWindowMessageFilterEx", "Ptr", MainGui.Hwnd, "UInt", WM_DROPFILES, "UInt", MSGFLT_ALLOW, "Ptr", 0)

        ; events
        onChangeTab(Tab, Info) {
            if Tab.Value == 5 {
                filter.Focus()
            }
        }

        selectMapFolder(Button, Info) {
            Folder := SelectFolder()
            if Folder != "" {
                mapFolder.Text := Folder
                updateMapList(filter.text)
                IniWrite(Folder, iniFileName, "MapTab", "mapFolder")
            }
        }

        openMapFolder(Button, Info) {
            Run(mapFolder.Text)
        }

        onChangeMapFilter(Button, Info) {
            updateMapList(Button.Text)
            IniWrite(Button.Text, iniFileName, "MapTab", "filter")
        }

        updateMapList(filter) {
            if (filter == "") {
                return
            }

            mapList.Delete()

            Loop Files, mapFolder.Text "\*.w3x" {
                if (InStr(A_LoopFileName, filter)) {
                    mapList.Add(, A_LoopFileName, FormatTime(A_LoopFileTimeCreated, "MM/dd/yyyy hh:mm tt"), A_LoopFileTimeCreated, Format("{:.2f}", A_LoopFileSizeKB / 1024))
                }
            }

            mapList.ModifyCol
            mapList.ModifyCol(3, 0)
            mapList.ModifyCol(4, 80)
        }

        onClickCol(ListView, Info) {
            if (Info == 2) {
                ListView.ModifyCol(3, this.sortAsc ? "Sort" : "SortDesc")
                this.sortAsc := !this.sortAsc
            }
        }

        dropMap(GuiObj, GuiCtrlObj, FileArray, X, Y) {
            fileNames := []
            for file in FileArray {
                if InStr(file, ".w3x") {
                    split := StrSplit(file, "\")
                    fileName := split.Pop()
                    targetFile := mapFolder.Text "\" fileName
                    if (file != targetFile) {
                        try FileCopy(file, mapFolder.Text "\", 1)
                    }
                    fileNames.Push(StrReplace(fileName, ".w3x", ""))
                }
            }
            if (fileNames.Length > 0) {
                updateMapList(filter.text)
                MsgBox("已加入地圖：`n" Join("`n", fileNames*))
            }
        }
    }
}