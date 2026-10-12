#Requires AutoHotkey v2.0
#Include wc3rpgTool.ahk
#Include Helper.ahk
#Include RegisterHotkey.ahk

class ToolTab {
    tabName := "ToolTab"
    newHK := Map()
    slotControls := Map()

    __New(MainGui, Tab) {
        Tab.UseTab(2)

        ; --- 物品欄 6 格改鍵 GroupBox ---
        MainGui.AddGroupBox("Section w540 h370", "🎒 物品欄 6 格改鍵 (Inventory Remap - 支援點擊自訂)")

        ; 欄位設定陣列 [名稱, 顯示標題, 預設鍵, 原生魔獸按鍵, X, Y]
        slotConfigs := [
            { name: "inventoryHK1", title: "【欄位 1】左上格 (Numpad 7)", default: "1", target: "Numpad7", x: 45,  y: 45 },
            { name: "inventoryHK2", title: "【欄位 2】右上格 (Numpad 8)", default: "2", target: "Numpad8", x: 295, y: 45 },
            { name: "inventoryHK3", title: "【欄位 3】中左格 (Numpad 4)", default: "3", target: "Numpad4", x: 45,  y: 135 },
            { name: "inventoryHK4", title: "【欄位 4】中右格 (Numpad 5)", default: "4", target: "Numpad5", x: 295, y: 135 },
            { name: "inventoryHK5", title: "【欄位 5】左下格 (Numpad 1)", default: "5", target: "Numpad1", x: 45,  y: 225 },
            { name: "inventoryHK6", title: "【欄位 6】右下格 (Numpad 2)", default: "6", target: "Numpad2", x: 295, y: 225 }
        ]

        for cfg in slotConfigs {
            ; 標籤說明
            lbl := MainGui.AddText("x" cfg.x " y" cfg.y " w200 Center", cfg.title)
            lbl.SetFont("s9 w600 cGray")
            
            ; 醒目按鍵大方塊
            savedKey := IniRead(iniFileName, this.tabName, cfg.name, cfg.default)
            btnBox := MainGui.AddText("x" cfg.x " y" (cfg.y + 20) " w200 h55 Border Center 0x200 BackgroundWhite", ReadableHotkey(savedKey, true))
            btnBox.SetFont("s16 w700 cBlue")
            btnBox.Name := cfg.name

            ; 儲存控制項引用並綁定點擊事件
            this.slotControls.Set(cfg.name, { box: btnBox, cfg: cfg })
            btnBox.OnEvent("Click", (ctrl, *) => this.recordSlot(ctrl))
        }

        ; 快速範本按鈕
        btnPresetNum := MainGui.AddButton("x45 y320 w145 h36 -TabStop", "⚡ 一鍵設為 1 ~ 6 鍵")
        btnPresetNum.SetFont("s9 w600")
        btnPresetNum.OnEvent("Click", (*) => this.applyPreset(["1", "2", "3", "4", "5", "6"]))

        btnPresetZXC := MainGui.AddButton("x+25 w155 h36 -TabStop", "⚡ 一鍵設為 Z X C V 鍵")
        btnPresetZXC.SetFont("s9 w600")
        btnPresetZXC.OnEvent("Click", (*) => this.applyPreset(["z", "x", "c", "v", "", ""]))

        btnClearAll := MainGui.AddButton("x+25 w145 h36 -TabStop", "🗑️ 清空所有物品欄")
        btnClearAll.SetFont("s9")
        btnClearAll.OnEvent("Click", (*) => this.applyPreset(["", "", "", "", "", ""]))


        ; --- 滑鼠側鍵映射與功能開關 ---
        MainGui.AddGroupBox("xs ys y+20 Section w540 h155", "🖱️ 滑鼠側鍵映射與功能開關 (Mouse & Settings)")

        ; 滑鼠側鍵 1
        lblM1 := MainGui.AddText("xp+35 yp+25 w140 Center", "滑鼠側下鍵 (XButton1)")
        lblM1.SetFont("s9 w600 cGray")
        savedM1 := IniRead(iniFileName, this.tabName, "mouseHK1", "")
        mouseBox1 := MainGui.AddText("xp yp+20 w140 h48 Border Center 0x200 BackgroundWhite", ReadableHotkey(savedM1, true))
        mouseBox1.SetFont("s14 w700 cGreen")
        mouseBox1.Name := "mouseHK1"
        this.slotControls.Set("mouseHK1", { box: mouseBox1, cfg: { name: "mouseHK1", title: "滑鼠側下鍵 (XButton1)", default: "", target: "Left" } })
        mouseBox1.OnEvent("Click", (ctrl, *) => this.recordSlot(ctrl))

        ; 滑鼠側鍵 2
        lblM2 := MainGui.AddText("x+30 yp-20 w140 Center", "滑鼠側上鍵 (XButton2)")
        lblM2.SetFont("s9 w600 cGray")
        savedM2 := IniRead(iniFileName, this.tabName, "mouseHK2", "")
        mouseBox2 := MainGui.AddText("xp yp+20 w140 h48 Border Center 0x200 BackgroundWhite", ReadableHotkey(savedM2, true))
        mouseBox2.SetFont("s14 w700 cGreen")
        mouseBox2.Name := "mouseHK2"
        this.slotControls.Set("mouseHK2", { box: mouseBox2, cfg: { name: "mouseHK2", title: "滑鼠側上鍵 (XButton2)", default: "", target: "Right" } })
        mouseBox2.OnEvent("Click", (ctrl, *) => this.recordSlot(ctrl))

        ; 右側開關選項
        this.enableInventoryChk := MainGui.AddCheckbox("x+35 yp+5 -TabStop", "啟用物品欄改鍵")
        this.enableInventoryChk.SetFont("s10 w600")
        this.enableInventoryChk.Value := IniRead(iniFileName, this.tabName, "enableRemapInventory", 1)
        this.enableInventoryChk.OnEvent("Click", (chk, *) => (IniWrite(chk.Value, iniFileName, this.tabName, "enableRemapInventory"), this.registerAll()))

        this.enableMouseChk := MainGui.AddCheckbox("xp y+20 -TabStop", "啟用滑鼠側鍵改鍵")
        this.enableMouseChk.SetFont("s10 w600")
        this.enableMouseChk.Value := IniRead(iniFileName, this.tabName, "enableRemapMouse", 1)
        this.enableMouseChk.OnEvent("Click", (chk, *) => (IniWrite(chk.Value, iniFileName, this.tabName, "enableRemapMouse"), this.registerAll()))

        ; 註冊全部熱鍵
        this.registerAll()
    }

