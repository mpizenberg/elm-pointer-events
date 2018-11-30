module Main exposing (DragEvent(..), MetaData, WithoutRawData, extractMetadata, fileDropConfig, main, view, withoutRawData)

import Browser
import File exposing (File)
import Html exposing (Html, div, p, text)
import Html.Events.Extra.Drag as Drag
import Html.Events.Extra.Mouse as Mouse


main : Program () DragEvent DragEvent
main =
    Browser.sandbox
        { init = None
        , view = view
        , update = \event _ -> event
        }


type DragEvent
    = None
    | Over WithoutRawData
    | Drop WithoutRawData
    | Enter WithoutRawData
    | Leave WithoutRawData


type alias WithoutRawData =
    { mouseEvent : Mouse.Event
    , metadata : List MetaData
    }


type alias MetaData =
    { name : String
    , mimeType : String
    , size : Int
    }



-- View


view : DragEvent -> Html DragEvent
view model =
    div []
        -- Dropable area (grayed in css)
        [ p (Drag.onFileFromOS fileDropConfig) [ text <| Debug.toString model ] ]


fileDropConfig : Drag.FileDropConfig DragEvent
fileDropConfig =
    { onOver = Over << withoutRawData
    , onDrop = Drop << withoutRawData
    , onEnter = Just (Enter << withoutRawData)
    , onLeave = Just (Leave << withoutRawData)
    }


withoutRawData : Drag.Event -> WithoutRawData
withoutRawData event =
    { mouseEvent = event.mouseEvent
    , metadata = List.map extractMetadata event.dataTransfer.files
    }


extractMetadata : File -> MetaData
extractMetadata file =
    { name = File.name file
    , mimeType = File.mime file
    , size = File.size file
    }
