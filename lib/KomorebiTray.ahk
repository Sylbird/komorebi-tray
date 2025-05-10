#Include Komorebi.ahk
#Include KomorebiEvents.ahk
#Include Popup.ahk

class KomorebiTray {
    ; Main tray menu object.
    static mainMenu := A_TrayMenu
    ; Komorebi menu instance.
    static komorebiMenu := Menu()
    ; Get the current pause status
    static menuPaused := false
    ; Get the current pause menu name
    static pauseName => this.menuPaused ? "Resume" : "Pause"
    ; Method to update app's current status
    static statusUpdater := ObjBindMethod(this, "updateStatus")

    ; Start tray listener
    static start() {
        SetTimer(this.statusUpdater, 10)
        ; Enable the pause menu
        this.mainMenu.Enable(this.pauseName)
        this.mainMenu.Default := this.pauseName
    }

    ; Stop komorebi and trigger a waiting state.
    static stop(*) {
        this.waiting()
        Komorebi.stop()
    }

    ; Put the tray into a waiting state.
    static waiting() {
        SetTimer(this.statusUpdater, 0)
        ; Disable the pause menu
        this.mainMenu.Disable(this.pauseName)
        this.mainMenu.Default := ""
        ; Tray icon in waiting mode
        TraySetIcon("images/ico/app.ico")
        A_IconTip := "Waiting for Komorebi..."
        Popup.new("Komorebi disconnected", 2000)
    }

    ; Restart komorebi.
    static restart(*) {
        Komorebi.stop()
        Komorebi.start()
    }

    ; Pause komorebi.
    static pause(*) {
        Komorebi.togglePause()
    }

    ; Reload the entire app.
    static reload(*) {
        KomorebiEvents.stop()
        Reload()
    }

    ; Exit the entire app.
    static exit(*) {
        KomorebiEvents.stop()
        ExitApp()
    }

    ; Generate the tray menu.
    static create() {
        this.mainMenu.Delete()
        this.mainMenu.Add("Komorebi", this.komorebiMenu)
        this.komorebiMenu.Add("Restart", ObjBindMethod(this, "restart"))
        this.komorebiMenu.Add("Stop", ObjBindMethod(this, "stop"))
        this.mainMenu.Add() ; separator
        this.mainMenu.Add("Pause", ObjBindMethod(this, "pause"))
        this.mainMenu.Add("Reload", ObjBindMethod(this, "reload"))
        this.mainMenu.Add("Exit", ObjBindMethod(this, "exit"))
        this.mainMenu.ClickCount := 1

        this.start()
    }

    ; Update status with current data available
    static updateStatus() {
        if (Komorebi.workspace != Komorebi.workspaceLast) {
            Komorebi.workspaceLast := Komorebi.workspace
            if (Komorebi.workspace <= Komorebi.workspaceMax) {
                TraySetIcon("images/ico/d-" Komorebi.workspace ".ico")
            } else {
                TraySetIcon("images/ico/app.ico")
            }
            A_IconTip := Komorebi.workspaceName " @ " Komorebi.displayName
            Popup.new(Komorebi.workspaceName)
        }
        if (Komorebi.isPaused and not this.menuPaused) {
            this.mainMenu.Rename(this.pauseName, "Resume")
            TraySetIcon("images/ico/pause.ico")
            this.menuPaused := true
        }
        if ( not Komorebi.isPaused and this.menuPaused) {
            this.mainMenu.Rename(this.pauseName, "Pause")
            TraySetIcon("images/ico/d-" Komorebi.workspace ".ico")
            this.menuPaused := false
        }
    }

}
