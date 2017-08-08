module Services.DungeonGeneration exposing (..)
import Constants.Map exposing (defaultMap, blankMap)

type DungeonGenerator = ConstantGenerator
  | RogueGenerator Int Int


generatorToCharList: DungeonGenerator -> List Char
generatorToCharList generator =
  case generator of
    ConstantGenerator ->
      String.toList defaultMap
    RogueGenerator width height ->
      blankMap (width * height)
      |> String.toList
