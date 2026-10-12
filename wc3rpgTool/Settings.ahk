#Requires AutoHotkey v2.0
#Include wc3rpgTool.ahk

class Settings {
    tabName := "SettingsTab"
    checkboxes := [Gui.CheckBox]

    __New(MainGui, Tab) {
        ; 綁定第 5 分頁（設定）
        Tab.UseTab(5)

        ; GroupBox 常用功能開關
        MainGui.AddGroupBox("Section w550 h240", "功能偏好設定 (Preferences)")

        enableToolonStartCheckbox := MainGui.AddCheckbox("xp+20 yp+28 Section venableToolonStartCheckbox -TabStop", "軟體啟動時自動啟用改鍵輔助")
        enableToolAfterLoadCheckbox := MainGui.AddCheckbox("xs y+18 venableToolAfterLoad -TabStop", "存檔讀取成功後自動啟用改鍵輔助")
        summonBagAfterLoadCheckbox := MainGui.AddCheckbox("xs y+18 vsummonBagAfterLoad -TabStop", "存檔讀取成功後自動召喚背包 (發送 Esc)")
        autoToggleToolCheckbox := MainGui.AddCheckbox("xs y+18 vautoToggleToolCheckbox -TabStop", "打字聊天時自動暫停改鍵 (Enter/左鍵/Esc 自動偵測，避免聊天衝突)")
        hideMainCheckbox := MainGui.AddCheckbox("xs y+18 vhideMainCheckbox -TabStop", "軟體啟動時直接最小化/隱藏主視窗 (可按 F8 呼叫)")

        ; GroupBox 系統進階設定
        MainGui.AddGroupBox("xs ys y+30 Section w550 h160", "系統進階設定 (Advanced)")

        MainGui.AddText("xp+20 yp+30", "按鍵間隔延遲時間 (ms): ")
        keyDelayTextbox := MainGui.AddEdit("x+10 yp-3 Number Limit3 -WantReturn vkeyDelay -TabStop w60", "10")
        applyButton := MainGui.AddButton("x+15 w100 h28 -TabStop", "套用延遲")
        applyButton.SetFont("s9 w600")
        applyButton.OnEvent("Click", onClickApply)

        resetButton := MainGui.AddButton("xs+20 y+25 w150 h36 -TabStop", "↩️ 重設所有設定")
        resetButton.SetFont("s9")
        resetButton.OnEvent("Click", onClickReset)
        MainGui.AddText("x+15 yp+10 cGray", "清除 wc3rpgToolData.ini 並恢復所有預設值")

        this.checkboxes := [
            enableToolonStartCheckbox,
            enableToolAfterLoadCheckbox,
            summonBagAfterLoadCheckbox,
            hideMainCheckbox,
            autoToggleToolCheckbox
        ]

        for checkbox in this.checkboxes {
            checkbox.OnEvent("Click", onClickCheckbox)
            checkbox.Value := IniRead(iniFileName, this.tabName, checkbox.Name, (checkbox.Name == "autoToggleToolCheckbox" ? true : false))
        }

        keyDelayTextbox.text := IniRead(iniFileName, "SettingsTab", "keyDelay", 10)

        onClickReset(Button, Info) {
            result := MsgBox("確定要清除所有設定並恢復預設值嗎？", "重設設定", "YesNo Icon? Owner" MainGui.Hwnd)
            if (result == "Yes") {
                try FileDelete(A_ScriptDir "\" iniFileName)
                Reload
            }
        }

        onClickApply(Button, Info) {
            delay := keyDelayTextbox.text
            if IsInteger(delay) {
                SetKeyDelay(Integer(delay))
                IniWrite(Integer(delay), iniFileName, this.tabName, "keyDelay")
                ToolTip("✅ 已套用按鍵延遲時間: " delay " ms")
                SetTimer () => ToolTip(), -2500
            } else {
                ToolTip("⚠️ 延遲時間必須為整數數字")
                SetTimer () => ToolTip(), -2500
            }
        }

        onClickCheckbox(Button, Info) {
            IniWrite(Button.Value, iniFileName, this.tabName, Button.Name)
        }
    }
}