module Main exposing (..)

import Browser
import Events.Extra.Drag as Drag
import Events.Extra.Mouse as Mouse
import Html exposing (Attribute, Html, div, p, text)


main : Program () Model Msg
main =
    Browser.element
        { init = always ( Nothing, Cmd.none )
        , view = view
        , update = update
        , subscriptions = always Sub.none
        }


type alias Model =
    Maybe DragEvent


type DragEvent
    = Over WithoutRawData
    | Leave
    | Drop WithoutRawData


type alias WithoutRawData =
    { mouseEvent : Mouse.Event
    , metadata : List MetaData
    }


type alias MetaData =
    { name : String
    , mimeType : String
    , size : Int
    }



-- Update


type Msg
    = DragEventMsg DragEvent


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        DragEventMsg event ->
            ( Just event, Cmd.none )



-- View


view : Model -> Html Msg
view model =
    div []
        [ p
            -- Dropable area (grayed in css)
            [ Drag.onOver (DragEventMsg << Over << withoutRawData)
            , Drag.onDrop (DragEventMsg << Drop << withoutRawData)
            , Drag.onLeave (always <| DragEventMsg Leave)
            ]
            [ text <| Debug.toString model ]
        ]


withoutRawData : Drag.Event -> WithoutRawData
withoutRawData event =
    { mouseEvent = event.mouseEvent
    , metadata = List.map extractMetadata event.dataTransfer.files
    }


extractMetadata : Drag.File -> MetaData
extractMetadata file =
    { name = file.name
    , mimeType = file.mimeType
    , size = file.size
    }
