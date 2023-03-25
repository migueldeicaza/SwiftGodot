public enum Side: Int {
    case left = 0 // SIDE_LEFT
    case top = 1 // SIDE_TOP
    case right = 2 // SIDE_RIGHT
    case bottom = 3 // SIDE_BOTTOM
}

public enum Corner: Int {
    case topLeft = 0 // CORNER_TOP_LEFT
    case topRight = 1 // CORNER_TOP_RIGHT
    case bottomRight = 2 // CORNER_BOTTOM_RIGHT
    case bottomLeft = 3 // CORNER_BOTTOM_LEFT
}

public enum Orientation: Int {
    case vertical = 1 // VERTICAL
    case horizontal = 0 // HORIZONTAL
}

public enum ClockDirection: Int {
    case clockwise = 0 // CLOCKWISE
    case counterclockwise = 1 // COUNTERCLOCKWISE
}

public enum HorizontalAlignment: Int {
    case left = 0 // HORIZONTAL_ALIGNMENT_LEFT
    case center = 1 // HORIZONTAL_ALIGNMENT_CENTER
    case right = 2 // HORIZONTAL_ALIGNMENT_RIGHT
    case fill = 3 // HORIZONTAL_ALIGNMENT_FILL
}

public enum VerticalAlignment: Int {
    case top = 0 // VERTICAL_ALIGNMENT_TOP
    case center = 1 // VERTICAL_ALIGNMENT_CENTER
    case bottom = 2 // VERTICAL_ALIGNMENT_BOTTOM
    case fill = 3 // VERTICAL_ALIGNMENT_FILL
}

public enum InlineAlignment: Int {
    case centerTo = 1 // INLINE_ALIGNMENT_CENTER_TO
    case baselineTo = 3 // INLINE_ALIGNMENT_BASELINE_TO
    case bottomTo = 2 // INLINE_ALIGNMENT_BOTTOM_TO
    case toCenter = 4 // INLINE_ALIGNMENT_TO_CENTER
    case toBaseline = 8 // INLINE_ALIGNMENT_TO_BASELINE
    case toBottom = 12 // INLINE_ALIGNMENT_TO_BOTTOM
    case top = 0 // INLINE_ALIGNMENT_TOP
    case center = 5 // INLINE_ALIGNMENT_CENTER
    case bottom = 14 // INLINE_ALIGNMENT_BOTTOM
}

public enum EulerOrder: Int {
    case xyz = 0 // EULER_ORDER_XYZ
    case xzy = 1 // EULER_ORDER_XZY
    case yxz = 2 // EULER_ORDER_YXZ
    case yzx = 3 // EULER_ORDER_YZX
    case zxy = 4 // EULER_ORDER_ZXY
    case zyx = 5 // EULER_ORDER_ZYX
}

