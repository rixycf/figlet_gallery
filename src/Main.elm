port module Main exposing (main)

import Browser
import FontList
import GeneratedFigList
import Html exposing (..)
import Html.Attributes exposing (class, cols, placeholder, readonly, rows, selected, type_, value)
import Html.Events as Events exposing (onInput)
import Json.Decode as Json



-- Model


type alias Model =
    { figletOp : FigletOp, figletChars : String, fontList : List String, figList : List String }


type alias FigletOp =
    { inputText : String
    , font : String
    , horizontalLayout : String
    , verticalLayout : String
    }


initFigletOp : FigletOp
initFigletOp =
    FigletOp "Welcome!" "ANSI Shadow" "dafault" "dafault"


initFigletChars : String
initFigletChars =
    """
██╗    ██╗███████╗██╗      ██████╗ ██████╗ ███╗   ███╗███████╗
██║    ██║██╔════╝██║     ██╔════╝██╔═══██╗████╗ ████║██╔════╝
██║ █╗ ██║█████╗  ██║     ██║     ██║   ██║██╔████╔██║█████╗  
██║███╗██║██╔══╝  ██║     ██║     ██║   ██║██║╚██╔╝██║██╔══╝  
╚███╔███╔╝███████╗███████╗╚██████╗╚██████╔╝██║ ╚═╝ ██║███████╗
 ╚══╝╚══╝ ╚══════╝╚══════╝ ╚═════╝ ╚═════╝ ╚═╝     ╚═╝╚══════╝
                                                              
    """


init : () -> ( Model, Cmd Msg )
init _ =
    ( Model initFigletOp initFigletChars FontList.fontList GeneratedFigList.generatedFigList, Cmd.none )



-- Updatee


type Msg
    = Input String
    | ReceiveFiglet String
    | SelectFont String


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

        SelectFont newFont ->
            let
                figOp =
                    model.figletOp

                newFigOp =
                    { figOp | font = newFont }
            in
            ( { model | figletOp = newFigOp }, inputFigletJS newFigOp )

        ReceiveFiglet figlet ->
            ( { model | figletChars = figlet }, Cmd.none )



-- View


view : Model -> Html Msg
view model =
    let
        handler selectedValue =
            SelectFont selectedValue

        half =
            round (toFloat (List.length model.fontList) / 2)
    in
    div []
        [ div []
            [ h1 [] [ text "Figlet Generator" ] ]
        , div [] [ h2 [] [ text "\"Figlet Generator\" genarate ASCII art" ] ]
        , div [] [ text "Font" ]
        , div []
            [ select [ onChange handler ] (List.map pullDownMenu model.fontList) ]
        , div [] [ text "TextField" ]
        , div []
            [ Html.form []
                [ textarea [ value model.figletOp.inputText, onInput Input, rows 4, cols 40 ] [] ]
            ]
        , div [] [ h2 [] [ text "Result" ] ]
        , div [] [ textarea [ class "resultArea", rows 15, cols 80, readonly True ] [ text model.figletChars ] ]
        , h2 [] [ text "---- Gallery ----" ]
        , div [ class "row" ]
            [ div [ class "column" ]
                (List.map2
                    map2func
                    (List.take half model.fontList)
                    (List.take half model.figList)
                )
            , div
                [ class "column" ]
                (List.map2
                    map2func
                    (List.drop half model.fontList)
                    (List.drop half model.figList)
                )
            ]
        ]


map2func : String -> String -> Html msg
map2func font fig =
    div [] [ text font, br [] [], textarea [ rows 15, cols 50 ] [ text fig ] ]


onChange : (String -> msg) -> Attribute msg
onChange handler =
    Events.on "change" (Json.map handler Events.targetValue)


pullDownMenu : String -> Html Msg
pullDownMenu font =
    option [ value font ] [ text font ]



-- Main


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
