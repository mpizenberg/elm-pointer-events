-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this
-- file, You can obtain one at http://mozilla.org/MPL/2.0/


module Html.Events.Extra.Drag
    exposing
        ( DataTransfer
        , DraggedSourceConfig
        , DropEffect(..)
        , DropTargetConfig
        , EffectAllowed
        , Event
        , File
        , FileDropConfig
        , dataTransferDecoder
        , dropEffectToString
        , effectAllowedToString
        , eventDecoder
        , fileDecoder
        , fileListDecoder
        , onDropTarget
        , onFileFromOS
        , onSourceDrag
        , overPortData
        , startPortData
        )

{-| [HTML5 drag events][dragevent] is a quite complicated specification.
Mostly because it is very stateful, and many properties and functions
only make sense in one situation and not the rest.
For example, the `effectAllowed` property can only be set successfully
in a `dragstart` event, and setting it in another will be ignored.
Another example, the `dragend` should be attached to the object dragged,
while the `dragleave` should be attached to potential drop target.
One more, the `dragover` event listener is required on a drop target.
Otherwise the drop event will be cancelled.

Consequently, I've chosen to present a slightly opinionated API for drag events,
mitigating most of potential errors.
In case it prevents you from using it, please report your use case in
[an issue][issues]. I hope by also providing the decoders,
the library can still help you setup your own event listeners.

There seems to be two main use cases for drag events:

1.  Dropping files from the OS as resources to load.
2.  Drag and dropping DOM elements in page.

The rest of the documentation presents the API with those use cases in mind.

[dragevent]: https://developer.mozilla.org/en-US/docs/Web/API/DragEvent
[issues]: https://github.com/mpizenberg/elm-pointer-events/issues


# The Event Type

@docs Event, DataTransfer, File


# File Dropping

@docs onFileFromOS, FileDropConfig


# Drag and Drop

I encourage you to read [this blog post][disaster] before you take the decision
to use HTML5 drag and drop API instead of your own custom solution.

[disaster]: https://www.quirksmode.org/blog/archives/2009/09/the_html5_drag.html


## Managing the Dragged Item

@docs onSourceDrag, DraggedSourceConfig, EffectAllowed, startPortData, effectAllowedToString


## Managing a Drop Target

@docs onDropTarget, DropTargetConfig, DropEffect, overPortData, dropEffectToString


# Decoders for Advanced Usage

@docs eventDecoder, dataTransferDecoder, fileListDecoder, fileDecoder

-}

import Html
import Html.Attributes
import Html.Events
import Html.Events.Extra.Mouse as Mouse
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



-- FILE DROPPING #####################################################


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


{-| Configuration of a file drop target.

PS: `dragenter` and `dragleave` are kind of inconsistent since they
bubble up from children items (not consistently depending on borders in addition).
You should prefer to let them be `Nothing`, or to add the CSS property
`pointer-events: none` to all children.

-}
type alias FileDropConfig msg =
    { onOver : Event -> msg
    , onDrop : Event -> msg
    , onEnter : Maybe (Event -> msg)
    , onLeave : Maybe (Event -> msg)
    }



-- DRAG AND DROP #####################################################


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


{-| Put the effect allowed and the dragstart event
in a data format that can be sent through port.
-}
startPortData : EffectAllowed -> Value -> { effectAllowed : String, event : Value }
startPortData effectAllowed value =
    { effectAllowed = effectAllowedToString effectAllowed, event = value }


{-| Convert `EffectAllowed` into its String equivalent.
-}
effectAllowedToString : EffectAllowed -> String
effectAllowedToString eff =
    case ( eff.move, eff.copy, eff.link ) of
        ( False, False, False ) ->
            "none"

        ( True, False, False ) ->
            "move"

        ( False, True, False ) ->
            "copy"

        ( False, False, True ) ->
            "link"

        ( True, True, False ) ->
            "copyMove"

        ( True, False, True ) ->
            "linkMove"

        ( False, True, True ) ->
            "copyLink"

        ( True, True, True ) ->
            "all"


{-| Drag events listeners for the drop target element.

PS: `dragenter` and `dragleave` are kind of inconsistent since they
bubble up from children items (not consistently depending on borders in addition).
You should prefer to let them be `Nothing`, or to add the CSS property
`pointer-events: none` to all children.

-}
onDropTarget : DropTargetConfig msg -> List (Html.Attribute msg)
onDropTarget config =
    List.filterMap identity <|
        [ Just (valuePreventedOn "dragover" (config.onOver config.dropEffect))
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


{-| Put the drop effect and the dragover event
in a data format that can be sent through port.
-}
overPortData : DropEffect -> Value -> { dropEffect : String, event : Value }
overPortData dropEffect value =
    { dropEffect = dropEffectToString dropEffect, event = value }


{-| Convert a `DropEffect` into its string equivalent.
-}
dropEffectToString : DropEffect -> String
dropEffectToString dropEffect =
    case dropEffect of
        NoDropEffect ->
            "none"

        MoveOnDrop ->
            "move"

        CopyOnDrop ->
            "copy"

        LinkOnDrop ->
            "link"



-- EVENTS LISTENERS ##################################################


valueOn : String -> (Value -> msg) -> Html.Attribute msg
valueOn event tag =
    Decode.value
        |> Decode.map (\value -> { message = tag value, stopPropagation = True, preventDefault = False })
        |> Html.Events.custom event


valuePreventedOn : String -> (Value -> msg) -> Html.Attribute msg
valuePreventedOn event tag =
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
