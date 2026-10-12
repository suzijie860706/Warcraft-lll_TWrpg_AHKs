#Requires AutoHotkey v2.0
#Include Helper.ahk
#Include wc3rpgTool.ahk

class HotkeyTab {
    tabName := "HotkeyTab"
    configPath := A_ScriptDir "\HotkeysConfig.ini"
    registeredHotkeys := Map()
    hotkeyListView := Gui.ListView

    __New(MainGui, Tab) {
        ; 綁定第 4 分頁（快捷鍵說明）
        Tab.UseTab(4)

        ; 上方說明 GroupBox
        MainGui.AddGroupBox("Section w550 h400", "快捷鍵列表 (雙擊兩下可直接修改 / Double Click to Edit)")
        
        ; ListView 展示所有快捷鍵對照，支援雙擊兩下直接修改
        this.hotkeyListView := MainGui.AddListView("xp+15 yp+25 w520 h355 -Multi ReadOnly -TabStop", ["快捷鍵 (Hotkey)", "功能名稱 (Function)", "功能詳細說明"])
        this.hotkeyListView.SetFont("s10")
        this.hotkeyListView.OnEvent("DoubleClick", (LV, RowNumber) => this.onDoubleClickRow(LV, RowNumber))
        
        ; 下方操作按鈕 GroupBox
        MainGui.AddGroupBox("xs ys y+15 Section w550 h100", "自訂設定 (Configuration / 설정)")

        openConfigBtn := MainGui.AddButton("xp+15 yp+25 w160 h45 -TabStop", "📝 開啟快捷鍵設定檔`n(記事本編輯)")
        openConfigBtn.SetFont("s10 w600")
        openConfigBtn.OnEvent("Click", (*) => this.openConfigFile())

        reloadConfigBtn := MainGui.AddButton("x+15 w160 h45 -TabStop", "🔄 重新載入設定`n(存檔後點此套用)")
        reloadConfigBtn.SetFont("s10 w600")
        reloadConfigBtn.OnEvent("Click", (*) => this.reloadConfig())

        resetConfigBtn := MainGui.AddButton("x+15 w160 h45 -TabStop", "↩️ 恢復預設值`n(Reset Default)")
        resetConfigBtn.SetFont("s10")
        resetConfigBtn.OnEvent("Click", (*) => this.resetToDefault())

        ; 初始化設定與註冊熱鍵
        this.ensureConfigFile()
        this.loadAndRegisterHotkeys()
    }

