#Requires AutoHotkey v2.0
#Include wc3rpgTool.ahk
#Include Helper.ahk

class Overlay {
    overlayGui := Gui
    textGui := Gui.Text

    __New() {
        this.overlayGui := Gui("AlwaysOnTop -SysMenu Owner LastFound -Caption")
        this.textGui := this.overlayGui.AddText("w120 h80", "輔助: " (toolEnabled ? "已啟用" : "已暫停"))
        this.textGui.SetFont("s12 cRed")
        this.overlayGui.BackColor := "EEAA99"
        WinSetTransColor("EEAA99", this.overlayGui.Hwnd)

        ; 預設完全隱藏螢幕懸浮文字（如需開啟可在設定分頁啟用）
        if IniRead(iniFileName, "SettingsTab", "showOverlayCheckbox", false) {
            this.overlayGui.Show("x0 y0")
            global showOverlay := true
        } else {
            this.overlayGui.Hide()
            global showOverlay := false
        }
    }

    updateText() {
        if (showOverlay) {
            this.textGui.Text := "輔助: " (toolEnabled ? "已啟用" : "已暫停")
        }
    }
}