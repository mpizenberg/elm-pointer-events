-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this
-- file, You can obtain one at http://mozilla.org/MPL/2.0/


module Html.Events.Extra.Touch
    exposing
        ( Event
        , Keys
        , Touch
        , eventDecoder
        , onCancel
        , onEnd
        , onMove
        , onStart
        , onWithOptions
        , touchDecoder
        , touchListDecoder
        )

{-| Handling touch events.

@docs Event, Keys, Touch


# Touch Events

@docs onStart, onMove, onEnd, onCancel


# Advanced Usage

@docs onWithOptions, eventDecoder, touchDecoder, touchListDecoder

-}

import Html
import Html.Events
import Internal.Decode
import Json.Decode as Decode exposing (Decoder)


{-| Type that get returned by a browser touch event.
Its purpose is to provide all useful properties of JavaScript [TouchEvent]
in the context of the elm programming language.

This event contains key modifiers that may have been pressed during touch event,
and lists of Touch objects corresponding to JavaScript [Touch] objects.

  - `changedTouches`: the Touch objects representing individual points
    of contact whose states changed between the previous event and this one.
  - `targetTouches`: the Touch objects that are both currently in contact with
    the touch surface and were also started on the same element that is the event target.
  - `touches`: the Touch objects representing all current points of contact
    with the surface, regardless of target or changed status.

[TouchEvent]: https://developer.mozilla.org/en-US/docs/Web/API/TouchEvent
[Touch]: https://developer.mozilla.org/en-US/docs/Web/API/Touch

-}
type alias Event =
    { keys : Keys
    , changedTouches : List Touch
    , targetTouches : List Touch
    , touches : List Touch
    }


{-| Keys modifiers pressed during the event.
Checking if the ctrl key was pressed when the event triggered is as easy as:

    isCtrlKeyPressed : Touch.Event -> Bool
    isCtrlKeyPressed touchEvent =
        touchEvent.keys.ctrl

Beware that it may not be working on some platforms, returning always false.

-}
type alias Keys =
    { alt : Bool
    , ctrl : Bool
    , shift : Bool
    }


{-| A Touch object.
It has a unique identifier, kept from start to end of a touch interaction.
Client, page, and screen positions are provided for API completeness,
however, you shall only need to use the `clientPos` property.
For example, to get the coordinates of a touch event:

    touchCoordinates : Touch.Event -> ( Float, Float )
    touchCoordinates touchEvent =
        List.head touchEvent.changedTouches
            |> Maybe.map .clientPos
            |> Maybe.withDefault ( 0, 0 )

-}
type alias Touch =
    { identifier : Int
    , clientPos : ( Float, Float )
    , pagePos : ( Float, Float )
    , screenPos : ( Float, Float )
    }



-- EVENTS ############################################################


{-| Triggered on a "touchstart" event.
Let's say that we have a message type like this:

    type Msg
        = StartMsg ( Float, Float )
        | MoveMsg ( Float, Float )
        | EndMsg ( Float, Float )
        | CancelMsg ( Float, Float )

We can listen to `touchstart` events like follows:

    div
        [ Touch.onStart (\event -> StartMsg (touchCoordinates event)) ]
        [ text "touch here" ]

In a curried style, this can also be written:

    div
        [ Touch.onStart (StartMsg << touchCoordinates) ]
        [ text "touch here" ]

-}
onStart : (Event -> msg) -> Html.Attribute msg
onStart =
    onWithOptions "touchstart" stopOptions


{-| Triggered on a "touchmove" event.
Similarly than with `onStart`, we can write:

    div
        [ Touch.onMove (MoveMsg << touchCoordinates) ]
        [ text "touch here" ]

-}
onMove : (Event -> msg) -> Html.Attribute msg
onMove =
    onWithOptions "touchmove" stopOptions


{-| Triggered on a "touchend" event.
Similarly than with `onStart`, we can write:

    div
        [ Touch.onEnd (EndMsg << touchCoordinates) ]
        [ text "touch here" ]

-}
onEnd : (Event -> msg) -> Html.Attribute msg
onEnd =
    onWithOptions "touchend" stopOptions


{-| Triggered on a "touchcancel" event.
Similarly than with `onStart`, we can write:

    div
        [ Touch.onCancel (CancelMsg << touchCoordinates) ]
        [ text "touch here" ]

-}
onCancel : (Event -> msg) -> Html.Attribute msg
onCancel =
    onWithOptions "touchcancel" stopOptions


{-| Personalize the html event options.
If for some reason the default behavior of this package (stop propagation and prevent default)
does not fit your needs, you can change it like follows:

    onStart : (Touch.Event -> msg) -> Html.Attribute msg
    onStart =
        { stopPropagation = False, preventDefault = True }
            |> Touch.onWithOptions "touchstart"

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


{-| Touch event decoder.
The decoder is provided so that you can extend touch events if something you need is not provided.
-}
eventDecoder : Decoder Event
eventDecoder =
    Decode.map4 Event
        Internal.Decode.keys
        (Decode.field "changedTouches" <| touchListDecoder touchDecoder)
        (Decode.field "targetTouches" <| touchListDecoder touchDecoder)
        (Decode.field "touches" <| touchListDecoder touchDecoder)


{-| Touch object decoder.
The decoder is provided so that you can extend touch events if something you need is not provided.
-}
touchDecoder : Decoder Touch
touchDecoder =
    Decode.map4 Touch
        (Decode.field "identifier" Decode.int)
        Internal.Decode.clientPos
        Internal.Decode.pagePos
        Internal.Decode.screenPos


{-| Personalized TouchList decoder.
This decoder is provided so that you can extend touch events if something you need is not provided.
If for example, you need the [`Touch.force`][touch-force] property,
(which is not implemented by this package since not compatible with most browsers)
and can guaranty in your use case that it will be used with a compatible browser,
you could define:

    type alias MyTouchEvent =
        { changedTouches : TouchWithForce
        }

    type alias TouchWithForce =
        { touch : Touch
        , force : Float
        }

    decodeMyTouchEvent : Decoder MyTouchEvent
    decodeMyTouchEvent =
        Decode.map MyTouchEvent
            (Decode.field "changedTouches" (touchListDecoder decodeWithForce))

    decodeWithForce : Decoder TouchWithForce
    decodeWithForce =
        Decode.map2 TouchWithForce
            Touch.touchDecoder
            (Decode.field "force" Decode.float)

[touch-force]: https://developer.mozilla.org/en-US/docs/Web/API/Touch/force

-}
touchListDecoder : Decoder a -> Decoder (List a)
touchListDecoder =
    Internal.Decode.dynamicListOf
