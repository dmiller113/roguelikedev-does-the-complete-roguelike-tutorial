port module CharonGame exposing (..)
import Html exposing (Html, div)
import Time exposing (Time, millisecond)
import Keyboard exposing (KeyCode, downs)
import Char exposing (fromCode)
import String exposing (fromChar)
import Dict exposing (Dict)
import Set exposing (Set)
import Random
import Models.Entity exposing (Entity)
import Services.Component exposing (Components)
import Models.Position exposing (extractPosition)
import Services.Key exposing (Key(..), handleKeyCode)
import Models.ComponentStateTypes exposing (Position, DrawInfo, Symbol, Momentum, sortDrawInfo, drawInfoToString, Coord)
import Services.Movement exposing (updateMovables, moveActors)
import Services.Map exposing (Tile, initMap)
import Services.Physical exposing (PhysicalDict, PhysicalInfo)
import Services.FoV exposing (produceFoVMap)
import Services.DungeonGeneration exposing (DungeonGenerator(..))
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
  , fov: Set Coord
  , explored: Set Coord
  , initialSeedValue: Int
  , currentSeed: Random.Seed
  }


initialPos: Position
initialPos = { x = 42, y = 13 }

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
  , fov = Set.empty
  , explored = Set.empty
  , initialSeedValue = 0
  , currentSeed = Random.initialSeed 0
  }
  , render <| renderView (Set.empty) (Set.empty) initialDrawDict
  )

mapDimensions: { x: Int, y: Int }
mapDimensions = {x = 80, y = 25}

-- Updates
type Msg = Reset
  | Tick Time
  | KeyDown KeyCode
  | FoVSub Coord


update: Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case model.state of
    Init ->
      let
        (map, newPositions, newDrawables, physicals, newId, seed) =
          initMap model.nextAvailableId (mapDimensions.x - 1) (mapDimensions.y - 1)
            model.components.positions model.components.drawables <| RogueGenerator 80 24 model.currentSeed
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
          , currentSeed = seed
          }, Cmd.batch [(createFov <| produceFoVMap physicals newPositions), computeFov {x = initialPos.x, y = initialPos.y, r = 10}] )
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
        ({ model | key = NoKey }, render <| renderView model.fov model.explored model.components.drawables)
    FoVSub fovInfo ->
      ({model | fov = Set.insert fovInfo model.fov, explored = Set.insert fovInfo model.explored}, Cmd.none)
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
        ( { model | key = key, components = newComponents, fov = Set.empty },  computeFov {x = pos.x, y = pos.y, r = 10} )

-- View
view: Model -> Html Msg
view model =
  div [] []


renderView: Set Coord -> Set Coord -> Dict Int DrawInfo -> String
renderView fov explored dictDi =
  let
    actorDI = Maybe.withDefault initialDrawInfo <| Dict.get 0 dictDi
    actorString = drawInfoToString fov explored actorDI
    actorPos = actorDI.position
    posInt = (actorPos.x + actorPos.y * mapDimensions.x) * 31
  in
    Dict.remove 0 dictDi |>
    Dict.values |>
    List.sortBy (.position >> .y) |>
    sortDrawInfo |>
    List.map (drawInfoToString fov explored) |>
    List.foldr (++) "" |>
    insertAt 31 posInt actorString

-- Subscriptions
subscriptions: Model -> Sub Msg
subscriptions model =
  Sub.batch
    [ Time.every (1000 / 24 * millisecond) Tick
    , downs KeyDown
    , getFov FoVSub
    ]


-- Ports
port render: String -> Cmd msg
port createFov: String -> Cmd msg
port computeFov: {x: Int, y: Int, r: Int} -> Cmd msg
port getFov: (Coord -> msg) -> Sub msg
