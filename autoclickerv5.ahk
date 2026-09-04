#Requires AutoHotkey v2.0
#SingleInstance Force

; ============================================================
; AUTOCLICKER - d1m0nr
; AutoHotkey v2
; ============================================================

global APP_NAME := "Autoclicker - d1m0nr"
global AppLanguage := "EN"

; ============================================================
; CONFIGURACION
; ============================================================

global LOCAL_APPDATA := EnvGet("LOCALAPPDATA")
global CONFIG_DIR := LOCAL_APPDATA . "\Scripts.d1m0nr"
global CONFIG_FILE := CONFIG_DIR . "\autoclicker.ini"

; ============================================================
; ESTADO
; ============================================================

global IsRunning := false
global IsStarting := false
global IsClosing := false

global TotalClicks := 0
global RealCPS := 0.0
global RecentClicks := []

global SessionStartQPC := 0
global TotalActiveSeconds := 0.0

; ============================================================
; OPCIONES
; ============================================================

global ActivationHotkey := "XButton1"
global RegisteredHotkey := ""
global ActivationMode := "Toggle"

global ClickButton := "LButton"

global SpeedMode := "CPS"
global SpeedValue := 10.0

global RandomEnabled := false
global RandomCPSMin := 5.0
global RandomCPSMax := 15.0
global RandomTimeMin := 3.0
global RandomTimeMax := 7.0

global ClickLimitEnabled := false
global ClickLimit := 10000

global TimeLimitEnabled := false
global TimeLimit := 60.0

global StartDelay := 0.0

global CurrentProfile := "Default"

; ============================================================
; HIGH PRECISION TIMER
; ============================================================

global QPCFrequency := 0
global CurrentCPS := 10.0
global NextClickQPC := 0
global CurrentSegmentEndQPC := 0

; Estado específico del modo "Segundo pulsado el click".
global HoldActive := false
global HoldEndQPC := 0

; ============================================================
; GUI
; ============================================================

global MainGui
global LanguageLabel
global LanguageDropDown

global TitleText
global SubtitleText
global StatusText
global StatusDescriptionText
global SpeedHeading
global SpeedDescription
global ActivationHeading
global ActivationDescription
global ClickHeading
global RandomDescription
global RandomSeparator1
global RandomSeparator2
global LimitsHeading
global StartHeading
global StartDescription
global StartUnitText
global StatsRealLabel
global StatsConfigLabel
global StatsTimeLabel
global SaveButton
global SaveAsButton
global ProfileLabel
global DeleteProfileButton

global StatusText
global ConfiguredCPSText
global RealCPSText
global TimeText


global StartButton
global ProfileDropDown

global RandomPrimaryLabel
global RandomTimeLabel

global SpeedModeDrop
global SpeedValueEdit

global ActivationTypeDrop
global ActivationKeyEdit
global ActivationModeDrop

global ClickButtonDrop

global RandomCheck
global RandomCPSMinEdit
global RandomCPSMaxEdit
global RandomTimeMinEdit
global RandomTimeMaxEdit

global ClickLimitCheck
global ClickLimitEdit

global TimeLimitCheck
global TimeLimitEdit

global StartDelayEdit


; ============================================================
; INICIO
; ============================================================

EnsureConfig()

DllCall(
    "QueryPerformanceFrequency",
    "Int64*",
    &QPCFrequency
)

DllCall(
    "Winmm\timeBeginPeriod",
    "UInt",
    1
)

LoadProfile("Default")

OnError(HandleScriptError)
OnExit(Cleanup)

BuildGUI()
RegisterActivationHotkey()

SetTimer(UpdateInterface, 100)
SetTimer(UpdateRealCPS, 100)


; ============================================================
; CONFIG
; ============================================================

EnsureConfig()
{
    global CONFIG_DIR
    global CONFIG_FILE

    if !DirExist(CONFIG_DIR)
        DirCreate(CONFIG_DIR)

    if FileExist(CONFIG_FILE)
        return

    section := "Profile_Default"

    IniWrite("XButton1", CONFIG_FILE, section, "ActivationHotkey")
    IniWrite("Toggle", CONFIG_FILE, section, "ActivationMode")
    IniWrite("LButton", CONFIG_FILE, section, "ClickButton")

    IniWrite("CPS", CONFIG_FILE, section, "SpeedMode")
    IniWrite("10", CONFIG_FILE, section, "SpeedValue")

    IniWrite("0", CONFIG_FILE, section, "RandomEnabled")
    IniWrite("5", CONFIG_FILE, section, "RandomCPSMin")
    IniWrite("15", CONFIG_FILE, section, "RandomCPSMax")
    IniWrite("3", CONFIG_FILE, section, "RandomTimeMin")
    IniWrite("7", CONFIG_FILE, section, "RandomTimeMax")

    IniWrite("0", CONFIG_FILE, section, "ClickLimitEnabled")
    IniWrite("10000", CONFIG_FILE, section, "ClickLimit")

    IniWrite("0", CONFIG_FILE, section, "TimeLimitEnabled")
    IniWrite("60", CONFIG_FILE, section, "TimeLimit")

    IniWrite("0", CONFIG_FILE, section, "StartDelay")
}


LoadProfile(profileName)
{
    global CONFIG_FILE
    global CurrentProfile

    global ActivationHotkey
    global ActivationMode
    global ClickButton

    global SpeedMode
    global SpeedValue

    global RandomEnabled
    global RandomCPSMin
    global RandomCPSMax
    global RandomTimeMin
    global RandomTimeMax

    global ClickLimitEnabled
    global ClickLimit

    global TimeLimitEnabled
    global TimeLimit

    global StartDelay

    section := "Profile_" . profileName

    ActivationHotkey := IniRead(
        CONFIG_FILE,
        section,
        "ActivationHotkey",
        "XButton1"
    )

    ActivationMode := IniRead(
        CONFIG_FILE,
        section,
        "ActivationMode",
        "Toggle"
    )

    ClickButton := IniRead(
        CONFIG_FILE,
        section,
        "ClickButton",
        "LButton"
    )

    SpeedMode := IniRead(
        CONFIG_FILE,
        section,
        "SpeedMode",
        "CPS"
    )

    SpeedValue := Number(
        IniRead(
            CONFIG_FILE,
            section,
            "SpeedValue",
            "10"
        )
    )

    RandomEnabled := Integer(
        IniRead(
            CONFIG_FILE,
            section,
            "RandomEnabled",
            "0"
        )
    ) = 1

    RandomCPSMin := Number(
        IniRead(
            CONFIG_FILE,
            section,
            "RandomCPSMin",
            "5"
        )
    )

    RandomCPSMax := Number(
        IniRead(
            CONFIG_FILE,
            section,
            "RandomCPSMax",
            "15"
        )
    )

    RandomTimeMin := Number(
        IniRead(
            CONFIG_FILE,
            section,
            "RandomTimeMin",
            "3"
        )
    )

    RandomTimeMax := Number(
        IniRead(
            CONFIG_FILE,
            section,
            "RandomTimeMax",
            "7"
        )
    )

    ClickLimitEnabled := Integer(
        IniRead(
            CONFIG_FILE,
            section,
            "ClickLimitEnabled",
            "0"
        )
    ) = 1

    ClickLimit := Integer(
        IniRead(
            CONFIG_FILE,
            section,
            "ClickLimit",
            "10000"
        )
    )

    TimeLimitEnabled := Integer(
        IniRead(
            CONFIG_FILE,
            section,
            "TimeLimitEnabled",
            "0"
        )
    ) = 1

    TimeLimit := Number(
        IniRead(
            CONFIG_FILE,
            section,
            "TimeLimit",
            "60"
        )
    )

    StartDelay := Number(
        IniRead(
            CONFIG_FILE,
            section,
            "StartDelay",
            "0"
        )
    )

    CurrentProfile := profileName
}


