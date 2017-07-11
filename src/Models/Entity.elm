module Models.Entity exposing (Entity)
import Services.Component exposing (Component(..))


type alias Entity =
  { id: Int
  , name: String
  }


-- Update stuff specific to Entities
