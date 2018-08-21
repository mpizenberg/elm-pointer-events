# Upgrade Notice

## From elm 0.18 to 0.19

### Coming from elm-mouse-events

Not many changes, you should get through without any major issue.
Most importantly:

* Mouse module is now under `Html.Events.Extra.Mouse` so changing your imports
  from `import Mouse` to `import Html.Events.Extra.Mouse as Mouse`
  should be sufficient most of the time.
* The `Mouse.Event` type now also has `button`, `pagePos` and `screenPos` attributes.
  Depending on your usage, it might imply no or minor changes.

### Coming from elm-touch-events

Many changes. Most importantly:

* The `Touch` module is now under `Html.Events.Extra.Touch`.
  You can change imports like so: `import Html.Events.Extra.Touch as Touch`.
* The modules `Touch`, `SingleTouch` and `MultiTouch` have been merged in one
  unique `Touch` module.
  It only features multitouch since getting a single touch event from
  the multitouch event is trivial with a function like `touchCoordinates`
  (see below).
* The type `Touch.Event` is not opaque anymore.
* Touches (changed, target, touches) are simple list instead of dicts now.
  Previous dict id are now in the `identifier : Int` field of a `Touch`.
* A `Touch` also provides page and screen positions in addition to client.
* Decoders are provided for advanced usage in case needed.

```elm
touchCoordinates : Touch.Event -> ( Float, Float )
touchCoordinates touchEvent =
    List.head touchEvent.changedTouches
        |> Maybe.map .clientPos
        |> Maybe.withDefault ( 0, 0 )
```
