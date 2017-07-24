port module CharonGame exposing (..)
import Html exposing (Html, div)
import Time exposing (Time, millisecond)
import Keyboard exposing (KeyCode, downs)
import Char exposing (fromCode)
import String exposing (fromChar)
import Dict exposing (Dict)
import Models.Entity exposing (Entity)
import Services.Component exposing (Component(..))
import Models.Position exposing (updatePosition, extractPosition)
import Services.Key exposing (Key(..), handleKeyCode)
import Models.ComponentStateTypes exposing (Position, DrawInfo, Symbol, Momentum, sortDrawInfo)
import Services.Movement exposing (updateMovables, moveActors)
import Services.Map exposing (Tile, initMap)
import Lib.Utils exposing (insertAt)
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
type ProgramState = Init
  | GamePlay
  | GameOver


type alias Components =
  { positions: Dict Int Position
  , drawables: Dict Int DrawInfo
  , movables: Dict Int Momentum
  }

type alias Model =
  { actor: Entity
  , key: Key
  , components: Components
  , currentMap: List Tile
  , nextAvailableId: Int
  , state: ProgramState
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

initialMomentum: Momentum
initialMomentum =
  { cX = 0
  , cY = 0
  }

initialPosDict: Dict Int Position
initialPosDict = Dict.singleton 0 initialPos

initialDrawDict: Dict Int DrawInfo
initialDrawDict = Dict.singleton 0 initialDrawInfo

initialMovables: Dict Int Momentum
initialMovables = Dict.singleton 0 initialMomentum

initialKey: Key
initialKey = NoKey

initialComponents: Components
initialComponents =
  { positions = initialPosDict
  , drawables = initialDrawDict
  , movables = initialMovables
  }

init: (Model, Cmd Msg)
init = (
  { actor = {id = 0, name="Player"}
  , key = initialKey
  , components = initialComponents
  , currentMap = []
  , nextAvailableId = 1
  , state = Init
  }
  , render <| renderView initialDrawDict
  )

mapDimensions: { x: Int, y: Int }
mapDimensions = {x = 80, y = 25}

-- Updates
type Msg = Reset
  | Tick Time
  | KeyDown KeyCode


update: Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case model.state of
    Init ->
      let
        (map, newPositions, newDrawables, newId) = initMap model.nextAvailableId (mapDimensions.x - 1) (mapDimensions.y - 1) model.components.positions model.components.drawables
        precomponents = model.components
        components = { precomponents | positions = newPositions
          , drawables = newDrawables
          }
      in
        ({ model | state = GamePlay
          , currentMap = map
          , nextAvailableId = newId
          , components = components
          }, Cmd.none)
    GamePlay ->
      gameplayUpdate msg model
    _ ->
      (model, Cmd.none)


gameplayUpdate: Msg -> Model -> (Model, Cmd Msg)
gameplayUpdate msg model =
  case msg of
    Reset ->
      init
    Tick newTime ->
      let
        di = Maybe.withDefault initialDrawInfo <| Dict.get model.actor.id model.components.drawables
      in
        ({ model | key = NoKey }, render <| renderView model.components.drawables)
    KeyDown code ->
      let
        key = handleKeyCode code
        movables = updateMovables model.components.movables key model.actor.id
        di = Maybe.withDefault initialDrawInfo <|
          Dict.get model.actor.id model.components.drawables

        newPositions = moveActors movables model.components.positions
        pos = Maybe.withDefault initialPos <| Dict.get model.actor.id newPositions
        newDrawables = (Dict.union <| Dict.singleton model.actor.id { di | position = pos }) model.components.drawables
        newComponents = { drawables = newDrawables, positions = newPositions, movables = model.components.movables}
      in
        ( { model | key = key, components = newComponents }, Cmd.none)

-- View
view: Model -> Html Msg
view model =
  div [] []


renderView: Dict Int DrawInfo -> String
renderView dictDi =
  let
    actorPos = .position <| Maybe.withDefault initialDrawInfo <| Dict.get 0 dictDi
    posInt = actorPos.x + actorPos.y * mapDimensions.x
  in
    Dict.remove 0 dictDi |>
    Dict.values |>
    sortDrawInfo |>
    List.map (\x -> fromChar x.symbol) |>
    List.foldl (++) "" |>
    insertAt posInt "@"


-- Subscriptions
subscriptions: Model -> Sub Msg
subscriptions model =
  Sub.batch
    [ Time.every (1000 / 24 * millisecond) Tick
    , downs KeyDown
    ]


-- Ports
port render: String -> Cmd msg
