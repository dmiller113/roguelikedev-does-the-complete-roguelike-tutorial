module Lib.Utils exposing (..)
import String exposing(dropLeft, left)


insertAt: Int -> Int -> String -> String -> String
insertAt num pos newPart origStr =
  left pos origStr ++ newPart ++ dropLeft (pos + num) origStr
