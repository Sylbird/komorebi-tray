#Include GuiEnhancerKit.ahk

class Popup {
    ; Fade-in animation flag.
    static AW_FADE_IN := 0x00080000
    ; Fade-out animation flag.
    static AW_FADE_OUT := 0x00090000

    ; Default style settings
    static DEFAULT_FONT_SIZE := "11"
    static DEFAULT_FONT_NAME := "Segoe UI"
    static DEFAULT_FONT_COLOR := "white"
    static DEFAULT_BG_COLOR := "0x000000"
    static DEFAULT_TIMER := 1500

    ; Current message to show.
    static message := ""
    ; Current popup Gui instance.
    static Gui := GuiExt()
    ; Popup message ID.
    static ID := 0
    ; Animation time to be shown (in ms).
    static animationTime := 10
    ; Text control handle
    static textCtrl := 0
    ; Timer callback reference
    static timerFunc := 0

    ; Create and show a popup message on-screen.
    static new(
        message,
        timer := this.DEFAULT_TIMER,
        fontSize := this.DEFAULT_FONT_SIZE,
        fontColor := this.DEFAULT_FONT_COLOR,
        bgColor := this.DEFAULT_BG_COLOR
    ) {
        this.message := message
        this.fontSize := fontSize
        this.fontColor := fontColor
        this.bgColor := bgColor

        ; Cancel any existing timer
        if (this.timerFunc) {
            SetTimer(this.timerFunc, 0)
        }
        ; If the GUI is already shown, update its text and resize it
        if (this.Gui.Hwnd && WinExist("ahk_id " this.Gui.Hwnd)) {
            WinSetTransparent(255, "ahk_id " this.Gui.Hwnd)
            ; Update text, resize GUI, and show it
            this.SetTextAndResize(this.textCtrl, message)
            ; Set a timer to hide the GUI after the specified duration
            this.timerFunc := ObjBindMethod(this, "FadeOut")
            SetTimer(this.timerFunc, -timer)
            return
        }
        ; Set Rounded Corner for Windows 11
        if (VerCompare(A_OSVersion, "10.0.22000") >= 0) {
            this.Gui.SetWindowAttribute(33, 2)
        }
        ; Set blur-behind accent effect. (Supported starting with Windows 11 Build 22000.)
        if (VerCompare(A_OSVersion, "10.0.22600") >= 0) {
            this.Gui.SetWindowAttribute(16, true)  ; required for DWMSBT_TRANSIENTWINDOW
            this.Gui.SetWindowAttribute(38, 3)
        }
        this.Gui.Opt("+Disabled -Caption +ToolWindow +LastFound +AlwaysOnTop -Border -SysMenu ")
        this.Gui.SetDarkTitle()
        this.Gui.BackColor := bgColor
        this.Gui.SetFont(Format("s{1} c{2}", fontSize, fontColor), this.DEFAULT_FONT_NAME)
        this.textCtrl := this.Gui.AddText(, message)
        this.Gui.Show("Center")
        this.ID := WinExist()
        ; Makes the window transparent
        this.Gui.SetBorderless(0)
        ; Set a timer to hide the GUI after the specified duration
        this.timerFunc := ObjBindMethod(this, "FadeOut")
        SetTimer(this.timerFunc, -timer)
    }

    static SetTextAndResize(textCtrl, text) {
        textCtrl.Value := ""
        textCtrl.Move(, , GetTextSize(textCtrl, text)*)
        textCtrl.Value := text
        textCtrl.Gui.Show('AutoSize Center NoActivate')

        GetTextSize(textCtrl, text) {
            static WM_GETFONT := 0x0031, DT_CALCRECT := 0x400
            hDC := DllCall('GetDC', 'Ptr', textCtrl.Hwnd, 'Ptr')
            hPrevObj := DllCall('SelectObject', 'Ptr', hDC, 'Ptr', SendMessage(WM_GETFONT, , , textCtrl), 'Ptr')
            height := DllCall('DrawText', 'Ptr', hDC, 'Str', text, 'Int', -1, 'Ptr', buf := Buffer(16), 'UInt',
            DT_CALCRECT)
            width := NumGet(buf, 8, 'Int') - NumGet(buf, 'Int')
            DllCall('SelectObject', 'Ptr', hDC, 'Ptr', hPrevObj, 'Ptr')
            DllCall('ReleaseDC', 'Ptr', textCtrl.Hwnd, 'Ptr', hDC)
            return [Round(width * 96 / A_ScreenDPI), Round(height * 96 / A_ScreenDPI)]
        }
    }

    ; Make the GUI transparent to simulate hiding
    static FadeOut() {
        if (this.Gui.Hwnd && WinExist("ahk_id " this.Gui.Hwnd)) {
            WinSetTransparent(0, "ahk_id " this.Gui.Hwnd)
        }
        ; Clear timer reference
        this.timerFunc := 0
    }
}
