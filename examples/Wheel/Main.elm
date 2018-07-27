module Main exposing (..)

import Browser
import Html exposing (Html, div, p, text)
import Html.Events.Extra.Wheel as Wheel


main : Program () WheelEvent WheelEvent
main =
    Browser.sandbox
        { init = None
        , view = view
        , update = always
        }


type WheelEvent
    = None
    | Wheel Wheel.Event


view : WheelEvent -> Html WheelEvent
view event =
    div []
        [ p
            [ Wheel.onWheel Wheel ]
            [ text <| Debug.toString event ]
        ]