    ; 套用預設組合
    applyPreset(keyList) {
        for i, keyVal in keyList {
            slotKeyName := "inventoryHK" i
            IniWrite(keyVal, iniFileName, this.tabName, slotKeyName)
            if this.slotControls.Has(slotKeyName) {
                ctrlData := this.slotControls.Get(slotKeyName)
                ctrlData.box.Text := ReadableHotkey(keyVal, true)
            }
        }
        this.registerAll()
        ToolTip("✅ 已套用物品欄快捷鍵組合！")
        SetTimer(() => ToolTip(), -2500)
    }

    ; 點擊方塊跳出按鍵錄製對話框
    recordSlot(boxControl, slotTitle := "", targetKey := "") {
        if this.slotControls.Has(boxControl.Name) {
            slotData := this.slotControls.Get(boxControl.Name)
            slotTitle := slotData.cfg.title
            targetKey := slotData.cfg.target
        }
        savedKey := IniRead(iniFileName, this.tabName, boxControl.Name, "")
        
        modalGui := Gui("+AlwaysOnTop +Owner" MainGui.Hwnd, "設定改鍵 - " slotTitle)
        modalGui.SetFont("s10")
        modalHwnd := modalGui.Hwnd
        isFinished := false
        capturedKey := savedKey

        modalGui.AddText("w380 Center", "請直接在鍵盤上按下欲設定的按鍵：`n(對應遊戲內按鍵: " targetKey ")")

        displayBox := modalGui.AddText("w380 h60 0x200 Center Border BackgroundWhite", ReadableHotkey(savedKey, true))
        displayBox.SetFont("s18 w700 cBlue")

        statusText := modalGui.AddText("w380 Center cGray", "正在監聽鍵盤輸入... (按 Enter 套用 / 按 Esc 取消)")

        recHook := InputHook("L0 I1", "{All}")
        recHook.KeyOpt("{All}", "E")
        recHook.KeyOpt("{LCtrl}{RCtrl}{LAlt}{RAlt}{LShift}{RShift}{LWin}{RWin}", "-E")

        onSysCommand(wParam, lParam, msg, hwnd) {
            if ((wParam & 0xFFF0) == 0xF100 && hwnd == modalHwnd)
                return 0
        }
        OnMessage(0x0112, onSysCommand)

        btnApply := modalGui.AddButton("x30 y+18 w100 h36 Default", "確定套用")
        btnApply.SetFont("s10 w600")
        btnClear := modalGui.AddButton("x+15 w100 h36", "清空此鍵")
        btnCancel := modalGui.AddButton("x+15 w100 h36", "取消")

        cleanupAndClose() {
            if isFinished
                return
            isFinished := true
            OnMessage(0x0112, onSysCommand, 0)
            try recHook.Stop()
            try modalGui.Destroy()
        }

        applyChange(*) {
            if isFinished
                return
            isFinished := true
            OnMessage(0x0112, onSysCommand, 0)
            try recHook.Stop()
            IniWrite(capturedKey, iniFileName, this.tabName, boxControl.Name)
            boxControl.Text := ReadableHotkey(capturedKey, true)
            this.registerAll()
            ToolTip("✅ 【" slotTitle "】已設定為: " capturedKey)
            SetTimer(() => ToolTip(), -2500)
            try modalGui.Destroy()
        }

        clearKey(*) {
            if isFinished
                return
            isFinished := true
            OnMessage(0x0112, onSysCommand, 0)
            try recHook.Stop()
            IniWrite("", iniFileName, this.tabName, boxControl.Name)
            boxControl.Text := ""
            this.registerAll()
            ToolTip("🗑️ 已清空【" slotTitle "】")
            SetTimer(() => ToolTip(), -2500)
            try modalGui.Destroy()
        }

        cancelChange(*) {
            cleanupAndClose()
        }

        btnApply.OnEvent("Click", applyChange)
        btnClear.OnEvent("Click", clearKey)
        btnCancel.OnEvent("Click", cancelChange)
        modalGui.OnEvent("Close", cancelChange)
        modalGui.OnEvent("Escape", cancelChange)

        recHook.OnEnd := (ihObj) => onKeyRecorded(ihObj)

        onKeyRecorded(ihObj) {
            if (isFinished || ihObj.EndReason != "EndKey")
                return
            if !WinExist(modalHwnd)
                return

            endKey := ihObj.EndKey
            if (endKey == "")
                return

            if (endKey == "Escape") {
                cancelChange()
                return
            }

            if (endKey == "Enter" || endKey == "NumpadEnter") {
                applyChange()
                return
            }

            mods := ""
            if GetKeyState("Ctrl", "P") || InStr(ihObj.EndMods, "^")
                mods .= "^"
            if GetKeyState("Alt", "P") || InStr(ihObj.EndMods, "!")
                mods .= "!"
            if GetKeyState("Shift", "P") || InStr(ihObj.EndMods, "+")
                mods .= "+"
            if GetKeyState("LWin", "P") || GetKeyState("RWin", "P") || InStr(ihObj.EndMods, "#")
                mods .= "#"

            capturedKey := mods . endKey
            readableText := ReadableHotkey(capturedKey, true)
            
            try {
                if WinExist(modalHwnd) {
                    displayBox.Text := readableText
                    statusText.Text := "已偵測到: " readableText " (按 Enter 儲存，或按其他鍵更換)"
                }
            }

            if (!isFinished && WinExist(modalHwnd)) {
                try recHook.Start()
            }
        }

        modalGui.Show("w400 h225")
        recHook.Start()
    }