SaveCurrentProfile()
{
    global CONFIG_FILE
    global CurrentProfile

    global ActivationHotkey
    global ActivationMode
    global ClickButton

    global SpeedMode
    global SpeedValue

    global RandomEnabled
    global RandomCPSMin
    global RandomCPSMax
    global RandomTimeMin
    global RandomTimeMax

    global ClickLimitEnabled
    global ClickLimit

    global TimeLimitEnabled
    global TimeLimit

    global StartDelay

    section := "Profile_" . CurrentProfile

    IniWrite(
        ActivationHotkey,
        CONFIG_FILE,
        section,
        "ActivationHotkey"
    )

    IniWrite(
        ActivationMode,
        CONFIG_FILE,
        section,
        "ActivationMode"
    )

    IniWrite(
        ClickButton,
        CONFIG_FILE,
        section,
        "ClickButton"
    )

    IniWrite(
        SpeedMode,
        CONFIG_FILE,
        section,
        "SpeedMode"
    )

    IniWrite(
        SpeedValue,
        CONFIG_FILE,
        section,
        "SpeedValue"
    )

    IniWrite(
        RandomEnabled ? 1 : 0,
        CONFIG_FILE,
        section,
        "RandomEnabled"
    )

    IniWrite(
        RandomCPSMin,
        CONFIG_FILE,
        section,
        "RandomCPSMin"
    )

    IniWrite(
        RandomCPSMax,
        CONFIG_FILE,
        section,
        "RandomCPSMax"
    )

    IniWrite(
        RandomTimeMin,
        CONFIG_FILE,
        section,
        "RandomTimeMin"
    )

    IniWrite(
        RandomTimeMax,
        CONFIG_FILE,
        section,
        "RandomTimeMax"
    )

    IniWrite(
        ClickLimitEnabled ? 1 : 0,
        CONFIG_FILE,
        section,
        "ClickLimitEnabled"
    )

    IniWrite(
        ClickLimit,
        CONFIG_FILE,
        section,
        "ClickLimit"
    )

    IniWrite(
        TimeLimitEnabled ? 1 : 0,
        CONFIG_FILE,
        section,
        "TimeLimitEnabled"
    )

    IniWrite(
        TimeLimit,
        CONFIG_FILE,
        section,
        "TimeLimit"
    )

    IniWrite(
        StartDelay,
        CONFIG_FILE,
        section,
        "StartDelay"
    )
}


; ============================================================
; GUI
; ============================================================

