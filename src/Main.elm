port module Main exposing (main)

import Browser
import Html exposing (..)
import Html.Attributes exposing (class, cols, rows, value)
import Html.Events exposing (onInput)



-- Model


type alias Model =
    { figletOp : FigletOp, figletChars : String }


type alias FigletOp =
    { inputText : String
    , font : String
    , horizontalLayout : String
    , verticalLayout : String
    }


initFigletOp : FigletOp
initFigletOp =
    FigletOp "" "Ghost" "dafault" "dafault"


init : () -> ( Model, Cmd Msg )
init _ =
    ( Model initFigletOp "", Cmd.none )



-- Updatee


type Msg
    = Input String
    | ReceiveFiglet String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Input input ->
            let
                figOp =
                    model.figletOp

                newFigOp =
                    { figOp | inputText = input }
            in
            ( { model | figletOp = newFigOp }, inputFigletJS newFigOp )

        ReceiveFiglet figlet ->
            ( { model | figletChars = figlet }, Cmd.none )



-- View


view : Model -> Html Msg
view model =
    div []
        [ Html.form []
            [ input [ value model.figletOp.inputText, onInput Input ] []
            ]
        , div [ class "textarea" ] [ textarea [ rows 30, cols 100 ] [ text model.figletChars ] ]
        ]


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }



-- Port


port inputFigletJS : FigletOp -> Cmd msg


port receiveFiglet : (String -> msg) -> Sub msg


subscriptions : Model -> Sub Msg
subscriptions model =
    receiveFiglet ReceiveFiglet



-- Internal
