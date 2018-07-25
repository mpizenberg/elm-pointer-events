port module Main exposing (..)

import Browser
import Dict exposing (Dict)
import Events.Extra.Drag as Drag
import Html exposing (Html, div, h1, p, text)
import Html.Attributes exposing (class, id)
import Json.Decode as Decode exposing (Value)
import List


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = always Sub.none
        }


type alias Model =
    { dragAndDropStatus : DragAndDropStatus
    , tasks : Dict Int Task
    }


type DragAndDropStatus
    = NoDnD
    | Dragging Int


type Task
    = Task ProgressStatus String


type ProgressStatus
    = ToDo
    | Doing
    | Done


init : () -> ( Model, Cmd Msg )
init () =
    ( initialModel, Cmd.none )


initialModel : Model
initialModel =
    { dragAndDropStatus = NoDnD
    , tasks =
        Dict.fromList
            [ ( 1, Task ToDo "Prepare a cake" )
            , ( 2, Task ToDo "Go for a run" )
            ]
    }



-- Update


type Msg
    = DragStart Int Drag.EffectAllowed Value
    | DragEnd
    | DragOver Drag.DropEffect Value
    | Drop ProgressStatus


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( Debug.log "msg" msg, model.dragAndDropStatus ) of
        ( DragStart id _ _, _ ) ->
            ( { model | dragAndDropStatus = Dragging id }, Cmd.none )

        ( DragEnd, _ ) ->
            ( { model | dragAndDropStatus = NoDnD }, Cmd.none )

        ( DragOver _ _, _ ) ->
            ( model, Cmd.none )

        ( Drop status, Dragging id ) ->
            let
                newTasks =
                    Dict.update id (maybeSetStatus status) model.tasks
            in
            ( { model | tasks = newTasks }, Cmd.none )

        _ ->
            ( model, Cmd.none )


maybeSetStatus : ProgressStatus -> Maybe Task -> Maybe Task
maybeSetStatus status maybeTask =
    case maybeTask of
        Just (Task _ instruction) ->
            Just (Task status instruction)

        _ ->
            maybeTask



-- View


view : Model -> Html Msg
view model =
    div [ id "kanban" ]
        [ div
            (class "kanban-area" :: id "todo" :: Drag.onDropTarget (dropTargetConfig ToDo))
            (h1 [] [ text "To Do" ] :: viewTasks ToDo model)
        , div
            (class "kanban-area" :: id "doing" :: Drag.onDropTarget (dropTargetConfig Doing))
            (h1 [] [ text "Doing" ] :: viewTasks Doing model)
        , div
            (class "kanban-area" :: id "done" :: Drag.onDropTarget (dropTargetConfig Done))
            (h1 [] [ text "Done" ] :: viewTasks Done model)
        ]


dropTargetConfig : ProgressStatus -> Drag.DropTargetConfig Msg
dropTargetConfig status =
    { dropEffect = Drag.MoveOnDrop
    , onOver = DragOver
    , onDrop = always (Drop status)
    , onEnter = Nothing
    , onLeave = Nothing
    }


viewTasks : ProgressStatus -> Model -> List (Html Msg)
viewTasks status model =
    model.tasks
        |> Dict.filter (\_ task -> progressStatus task == status)
        |> Dict.toList
        |> List.map viewOneTask


progressStatus : Task -> ProgressStatus
progressStatus (Task status _) =
    status


viewOneTask : ( Int, Task ) -> Html Msg
viewOneTask ( id, Task status instruction ) =
    p (class "task" :: Drag.onSourceDrag (draggedSourceConfig id)) [ text instruction ]


draggedSourceConfig : Int -> Drag.DraggedSourceConfig Msg
draggedSourceConfig id =
    { effectAllowed = { move = True, copy = False, link = False }
    , onStart = DragStart id
    , onEnd = always DragEnd
    , onDrag = Nothing
    }
