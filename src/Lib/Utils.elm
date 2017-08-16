module Lib.Utils exposing (..)
import String exposing(dropLeft, left)
import Maybe exposing (Maybe(..))
import Array exposing (Array)
import Random

insertAt: Int -> Int -> String -> String -> String
insertAt num pos newPart origStr =
  left pos origStr ++ newPart ++ dropLeft (pos + num) origStr


getRandomItem: Random.Seed -> Array a -> (Maybe a, Random.Seed)
getRandomItem seed items =
  let
    (i, stepSeed) = flip Random.step seed <| Random.int 0 <| Array.length items
  in
    (Array.get i items, stepSeed)

mapWithRandom: (a -> b -> c) -> Random.Generator a -> Random.Seed -> List b -> (List c, Random.Seed)
mapWithRandom func gen seed items =
  let
    randomListGen = flip Random.list gen <| List.length items
    (randomsList, outerSeed) = Random.step randomListGen seed
  in
    (List.map2 func randomsList items, outerSeed)