    ; 確保設定檔存在，若不存在則建立帶有三語註解的初始檔
    ensureConfigFile() {
        if !FileExist(this.configPath) {
            defaultContent := "
(
; ==============================================================================
;           魔獸爭霸 3 RPG 輔助工具 - 全域快捷鍵自訂設定檔
;           Warcraft III RPG Tool - Global Hotkeys Configuration
;           워크래프트 3 RPG 도구 - 전역 단축키 설정 파일
;
; 說明 (Instructions / 안내):
; 1. 修改按鍵後請存檔 (Ctrl + S)。
;    Save the file after editing (Ctrl + S).
;    수정 후 파일을 저장하세요 (Ctrl + S).
; 2. 在工具介面點擊「重新載入設定」按鈕即可立即生效，無需重啟程式！
;    Click 'Reload Config' in the tool to apply changes immediately!
;    프로그램에서 '설정 다시 불러오기' 버튼을 누르면 즉시 적용됩니다!
; ==============================================================================
;
; ------------------------------------------------------------------------------
; 【組合鍵撰寫語法教學 / Key Combinations Syntax Guide / 조합키 작성법 안내】
; 若您想使用「組合鍵」（例如 Ctrl + 某鍵、Alt + 某鍵），請在按鍵前加上對應符號：
; If you want to use key combinations, prefix the key with these modifier symbols:
; 조합키(Ctrl, Alt 등)를 사용하려면 키 앞에 아래 기호를 붙여주세요:
;
;   符號 (Symbol) | 按鍵 (Modifier) | 組合範例 (Example)       | 說明 (Explanation)
;   -------------+---------------+------------------------+---------------------
;        ^       |     Ctrl      |  ^F2                   | Ctrl + F2
;        !       |     Alt       |  !F8                   | Alt + F8
;        +       |     Shift     |  +F7                   | Shift + F7
;        #       |     Win 鍵    |  #F1                   | Win + F1
;
; 多鍵組合範例 (Multiple Modifiers / 다중 조합키):
;   ^!F2   ➔  Ctrl + Alt + F2
;   ^+F8   ➔  Ctrl + Shift + F8
;   !F2    ➔  Alt + F2
; ------------------------------------------------------------------------------

[Hotkeys]

; ------------------------------------------------------------------------------
; 【功能 1】在魔獸中 開啟 / 關閉 輔助改鍵工具
; [Function 1] Toggle Tool On / Off in Warcraft III
; [기능 1] 워크래프트 3 내에서 도구 켜기 / 끄기
;
; 說明: 在遊戲內切換改鍵是否啟用。畫面左上角會顯示「輔助: 已啟用 / 已暫停」。
; Desc: Toggles key remapping inside the game. Overlay shows status.
; 설명: 게임 내에서 키 매핑 도구를 활성화/비활성화합니다.
;
; 預設值 (Default / 기본값): F2 (程式底層同時內建支援 F10 / Also supports F10)
; 修改範例 (Examples / 예시): F2, F1, F3, F4, `
; ------------------------------------------------------------------------------
ToggleTool = F2


; ------------------------------------------------------------------------------
; 【功能 2】顯示 / 隱藏 本工具主視窗
; [Function 2] Show / Hide Main Tool Window
; [기능 2] 메인 프로그램 창 표시 / 숨기기
;
; 說明: 按下此鍵可在任何時候快速呼叫出本工具的設定面板，或將其縮小隱藏。
; Desc: Press this key anytime to show or hide the main tool GUI.
; 설명: 언제든지 이 키를 눌러 메인 설정 창을 표시하거나 숨깁니다.
;
; 預設值 (Default / 기본값): F8
; 修改範例 (Examples / 예시): F8, F9, F11, Insert
; ------------------------------------------------------------------------------
ShowHideMainWindow = F8


; ------------------------------------------------------------------------------
; 【功能 3】顯示 / 隱藏 螢幕左上角狀態浮動窗 (Overlay)
; [Function 3] Show / Hide Status Overlay
; [기능 3] 화면 좌측 상단 상태 오버레이 표시 / 숨기기
;
; 說明: 切換遊戲畫面左上角「輔助: 已啟用」文字的顯示或隱藏。
; Desc: Toggles visibility of the 'Tool: Enabled/Disabled' text overlay.
; 설명: 좌측 상단의 상태 표시 오버레이 창을 표시하거나 숨깁니다.
;
; 預設值 (Default / 기본값): F7
; 修改範例 (Examples / 예시): F7, F6, Home
; ------------------------------------------------------------------------------
ShowHideOverlay = F7


; ------------------------------------------------------------------------------
; 【功能 4】在魔獸中暫停遊戲 (單人/單機有效)
; [Function 4] Pause Game in Warcraft III (Singleplayer)
; [기능 4] 게임 일시정지 (싱글 플레이)
;
; 說明: 在魔獸中自動送出暫停遊戲指令。
; Desc: Sends pause game command sequence in Warcraft III.
; 설명: 게임 일시정지 명령을 전송합니다.
;
; 預設值 (Default / 기본값): Pause
; 修改範例 (Examples / 예시): Pause, ScrollLock
; ------------------------------------------------------------------------------
PauseGame = Pause
)"
            FileAppend(defaultContent, this.configPath, "UTF-8")
        }
    }

    ; 讀取設定檔並註冊所有熱鍵
    loadAndRegisterHotkeys() {
        ; 清除舊有已註冊的動態熱鍵
        for keyStr, hkObj in this.registeredHotkeys {
            try Hotkey(keyStr, "Off")
        }
        this.registeredHotkeys.Clear()

        ; 從 HotkeysConfig.ini 讀取設定值
        hkToggleTool := IniRead(this.configPath, "Hotkeys", "ToggleTool", "F2")
        hkShowMain   := IniRead(this.configPath, "Hotkeys", "ShowHideMainWindow", "F8")
        hkPauseGame  := IniRead(this.configPath, "Hotkeys", "PauseGame", "Pause")

        ; 註冊熱鍵 1：開啟/關閉輔助 (在魔獸中 與 本工具主視窗中 生效)
        if (hkToggleTool != "") {
            this.safeRegisterHotkey(hkToggleTool, toggleTool, WarcraftIII)
            try this.safeRegisterHotkey(hkToggleTool, toggleTool, "ahk_id " MainGui.Hwnd)
        }

        ; 註冊熱鍵 2：顯示/隱藏主視窗 (全域生效)
        if (hkShowMain != "") {
            this.safeRegisterHotkey(hkShowMain, showHideMainGui)
        }

        ; 註冊熱鍵 3：暫停遊戲 (在魔獸中生效)
        if (hkPauseGame != "") {
            this.safeRegisterHotkey(hkPauseGame, pauseGame, WarcraftIII)
        }

        ; 更新 ListView 介面列表顯示
        this.refreshListView(hkToggleTool, hkShowMain, hkPauseGame)
        try updateAppStatus()
    }

    ; 安全註冊熱鍵函式
    safeRegisterHotkey(keyStr, callback, targetWin := "") {
        keyNorm := "$" . Trim(keyStr, "$ ")
        try {
            if (targetWin != "") {
                HotIfWinactive(targetWin)
            } else {
                HotIfWinactive()
            }
            Hotkey(keyNorm, (*) => callback(), "On")
            this.registeredHotkeys.Set(keyNorm, true)
            HotIfWinactive()
        } catch Error as e {
            ; 忽略註冊無效鍵之例外
        }
    }

    ; 重新整理 ListView 列表內容
    refreshListView(hkToggleTool, hkShowMain, hkPauseGame) {
        this.hotkeyListView.Delete()
        
        this.hotkeyListView.Add(, hkToggleTool, "切換輔助開關", "單鍵切換：在魔獸中開啟 / 關閉 輔助工具")
        this.hotkeyListView.Add(, hkShowMain, "顯示/隱藏主視窗", "在遊戲中隨時呼叫或隱藏本工具設定視窗")
        this.hotkeyListView.Add(, hkPauseGame, "在魔獸中暫停遊戲", "自動發送暫停指令")
        
        this.hotkeyListView.ModifyCol(1, 130)
        this.hotkeyListView.ModifyCol(2, 140)
        this.hotkeyListView.ModifyCol(3, 245)
    }

    ; 點擊「開啟快捷鍵設定檔」按鈕
    openConfigFile() {
        this.ensureConfigFile()
        Run('notepad.exe "' this.configPath '"')
    }

    ; 點擊「重新載入設定」按鈕
    reloadConfig() {
        this.ensureConfigFile()
        this.loadAndRegisterHotkeys()
        ToolTip("✅ 已成功重新載入快捷鍵設定！`nHotkeys configuration reloaded successfully!")
        SetTimer(() => ToolTip(), -3000)
    }

    ; 點擊「恢復預設值」按鈕
    resetToDefault() {
        result := MsgBox("確定要將所有快捷鍵恢復為原廠預設值嗎？`nAre you sure you want to reset all hotkeys to default?", "恢復預設值", "YesNo Icon? Owner" MainGui.Hwnd)
        if (result == "Yes") {
            try FileDelete(this.configPath)
            this.ensureConfigFile()
            this.loadAndRegisterHotkeys()
            ToolTip("↩️ 已成功恢復為預設快捷鍵設定！`nReset to default hotkeys successfully!")
            SetTimer(() => ToolTip(), -3000)
        }
    }

    ; 雙擊兩下該列進行快捷鍵自動錄製
    onDoubleClickRow(LV, RowNumber) {
        if (RowNumber <= 0) {
            return
        }

        ; 依據該列第 2 欄的功能名稱動態判定（不受使用者點擊欄位標題排序影響）
        funcName := LV.GetText(RowNumber, 2)
        switch funcName {
            case "切換輔助開關", "開關輔助改鍵":
                keyName := "ToggleTool"
                funcName := "切換輔助開關"
                defaultKey := IniRead(this.configPath, "Hotkeys", keyName, "F2")
            case "顯示/隱藏主視窗":
                keyName := "ShowHideMainWindow"
                defaultKey := IniRead(this.configPath, "Hotkeys", keyName, "F8")
            case "在魔獸中暫停遊戲":
                keyName := "PauseGame"
                defaultKey := IniRead(this.configPath, "Hotkeys", keyName, "Pause")
            default:
                ToolTip("⚠️ 此項目為系統內建固定快捷鍵，無法修改`n(This is a built-in fixed shortcut)")
                SetTimer(() => ToolTip(), -2500)
                return
        }

        ; 建立專屬快捷鍵錄製彈窗
        modalGui := Gui("+AlwaysOnTop +Owner" MainGui.Hwnd, "錄製快捷鍵 - " funcName)
        modalGui.SetFont("s10")

        modalHwnd := modalGui.Hwnd
        isFinished := false
        capturedKey := defaultKey

        modalGui.AddText("w380 Center", "請直接在鍵盤上按下欲設定的按鍵或組合鍵：`n(支援單鍵如 F2、或組合鍵如 Ctrl+F2)")

        displayBox := modalGui.AddText("w380 h60 0x200 Center Border BackgroundWhite", ReadableHotkey(defaultKey, true))
        displayBox.SetFont("s18 w700 cGreen")

        statusText := modalGui.AddText("w380 Center cGray", "正在監聽鍵盤輸入... (按 Enter 套用 / 按 Esc 取消)")

        ; 啟動獨立的 InputHook 捕捉鍵盤輸入 (不帶 "V"，攔截按鍵不外流至視窗，防止 F10/Alt 觸發系統選單)
        recHook := InputHook("L0 I1", "{All}")
        recHook.KeyOpt("{All}", "E")
        recHook.KeyOpt("{LCtrl}{RCtrl}{LAlt}{RAlt}{LShift}{RShift}{LWin}{RWin}", "-E")

        ; 阻擋 Windows 系統將 F10 或 Alt 判定為選單列焦點 (SC_KEYMENU = 0xF100)
        onSysCommand(wParam, lParam, msg, hwnd) {
            if ((wParam & 0xFFF0) == 0xF100 && hwnd == modalHwnd)
                return 0
        }
        OnMessage(0x0112, onSysCommand)

        btnApply := modalGui.AddButton("x30 y+18 w100 h36 Default", "確定套用")
        btnApply.SetFont("s10 w600")
        btnClear := modalGui.AddButton("x+15 w100 h36", "清空停用")
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
            if (capturedKey != "") {
                IniWrite(capturedKey, this.configPath, "Hotkeys", keyName)
                this.loadAndRegisterHotkeys()
                ToolTip("✅ 【" funcName "】快捷鍵已更新為: " capturedKey)
                SetTimer(() => ToolTip(), -3000)
            }
            try modalGui.Destroy()
        }

        clearKey(*) {
            if isFinished
                return
            isFinished := true
            OnMessage(0x0112, onSysCommand, 0)
            try recHook.Stop()
            IniWrite("", this.configPath, "Hotkeys", keyName)
            this.loadAndRegisterHotkeys()
            ToolTip("🗑️ 已清空【" funcName "】快捷鍵")
            SetTimer(() => ToolTip(), -3000)
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
            ; 若已完成、非按鍵觸發、或視窗已被關閉，直接返回
            if (isFinished || ihObj.EndReason != "EndKey")
                return
            if !WinExist(modalHwnd)
                return

            endKey := ihObj.EndKey
            if (endKey == "")
                return

            ; 按 Esc 取消
            if (endKey == "Escape") {
                cancelChange()
                return
            }

            ; 按 Enter 確認套用
            if (endKey == "Enter" || endKey == "NumpadEnter") {
                applyChange()
                return
            }

            ; 組合修飾鍵符號
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
                    displayBox.SetFont("s18 w700 cBlue")
                    statusText.Text := "已偵測到: " readableText " (按 Enter 儲存，或按其他鍵更換)"
                }
            }

            ; 繼續監聽下一次按下，以便使用者隨時更換
            if (!isFinished && WinExist(modalHwnd)) {
                try recHook.Start()
            }
        }

        modalGui.Show("w400 h225")
        recHook.Start()
    }
}