BuildGUI()
{
    global

    MainGui := Gui(
        "+AlwaysOnTop -MaximizeBox",
        APP_NAME
    )

    MainGui.BackColor := "17191D"
    MainGui.MarginX := 22
    MainGui.MarginY := 16

    ; --------------------------------------------------------
    ; TITULO + IDIOMA
    ; --------------------------------------------------------

    MainGui.SetFont(
        "s18 Bold cFFFFFF",
        "Segoe UI"
    )

    TitleText := MainGui.AddText(
        "xm y12 w320 h34",
        "AUTOCLICKER"
    )

    MainGui.SetFont(
        "s8 c8B929E",
        "Segoe UI"
    )

    LanguageLabel := MainGui.AddText(
        "x350 y18 w35 h18",
        "Lang:"
    )

    LanguageDropDown := MainGui.Add(
        "DropDownList",
        "x+4 yp-2 w65 R2",
        ["EN", "ES"]
    )

    LanguageDropDown.Choose(1)
    LanguageDropDown.OnEvent(
        "Change",
        LanguageChanged
    )

    SubtitleText := MainGui.AddText(
        "xm y+1 w420",
        "d1m0nr - Precision Click Engine"
    )

    ; --------------------------------------------------------
    ; ESTADO
    ; --------------------------------------------------------

    StatusText := MainGui.AddText(
        "xm y+10 w420 h25 Center cFF5555",
        "●  DEACTIVATED"
    )

    MainGui.SetFont(
        "s8 c737983",
        "Segoe UI"
    )

    StatusDescriptionText := MainGui.AddText(
        "xm y+1 w420 Center",
        "The autoclicker is stopped"
    )

    ; --------------------------------------------------------
    ; VELOCIDAD
    ; --------------------------------------------------------

    MainGui.SetFont(
        "s10 Bold cFFFFFF",
        "Segoe UI"
    )

    SpeedHeading := MainGui.AddText(
        "xm y+10",
        "SPEED"
    )

    MainGui.SetFont(
        "s8 c8B929E",
        "Segoe UI"
    )

    SpeedDescription := MainGui.AddText(
        "xm y+2 w420",
        "Main autoclicker speed."
    )

    SpeedModeDrop := MainGui.Add(
        "DropDownList",
        "xm y+5 w205",
        [
            "Clicks per second",
            "Seconds per click",
            "Hold duration"
        ]
    )

    SpeedModeDrop.OnEvent(
        "Change",
        SpeedModeChanged
    )

    SpeedValueEdit := MainGui.Add(
        "Edit",
        "x+8 yp w207 h24 c000000 BackgroundFFFFFF Center",
        "10"
    )

    ; --------------------------------------------------------
    ; ACTIVACION
    ; --------------------------------------------------------

    MainGui.SetFont(
        "s10 Bold cFFFFFF",
        "Segoe UI"
    )

    ActivationHeading := MainGui.AddText(
        "xm y+10",
        "ACTIVATION"
    )

    MainGui.SetFont(
        "s8 c8B929E",
        "Segoe UI"
    )

    ActivationDescription := MainGui.AddText(
        "xm y+2 w420",
        "Independent key to start or stop."
    )

    ActivationTypeDrop := MainGui.Add(
        "DropDownList",
        "xm y+5 w205",
        [
            "Keyboard",
            "Mouse 4",
            "Mouse 5"
        ]
    )

    ActivationKeyEdit := MainGui.Add(
        "Edit",
        "x+8 yp w207 h24 c000000 BackgroundFFFFFF Center",
        "XButton1"
    )

    ActivationModeDrop := MainGui.Add(
        "DropDownList",
        "xm y+5 w420",
        [
            "Toggle",
            "Hold"
        ]
    )

    ; --------------------------------------------------------
    ; BOTON DE CLICK
    ; --------------------------------------------------------

    MainGui.SetFont(
        "s10 Bold cFFFFFF",
        "Segoe UI"
    )

    ClickHeading := MainGui.AddText(
        "xm y+10",
        "CLICK BUTTON"
    )

    ClickButtonDrop := MainGui.Add(
        "DropDownList",
        "xm y+5 w420",
        [
            "Left",
            "Right",
            "Middle",
            "Mouse 4",
            "Mouse 5"
        ]
    )

    ; --------------------------------------------------------
    ; RANDOM
    ; --------------------------------------------------------

    RandomCheck := MainGui.Add(
        "CheckBox",
        "xm y+10",
        "Randomize"
    )

    MainGui.SetFont(
        "s8 c8B929E",
        "Segoe UI"
    )

    RandomDescription := MainGui.AddText(
        "xm y+1 w420",
        "Randomly changes CPS and duration."
    )

    MainGui.SetFont(
        "s8 cFFFFFF",
        "Segoe UI"
    )

    RandomPrimaryLabel := MainGui.AddText(
        "xm y+5 w48",
        "CPS:"
    )

    RandomCPSMinEdit := MainGui.Add(
        "Edit",
        "x+3 w65 h23 c000000 BackgroundFFFFFF Center",
        "5"
    )

    RandomSeparator1 := MainGui.AddText(
        "x+3 w12 Center",
        "-"
    )

    RandomCPSMaxEdit := MainGui.Add(
        "Edit",
        "x+3 w65 h23 c000000 BackgroundFFFFFF Center",
        "15"
    )

    RandomTimeLabel := MainGui.AddText(
        "x+12 w55",
        "Time:"
    )

    RandomTimeMinEdit := MainGui.Add(
        "Edit",
        "x+3 w48 h23 c000000 BackgroundFFFFFF Center",
        "3"
    )

    RandomSeparator2 := MainGui.AddText(
        "x+2 w12 Center",
        "-"
    )

    RandomTimeMaxEdit := MainGui.Add(
        "Edit",
        "x+2 w48 h23 c000000 BackgroundFFFFFF Center",
        "7"
    )

    ; --------------------------------------------------------
    ; LIMITES
    ; --------------------------------------------------------

    MainGui.SetFont(
        "s10 Bold cFFFFFF",
        "Segoe UI"
    )

    LimitsHeading := MainGui.AddText(
        "xm y+10",
        "LIMITS"
    )

    MainGui.SetFont(
        "s8 cFFFFFF",
        "Segoe UI"
    )

    ClickLimitCheck := MainGui.Add(
        "CheckBox",
        "xm y+5 w115",
        "Max clicks"
    )

    ClickLimitEdit := MainGui.Add(
        "Edit",
        "x+4 w90 h23 c000000 BackgroundFFFFFF Center",
        "10000"
    )

    TimeLimitCheck := MainGui.Add(
        "CheckBox",
        "x+15 w115",
        "Max time"
    )

    TimeLimitEdit := MainGui.Add(
        "Edit",
        "x+4 w70 h23 c000000 BackgroundFFFFFF Center",
        "60"
    )

    ; --------------------------------------------------------
    ; INICIO
    ; --------------------------------------------------------

    MainGui.SetFont(
        "s10 Bold cFFFFFF",
        "Segoe UI"
    )

    StartHeading := MainGui.AddText(
        "xm y+10",
        "START"
    )

    MainGui.SetFont(
        "s8 c8B929E",
        "Segoe UI"
    )

    StartDescription := MainGui.AddText(
        "xm y+2 w420",
        "The delay only affects the Start button."
    )

    StartDelayEdit := MainGui.Add(
        "Edit",
        "xm y+5 w85 h24 c000000 BackgroundFFFFFF Center",
        "0"
    )

    StartUnitText := MainGui.AddText(
        "x+6 yp+5",
        "seconds"
    )

    ; --------------------------------------------------------
    ; ESTADISTICAS
    ; --------------------------------------------------------

    MainGui.SetFont(
        "s1",
        "Segoe UI"
    )

    MainGui.AddText(
        "xm y+8 w420 h1 Background3A3D44"
    )

    MainGui.SetFont(
        "s8 Bold cFFFFFF",
        "Segoe UI"
    )

    StatsRealLabel := MainGui.AddText(
        "xm y+7 w135 Center",
        "REAL CPS"
    )

    StatsConfigLabel := MainGui.AddText(
        "x+8 yp w135 Center",
        "CONFIG"
    )

    StatsTimeLabel := MainGui.AddText(
        "x+8 yp w134 Center",
        "TIME"
    )

    MainGui.SetFont(
        "s10 Bold cFFFFFF",
        "Segoe UI"
    )

    RealCPSText := MainGui.AddText(
        "xm y+3 w135 Center",
        "0.0"
    )

    ConfiguredCPSText := MainGui.AddText(
        "x+8 yp w135 Center",
        "10.0"
    )

    TimeText := MainGui.AddText(
        "x+8 yp w134 Center",
        "00:00:00"
    )

    ; --------------------------------------------------------
    ; BOTON PRINCIPAL
    ; --------------------------------------------------------

    StartButton := MainGui.Add(
        "Button",
        "xm y+8 w420 h32",
        "START"
    )

    StartButton.OnEvent(
        "Click",
        StartFromGUI
    )

    ; --------------------------------------------------------
    ; BOTONES SECUNDARIOS
    ; --------------------------------------------------------

    SaveButton := MainGui.Add(
        "Button",
        "xm y+6 w205 h27",
        "SAVE"
    )

    SaveButton.OnEvent(
        "Click",
        SaveGUIConfiguration
    )

    SaveAsButton := MainGui.Add(
        "Button",
        "x+10 yp w205 h27",
        "SAVE AS..."
    )

    SaveAsButton.OnEvent(
        "Click",
        SaveAsProfile
    )

    ; --------------------------------------------------------
    ; PERFIL
    ; --------------------------------------------------------

    MainGui.SetFont(
        "s8 c8B929E",
        "Segoe UI"
    )

    ProfileLabel := MainGui.AddText(
        "xm y+8",
        "PROFILE:"
    )

    ProfileDropDown := MainGui.Add(
        "DropDownList",
        "xm y+5 w270",
        GetProfiles()
    )

    ProfileDropDown.OnEvent(
        "Change",
        ProfileChanged
    )

    DeleteProfileButton := MainGui.Add(
        "Button",
        "x+10 yp w130 h23",
        "DELETE"
    )

    DeleteProfileButton.OnEvent(
        "Click",
        DeleteSelectedProfile
    )

    MainGui.OnEvent(
        "Close",
        (*) => ExitApp()
    )

    MainGui.Show(
        "w465 h720"
    )

    SyncGUI()
    UpdateLanguage()
}


; ============================================================
; SINCRONIZAR GUI
; ============================================================

