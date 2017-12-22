module Mouse
    exposing
        ( Event
        , Keys
        , eventDecoder
        , onClick
        , onDoubleClick
        , onDown
        , onEnter
        , onLeave
        , onMove
        , onOut
        , onOver
        , onUp
        , onWithOptions
        )

{-| Handling detailed mouse events.

@docs Event, Keys

@docs onDown, onMove, onUp, onWithOptions

@docs onClick, onDoubleClick

@docs onEnter, onOver, onLeave, onOut

@docs eventDecoder

-}

import Html exposing (Attribute)
import Html.Events as Events
import Json.Decode as Decode exposing (Decoder)


-- MODEL #############################################################


{-| Type that get returned by a mouse event.

TODO: add other mouse properties

  - buttons (not compatible mac / safari)
  - metaKey (not compatible linux)
  - movementX / movementY (not compatible safari)
  - region (not compatible)
  - x / y (is it useful?)

-}
type alias Event =
    { keys : Keys
    , button : Button
    , clientPos : ( Float, Float )
    , offsetPos : ( Float, Float )
    , pagePos : ( Float, Float )
    , screenPos : ( Float, Float )
    }


{-| The keys that might have been pressed during mouse event.
-}
type alias Keys =
    { alt : Bool, ctrl : Bool, shift : Bool }


{-| The button pressed for the event.
As such, it is not reliable for events such as
`mouseenter`, `mouseleave`, `mouseover`, `mouseout`, or `mousemove`.
-}
type Button
    = ErrorButton
    | MainButton
    | MiddleButton
    | SecondButton
    | BackButton
    | ForwardButton



-- EVENTS ############################################################


{-| Listen to `mousedown` events.
-}
onDown : (Event -> msg) -> Attribute msg
onDown =
    onWithOptions "mousedown" stopOptions


{-| Listen to `mousemove` events.
-}
onMove : (Event -> msg) -> Attribute msg
onMove =
    onWithOptions "mousemove" stopOptions


{-| Listen to `mouseup` events.
-}
onUp : (Event -> msg) -> Attribute msg
onUp =
    onWithOptions "mouseup" stopOptions


{-| Listen to `click` events.
-}
onClick : (Event -> msg) -> Attribute msg
onClick =
    onWithOptions "click" stopOptions


{-| Listen to `dblclick` events.
-}
onDoubleClick : (Event -> msg) -> Attribute msg
onDoubleClick =
    onWithOptions "dblclick" stopOptions


{-| Listen to `mouseenter` events.
-}
onEnter : (Event -> msg) -> Attribute msg
onEnter =
    onWithOptions "mouseenter" stopOptions


{-| Listen to `mouseover` events.
-}
onOver : (Event -> msg) -> Attribute msg
onOver =
    onWithOptions "mouseover" stopOptions


{-| Listen to `mouseleave` events.
-}
onLeave : (Event -> msg) -> Attribute msg
onLeave =
    onWithOptions "mouseleave" stopOptions


{-| Listen to `mouseout` events.
-}
onOut : (Event -> msg) -> Attribute msg
onOut =
    onWithOptions "mouseout" stopOptions


{-| Choose the mouse event to listen to, and specify the event options.
-}
onWithOptions : String -> Events.Options -> (Event -> msg) -> Attribute msg
onWithOptions event options tag =
    Decode.map tag eventDecoder
        |> Events.onWithOptions event options


stopOptions : Events.Options
stopOptions =
    { stopPropagation = True
    , preventDefault = True
    }



-- DECODERS ##########################################################


{-| An `Event` decoder for mouse events.
-}
eventDecoder : Decoder Event
eventDecoder =
    Decode.map6 Event
        keysDecoder
        buttonDecoder
        clientPosDecoder
        offsetPosDecoder
        pagePosDecoder
        screenPosDecoder


keysDecoder : Decoder Keys
keysDecoder =
    Decode.map3 Keys
        (Decode.field "altKey" Decode.bool)
        (Decode.field "ctrlKey" Decode.bool)
        (Decode.field "shiftKey" Decode.bool)


buttonDecoder : Decoder Button
buttonDecoder =
    Decode.map buttonFromId
        (Decode.field "button" Decode.int)


buttonFromId : Int -> Button
buttonFromId id =
    case id of
        0 ->
            MainButton

        1 ->
            MiddleButton

        2 ->
            SecondButton

        3 ->
            BackButton

        4 ->
            ForwardButton

        _ ->
            ErrorButton


clientPosDecoder : Decoder ( Float, Float )
clientPosDecoder =
    Decode.map2 (,)
        (Decode.field "clientX" Decode.float)
        (Decode.field "clientY" Decode.float)


offsetPosDecoder : Decoder ( Float, Float )
offsetPosDecoder =
    Decode.map2 (,)
        (Decode.field "offsetX" Decode.float)
        (Decode.field "offsetY" Decode.float)


pagePosDecoder : Decoder ( Float, Float )
pagePosDecoder =
    Decode.map2 (,)
        (Decode.field "pageX" Decode.float)
        (Decode.field "pageY" Decode.float)


screenPosDecoder : Decoder ( Float, Float )
screenPosDecoder =
    Decode.map2 (,)
        (Decode.field "screenX" Decode.float)
        (Decode.field "screenY" Decode.float)
