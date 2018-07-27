-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this
-- file, You can obtain one at http://mozilla.org/MPL/2.0/


module Html.Events.Extra.Pointer
    exposing
        ( ContactDetails
        , DeviceType(..)
        , Event
        , eventDecoder
        , onCancel
        , onDown
        , onEnter
        , onLeave
        , onMove
        , onOut
        , onOver
        , onUp
        , onWithOptions
        )

{-| Handling pointer events.

@docs Event, DeviceType, ContactDetails


# Basic Usage

@docs onDown, onMove, onUp, onCancel, onOver, onEnter, onOut, onLeave


# Advanced Usage

@docs onWithOptions, eventDecoder

-}

import Html
import Html.Events
import Html.Events.Extra.Mouse as Mouse
import Json.Decode as Decode exposing (Decoder)



-- MODEL #############################################################


{-| Type that get returned by a pointer event.

Since the JS class [`PointerEvent`][PointerEvent] inherits from [`MouseEvent`][MouseEvent],
the `pointer` attribute here is of type [`Mouse.Event`][Mouse-Event].

So to get the relative (offset) position of a pointer event for example:

    relativePos : Pointer.Event -> ( Float, Float )
    relativePos event =
        event.pointer.offsetPos

And to know if the shift key was pressed:

    isShiftKeyPressed : Pointer.Event -> Bool
    isShiftKeyPressed event =
        event.pointer.key.shift

[PointerEvent]: https://developer.mozilla.org/en-US/docs/Web/API/PointerEvent
[MouseEvent]: https://developer.mozilla.org/en-US/docs/Web/API/MouseEvent
[Mouse-Event]: http://package.elm-lang.org/packages/mpizenberg/elm-mouse-events/latest/Mouse#Event

-}
type alias Event =
    { pointerType : DeviceType
    , pointer : Mouse.Event
    , pointerId : Int
    , isPrimary : Bool
    , contactDetails : ContactDetails
    }


{-| The type of device that generated the pointer event
-}
type DeviceType
    = MouseType
    | TouchType
    | PenType


{-| Details of the point of contact, for advanced use cases.
-}
type alias ContactDetails =
    { width : Float
    , height : Float
    , pressure : Float
    , tiltX : Float
    , tiltY : Float
    }


stringToPointerType : String -> DeviceType
stringToPointerType str =
    case str of
        "pen" ->
            PenType

        "touch" ->
            TouchType

        _ ->
            MouseType



-- EVENTS ############################################################