SyncGUI()
{
    global

    switch SpeedMode
    {
        case "CPS":
            SpeedModeDrop.Choose(1)

        case "Seconds":
            SpeedModeDrop.Choose(2)

        case "HoldSeconds":
            SpeedModeDrop.Choose(3)

        default:
            SpeedMode := "CPS"
            SpeedModeDrop.Choose(1)
    }

    SpeedValueEdit.Value := SpeedValue

    if ActivationHotkey = "XButton1"
    {
        ActivationTypeDrop.Choose(2)
        ActivationKeyEdit.Value := "Mouse 4"
    }
    else if ActivationHotkey = "XButton2"
    {
        ActivationTypeDrop.Choose(3)
        ActivationKeyEdit.Value := "Mouse 5"
    }
    else
    {
        ActivationTypeDrop.Choose(1)
        ActivationKeyEdit.Value := ActivationHotkey
    }

    if ActivationMode = "Toggle"
        ActivationModeDrop.Choose(1)
    else
        ActivationModeDrop.Choose(2)

    switch ClickButton
    {
        case "LButton":
            ClickButtonDrop.Choose(1)

        case "RButton":
            ClickButtonDrop.Choose(2)

        case "MButton":
            ClickButtonDrop.Choose(3)

        case "XButton1":
            ClickButtonDrop.Choose(4)

        case "XButton2":
            ClickButtonDrop.Choose(5)
    }

    RandomCheck.Value :=
        RandomEnabled ? 1 : 0

    RandomCPSMinEdit.Value :=
        RandomCPSMin

    RandomCPSMaxEdit.Value :=
        RandomCPSMax

    RandomTimeMinEdit.Value :=
        RandomTimeMin

    RandomTimeMaxEdit.Value :=
        RandomTimeMax

    ClickLimitCheck.Value :=
        ClickLimitEnabled ? 1 : 0

    ClickLimitEdit.Value :=
        ClickLimit

    TimeLimitCheck.Value :=
        TimeLimitEnabled ? 1 : 0

    TimeLimitEdit.Value :=
        TimeLimit

    StartDelayEdit.Value :=
        StartDelay

    UpdateRandomLabels()
}


; ============================================================
; CAMBIO DE MODO DE VELOCIDAD
; ============================================================

SpeedModeChanged(*)
{
    UpdateRandomLabels()
}


UpdateRandomLabels()
{
    global

    if SpeedMode = "HoldSeconds"
    {
        if AppLanguage = "ES"
        {
            RandomPrimaryLabel.Text := "Pulsado:"
            RandomTimeLabel.Text := "Pausa:"
            RandomDescription.Text :=
                "Cambia aleatoriamente la duración y la pausa."
        }
        else
        {
            RandomPrimaryLabel.Text := "Hold:"
            RandomTimeLabel.Text := "Pause:"
            RandomDescription.Text :=
                "Randomizes hold and pause durations."
        }
    }
    else
    {
        if AppLanguage = "ES"
        {
            RandomPrimaryLabel.Text := "CPS:"
            RandomTimeLabel.Text := "Tiempo:"
            RandomDescription.Text :=
                "Cambia aleatoriamente los CPS y la duración."
        }
        else
        {
            RandomPrimaryLabel.Text := "CPS:"
            RandomTimeLabel.Text := "Time:"
            RandomDescription.Text :=
                "Randomly changes CPS and duration."
        }
    }
}


LanguageChanged(*)
{
    global AppLanguage

    AppLanguage := LanguageDropDown.Text

    if AppLanguage != "ES"
        AppLanguage := "EN"

    UpdateLanguage()
}


T(key)
{
    global AppLanguage

    translations := Map(
        "LANG_LABEL", AppLanguage = "ES" ? "Idioma:" : "Lang:",
        "SUBTITLE", AppLanguage = "ES" ? "d1m0nr - Motor de clicks de precisión" : "d1m0nr - Precision Click Engine",

        "STATUS_ON", AppLanguage = "ES" ? "●  ACTIVADO" : "●  ACTIVATED",
        "STATUS_OFF", AppLanguage = "ES" ? "●  DESACTIVADO" : "●  DEACTIVATED",
        "STATUS_RUNNING", AppLanguage = "ES" ? "El autoclicker está activo" : "The autoclicker is running",
        "STATUS_STOPPED", AppLanguage = "ES" ? "El autoclicker está detenido" : "The autoclicker is stopped",

        "SPEED", AppLanguage = "ES" ? "VELOCIDAD" : "SPEED",
        "SPEED_DESC", AppLanguage = "ES" ? "Velocidad principal del autoclicker." : "Main autoclicker speed.",
        "SPEED_CPS", AppLanguage = "ES" ? "Clicks por segundo" : "Clicks per second",
        "SPEED_SECONDS", AppLanguage = "ES" ? "Segundos por click" : "Seconds per click",
        "SPEED_HOLD", AppLanguage = "ES" ? "Segundo pulsado el click" : "Hold duration",

        "ACTIVATION", AppLanguage = "ES" ? "ACTIVACIÓN" : "ACTIVATION",
        "ACTIVATION_DESC", AppLanguage = "ES" ? "Tecla independiente para iniciar o detener." : "Independent key to start or stop.",
        "KEYBOARD", AppLanguage = "ES" ? "Teclado" : "Keyboard",

        "CLICK_BUTTON", AppLanguage = "ES" ? "BOTÓN DE CLICK" : "CLICK BUTTON",
        "LEFT", AppLanguage = "ES" ? "Izquierdo" : "Left",
        "RIGHT", AppLanguage = "ES" ? "Derecho" : "Right",
        "MIDDLE", AppLanguage = "ES" ? "Central" : "Middle",

        "RANDOM", AppLanguage = "ES" ? "Randomizar" : "Randomize",

        "LIMITS", AppLanguage = "ES" ? "LÍMITES" : "LIMITS",
        "MAX_CLICKS", AppLanguage = "ES" ? "Clicks máximos" : "Max clicks",
        "MAX_TIME", AppLanguage = "ES" ? "Tiempo máximo" : "Max time",

        "START", AppLanguage = "ES" ? "INICIO" : "START",
        "STOP", AppLanguage = "ES" ? "DETENER" : "STOP",
        "START_DESC", AppLanguage = "ES" ? "El retraso solo afecta al botón Inicio." : "The delay only affects the Start button.",
        "SECONDS", AppLanguage = "ES" ? "segundos" : "seconds",
        "STARTING", AppLanguage = "ES" ? "INICIANDO..." : "STARTING...",

        "REAL_CPS", AppLanguage = "ES" ? "CPS REAL" : "REAL CPS",
        "CONFIG", AppLanguage = "ES" ? "CONFIG" : "CONFIG",
        "TIME", AppLanguage = "ES" ? "TIEMPO" : "TIME",

        "SAVE", AppLanguage = "ES" ? "GUARDAR" : "SAVE",
        "SAVE_AS", AppLanguage = "ES" ? "GUARDAR COMO..." : "SAVE AS...",
        "PROFILE", AppLanguage = "ES" ? "PERFIL:" : "PROFILE:",
        "DELETE", AppLanguage = "ES" ? "BORRAR" : "DELETE",

        "CONFIG_SAVED", AppLanguage = "ES" ? "Configuración guardada." : "Configuration saved.",
        "SAVE_PROFILE_PROMPT", AppLanguage = "ES" ? "Escribe el nombre del nuevo perfil:" : "Enter the name of the new profile:",
        "SAVE_PROFILE_TITLE", AppLanguage = "ES" ? "Guardar configuración" : "Save configuration",
        "PROFILE_NAME_REQUIRED", AppLanguage = "ES" ? "Debes introducir un nombre para el perfil." : "You must enter a profile name.",
        "PROFILE_NAME_INVALID", AppLanguage = "ES" ? "El nombre introducido no es válido." : "The entered name is not valid.",
        "PROFILE_SAVED", AppLanguage = "ES" ? "Perfil guardado: " : "Profile saved: ",

        "DELETE_DEFAULT", AppLanguage = "ES" ? "El perfil Default no se puede borrar." : "The Default profile cannot be deleted.",
        "DELETE_CONFIRM", AppLanguage = "ES" ? "¿Seguro que quieres borrar el perfil?" : "Are you sure you want to delete this profile?",
        "PROFILE_DELETED", AppLanguage = "ES" ? "Perfil borrado: " : "Profile deleted: ",

        "HOTKEY_ERROR", AppLanguage = "ES" ? "No se pudo registrar la tecla de activación." : "The activation key could not be registered.",
        "ERROR_TITLE", AppLanguage = "ES" ? "Error" : "Error",
        "SAVE_ERROR", AppLanguage = "ES" ? "No se pudo guardar el perfil." : "The profile could not be saved.",
        "DELETE_ERROR", AppLanguage = "ES" ? "No se pudo borrar el perfil." : "The profile could not be deleted.",
        "SAFETY_ERROR", AppLanguage = "ES" ? "El autoclicker se ha detenido por seguridad." : "The autoclicker was stopped for safety.",
        "ERROR_LABEL", AppLanguage = "ES" ? "Error:" : "Error:",
        "KEY_LABEL", AppLanguage = "ES" ? "Tecla:" : "Key:",
        "PROFILE_LABEL", AppLanguage = "ES" ? "Perfil: " : "Profile: "
    )

    return translations.Has(key)
        ? translations[key]
        : key
}


