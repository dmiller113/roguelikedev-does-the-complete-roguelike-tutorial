port module CharonGame exposing (..)
import Html exposing (Html, div)
import Time exposing (Time, millisecond)
import Keyboard exposing (KeyCode, downs)
import Char exposing (fromCode)
import String exposing (fromChar)
import Models.Actor exposing (Actor, Component(..))
import Models.Position exposing (Position)
import Services.Key exposing (KeyboardStatus, tickKeyboard, updateKeyboardStatus)
-- Look into Keyboard.Extra


-- Main
main: Program Never Model Msg
main =
  Html.program
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }


-- Models
type alias Model =
  { actor: Actor
  , keys: KeyboardStatus
  }

initialPos: Component
initialPos = PositionComponent { x = 40, y = 13 }

initialKeys: KeyboardStatus
initialKeys = []

init: (Model, Cmd Msg)
init = (
  { actor = {id = 0, name="Player", components=[initialPos]}
  , keys = initialKeys
  }
  , render ({ x = 40, y = 13 }, "@")
  )


-- Updates
type Msg = Reset
  | Tick Time
  | KeyDown KeyCode
  | Turn KeyCode


update: Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Reset ->
      init
    Tick newTime ->
      ({ model | keys = tickKeyboard model.keys}, Cmd.none)
    KeyDown code ->
      let
        keys = updateKeyboardStatus model.keys code
      in
        ( { model | keys = keys }, render ({ x = 13, y = 15}, "@"))
    Turn _ ->
      let
        actor = model.actor
        newActor = actor
        keys = model.keys
      in
        ( { model | actor = newActor, keys = keys }, Cmd.none)


-- View
view: Model -> Html Msg
view model =
  div [] []

-- Subscriptions
subscriptions: Model -> Sub Msg
subscriptions model =
  Sub.batch
    [ Time.every (1000 / 24 * millisecond) Tick
    , downs KeyDown
    , downs Turn
    ]


-- Ports
port render: (Position, String) -> Cmd msg