    ; 註冊所有熱鍵
    registerAll() {
        ; 先關閉舊的熱鍵
        for ctrl, hkObj in this.newHK {
            hkObj.enable := false
            hkObj.updateHotkey()
        }
        this.newHK.Clear()

        ; 物品欄映射 (Numpad 7, 8, 4, 5, 1, 2)
        invTargets := Map(
            "inventoryHK1", "Numpad7",
            "inventoryHK2", "Numpad8",
            "inventoryHK3", "Numpad4",
            "inventoryHK4", "Numpad5",
            "inventoryHK5", "Numpad1",
            "inventoryHK6", "Numpad2"
        )

        isInvEnabled := this.enableInventoryChk.Value
        for slotName, numpadKey in invTargets {
            hk := IniRead(iniFileName, this.tabName, slotName, "")
            if (hk != "") {
                targetFunc := remapInventoryKey.Bind(numpadKey)
                regHk := RegisterHotkey(hk, targetFunc, WarcraftIII, isInvEnabled)
                this.newHK.Set(slotName, regHk)
            }
        }

        ; 滑鼠側鍵映射
        isMouseEnabled := this.enableMouseChk.Value
        mouseTargets := Map(
            "mouseHK1", "Left",
            "mouseHK2", "Right"
        )
        for mouseName, mouseClickType in mouseTargets {
            hk := IniRead(iniFileName, this.tabName, mouseName, "")
            if (hk != "") {
                targetFunc := remapMouseKey.Bind(mouseClickType)
                regHk := RegisterHotkey(hk, targetFunc, WarcraftIII, isMouseEnabled)
                this.newHK.Set(mouseName, regHk)
            }
        }

        remapInventoryKey(targetNumpad) {
            SendEvent("{" targetNumpad " Down}")
            Sleep(25)
            SendEvent("{" targetNumpad " Up}")
        }

        remapMouseKey(clickType) {
            MouseClick(clickType)
        }
    }

    ; 當狀態切換 (開關輔助) 時更新熱鍵生效狀態
    updateHotkeys() {
        for slotName, hkObj in this.newHK {
            hkObj.updateHotkey()
        }
    }
}