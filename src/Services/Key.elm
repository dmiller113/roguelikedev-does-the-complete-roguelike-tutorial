module Services.Key exposing (
  KeyboardStatus, handleKeyCode,
  tickKeyboard, updateKeyboardStatus, Key(..))

import Keyboard exposing (KeyCode)


type Key = NoKey
  | Up
  | Right
  | Down
  | Left

type alias KeyStatus =
  { key: Key
  , ticks_active: Int
  }

type alias KeyboardStatus = List KeyStatus

handleKeyCode: KeyCode -> Key
handleKeyCode code =
  case code of
    37 -> -- Left
      Left
    38 -> -- Up
      Up
    39 -> -- Right
      Right
    40 -> -- Down
      Down
    _ ->
      NoKey

updateKeyboardStatus: KeyboardStatus -> KeyCode -> KeyboardStatus
updateKeyboardStatus kbstatus code =
  case handleKeyCode code of
    NoKey ->
      kbstatus
    keytype ->
      kbstatus ++ [{ key = keytype, ticks_active = 9 }]

tickKeyStatus: KeyStatus -> KeyStatus
tickKeyStatus key =
  { key | ticks_active = key.ticks_active - 1}


tickKeyboard: KeyboardStatus -> KeyboardStatus
tickKeyboard kb =
  List.filter (\i -> i.ticks_active > 0) <| List.map tickKeyStatus kb