UpdateLanguage()
{
    global

    LanguageLabel.Text := T("LANG_LABEL")
    SubtitleText.Text := T("SUBTITLE")

    SpeedHeading.Text := T("SPEED")
    SpeedDescription.Text := T("SPEED_DESC")

    SpeedModeDrop.Delete()
    SpeedModeDrop.Add([
        T("SPEED_CPS"),
        T("SPEED_SECONDS"),
        T("SPEED_HOLD")
    ])

    ActivationHeading.Text := T("ACTIVATION")
    ActivationDescription.Text := T("ACTIVATION_DESC")

    ActivationTypeDrop.Delete()
    ActivationTypeDrop.Add([
        T("KEYBOARD"),
        "Mouse 4",
        "Mouse 5"
    ])

    ClickHeading.Text := T("CLICK_BUTTON")

    ClickButtonDrop.Delete()
    ClickButtonDrop.Add([
        T("LEFT"),
        T("RIGHT"),
        T("MIDDLE"),
        "Mouse 4",
        "Mouse 5"
    ])

    RandomCheck.Text := T("RANDOM")

    LimitsHeading.Text := T("LIMITS")
    ClickLimitCheck.Text := T("MAX_CLICKS")
    TimeLimitCheck.Text := T("MAX_TIME")

    StartHeading.Text := T("START")
    StartDescription.Text := T("START_DESC")
    StartUnitText.Text := T("SECONDS")

    StatsRealLabel.Text := T("REAL_CPS")
    StatsConfigLabel.Text := T("CONFIG")
    StatsTimeLabel.Text := T("TIME")

    StartButton.Text :=
        IsRunning
            ? T("STOP")
            : T("START")

    SaveButton.Text := T("SAVE")
    SaveAsButton.Text := T("SAVE_AS")
    ProfileLabel.Text := T("PROFILE")
    DeleteProfileButton.Text := T("DELETE")

    if IsRunning
    {
        StatusText.Text := T("STATUS_ON")
        StatusDescriptionText.Text := T("STATUS_RUNNING")
    }
    else if !IsStarting
    {
        StatusText.Text := T("STATUS_OFF")
        StatusDescriptionText.Text := T("STATUS_STOPPED")
    }

    SpeedModeDrop.Choose(
        SpeedMode = "CPS"
            ? 1
            : SpeedMode = "Seconds"
                ? 2
                : 3
    )

    ActivationTypeDrop.Choose(
        ActivationHotkey = "XButton1"
            ? 2
            : ActivationHotkey = "XButton2"
                ? 3
                : 1
    )

    switch ClickButton
    {
        case "LButton":
            ClickButtonDrop.Choose(1)
        case "RButton":
            ClickButtonDrop.Choose(2)
        case "MButton":
            ClickButtonDrop.Choose(3)
        case "XButton1":
            ClickButtonDrop.Choose(4)
        case "XButton2":
            ClickButtonDrop.Choose(5)
    }

    LanguageDropDown.Choose(
        AppLanguage = "ES" ? 2 : 1
    )

    UpdateRandomLabels()
}


; ============================================================
; LEER GUI
; ============================================================

ReadGUI()
{
    global

    switch SpeedModeDrop.Value
    {
        case 1:
            SpeedMode := "CPS"
        case 2:
            SpeedMode := "Seconds"
        case 3:
            SpeedMode := "HoldSeconds"
        default:
            SpeedMode := "CPS"
    }

    SpeedValue :=
        Number(
            SpeedValueEdit.Value
        )

    if SpeedMode = "CPS"
    {
        if SpeedValue < 1
            SpeedValue := 1

        if SpeedValue > 100
            SpeedValue := 100
    }
    else if SpeedMode = "Seconds"
    {
        if SpeedValue < 0.01
            SpeedValue := 0.01
    }
    else
    {
        ; Tiempo durante el que se mantiene pulsado el botón.
        if SpeedValue < 0.01
            SpeedValue := 0.01

        ; Evitamos duraciones absurdamente grandes.
        if SpeedValue > 3600
            SpeedValue := 3600
    }

    ActivationMode :=
        ActivationModeDrop.Text

    activationType :=
        ActivationTypeDrop.Value

    if activationType = 2
    {
        ActivationHotkey :=
            "XButton1"
    }
    else if activationType = 3
    {
        ActivationHotkey :=
            "XButton2"
    }
    else
    {
        ActivationHotkey :=
            Trim(
                ActivationKeyEdit.Value
            )

        if ActivationHotkey = ""
            ActivationHotkey := "F6"
    }

    switch ClickButtonDrop.Value
    {
        case 1:
            ClickButton := "LButton"

        case 2:
            ClickButton := "RButton"

        case 3:
            ClickButton := "MButton"

        case 4:
            ClickButton := "XButton1"

        case 5:
            ClickButton := "XButton2"
    }

    RandomEnabled :=
        RandomCheck.Value = 1

    RandomCPSMin :=
        Number(
            RandomCPSMinEdit.Value
        )

    RandomCPSMax :=
        Number(
            RandomCPSMaxEdit.Value
        )

    RandomTimeMin :=
        Number(
            RandomTimeMinEdit.Value
        )

    RandomTimeMax :=
        Number(
            RandomTimeMaxEdit.Value
        )

    if SpeedMode = "HoldSeconds"
    {
        ; En Hold, estos dos campos representan el rango de
        ; duración que el botón permanece pulsado.
        if RandomCPSMin < 0.01
            RandomCPSMin := 0.01

        if RandomCPSMax < RandomCPSMin
            RandomCPSMax := RandomCPSMin

        if RandomCPSMax > 3600
            RandomCPSMax := 3600
    }
    else
    {
        if RandomCPSMin < 1
            RandomCPSMin := 1

        if RandomCPSMax > 100
            RandomCPSMax := 100

        if RandomCPSMin > RandomCPSMax
        {
            temp := RandomCPSMin
            RandomCPSMin := RandomCPSMax
            RandomCPSMax := temp
        }
    }

    ; En Hold, estos dos campos representan el rango de pausa
    ; entre soltar el botón y volver a pulsarlo.
    if RandomTimeMin < 0.01
        RandomTimeMin := 0.01

    if RandomTimeMax < RandomTimeMin
        RandomTimeMax := RandomTimeMin

    if RandomTimeMax > 3600
        RandomTimeMax := 3600

    ClickLimitEnabled :=
        ClickLimitCheck.Value = 1

    ClickLimit :=
        Integer(
            ClickLimitEdit.Value
        )

    if ClickLimit < 1
        ClickLimit := 1

    TimeLimitEnabled :=
        TimeLimitCheck.Value = 1

    TimeLimit :=
        Number(
            TimeLimitEdit.Value
        )

    if TimeLimit < 0.1
        TimeLimit := 0.1

    StartDelay :=
        Number(
            StartDelayEdit.Value
        )

    if StartDelay < 0
        StartDelay := 0
}


