module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Pointer


main : Program Never PointerEvent PointerEvent
main =
    beginnerProgram
        { model = None
        , view = view
        , update = \event _ -> event
        }


type PointerEvent
    = None
    | Down Pointer.Event
    | Move Pointer.Event
    | Up Pointer.Event


view : PointerEvent -> Html PointerEvent
view event =
    div []
        [ p
            [ Pointer.onDown Down
            , Pointer.onMove Move
            , Pointer.onUp Up

            -- no touch-action (prevents scrolling and co.)
            , style [ ( "touch-action", "none" ) ]

            -- pointer capture hack to continue "globally" the event anywhere on document.
            , attribute "onpointerdown" "event.target.setPointerCapture(event.pointerId);"
            ]
            [ text <| toString event ]
        ]
