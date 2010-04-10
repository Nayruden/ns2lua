// ======= Copyright © 2003-2010, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Constants.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
//                  Max McGuire (max@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================
Script.Load("lua/Balance.lua")

// Keycodes (for panel key press events)
kKeyCodeNone                            = 0
kKeyCode0                               = 1
kKeyCode1                               = 2
kKeyCode2                               = 3
kKeyCode3                               = 4
kKeyCode4                               = 5
kKeyCode5                               = 6
kKeyCode6                               = 7
kKeyCode7                               = 8
kKeyCode8                               = 9
kKeyCode9                               = 10
kKeyCodeA                               = 11
kKeyCodeB                               = 12
kKeyCodeC                               = 13
kKeyCodeD                               = 14
kKeyCodeE                               = 15
kKeyCodeF                               = 16
kKeyCodeG                               = 17
kKeyCodeH                               = 18
kKeyCodeI                               = 19
kKeyCodeJ                               = 20
kKeyCodeK                               = 21
kKeyCodeL                               = 22
kKeyCodeM                               = 23
kKeyCodeN                               = 24
kKeyCodeO                               = 25
kKeyCodeP                               = 26
kKeyCodeQ                               = 27
kKeyCodeR                               = 28
kKeyCodeS                               = 29
kKeyCodeT                               = 30
kKeyCodeU                               = 31
kKeyCodeV                               = 32
kKeyCodeW                               = 33
kKeyCodeX                               = 34
kKeyCodeY                               = 35
kKeyCodeZ                               = 36
kKeyCodeKeyPad0                         = 37
kKeyCodeKeyPad1                         = 38
kKeyCodeKeyPad2                         = 39
kKeyCodeKeyPad3                         = 40
kKeyCodeKeyPad4                         = 41
kKeyCodeKeyPad5                         = 42
kKeyCodeKeyPad6                         = 43
kKeyCodeKeyPad7                         = 44
kKeyCodeKeyPad8                         = 45
kKeyCodeKeyPad9                         = 46
kKeyCodeKeyPadDivide                    = 47
kKeyCodeKeyPadMultiply                  = 48
kKeyCodeKeyPadMinus                     = 49
kKeyCodeKeyPadPlus                      = 50
kKeyCodeKeyPadEnter                     = 51
kKeyCodeKeyPadDecimal                   = 52
kKeyCodeLBracket                        = 53
kKeyCodeRBracket                        = 54
kKeyCodeSemicolon                       = 55
kKeyCodeApostrophe                      = 56
kKeyCodeBackquote                       = 57
kKeyCodeComma                           = 58
kKeyCodePeriod                          = 59
kKeyCodeSlash                           = 60
kKeyCodeBackslash                       = 61
kKeyCodeMinus                           = 62
kKeyCodeEqual                           = 63
kKeyCodeEnter                           = 64
kKeyCodeSpace                           = 65
kKeyCodeBackspace                       = 66
kKeyCodeTab                             = 67
kKeyCodeCapsLock                        = 68    
kKeyCodeNumLock                         = 69
kKeyCodeEscape                          = 70
kKeyCodeScrollLock                      = 71
kKeyCodeInsert                          = 72
kKeyCodeDelete                          = 73
kKeyCodeHome                            = 74
kKeyCodeEnd                             = 75
kKeyCodePageUp                          = 76
kKeyCodePageDown                        = 77
kKeyCodeBreak                           = 78
kKeyCodeLShift                          = 79
kKeyCodeRShift                          = 80
kKeyCodeLAlt                            = 81
kKeyCodeRAlt                            = 82
kKeyCodeLControl                        = 83
kKeyCodeRControl                        = 84
kKeyCodeLWin                            = 85
kKeyCodeRWin                            = 86
kKeyCodeApp                             = 87
kKeyCodeUp                              = 88
kKeyCodeLeft                            = 89
kKeyCodeDown                            = 90
kKeyCodeRight                           = 91
kKeyCodeF1                              = 92
kKeyCodeF2                              = 93
kKeyCodeF3                              = 94
kKeyCodeF4                              = 95
kKeyCodeF5                              = 96
kKeyCodeF6                              = 97
kKeyCodeF7                              = 98
kKeyCodeF8                              = 99
kKeyCodeF9                              = 100
kKeyCodeF10                             = 101
kKeyCodeF11                             = 102
kKeyCodeF12                             = 103
kKeyCodeCapsLockToggle                  = 104
kKeyCodeNumLockToggle                   = 105
kKeyCodeScrollLockToggle                = 106

// Mouse buttons
kLeftMouseButton                        = 0
kRightMouseButton                       = 1

// Math constants
kEpsilon                                = 0.0001

// Minimum player velocity for network performance and ease of debugging
kMinimumPlayerVelocity                  = .05