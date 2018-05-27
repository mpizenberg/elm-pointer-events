port module Main exposing (..)

import Browser
import Events.Extra.Drag as Drag
import Events.Extra.Mouse as Mouse
import Html exposing (Attribute, Html, div, p, text)
import Html.Events
import Json.Decode as Decode exposing (Decoder, Value)


main : Program () Model Msg
main =
    Browser.embed
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
    | PortEventMsg String Value


type alias PortEvent =
    { name : String
    , value : Value
    }


port portEvent : PortEvent -> Cmd msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        DragEventMsg event ->
            ( Just event, Cmd.none )

        PortEventMsg event value ->
            ( model, portEvent { name = event, value = value } )



-- View


view : Model -> Html Msg
view model =
    div
        -- Prevent any kind of drop outside of dropable area.
        -- It is doing inside a port: event.dataTransfer.dropEffect = 'none'
        -- to change the cursor and prevent the drop event from happening.
        [ portEventDecoderOn "dragover" ]
        [ p
            -- Dropable area (grayed in css)
            [ Drag.onOver (DragEventMsg << Over << withoutRawData)
            , Drag.onDrop (DragEventMsg << Drop << withoutRawData)
            , Drag.onLeave (always <| DragEventMsg Leave)
            ]
            [ text <| Debug.toString model ]
        ]


portEventDecoderOn : String -> Attribute Msg
portEventDecoderOn event =
    Html.Events.preventDefaultOn event (Decode.map (\v -> ( PortEventMsg event v, True )) Decode.value)


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
