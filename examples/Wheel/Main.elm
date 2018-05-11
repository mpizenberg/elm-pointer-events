module Main exposing (..)

import Browser
import Html exposing (..)
import Wheel


main : Program () WheelEvent WheelEvent
main =
    Browser.sandbox
        { init = None
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
        [ text <| Debug.toString event ]
