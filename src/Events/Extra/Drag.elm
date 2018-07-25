-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this
-- file, You can obtain one at http://mozilla.org/MPL/2.0/


module Events.Extra.Drag
    exposing
        ( DataTransfer
        , Event
        , File
        , dataTransferDecoder
        , eventDecoder
        , fileDecoder
        , fileListDecoder
          -- , onDrag
          -- , onDrop
          -- , onEnd
          -- , onEnter
          -- , onLeave
          -- , onOver
          -- , onStart
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


# Advanced Usage

@docs eventDecoder, dataTransferDecoder, fileListDecoder, fileDecoder

-}

import Events.Extra.Mouse as Mouse
import Html
import Html.Attributes
import Html.Events
import Internal.Decode
import Json.Decode as Decode exposing (Decoder, Value)


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
  - `mimeType`: [MIME] type of the file
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
    , mimeType : String
    , size : Int
    , data : Decode.Value
    }



-- EVENTS ############################################################


{-| Configuration of a file drop target.
-}
type alias FileDropConfig msg =
    { onOver : Event -> msg
    , onDrop : Event -> msg
    , onEnter : Maybe (Event -> msg)
    , onLeave : Maybe (Event -> msg)
    }


{-| Events listeners for a file drop target element.

PS: incompatible with `onDropTarget` since both functions
use the same events listeners.
If you need to have a drop target working for both files and DOM elements,
you can directly use `onDropTarget`.

-}
onFileFromOS : FileDropConfig msg -> List (Html.Attribute msg)
onFileFromOS config =
    List.filterMap identity <|
        [ Just (on "dragover" config.onOver)
        , Just (on "drop" config.onDrop)
        , Maybe.map (on "dragenter") config.onEnter
        , Maybe.map (on "dragleave") config.onLeave
        ]


{-| Configuration of a drop target.
You should provide message taggers for `dragover` and `drop` events.
You can also provide message taggers for `dragenter` and `dragleave` events.
-}
type alias DropTargetConfig msg =
    { dropEffect : DropEffect
    , onOver : DropEffect -> Value -> msg
    , onDrop : Event -> msg
    , onEnter : Maybe (Event -> msg)
    , onLeave : Maybe (Event -> msg)
    }


{-| Drop effect as configured by the drop target.
This will change the visual aspect of the mouse icon.

If the drop target sets (via port on `dragover`) a drop effect
incompatible with the effects allowed for the dragged item,
the drop will not happen.

-}
type DropEffect
    = NoDropEffect
    | MoveOnDrop
    | CopyOnDrop
    | LinkOnDrop


{-| Drag events listeners for the drop target element.
-}
onDropTarget : DropTargetConfig msg -> List (Html.Attribute msg)
onDropTarget config =
    List.filterMap identity <|
        [ Just (valueOn "dragover" (config.onOver config.dropEffect))
        , Just (on "drop" config.onDrop)
        , Maybe.map (on "dragenter") config.onEnter
        , Maybe.map (on "dragleave") config.onLeave
        ]


{-| Configuration of a draggable element.
You should provide message taggers for `dragstart` and `dragend` events.
You can (but it is more compute-intensive) provide a message tagger for `drag` events.
-}
type alias DraggedSourceConfig msg =
    { effectAllowed : EffectAllowed
    , onStart : EffectAllowed -> Value -> msg
    , onEnd : Event -> msg
    , onDrag : Maybe (Event -> msg)
    }


{-| Drop effects allowed for this draggable element.
Set to `True` all effects allowed.
This is used in the port of the `dragstart` event.
-}
type alias EffectAllowed =
    { move : Bool
    , copy : Bool
    , link : Bool
    }


{-| Drag events listeners for the source dragged element.
-}
onSourceDrag : DraggedSourceConfig msg -> List (Html.Attribute msg)
onSourceDrag config =
    List.filterMap identity <|
        [ Just (Html.Attributes.draggable "true")
        , Just (valueOn "dragstart" (config.onStart config.effectAllowed))
        , Just (on "dragend" config.onEnd)
        , Maybe.map (on "drag") config.onDrag
        ]


valueOn : String -> (Value -> msg) -> Html.Attribute msg
valueOn event tag =
    Decode.value
        |> Decode.map (\value -> { message = tag value, stopPropagation = True, preventDefault = True })
        |> Html.Events.custom event


on : String -> (Event -> msg) -> Html.Attribute msg
on event tag =
    eventDecoder
        |> Decode.map (\ev -> { message = tag ev, stopPropagation = True, preventDefault = True })
        |> Html.Events.custom event



-- DECODERS ##########################################################


{-| `Drag.Event` default decoder.
It is provided in case you would like to reuse/extend it.
-}
eventDecoder : Decoder Event
eventDecoder =
    Decode.map2 Event
        (Decode.field "dataTransfer" dataTransferDecoder)
        Mouse.eventDecoder


{-| `DataTransfer` decoder.
It is provided in case you would like to reuse/extend it.
-}
dataTransferDecoder : Decoder DataTransfer
dataTransferDecoder =
    Decode.map3 DataTransfer
        (Decode.field "files" <| fileListDecoder fileDecoder)
        (Decode.field "types" <| Decode.list Decode.string)
        (Decode.field "dropEffect" Decode.string)


{-| Transform a personalized `File` decoder into a `List File` decoder
since `Json.Decode.list` does not work for the list of files.
-}
fileListDecoder : Decoder a -> Decoder (List a)
fileListDecoder =
    Internal.Decode.dynamicListOf


{-| `File` decoder.
It is provided in case you would like to reuse/extend it.
-}
fileDecoder : Decoder File
fileDecoder =
    Decode.map4 File
        (Decode.field "name" Decode.string)
        (Decode.field "type" Decode.string)
        (Decode.field "size" Decode.int)
        Decode.value
