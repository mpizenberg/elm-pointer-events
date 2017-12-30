module Drag
    exposing
        ( DataTransfer
        , Event
        , File
        , onDrag
        , onDrop
        , onEnd
        , onEnter
        , onLeave
        , onOver
        , onStart
        )

import Html
import Html.Events
import Internal.Decode
import Json.Decode as Decode exposing (Decoder)


type alias Event =
    { dataTransfer : DataTransfer
    }


type alias DataTransfer =
    { files : List File
    }


type alias File =
    -- no support of lastModified in Safari
    { name : String
    , typeMIME : String
    , size : Int
    , data : Decode.Value
    }



-- EVENTS ############################################################


{-| Avoid, can be pretty expensive in resources.
-}
onDrag : (Event -> msg) -> Html.Attribute msg
onDrag =
    onWithOptions "drag" stopOptions


{-| Avoid, bug of target pointing to itself.
-}
onEnter : (Event -> msg) -> Html.Attribute msg
onEnter =
    onWithOptions "dragenter" stopOptions


onStart : (Event -> msg) -> Html.Attribute msg
onStart =
    onWithOptions "dragstart" stopOptions


onOver : (Event -> msg) -> Html.Attribute msg
onOver =
    onWithOptions "dragover" stopOptions


onDrop : (Event -> msg) -> Html.Attribute msg
onDrop =
    onWithOptions "drop" stopOptions


onLeave : (Event -> msg) -> Html.Attribute msg
onLeave =
    onWithOptions "dragleave" stopOptions


onEnd : (Event -> msg) -> Html.Attribute msg
onEnd =
    onWithOptions "dragend" stopOptions


onWithOptions : String -> Html.Events.Options -> (Event -> msg) -> Html.Attribute msg
onWithOptions event options tag =
    Decode.map tag eventDecoder
        |> Html.Events.onWithOptions event options


stopOptions : Html.Events.Options
stopOptions =
    { preventDefault = True
    , stopPropagation = True
    }



-- DECODERS ##########################################################


eventDecoder : Decoder Event
eventDecoder =
    fileListDecoder fileDecoder
        |> Decode.field "files"
        |> Decode.map DataTransfer
        |> Decode.field "dataTransfer"
        |> Decode.map Event


fileDecoder : Decoder File
fileDecoder =
    Decode.map4 File
        (Decode.field "name" Decode.string)
        (Decode.field "type" Decode.string)
        (Decode.field "size" Decode.int)
        Decode.value


fileListDecoder : Decoder a -> Decoder (List a)
fileListDecoder specialFileDecoder =
    let
        decodeNbFiles nbFiles =
            List.range 0 (nbFiles - 1)
                |> List.map decodeOneFile
                |> Internal.Decode.all

        decodeOneFile n =
            Decode.field (toString n) specialFileDecoder
    in
    Decode.field "length" Decode.int
        |> Decode.andThen decodeNbFiles
