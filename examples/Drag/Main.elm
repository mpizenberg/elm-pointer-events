module Main exposing (..)

import Drag
import Html exposing (..)
import Html.Attributes exposing (..)
import Mouse


main : Program Never DragEvent DragEvent
main =
    beginnerProgram
        { model = None
        , view = view
        , update = \event _ -> event
        }


type DragEvent
    = None
    | Over WithoutRawData
    | Leave
    | Drop WithoutRawData


type alias WithoutRawData =
    { mouseEvent : Mouse.Event
    , metadata : List MetaData
    }


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
        [ attribute "ondragover" "event.dataTransfer.dropEffect = 'none'; event.preventDefault();" ]
        [ p
            -- Dropable area
            [ Drag.onOver (Over << withoutRawData)
            , Drag.onDrop (Drop << withoutRawData)
            , Drag.onLeave (always Leave)
            ]
            [ text <| toString event ]
        ]


withoutRawData : Drag.Event -> WithoutRawData
withoutRawData event =
    { mouseEvent = event.mouseEvent
    , metadata = List.map extractMetadata event.dataTransfer.files
    }


extractMetadata : Drag.File -> MetaData
extractMetadata file =
    { name = file.name
    , typeMIME = file.typeMIME
    , size = file.size
    }
