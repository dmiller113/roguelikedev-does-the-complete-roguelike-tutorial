module Services.FoV exposing (..)
import Json.Encode exposing (encode, bool, object, Value)
import Dict exposing (Dict)
import Services.Physical exposing (PhysicalDict, PhysicalInfo)
import Models.Tiles exposing (TileInfo)
import Models.ComponentStateTypes exposing (Position, posToString)


produceFoVMap: PhysicalDict -> Dict Int Position -> String
produceFoVMap physicals positions =
  Dict.foldl (constructFoVEntry positions) [] physicals
  |> object |> encode 0


constructFoVEntry: Dict Int Position -> Int -> PhysicalInfo -> List (String, Value) -> List (String, Value)
constructFoVEntry positions eid physicalInfo acc =
  acc ++ [( Dict.get eid positions
  |> Maybe.withDefault { x = 0, y = 0 }
  |> posToString
  , bool <| not physicalInfo.blocksSight)]
