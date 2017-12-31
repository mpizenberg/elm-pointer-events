module Main exposing (..)

import Html exposing (..)
import Wheel


main : Program Never WheelEvent WheelEvent
main =
    beginnerProgram
        { model = None
        , view = view
        , update = \event _ -> event
        }


type WheelEvent
    = None
    | Wheel Wheel.Event


view : WheelEvent -> Html WheelEvent
view event =
    div
        [ Wheel.onWheel Wheel ]
        [ text <| toString event ]
