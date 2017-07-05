port module CharonGame exposing (..)
import Html exposing (Html, div)
import Time exposing (Time, millisecond)
import Keyboard exposing (KeyCode, downs)
import Char exposing (fromCode)
import String exposing (fromChar)
import Dict exposing (Dict)
import Models.Actor exposing (Actor)
import Services.Component exposing (Component(..))
import Models.Position exposing (updatePosition, extractPosition)
import Services.Key exposing (Key(..), handleKeyCode)
import Models.ComponentStateTypes exposing (Position, DrawInfo, Symbol)
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
  , positions: Dict Int Position
  , drawables: Dict Int DrawInfo
  }


initialPos: Position
initialPos = { x = 40, y = 13 }

initialSymbol: Symbol
initialSymbol = '@'

initialDrawInfo: DrawInfo
initialDrawInfo =
  { position = initialPos
  , symbol = initialSymbol
  }

initialPosDict: Dict Int Position
initialPosDict = Dict.singleton 0 initialPos

initialDrawDict: Dict Int DrawInfo
initialDrawDict = Dict.singleton 0 initialDrawInfo

initialKey: Key
initialKey = NoKey

init: (Model, Cmd Msg)
init = (
  { actor = {id = 0, name="Player"}
  , key = initialKey
  , positions = initialPosDict
  , drawables = initialDrawDict
  }
  , render (initialPos, String.fromChar initialSymbol)
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
        di = Maybe.withDefault initialDrawInfo <| Dict.get model.actor.id model.drawables
      in
        ({ model | key = NoKey }, render (di.position, String.fromChar di.symbol))
    KeyDown code ->
      let
        key = handleKeyCode code
        di = Maybe.withDefault initialDrawInfo <|
          Dict.get model.actor.id model.drawables
        symbol = di.symbol
        pos = (updatePosition <| extractPosition <|
          Dict.get model.actor.id model.positions) key
        newPositions = Dict.singleton model.actor.id pos
        newDrawables = Dict.singleton model.actor.id { position = pos, symbol = symbol }
      in
        ( { model | key = key, positions = newPositions, drawables = newDrawables }, Cmd.none)


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