; ============================================================
; HOTKEY
; ============================================================

RegisterActivationHotkey()
{
    global

    if RegisteredHotkey != ""
    {
        try Hotkey(
            "~*" . RegisteredHotkey,
            ,
            "Off"
        )

        try Hotkey(
            "~*" . RegisteredHotkey . " Up",
            ,
            "Off"
        )

        RegisteredHotkey := ""
    }

    try
    {
        if ActivationMode = "Toggle"
        {
            Hotkey(
                "~*" . ActivationHotkey,
                ActivationToggle,
                "On"
            )
        }
        else
        {
            Hotkey(
                "~*" . ActivationHotkey,
                ActivationDown,
                "On"
            )

            Hotkey(
                "~*" . ActivationHotkey . " Up",
                ActivationUp,
                "On"
            )
        }

        RegisteredHotkey :=
            ActivationHotkey

        return true
    }
    catch as err
    {
        MsgBox(
            T("HOTKEY_ERROR")
            . "`n`n"
            . T("KEY_LABEL")
            . ActivationHotkey
            . "`n`nError:`n"
            . err.Message,
            APP_NAME,
            "Icon!"
        )

        return false
    }
}


ActivationToggle(*)
{
    global

    if IsStarting
        return

    if IsRunning
        StopClicker()
    else
        StartClicker()
}


ActivationDown(*)
{
    global

    if IsStarting
        return

    if !IsRunning
        StartClicker()
}


ActivationUp(*)
{
    global

    if IsRunning
        StopClicker()
}


; ============================================================
; INICIO DESDE GUI
; ============================================================

StartFromGUI(*)
{
    global

    if IsRunning || IsStarting
        return

    ReadGUI()

    if !RegisterActivationHotkey()
        return

    SaveCurrentProfile()

    if StartDelay <= 0
    {
        StartClicker()
        return
    }

    IsStarting := true

    startTime := A_TickCount

    endTime :=
        startTime
        + Round(
            StartDelay * 1000
        )

    while A_TickCount < endTime
    {
        if IsClosing
            return

        remaining :=
            (
                endTime
                - A_TickCount
            ) / 1000

        StartButton.Text :=
            T("STARTING")
            . " "
            . Format(
                "{:.1f}",
                remaining
            )
            . " s"

        Sleep(50)
    }

    IsStarting := false

    StartClicker()
}


; ============================================================
; START
; ============================================================

StartClicker()
{
    global

    if IsRunning
        return

    IsRunning := true

    TotalClicks := 0
    RecentClicks := []
    RealCPS := 0.0

    HoldActive := false
    HoldEndQPC := 0

    DllCall(
        "QueryPerformanceCounter",
        "Int64*",
        &SessionStartQPC
    )

    SelectSpeedSegment()

    DllCall(
        "QueryPerformanceCounter",
        "Int64*",
        &NextClickQPC
    )

    if SpeedMode != "HoldSeconds"
    {
        interval :=
            GetClickInterval()

        NextClickQPC :=
            NextClickQPC
            + interval

    }

    StatusText.Text :=
        T("STATUS_ON")

    StatusDescriptionText.Text :=
        T("STATUS_RUNNING")

    StatusText.SetFont(
        "c55FF88"
    )

    StartButton.Text :=
        T("STOP")

    SetTimer(
        PrecisionEngine,
        1
    )
}


; ============================================================
; STOP
; ============================================================

StopClicker()
{
    global

    if !IsRunning
        return

    ; Si estaba en modo hold, soltamos el botón antes de detener el motor.
    if HoldActive
        ReleaseSelectedMouseButton()

    HoldActive := false
    HoldEndQPC := 0

    IsRunning := false

    SetTimer(
        PrecisionEngine,
        0
    )

    if SessionStartQPC != 0
    {
        nowQPC := 0

        DllCall(
            "QueryPerformanceCounter",
            "Int64*",
            &nowQPC
        )

        elapsedQPC :=
            nowQPC
            - SessionStartQPC

        TotalActiveSeconds +=
            elapsedQPC
            / QPCFrequency
    }

    SessionStartQPC := 0

    StatusText.Text :=
        T("STATUS_OFF")

    StatusDescriptionText.Text :=
        T("STATUS_STOPPED")

    StatusText.SetFont(
        "cFF5555"
    )

    StartButton.Text :=
        T("START")
}


; ============================================================
; MOTOR DE PRECISION
; ============================================================

PrecisionEngine()
{
    global

    if !IsRunning
        return

    try
    {
        nowQPC := 0

        DllCall(
            "QueryPerformanceCounter",
            "Int64*",
            &nowQPC
        )

        ; --------------------------------------------------------
        ; MODO "SEGUNDO PULSADO EL CLICK"
        ; --------------------------------------------------------

        if SpeedMode = "HoldSeconds"
        {
            if HoldActive
            {
                ; Mantener pulsado hasta cumplir exactamente la
                ; duración configurada.
                if nowQPC < HoldEndQPC
                    return

                ReleaseSelectedMouseButton()

                HoldActive := false

                ; Pausa entre pulsaciones. En modo Hold con
                ; Randomizar activo se obtiene del rango "Pausa".
                pauseDuration :=
                    GetRandomHoldPause()

                NextClickQPC :=
                    nowQPC
                    + Round(
                        pauseDuration
                        * QPCFrequency
                    )

                return
            }

            if nowQPC < NextClickQPC
                return

            PerformHold()

            return
        }

        ; --------------------------------------------------------
        ; MODOS DE CLICK NORMAL
        ; --------------------------------------------------------

        if RandomEnabled
        {
            if nowQPC >= CurrentSegmentEndQPC
                SelectSpeedSegment()
        }

        if nowQPC < NextClickQPC
            return

        PerformClick()

        if !IsRunning
            return

        interval :=
            GetClickInterval()

        NextClickQPC :=
            NextClickQPC
            + interval

        afterClickQPC := 0

        DllCall(
            "QueryPerformanceCounter",
            "Int64*",
            &afterClickQPC
        )

        if NextClickQPC < (
            afterClickQPC
            - QPCFrequency
        )
        {
            NextClickQPC :=
                afterClickQPC
                + interval
        }
    }
    catch
    {
        StopClicker()
    }
}


