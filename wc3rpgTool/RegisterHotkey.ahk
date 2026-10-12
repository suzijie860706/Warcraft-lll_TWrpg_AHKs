#Requires AutoHotkey v2.0
#Include wc3rpgTool.ahk
#Include Helper.ahk

; 全域判斷：目標視窗處於焦點、輔助總開關已啟用、且「非聊天打字中」
CanRemapActive(win) {
    global toolEnabled, chatting
    return WinActive(win) && toolEnabled && !chatting
}

class RegisterHotkey {
    key := ""
    function := ""
    targetWindow := ""
    enable := false

    __New(key := "", function := "", targetWindow := "", enable := false) {
        this.key := "*" . key
        this.function := function
        this.targetWindow := targetWindow
        this.enable := enable

        if key {
            this.updateHotkey()
        }
    }

    updateHotkey() {
        if !this.key {
            return
        }

        HotIf((*) => CanRemapActive(this.targetWindow))
        if !this.enable {
            try {
                Hotkey(this.key, "Off")
            }
        } else {
            try {
                Hotkey(this.key, (*) => this.function.Call(), "On")
            }
        }
        HotIf()
    }
}