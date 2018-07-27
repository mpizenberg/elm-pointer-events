module Main exposing (..)

import Browser
import Html exposing (Html, div, p, text)
import Html.Attributes exposing (style)
import Html.Events.Extra.Touch as Touch


main : Program () TouchEvent TouchEvent
main =
    Browser.sandbox
        { init = None
        , view = view
        , update = always
        }


type TouchEvent
    = None
    | Start Touch.Event
    | Move Touch.Event
    | End Touch.Event
    | Cancel Touch.Event


view : TouchEvent -> Html TouchEvent
view event =
    div []
        [ p
            [ Touch.onStart Start
            , Touch.onMove Move
            , Touch.onEnd End
            , Touch.onCancel Cancel

            -- no touch-action
            , style "touch-action" "none"
            ]
            [ text <| Debug.toString event ]
        ]