GetClickInterval()
{
    global

    if CurrentCPS <= 0
        CurrentCPS := 1

    return Round(
        QPCFrequency
        / CurrentCPS
    )
}


SelectSpeedSegment()
{
    global

    if SpeedMode = "HoldSeconds"
    {
        ; CurrentCPS se conserva para las estadísticas.
        ; La duración real del hold se decide al pulsar.
        CurrentCPS := 1 / SpeedValue
        CurrentSegmentEndQPC := 0
        return
    }

    if RandomEnabled
    {
        CurrentCPS :=
            Random(
                RandomCPSMin,
                RandomCPSMax
            )

        duration :=
            Random(
                RandomTimeMin,
                RandomTimeMax
            )

        nowQPC := 0

        DllCall(
            "QueryPerformanceCounter",
            "Int64*",
            &nowQPC
        )

        CurrentSegmentEndQPC :=
            nowQPC
            + Round(
                duration
                * QPCFrequency
            )

        return
    }

    if SpeedMode = "CPS"
        CurrentCPS := SpeedValue
    else
        CurrentCPS := 1 / SpeedValue

    CurrentSegmentEndQPC := 0
}


; ============================================================
; VALORES RANDOM DEL MODO HOLD
; ============================================================

GetRandomHoldDuration()
{
    global

    if !RandomEnabled
        return SpeedValue

    return Random(
        RandomCPSMin,
        RandomCPSMax
    )
}


GetRandomHoldPause()
{
    global

    if !RandomEnabled
        return 1.0

    return Random(
        RandomTimeMin,
        RandomTimeMax
    )
}


; ============================================================
; HOLD
; ============================================================

PerformHold()
{
    global

    if ClickLimitEnabled
    {
        if TotalClicks >= ClickLimit
        {
            StopClicker()
            return
        }
    }

    ; Necesitamos una lectura QPC válida incluso cuando no hay
    ; límite de tiempo, porque se usa para calcular HoldEndQPC.
    nowQPC := 0

    DllCall(
        "QueryPerformanceCounter",
        "Int64*",
        &nowQPC
    )

    if TimeLimitEnabled
    {
        if SessionStartQPC != 0
        {
            elapsed := (
                nowQPC
                - SessionStartQPC
            ) / QPCFrequency

            if elapsed >= TimeLimit
            {
                StopClicker()
                return
            }
        }
    }

    holdDuration :=
        GetRandomHoldDuration()

    PressSelectedMouseButton()

    HoldActive := true

    holdDurationQPC :=
        Round(
            holdDuration
            * QPCFrequency
        )

    HoldEndQPC :=
        nowQPC
        + holdDurationQPC

    ; Cada pulsación completa cuenta como un click para los
    ; límites y estadísticas.
    RegisterClick()
}


; ============================================================
; CLICK
; ============================================================

PerformClick()
{
    global

    if ClickLimitEnabled
    {
        if TotalClicks >= ClickLimit
        {
            StopClicker()
            return
        }
    }

    if TimeLimitEnabled
    {
        if SessionStartQPC != 0
        {
            nowQPC := 0

            DllCall(
                "QueryPerformanceCounter",
                "Int64*",
                &nowQPC
            )

            elapsed := (
                nowQPC
                - SessionStartQPC
            ) / QPCFrequency

            if elapsed >= TimeLimit
            {
                StopClicker()
                return
            }
        }
    }

    ; --------------------------------------------------------
    ; CLICK REAL
    ; --------------------------------------------------------

    switch ClickButton
    {
        case "LButton":
            SendMouseButton(
                0x0002,
                0x0004,
                0
            )

        case "RButton":
            SendMouseButton(
                0x0008,
                0x0010,
                0
            )

        case "MButton":
            SendMouseButton(
                0x0020,
                0x0040,
                0
            )

        case "XButton1":
            SendMouseButton(
                0x0080,
                0x0100,
                1
            )

        case "XButton2":
            SendMouseButton(
                0x0080,
                0x0100,
                2
            )
    }

    RegisterClick()
}


SendMouseButton(
    downFlag,
    upFlag,
    mouseData
)
{
    PressMouseButton(
        downFlag,
        mouseData
    )

    ReleaseMouseButton(
        upFlag,
        mouseData
    )
}


PressMouseButton(
    downFlag,
    mouseData
)
{
    DllCall(
        "User32\mouse_event",
        "UInt",
        downFlag,
        "UInt",
        0,
        "UInt",
        0,
        "UInt",
        mouseData,
        "UPtr",
        0
    )
}


ReleaseMouseButton(
    upFlag,
    mouseData
)
{
    DllCall(
        "User32\mouse_event",
        "UInt",
        upFlag,
        "UInt",
        0,
        "UInt",
        0,
        "UInt",
        mouseData,
        "UPtr",
        0
    )
}


PressSelectedMouseButton()
{
    global ClickButton

    switch ClickButton
    {
        case "LButton":
            PressMouseButton(
                0x0002,
                0
            )

        case "RButton":
            PressMouseButton(
                0x0008,
                0
            )

        case "MButton":
            PressMouseButton(
                0x0020,
                0
            )

        case "XButton1":
            PressMouseButton(
                0x0080,
                1
            )

        case "XButton2":
            PressMouseButton(
                0x0080,
                2
            )
    }
}


ReleaseSelectedMouseButton()
{
    global ClickButton

    switch ClickButton
    {
        case "LButton":
            ReleaseMouseButton(
                0x0004,
                0
            )

        case "RButton":
            ReleaseMouseButton(
                0x0010,
                0
            )

        case "MButton":
            ReleaseMouseButton(
                0x0040,
                0
            )

        case "XButton1":
            ReleaseMouseButton(
                0x0100,
                1
            )

        case "XButton2":
            ReleaseMouseButton(
                0x0100,
                2
            )
    }
}


; ============================================================
; CONTADOR
; ============================================================

RegisterClick()
{
    global

    TotalClicks++

    nowQPC := 0

    DllCall(
        "QueryPerformanceCounter",
        "Int64*",
        &nowQPC
    )

    RecentClicks.Push(
        nowQPC
    )
}


UpdateRealCPS()
{
    global

    if RecentClicks.Length = 0
    {
        RealCPS := 0.0
        return
    }

    nowQPC := 0

    DllCall(
        "QueryPerformanceCounter",
        "Int64*",
        &nowQPC
    )

    cutoff :=
        nowQPC
        - QPCFrequency

    while RecentClicks.Length > 0
    {
        if RecentClicks[1] >= cutoff
            break

        RecentClicks.RemoveAt(1)
    }

    RealCPS :=
        RecentClicks.Length
}


; ============================================================
; INTERFAZ
; ============================================================

