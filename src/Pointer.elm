module Pointer
    exposing
        ( Event
        , eventDecoder
        , onDown
        , onMove
        , onUp
        , onWithOptions
        )

{-| Handling pointer events.


# Simple default usage

@docs Event, onDown, onMove, onUp


# Advanced personalized usage

@docs onWithOptions, eventDecoder

-}

import Html
import Html.Events
import Json.Decode as Decode exposing (Decoder)
import Mouse


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
    { isPrimary : Bool
    , pointerId : Int
    , pointer : Mouse.Event
    }



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
for compatibility with all major browsers.
It is also recommended that you deactivate `touch-action`
to disable browsers scroll behaviors.

    div
        [ Pointer.onDown ...
        , Pointer.onMove ...
        , Pointer.onUp ...

        -- no touch-action
        , Html.Attributes.style [ ( "touch-action", "none" ) ]

        -- use elm-pep polyfill
        , Html.Attributes.attribute "elm-pep" "true"
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


{-| Choose the pointer event to listen to, and specify the event options.

The `Options` type here is the standard [`Html.Events.Options`][html-options] type.
If for some reason the default behavior of this lib
(stop propagation and prevent default) does not fit your needs,
you can change it with for example:

    myOnDown : (Pointer.Event -> msg) -> Html.Attribute msg
    myOnDown =
        { stopPropagation = False, preventDefault = True }
            |> Pointer.onWithOptions "pointerdown"

You can also use `Pointer.onWithOptions` to listen to an event not
already covered by the functions in this package, like `pointercancel`:

    onCancel : (Pointer.Event -> msg) -> Html.Attribute msg
    onCancel =
        { stopPropagation = True, preventDefault = True }
            |> Pointer.onWithOptions "pointercancel"

BEWARE that the minimalist [elm-pep] polyfill may not support
this event. So if you rely on it for compatibility with browsers
not supporting pointer events, such event may never get triggered.
If such a need arises, please open an issue in [elm-pep].

[html-options]: http://package.elm-lang.org/packages/elm-lang/html/2.0.0/Html-Events#Options

-}
onWithOptions : String -> Html.Events.Options -> (Event -> msg) -> Html.Attribute msg
onWithOptions event options tag =
    Decode.map tag eventDecoder
        |> Html.Events.onWithOptions event options


stopOptions : Html.Events.Options
stopOptions =
    { stopPropagation = True
    , preventDefault = True
    }



-- DECODERS ##########################################################


{-| An Event decoder for pointer events.

Similarly than with the [`elm-mouse-events`][Mouse-Event] package,
The decoder is provided so that you can extend `Pointer.Event` with
specific properties you need. If you need for example the [`pressure`][pressure]
attribute of the pointer event, you could extend the present decoder like:

    type alias MyPointerEvent =
        { pointerEvent : Pointer.Event
        , pressure : Float
        }

    myEventDecoder : Decoder MyPointerEvent
    myEventDecoder =
        Decode.map2 MyPointerEvent
            Pointer.eventDecoder
            (Decode.field "pressure" Decode.float)

And use it like as follows:

    type Msg
        = PressureMsg Float

    div
        [ myOnDown (.pressure >> PressureMsg) ]
        [ text "click here to measure pressure" ]

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
this property. So if you rely on it for compatibility with browsers
not supporting pointer events, a decoder with an unsupported attribute
will silently fail.
If such a need arises, please open an issue in [elm-pep].

[Mouse-Event]: http://package.elm-lang.org/packages/mpizenberg/elm-mouse-events/latest/Mouse#Event
[pressure]: https://developer.mozilla.org/en-US/docs/Web/API/PointerEvent/pressure
[elm-pep]: https://github.com/mpizenberg/elm-pep

-}
eventDecoder : Decoder Event
eventDecoder =
    Decode.map3 Event
        (Decode.field "isPrimary" Decode.bool)
        (Decode.field "pointerId" Decode.int)
        Mouse.eventDecoder
