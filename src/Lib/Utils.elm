module Lib.Utils exposing (..)
import String exposing(dropLeft, left)

insertAt: Int -> String -> String -> String
insertAt pos newPart origStr =
  left pos origStr ++ newPart ++ dropLeft (pos + 1) origStr
