module Main exposing (..)

import Drag
import Html exposing (..)
import Html.Attributes exposing (..)


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


view : DragEvent -> Html DragEvent
view event =
    div
        -- Prevent any kind of drop outside of dropable area.
        -- It changes the cursor and prevent the drop event from happening
        [ attribute "ondragover" "event.dataTransfer.dropEffect = 'none'" ]
        [ p
            -- Dropable area
            [ Drag.onOver (Over << metadata)
            , Drag.onDrop (Drop << metadata)
            , Drag.onLeave (always Leave)
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
