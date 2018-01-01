module Drag
    exposing
        ( DataTransfer
        , Event
        , File
        , dataTransferDecoder
        , eventDecoder
        , fileDecoder
        , fileListDecoder
          -- , onDrag
        , onDrop
          -- , onEnd
          -- , onEnter
        , onLeave
        , onOver
          -- , onStart
        , onWithOptions
        )

{-| Handling drag events.
Due to the limitation of not being able to call JavaScript functions
directly in elm, full drag and drop API cannot be supported.

However, most of the time we just need to be able to drop some files
from the file system to the web page.
By providing the `dragover`, and `drop` events,
this module enables such use case.
Of course, the file retrieved in the form of a
`Json.Decode.Value` would still have to be
sent through ports if further processing is needed
that cannot be done directly using the `Value`.

@docs Event, DataTransfer, File


# Drag Events

@docs onOver, onDrop, onLeave


# Advanced Usage

@docs onWithOptions

@docs eventDecoder, dataTransferDecoder, fileListDecoder, fileDecoder

-}

import Html
import Html.Events
import Internal.Decode
import Json.Decode as Decode exposing (Decoder)
import Mouse


{-| Type that get returned by a browser drag event.
It corresponds to a JavaScript [DragEvent].

Since a `DragEvent` inherits from `MouseEvent`,
all mouse event related properties are provided in the
`mouseEvent` attribute of type `Mouse.Event`.
Please refer to the `Mouse` module for more information on this value.

[DragEvent]: https://developer.mozilla.org/en-US/docs/Web/API/DragEvent

-}
type alias Event =
    { dataTransfer : DataTransfer
    , mouseEvent : Mouse.Event
    }


{-| Hold the data being dragged during a drag and drop operation.
This corresponds to JavaScript [DataTransfer].

The `files` attribute holds the list of files being dragged.

The `types` attribute contains a list of strings providing
the different formats of objects being dragged.

The `dropEffect` attribute provides feedback on the selected effect
for the current drag and drop operation. It can be one of:

  - `"none"`: the item may not be dropped
  - `"copy"`: a copy of the source item is made at the new location
  - `"move"`: the item is moved to a new location
  - `"link"`: a link to the source is somehow established at the new location

Beware that contrary to JavaScript, you have no way of modifying
`dropEffect` in elm. This is provided purely for information as read only,
like any other elm value.

The `effectAllowed` property is not provided since it has
no use in the context of elm.

The `items` property is not provided by lack of compatibility.

[DataTransfer]: https://developer.mozilla.org/en-US/docs/Web/API/DataTransfer

-}
type alias DataTransfer =
    { files : List File
    , types : List String
    , dropEffect : String
    }


{-| A file object is a specific kind of blob.
Its raw JavaScript value is hold in the `data` attribute
in the form of a `Json.Decode.Value`.
This corresponds to a JavaScript [`File`][jsFile]

  - `name`: name of the file, without the path for security reasons
  - `typeMIME`: [MIME] type of the file
  - `size`: size of the file in bytes

_Remark: providing these properties as attributes in an elm record
is the easiest way of bringing this `File` API to elm.
Of course if at some point the `File` API is supported in elm,
this would be changed to the supported version._

[jsFile]: https://developer.mozilla.org/en-US/docs/Web/API/File
[MIME]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Basics_of_HTTP/MIME_types

-}
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


{-| Listen to `dragover` events.
-}
onOver : (Event -> msg) -> Html.Attribute msg
onOver =
    onWithOptions "dragover" stopOptions


{-| Listen to `drop` events.
-}
onDrop : (Event -> msg) -> Html.Attribute msg
onDrop =
    onWithOptions "drop" stopOptions


{-| Listen to `dragleave` events.
-}
onLeave : (Event -> msg) -> Html.Attribute msg
onLeave =
    onWithOptions "dragleave" stopOptions


onEnd : (Event -> msg) -> Html.Attribute msg
onEnd =
    onWithOptions "dragend" stopOptions


{-| Personalize your drag events with chosen html options.
-}
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


{-| `Drag.Event` default decoder.
It is provided in case you would like to extend it.
-}
eventDecoder : Decoder Event
eventDecoder =
    Decode.map2 Event
        (Decode.field "dataTransfer" dataTransferDecoder)
        Mouse.eventDecoder


{-| `DataTransfer` decoder.
It is provided in case you would like to extend it.
-}
dataTransferDecoder : Decoder DataTransfer
dataTransferDecoder =
    Decode.map3 DataTransfer
        (Decode.field "files" <| fileListDecoder fileDecoder)
        (Decode.field "types" <| Decode.list Decode.string)
        (Decode.field "dropEffect" Decode.string)


{-| Turn a personalized file decoder into a `List` decoder.
-}
fileListDecoder : Decoder a -> Decoder (List a)
fileListDecoder =
    Internal.Decode.dynamicListOf


{-| `File` decoder.
It is provided in case you would like to extend it.
-}
fileDecoder : Decoder File
fileDecoder =
    Decode.map4 File
        (Decode.field "name" Decode.string)
        (Decode.field "type" Decode.string)
        (Decode.field "size" Decode.int)
        Decode.value