UpdateInterface()
{
    global

    RealCPSText.Text :=
        Format(
            "{:.1f}",
            RealCPS
        )

    ConfiguredCPSText.Text :=
        Format(
            "{:.1f}",
            CurrentCPS
        )

    elapsed :=
        TotalActiveSeconds

    if IsRunning
        && SessionStartQPC != 0
    {
        nowQPC := 0

        DllCall(
            "QueryPerformanceCounter",
            "Int64*",
            &nowQPC
        )

        elapsed += (
            nowQPC
            - SessionStartQPC
        ) / QPCFrequency
    }

    TimeText.Text :=
        FormatTimeSpan(
            elapsed
        )

    if IsRunning
    {
        StatusText.Text :=
            T("STATUS_ON")

        StatusDescriptionText.Text :=
            T("STATUS_RUNNING")

        StatusText.SetFont(
            "c55FF88"
        )
    }
    else if !IsStarting
    {
        StatusText.Text :=
            T("STATUS_OFF")

        StatusDescriptionText.Text :=
            T("STATUS_STOPPED")

        StatusText.SetFont(
            "cFF5555"
        )
    }
}


FormatTimeSpan(seconds)
{
    seconds :=
        Floor(seconds)

    hours :=
        Floor(
            seconds / 3600
        )

    minutes :=
        Floor(
            Mod(
                seconds,
                3600
            ) / 60
        )

    secs :=
        Mod(
            seconds,
            60
        )

    return Format(
        "{:02}:{:02}:{:02}",
        hours,
        minutes,
        secs
    )
}


; ============================================================
; GUARDAR
; ============================================================

SaveGUIConfiguration(*)
{
    global

    if IsRunning
        StopClicker()

    ReadGUI()

    if !RegisterActivationHotkey()
        return

    SaveCurrentProfile()

    ToolTip(
        T("CONFIG_SAVED")
    )

    SetTimer(
        () => ToolTip(),
        -1500
    )
}


; ============================================================
; GUARDAR COMO
; ============================================================

SaveAsProfile(*)
{
    global

    MainGui.Opt("+OwnDialogs")

    result :=
        InputBox(
            T("SAVE_PROFILE_PROMPT"),
            T("SAVE_PROFILE_TITLE"),
            "w350 h140",
            CurrentProfile
        )

    if result.Result != "OK"
        return

    profileName :=
        Trim(
            result.Value
        )

    if profileName = ""
    {
        MsgBox(
            T("PROFILE_NAME_REQUIRED"),
            APP_NAME,
            "Icon!"
        )
        return
    }

    profileName :=
        RegExReplace(
            profileName,
            "[\[\]\r\n]",
            ""
        )

    profileName :=
        Trim(
            profileName
        )

    if profileName = ""
    {
        MsgBox(
            T("PROFILE_NAME_INVALID"),
            APP_NAME,
            "Icon!"
        )
        return
    }

    ReadGUI()

    if !RegisterActivationHotkey()
        return

    CurrentProfile :=
        profileName

    try
    {
        SaveCurrentProfile()

        RefreshProfiles()

        ProfileDropDown.Text :=
            profileName

        ToolTip(
            T("PROFILE_SAVED")
            . profileName
        )

        SetTimer(
            () => ToolTip(),
            -1500
        )
    }
    catch as err
    {
        MsgBox(
            T("SAVE_ERROR")
            . "`n`n"
            . T("ERROR_LABEL")
            . "`n"
            . err.Message,
            APP_NAME,
            "Icon!"
        )
    }
}


; ============================================================
; PERFILES
; ============================================================

GetProfiles()
{
    global

    profiles := [
        "Default"
    ]

    if !FileExist(CONFIG_FILE)
        return profiles

    try
    {
        content :=
            FileRead(
                CONFIG_FILE,
                "UTF-8"
            )

        Loop Parse, content, "`n", "`r"
        {
            line :=
                Trim(
                    A_LoopField
                )

            if RegExMatch(
                line,
                "^\[Profile_(.+)\]$",
                &match
            )
            {
                profileName :=
                    match[1]

                if !HasArrayValue(
                    profiles,
                    profileName
                )
                {
                    profiles.Push(
                        profileName
                    )
                }
            }
        }
    }

    return profiles
}


HasArrayValue(
    array,
    value
)
{
    for item in array
    {
        if item = value
            return true
    }

    return false
}


RefreshProfiles()
{
    global

    profiles :=
        GetProfiles()

    ProfileDropDown.Delete()

    for profile in profiles
    {
        ProfileDropDown.Add(
            [profile]
        )
    }

    ProfileDropDown.Text :=
        CurrentProfile
}


ProfileChanged(*)
{
    global

    if IsRunning
        StopClicker()

    profileName :=
        ProfileDropDown.Text

    if profileName = ""
        profileName := "Default"

    LoadProfile(
        profileName
    )

    SyncGUI()

    RegisterActivationHotkey()
}


; ============================================================
; BORRAR PERFIL SELECCIONADO
; ============================================================

DeleteSelectedProfile(*)
{
    global

    MainGui.Opt("+OwnDialogs")

    profileName :=
        Trim(
            ProfileDropDown.Text
        )

    if profileName = ""
        return

    if profileName = "Default"
    {
        MsgBox(
            T("DELETE_DEFAULT"),
            APP_NAME,
            "Icon!"
        )
        return
    }

    answer :=
        MsgBox(
            T("DELETE_CONFIRM")
            . "`n`n"
            . profileName,
            APP_NAME,
            "YesNo Icon? Owner" . MainGui.Hwnd
        )

    if answer != "Yes"
        return

    if IsRunning
        StopClicker()

    try
    {
        IniDelete(
            CONFIG_FILE,
            "Profile_" . profileName
        )

        LoadProfile(
            "Default"
        )

        RefreshProfiles()

        ProfileDropDown.Text :=
            "Default"

        SyncGUI()

        if !RegisterActivationHotkey()
            return

        ToolTip(
            T("PROFILE_DELETED")
            . profileName
        )

        SetTimer(
            () => ToolTip(),
            -1500
        )
    }
    catch as err
    {
        MsgBox(
            T("DELETE_ERROR")
            . "`n`n"
            . T("PROFILE_LABEL")
            . profileName
            . "`n`n"
            . T("ERROR_LABEL")
            . "`n"
            . err.Message,
            APP_NAME,
            "Icon!"
        )
    }
}


; ============================================================
; ERROR
; ============================================================

HandleScriptError(
    error,
    mode
)
{
    global

    if IsClosing
        return

    try StopClicker()

    MsgBox(
        T("SAFETY_ERROR")
        . "`n`n"
        . T("ERROR_LABEL")
        . "`n"
        . error.Message,
        APP_NAME,
        "Icon!"
    )
}


; ============================================================
; SALIDA
; ============================================================

Cleanup(*)
{
    global

    IsClosing := true

    try StopClicker()

    if RegisteredHotkey != ""
    {
        try Hotkey(
            "~*" . RegisteredHotkey,
            ,
            "Off"
        )

        try Hotkey(
            "~*" . RegisteredHotkey . " Up",
            ,
            "Off"
        )
    }

    DllCall(
        "Winmm\timeEndPeriod",
        "UInt",
        1
    )
}