{-| Listen to `pointerdown` events.

Let's say that we have a message type like this:

    type Msg
        = DownMsg ( Float, Float )
        | MoveMsg ( Float, Float )
        | UpMsg ( Float, Float )

And we already have defined the `relativePos : Pointer.Event -> ( Float, Float )`
function (see [`Pointer.Event`](#Event) doc). Then we could listen to `pointerdown`
events with something like:

    div [ Pointer.onDown (relativePos >> DownMsg) ] [ text "click here" ]

However, since the [Pointer API][pointer-events]
is not well [supported by all browsers][caniuse-pointer],
I strongly recommend to use it in pair with the [elm-pep polyfill][elm-pep]
for compatibility with Safari and Firefox < 59.
It is also recommended that you deactivate `touch-action`
to disable browsers scroll behaviors.

    div
        [ Pointer.onDown ...
        , Pointer.onMove ...
        , Pointer.onUp ...

        -- no touch-action (prevent scroll etc.)
        , Html.Attributes.style [ ( "touch-action", "none" ) ]
        ]
        []

[pointer-events]: https://developer.mozilla.org/en-US/docs/Web/API/PointerEvent
[caniuse-pointer]: https://caniuse.com/#feat=pointer
[elm-pep]: https://github.com/mpizenberg/elm-pep

-}
onDown : (Event -> msg) -> Html.Attribute msg
onDown =
    onWithOptions "pointerdown" stopOptions


{-| Listen to `pointermove` events.

Similarly than with [`onDown`](#onDown), we can write something like:

    div [ Pointer.onMove (relativePos >> MoveMsg) ] [ text "move here" ]

-}
onMove : (Event -> msg) -> Html.Attribute msg
onMove =
    onWithOptions "pointermove" stopOptions


{-| Listen to `pointerup` events.

Similarly than with [`onDown`](#onDown), we can write something like:

    div [ Pointer.onUp (relativePos >> UpMsg) ] [ text "click here" ]

-}
onUp : (Event -> msg) -> Html.Attribute msg
onUp =
    onWithOptions "pointerup" stopOptions


{-| Listen to `pointercancel` events.

Similarly than with [`onDown`](#onDown), we can write something like:

    div [ Pointer.onCancel (relativePos >> UpMsg) ] [ text "move here" ]

-}
onCancel : (Event -> msg) -> Html.Attribute msg
onCancel =
    onWithOptions "pointercancel" stopOptions


{-| Listen to `pointerover` events.

Similarly than with [`onDown`](#onDown), we can write something like:

    div [ Pointer.onOver (relativePos >> UpMsg) ] [ text "move in here" ]

-}
onOver : (Event -> msg) -> Html.Attribute msg
onOver =
    onWithOptions "pointerover" stopOptions


{-| Listen to `pointerenter` events.

Similarly than with [`onDown`](#onDown), we can write something like:

    div [ Pointer.onEnter (relativePos >> UpMsg) ] [ text "move in here" ]

-}
onEnter : (Event -> msg) -> Html.Attribute msg
onEnter =
    onWithOptions "pointerenter" stopOptions


{-| Listen to `pointerout` events.

Similarly than with [`onDown`](#onDown), we can write something like:

    div [ Pointer.onOut (relativePos >> UpMsg) ] [ text "move out of here" ]

-}
onOut : (Event -> msg) -> Html.Attribute msg
onOut =
    onWithOptions "pointerout" stopOptions


{-| Listen to `pointerleave` events.

Similarly than with [`onDown`](#onDown), we can write something like:

    div [ Pointer.onLeave (relativePos >> UpMsg) ] [ text "move out of here" ]

-}
onLeave : (Event -> msg) -> Html.Attribute msg
onLeave =
    onWithOptions "pointerleave" stopOptions


{-| Choose the pointer event to listen to, and specify the event options.

If for some reason the default behavior of this lib
(stop propagation and prevent default) does not fit your needs,
you can change it with for example:

    myOnDown : (Pointer.Event -> msg) -> Html.Attribute msg
    myOnDown =
        { stopPropagation = False, preventDefault = True }
            |> Pointer.onWithOptions "pointerdown"

-}
onWithOptions : String -> EventOptions -> (Event -> msg) -> Html.Attribute msg
onWithOptions event options tag =
    eventDecoder
        |> Decode.map (\ev -> { message = tag ev, stopPropagation = options.stopPropagation, preventDefault = options.preventDefault })
        |> Html.Events.custom event


stopOptions : EventOptions
stopOptions =
    { stopPropagation = True
    , preventDefault = True
    }


{-| Options for the event.
-}
type alias EventOptions =
    { stopPropagation : Bool
    , preventDefault : Bool
    }



-- DECODERS ##########################################################


{-| An Event decoder for pointer events.

Similarly than with the `Mouse` module, the decoder is provided so that
you can extend `Pointer.Event` with specific properties you need.
If you need for example the [`tangentialPressure`][tangentialPressure]
attribute of the pointer event, you could extend the present decoder like:

    type alias MyPointerEvent =
        { pointerEvent : Pointer.Event
        , tangentialPressure : Float
        }

    myEventDecoder : Decoder MyPointerEvent
    myEventDecoder =
        Decode.map2 MyPointerEvent
            Pointer.eventDecoder
            (Decode.field "tangentialPressure" Decode.float)

And use it like as follows:

    type Msg
        = TangentialPressureMsg Float

    div
        [ myOnDown (.tangentialPressure >> TangentialPressureMsg) ]
        [ text "Use pen here to measure tangentialPressure" ]

    myOnDown : (MyPointerEvent -> msg) -> Html.Attribute msg
    myOnDown tag =
        Decode.map tag myEventDecoder
            |> Html.Events.onWithOptions "pointerdown" stopOptions

    stopOptions : Html.Events.Options
    stopOptions =
        { stopPropagation = True
        , preventDefault = True
        }

BEWARE that the minimalist [elm-pep] polyfill may not support
all properties. So if you rely on it for compatibility with browsers
not supporting pointer events, a decoder with an unsupported attribute
will silently fail.
If such a need arises, please open an issue in [elm-pep].

[tangentialPressure]: https://developer.mozilla.org/en-US/docs/Web/API/PointerEvent/tangentialPressure
[elm-pep]: https://github.com/mpizenberg/elm-pep

-}
eventDecoder : Decoder Event
eventDecoder =
    Decode.map5 Event
        (Decode.field "pointerType" pointerTypeDecoder)
        Mouse.eventDecoder
        (Decode.field "pointerId" Decode.int)
        (Decode.field "isPrimary" Decode.bool)
        contactDetailsDecoder


pointerTypeDecoder : Decoder DeviceType
pointerTypeDecoder =
    Decode.map stringToPointerType Decode.string


contactDetailsDecoder : Decoder ContactDetails
contactDetailsDecoder =
    Decode.map5 ContactDetails
        (Decode.field "width" Decode.float)
        (Decode.field "height" Decode.float)
        (Decode.field "pressure" Decode.float)
        (Decode.field "tiltX" Decode.float)
        (Decode.field "tiltY" Decode.float)
