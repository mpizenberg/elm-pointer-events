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


update : WheelEvent -> a -> WheelEvent
update event _ =
    event


view : WheelEvent -> Html WheelEvent
view event =
    div
        [ Wheel.onWheel Wheel ]
        [ text <| toString event ]
