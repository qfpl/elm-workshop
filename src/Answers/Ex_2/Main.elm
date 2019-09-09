module Main exposing (main)

import Browser
import Debug
import Generated.Api as BE
import Html as H
import Html.Attributes as HA
import Html.Attributes.Aria as HAA
import Html.Events as HE
import Http
import RemoteData exposing (RemoteData)
import Session
import Utils


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


type Msg
    = HandleLoginResp (Result Http.Error String)
    | SetLoginPlayerId String
    | SetLoginPassword String
    | LoginSubmit
    | SetRegisterPlayerId String
    | SetRegisterPassword String
    | SetRegisterPasswordAgain String
    | RegisterSubmit
    | HandleRegisterResp (Result Http.Error String)


type alias Model =
    { loginToken : Maybe String
    , loginErrorMessage : Maybe String
    , loginPlayerId : String
    , loginPassword : String
    , registerPlayerId : String
    , registerPassword : String
    , registerPasswordAgain : String
    , registerToken : Maybe String
    , registerErrorMessage : Maybe String
    , registerValidationIssues : List String
    }


init : flags -> ( Model, Cmd Msg )
init _ =
    ( { loginToken = Nothing
      , loginErrorMessage = Nothing
      , loginPlayerId = ""
      , loginPassword = ""
      , registerPlayerId = ""
      , registerPassword = ""
      , registerPasswordAgain = ""
      , registerErrorMessage = Nothing
      , registerToken = Nothing
      , registerValidationIssues = []
      }
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update action model =
    case action of
        HandleLoginResp (Ok token) ->
            ( { model | loginToken = Just token }, Cmd.none )

        HandleLoginResp (Err err) ->
            ( { model | loginErrorMessage = Just "Backend login failed" }, Cmd.none )

        SetLoginPlayerId s ->
            ( { model | loginPlayerId = s }, Cmd.none )

        SetLoginPassword s ->
            ( { model | loginPassword = s }, Cmd.none )

        LoginSubmit ->
            ( { model | loginToken = Nothing, loginErrorMessage = Nothing }
            , BE.postApiLogin (BE.DbPlayer model.loginPlayerId model.loginPassword) HandleLoginResp
            )

        HandleRegisterResp (Ok token) ->
            ( { model | registerToken = Just token }, Cmd.none )

        HandleRegisterResp (Err err) ->
            ( { model | registerErrorMessage = Just "Backend register failed" }, Cmd.none )

        SetRegisterPlayerId s ->
            ( { model | registerPlayerId = s }, Cmd.none )

        SetRegisterPassword s ->
            ( { model | registerPassword = s }, Cmd.none )

        SetRegisterPasswordAgain s ->
            ( { model | registerPasswordAgain = s }, Cmd.none )

        RegisterSubmit ->
            case validateDbPlayer model of
                Ok dbP ->
                    ( { model
                        | registerToken = Nothing
                        , registerErrorMessage = Nothing
                        , registerValidationIssues = []
                      }
                    , BE.postApiPlayers dbP HandleRegisterResp
                    )

                Err es ->
                    ( { model
                        | registerValidationIssues = es
                        , registerToken = Nothing
                        , registerErrorMessage = Nothing
                      }
                    , Cmd.none
                    )


validateDbPlayer : Model -> Result.Result (List String) BE.DbPlayer
validateDbPlayer model =
    if model.registerPassword == model.registerPasswordAgain then
        Ok (BE.DbPlayer model.registerPlayerId model.registerPassword)

    else
        Err [ "Passwords do not match" ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


view : Model -> H.Html Msg
view model =
    H.div []
        [ H.div [ HA.class "login-box" ]
            [ H.h1 [] [ H.text "Login" ]
            , H.form [ HE.onSubmit LoginSubmit ]
                [ H.input
                    [ HA.placeholder "Player Id"
                    , HAA.ariaLabel "Player ID"
                    , HE.onInput SetLoginPlayerId
                    , HA.value model.loginPlayerId
                    ]
                    []
                , H.input
                    [ HA.placeholder "Password"
                    , HA.type_ "password"
                    , HAA.ariaLabel "Password"
                    , HE.onInput SetLoginPassword
                    , HA.value model.loginPassword
                    ]
                    []
                , H.button
                    [ HA.class "btn primary" ]
                    [ H.text "Login" ]
                , case model.loginToken of
                    Nothing ->
                        H.text ""

                    Just t ->
                        H.pre [] [ H.text t ]
                , case model.loginErrorMessage of
                    Nothing ->
                        H.text ""

                    Just err ->
                        H.p [ HA.class "err" ] [ H.text err ]
                ]
            ]
        , H.div [ HA.class "login-box" ]
            [ H.h1 [] [ H.text "Register" ]
            , H.form [ HE.onSubmit RegisterSubmit ]
                [ H.input
                    [ HA.placeholder "Player Id"
                    , HAA.ariaLabel "Player ID"
                    , HE.onInput SetRegisterPlayerId
                    , HA.value model.registerPlayerId
                    ]
                    []
                , H.input
                    [ HA.placeholder "Password"
                    , HA.type_ "password"
                    , HAA.ariaLabel "Password"
                    , HE.onInput SetRegisterPassword
                    , HA.value model.registerPassword
                    ]
                    []
                , H.input
                    [ HA.placeholder "Password Again"
                    , HA.type_ "password"
                    , HAA.ariaLabel "Password Again"
                    , HE.onInput SetRegisterPasswordAgain
                    , HA.value model.registerPasswordAgain
                    ]
                    []
                , H.button
                    [ HA.class "btn primary" ]
                    [ H.text "Register" ]
                , case model.registerToken of
                    Nothing ->
                        H.text ""

                    Just t ->
                        H.pre [] [ H.text t ]
                , case model.registerErrorMessage of
                    Nothing ->
                        H.text ""

                    Just err ->
                        H.p [ HA.class "err" ] [ H.text err ]
                , H.ul [ HA.class "err" ] <| List.map (\err -> H.li [] [ H.text err ]) model.registerValidationIssues
                ]
            ]
        ]
