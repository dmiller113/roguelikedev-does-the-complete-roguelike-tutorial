port module CharonGame exposing (..)
import Html exposing (Html, div)
import Time exposing (Time, millisecond)
import Keyboard exposing (KeyCode, downs)
import Char exposing (fromCode)
import String exposing (fromChar)
import Dict exposing (Dict)
import Models.Entity exposing (Entity)
import Services.Component exposing (Components)
import Models.Position exposing (extractPosition)
import Services.Key exposing (Key(..), handleKeyCode)
import Models.ComponentStateTypes exposing (Position, DrawInfo, Symbol, Momentum, sortDrawInfo, drawInfoToString)
import Services.Movement exposing (updateMovables, moveActors)
import Services.Map exposing (Tile, initMap)
import Services.Physical exposing (PhysicalDict)
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


type alias Model =
  { actor: Entity
  , key: Key
  , components: Components
  , currentMap: List Tile
  , nextAvailableId: Int
  , state: ProgramState
  }


initialPos: Position
initialPos = { x = 41, y = 13 }

initialSymbol: Symbol
initialSymbol = '@'

initialDrawInfo: DrawInfo
initialDrawInfo =
  { position = initialPos
  , symbol = initialSymbol
  , foregroundColor = "#FFFFFF"
  , backgroundColor = "#232323"
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

initialPhysicals: PhysicalDict
initialPhysicals = Dict.singleton 0 { blocksMovement = True, blocksSight = False }

initialKey: Key
initialKey = NoKey

initialComponents: Components
initialComponents =
  { positions = initialPosDict
  , drawables = initialDrawDict
  , movables = initialMovables
  , physicals = initialPhysicals
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
        (map, newPositions, newDrawables, physicals, newId) = initMap model.nextAvailableId (mapDimensions.x - 1) (mapDimensions.y - 1) model.components.positions model.components.drawables
        precomponents = model.components
        components = { precomponents | positions = newPositions
          , drawables = newDrawables
          , physicals = physicals
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

        newPositions = moveActors movables model.components.physicals model.components.positions
        pos = Maybe.withDefault initialPos <| Dict.get model.actor.id newPositions
        newDrawables = (Dict.union <| Dict.singleton model.actor.id { di | position = pos }) model.components.drawables
        newComponents = { drawables = newDrawables
                        , positions = newPositions
                        , movables = model.components.movables
                        , physicals = model.components.physicals
                        }
      in
        ( { model | key = key, components = newComponents }, Cmd.none)

-- View
view: Model -> Html Msg
view model =
  div [] []


renderView: Dict Int DrawInfo -> String
renderView dictDi =
  let
    actorDI = Maybe.withDefault initialDrawInfo <| Dict.get 0 dictDi
    actorString = drawInfoToString actorDI
    actorPos = actorDI.position
    posInt = (actorPos.x + actorPos.y * mapDimensions.x) * 31
  in
    Dict.remove 0 dictDi |>
    Dict.values |>
    List.sortBy (.position >> .y) |>
    sortDrawInfo |>
    List.map drawInfoToString |>
    List.foldr (++) "" |>
    insertAt 31 posInt actorString

-- Subscriptions
subscriptions: Model -> Sub Msg
subscriptions model =
  Sub.batch
    [ Time.every (1000 / 24 * millisecond) Tick
    , downs KeyDown
    ]


-- Ports
port render: String -> Cmd msg
