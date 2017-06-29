port module CharonGame exposing (..)
import Html exposing (Html, div)
import Time exposing (Time, millisecond)
import Keyboard exposing (KeyCode, downs)
import Char exposing (fromCode)
import String exposing (fromChar)
import Models.Actor exposing (Actor)
import Services.Component exposing (Component(..), updateComponents)
import Models.Position exposing (updatePosition,
                                 extractPosition, isPositionComponent)
import Services.Key exposing (Key(..), handleKeyCode)
import Models.ComponentStateTypes exposing (Position)
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
  , key: Key
  }

initialPos: Component
initialPos = PositionComponent { x = 40, y = 13 } updatePosition

initialKey: Key
initialKey = NoKey

init: (Model, Cmd Msg)
init = (
  { actor = {id = 0, name="Player", components=[initialPos]}
  , key = initialKey
  }
  , render ({ x = 40, y = 13 }, "@")
  )


-- Updates
type Msg = Reset
  | Tick Time
  | KeyDown KeyCode


update: Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Reset ->
      init
    Tick newTime ->
      let
        posC = List.head <|
          List.filter isPositionComponent model.actor.components
        pos = extractPosition posC
      in
        ({ model | key = NoKey }, render (pos, "@"))
    KeyDown code ->
      let
        key = handleKeyCode code
        actor = model.actor
        newActor = { actor | components = updateComponents key actor.components }
      in
        ( { model | actor = newActor, key = key }, Cmd.none)


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
    ]


-- Ports
port render: (Position, String) -> Cmd msg
