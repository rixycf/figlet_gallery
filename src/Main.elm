port module Main exposing (main)

import Browser
import Html exposing (..)
import Html.Attributes exposing (class, cols, rows, value)
import Html.Events exposing (onInput)



-- Model


type alias Model =
    { input : String, figletChars : String, figletFont : String }


init : () -> ( Model, Cmd Msg )
init _ =
    ( Model "" "" "", Cmd.none )



-- Updatee


type Msg
    = Input String
    | ReceiveFiglet String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Input input ->
            ( { model | input = input }, inputFigletJS input )

        ReceiveFiglet figlet ->
            ( { model | figletChars = figlet }, Cmd.none )



-- View


view : Model -> Html Msg
view model =
    div []
        [ Html.form []
            [ input [ value model.input, onInput Input ] []
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


port inputFigletJS : String -> Cmd msg


port receiveFiglet : (String -> msg) -> Sub msg


subscriptions : Model -> Sub Msg
subscriptions model =
    receiveFiglet ReceiveFiglet