public enum Key: Int {
    case none = 0 // KEY_NONE
    case special = 4194304 // KEY_SPECIAL
    case escape = 4194305 // KEY_ESCAPE
    case tab = 4194306 // KEY_TAB
    case backtab = 4194307 // KEY_BACKTAB
    case backspace = 4194308 // KEY_BACKSPACE
    case enter = 4194309 // KEY_ENTER
    case kpEnter = 4194310 // KEY_KP_ENTER
    case insert = 4194311 // KEY_INSERT
    case delete = 4194312 // KEY_DELETE
    case pause = 4194313 // KEY_PAUSE
    case print = 4194314 // KEY_PRINT
    case sysreq = 4194315 // KEY_SYSREQ
    case clear = 4194316 // KEY_CLEAR
    case home = 4194317 // KEY_HOME
    case end = 4194318 // KEY_END
    case left = 4194319 // KEY_LEFT
    case up = 4194320 // KEY_UP
    case right = 4194321 // KEY_RIGHT
    case down = 4194322 // KEY_DOWN
    case pageup = 4194323 // KEY_PAGEUP
    case pagedown = 4194324 // KEY_PAGEDOWN
    case shift = 4194325 // KEY_SHIFT
    case ctrl = 4194326 // KEY_CTRL
    case meta = 4194327 // KEY_META
    case alt = 4194328 // KEY_ALT
    case capslock = 4194329 // KEY_CAPSLOCK
    case numlock = 4194330 // KEY_NUMLOCK
    case scrolllock = 4194331 // KEY_SCROLLLOCK
    case f1 = 4194332 // KEY_F1
    case f2 = 4194333 // KEY_F2
    case f3 = 4194334 // KEY_F3
    case f4 = 4194335 // KEY_F4
    case f5 = 4194336 // KEY_F5
    case f6 = 4194337 // KEY_F6
    case f7 = 4194338 // KEY_F7
    case f8 = 4194339 // KEY_F8
    case f9 = 4194340 // KEY_F9
    case f10 = 4194341 // KEY_F10
    case f11 = 4194342 // KEY_F11
    case f12 = 4194343 // KEY_F12
    case f13 = 4194344 // KEY_F13
    case f14 = 4194345 // KEY_F14
    case f15 = 4194346 // KEY_F15
    case f16 = 4194347 // KEY_F16
    case f17 = 4194348 // KEY_F17
    case f18 = 4194349 // KEY_F18
    case f19 = 4194350 // KEY_F19
    case f20 = 4194351 // KEY_F20
    case f21 = 4194352 // KEY_F21
    case f22 = 4194353 // KEY_F22
    case f23 = 4194354 // KEY_F23
    case f24 = 4194355 // KEY_F24
    case f25 = 4194356 // KEY_F25
    case f26 = 4194357 // KEY_F26
    case f27 = 4194358 // KEY_F27
    case f28 = 4194359 // KEY_F28
    case f29 = 4194360 // KEY_F29
    case f30 = 4194361 // KEY_F30
    case f31 = 4194362 // KEY_F31
    case f32 = 4194363 // KEY_F32
    case f33 = 4194364 // KEY_F33
    case f34 = 4194365 // KEY_F34
    case f35 = 4194366 // KEY_F35
    case kpMultiply = 4194433 // KEY_KP_MULTIPLY
    case kpDivide = 4194434 // KEY_KP_DIVIDE
    case kpSubtract = 4194435 // KEY_KP_SUBTRACT
    case kpPeriod = 4194436 // KEY_KP_PERIOD
    case kpAdd = 4194437 // KEY_KP_ADD
    case kp0 = 4194438 // KEY_KP_0
    case kp1 = 4194439 // KEY_KP_1
    case kp2 = 4194440 // KEY_KP_2
    case kp3 = 4194441 // KEY_KP_3
    case kp4 = 4194442 // KEY_KP_4
    case kp5 = 4194443 // KEY_KP_5
    case kp6 = 4194444 // KEY_KP_6
    case kp7 = 4194445 // KEY_KP_7
    case kp8 = 4194446 // KEY_KP_8
    case kp9 = 4194447 // KEY_KP_9
    case menu = 4194370 // KEY_MENU
    case hyper = 4194371 // KEY_HYPER
    case help = 4194373 // KEY_HELP
    case back = 4194376 // KEY_BACK
    case forward = 4194377 // KEY_FORWARD
    case stop = 4194378 // KEY_STOP
    case refresh = 4194379 // KEY_REFRESH
    case volumedown = 4194380 // KEY_VOLUMEDOWN
    case volumemute = 4194381 // KEY_VOLUMEMUTE
    case volumeup = 4194382 // KEY_VOLUMEUP
    case mediaplay = 4194388 // KEY_MEDIAPLAY
    case mediastop = 4194389 // KEY_MEDIASTOP
    case mediaprevious = 4194390 // KEY_MEDIAPREVIOUS
    case medianext = 4194391 // KEY_MEDIANEXT
    case mediarecord = 4194392 // KEY_MEDIARECORD
    case homepage = 4194393 // KEY_HOMEPAGE
    case favorites = 4194394 // KEY_FAVORITES
    case search = 4194395 // KEY_SEARCH
    case standby = 4194396 // KEY_STANDBY
    case openurl = 4194397 // KEY_OPENURL
    case launchmail = 4194398 // KEY_LAUNCHMAIL
    case launchmedia = 4194399 // KEY_LAUNCHMEDIA
    case launch0 = 4194400 // KEY_LAUNCH0
    case launch1 = 4194401 // KEY_LAUNCH1
    case launch2 = 4194402 // KEY_LAUNCH2
    case launch3 = 4194403 // KEY_LAUNCH3
    case launch4 = 4194404 // KEY_LAUNCH4
    case launch5 = 4194405 // KEY_LAUNCH5
    case launch6 = 4194406 // KEY_LAUNCH6
    case launch7 = 4194407 // KEY_LAUNCH7
    case launch8 = 4194408 // KEY_LAUNCH8
    case launch9 = 4194409 // KEY_LAUNCH9
    case launcha = 4194410 // KEY_LAUNCHA
    case launchb = 4194411 // KEY_LAUNCHB
    case launchc = 4194412 // KEY_LAUNCHC
    case launchd = 4194413 // KEY_LAUNCHD
    case launche = 4194414 // KEY_LAUNCHE
    case launchf = 4194415 // KEY_LAUNCHF
    case unknown = 8388607 // KEY_UNKNOWN
    case space = 32 // KEY_SPACE
    case exclam = 33 // KEY_EXCLAM
    case quotedbl = 34 // KEY_QUOTEDBL
    case numbersign = 35 // KEY_NUMBERSIGN
    case dollar = 36 // KEY_DOLLAR
    case percent = 37 // KEY_PERCENT
    case ampersand = 38 // KEY_AMPERSAND
    case apostrophe = 39 // KEY_APOSTROPHE
    case parenleft = 40 // KEY_PARENLEFT
    case parenright = 41 // KEY_PARENRIGHT
    case asterisk = 42 // KEY_ASTERISK
    case plus = 43 // KEY_PLUS
    case comma = 44 // KEY_COMMA
    case minus = 45 // KEY_MINUS
    case period = 46 // KEY_PERIOD
    case slash = 47 // KEY_SLASH
    case key0 = 48 // KEY_0
    case key1 = 49 // KEY_1
    case key2 = 50 // KEY_2
    case key3 = 51 // KEY_3
    case key4 = 52 // KEY_4
    case key5 = 53 // KEY_5
    case key6 = 54 // KEY_6
    case key7 = 55 // KEY_7
    case key8 = 56 // KEY_8
    case key9 = 57 // KEY_9
    case colon = 58 // KEY_COLON
    case semicolon = 59 // KEY_SEMICOLON
    case less = 60 // KEY_LESS
    case equal = 61 // KEY_EQUAL
    case greater = 62 // KEY_GREATER
    case question = 63 // KEY_QUESTION
    case at = 64 // KEY_AT
    case a = 65 // KEY_A
    case b = 66 // KEY_B
    case c = 67 // KEY_C
    case d = 68 // KEY_D
    case e = 69 // KEY_E
    case f = 70 // KEY_F
    case g = 71 // KEY_G
    case h = 72 // KEY_H
    case i = 73 // KEY_I
    case j = 74 // KEY_J
    case k = 75 // KEY_K
    case l = 76 // KEY_L
    case m = 77 // KEY_M
    case n = 78 // KEY_N
    case o = 79 // KEY_O
    case p = 80 // KEY_P
    case q = 81 // KEY_Q
    case r = 82 // KEY_R
    case s = 83 // KEY_S
    case t = 84 // KEY_T
    case u = 85 // KEY_U
    case v = 86 // KEY_V
    case w = 87 // KEY_W
    case x = 88 // KEY_X
    case y = 89 // KEY_Y
    case z = 90 // KEY_Z
    case bracketleft = 91 // KEY_BRACKETLEFT
    case backslash = 92 // KEY_BACKSLASH
    case bracketright = 93 // KEY_BRACKETRIGHT
    case asciicircum = 94 // KEY_ASCIICIRCUM
    case underscore = 95 // KEY_UNDERSCORE
    case quoteleft = 96 // KEY_QUOTELEFT
    case braceleft = 123 // KEY_BRACELEFT
    case bar = 124 // KEY_BAR
    case braceright = 125 // KEY_BRACERIGHT
    case asciitilde = 126 // KEY_ASCIITILDE
    case yen = 165 // KEY_YEN
    case section = 167 // KEY_SECTION
    case globe = 4194416 // KEY_GLOBE
    case keyboard = 4194417 // KEY_KEYBOARD
    case jisEisu = 4194418 // KEY_JIS_EISU
    case jisKana = 4194419 // KEY_JIS_KANA
}

public struct KeyModifierMask: OptionSet {
    public let rawValue: Int
    public init (rawValue: Int) {
        self.rawValue = rawValue
    }
    
    public static let keyCodeMask = KeyModifierMask (rawValue: 8388607)
    public static let keyModifierMask = KeyModifierMask (rawValue: 532676608)
    public static let keyMaskCmdOrCtrl = KeyModifierMask (rawValue: 16777216)
    public static let keyMaskShift = KeyModifierMask (rawValue: 33554432)
    public static let keyMaskAlt = KeyModifierMask (rawValue: 67108864)
    public static let keyMaskMeta = KeyModifierMask (rawValue: 134217728)
    public static let keyMaskCtrl = KeyModifierMask (rawValue: 268435456)
    public static let keyMaskKpad = KeyModifierMask (rawValue: 536870912)
    public static let keyMaskGroupSwitch = KeyModifierMask (rawValue: 1073741824)
}

