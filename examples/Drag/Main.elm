module Main exposing (..)

import Drag
import Html exposing (..)


main : Program Never DragEvent DragEvent
main =
    beginnerProgram
        { model = None
        , view = view
        , update = \event _ -> event
        }


type DragEvent
    = None
    | Over (List MetaData)
    | Leave
    | Drop (List MetaData)


type alias MetaData =
    { name : String
    , typeMIME : String
    , size : Int
    }


update : DragEvent -> DragEvent -> DragEvent
update event _ =
    event


view : DragEvent -> Html DragEvent
view event =
    div []
        [ p
            [ Drag.onOver (metadata >> Over)
            , Drag.onLeave (always Leave)
            , Drag.onDrop (metadata >> Drop)
            ]
            [ text <| toString event ]
        ]


metadata : Drag.Event -> List MetaData
metadata event =
    let
        extractMetaData : Drag.File -> MetaData
        extractMetaData file =
            { name = file.name
            , typeMIME = file.typeMIME
            , size = file.size
            }
    in
    List.map extractMetaData event.dataTransfer.files
