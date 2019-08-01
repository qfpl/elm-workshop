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
import Utils


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = always Sub.none
        }


type Msg
    = HandleLoginResp (Result Http.Error String)
    | SetLoginPlayerId String
    | SetLoginPassword String
    | SubmitLogin
    | HandleRegisterResp (Result Http.Error String)
    | SetRegisterPlayerId String
    | SetRegisterPassword String
    | SetRegisterPasswordAgain String
    | SubmitRegister


type alias Model =
    { loginToken : RemoteData String String
    , loginPlayerId : String
    , loginPassword : String
    , registerToken : RemoteData String String
    , registerValidationIssues : List String
    , registerPlayerId : String
    , registerPassword : String
    , registerPasswordAgain : String
    }


init : flags -> ( Model, Cmd Msg )
init _ =
    ( { loginToken = RemoteData.NotAsked
      , loginPlayerId = ""
      , loginPassword = ""
      , registerToken = RemoteData.NotAsked
      , registerValidationIssues = []
      , registerPlayerId = ""
      , registerPassword = ""
      , registerPasswordAgain = ""
      }
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update action model =
    case action of
        HandleLoginResp r ->
            ( { model | loginToken = RemoteData.fromResult r |> RemoteData.mapError Utils.httpErrorToStr }
            , Cmd.none
            )

        SetLoginPlayerId p ->
            ( { model | loginPlayerId = p }, Cmd.none )

        SetLoginPassword p ->
            ( { model | loginPassword = p }, Cmd.none )

        SubmitLogin ->
            ( { model | loginToken = RemoteData.Loading }
            , BE.postApiLogin (BE.DbPlayer model.loginPlayerId model.loginPassword) HandleLoginResp
            )

        HandleRegisterResp r ->
            ( { model | registerToken = RemoteData.fromResult r |> RemoteData.mapError Utils.httpErrorToStr }
            , Cmd.none
            )

        SetRegisterPlayerId p ->
            ( { model | registerPlayerId = p }, Cmd.none )

        SetRegisterPassword p ->
            ( { model | registerPassword = p }, Cmd.none )

        SetRegisterPasswordAgain p ->
            ( { model | registerPasswordAgain = p }, Cmd.none )

        SubmitRegister ->
            case validateRegisterDbPlayer model of
                Ok dbPlayer ->
                    ( { model | registerValidationIssues = [], registerToken = RemoteData.Loading }
                    , BE.postApiPlayers dbPlayer HandleRegisterResp
                    )

                Err problems ->
                    ( { model
                        | registerToken = RemoteData.NotAsked
                        , registerValidationIssues = problems
                      }
                    , Cmd.none
                    )


view : Model -> H.Html Msg
view model =
    H.div []
        [ H.div [ HA.class "login-box" ]
            [ H.h1 [] [ H.text "Login" ]
            , H.form [ HE.onSubmit SubmitLogin ]
                ([ H.input
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
                 ]
                    ++ (case model.loginToken of
                            RemoteData.NotAsked ->
                                [ H.text "NOT ASKED" ]

                            RemoteData.Loading ->
                                [ H.text "Loading" ]

                            RemoteData.Success _ ->
                                [ H.text "Success" ]

                            RemoteData.Failure e ->
                                [ H.p [ HA.class "err" ] [ H.text e ] ]
                       )
                )
            ]
        , H.div [ HA.class "login-box" ]
            [ H.h1 [] [ H.text "Register" ]
            , H.form [ HE.onSubmit SubmitRegister ]
                ([ H.input
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
                 ]
                    ++ List.map (\e -> H.p [ HA.class "err" ] [ H.text e ]) model.registerValidationIssues
                    ++ (case model.registerToken of
                            RemoteData.NotAsked ->
                                [ H.text "NOT ASKED" ]

                            RemoteData.Loading ->
                                [ H.text "Loading" ]

                            RemoteData.Success _ ->
                                [ H.text "Success" ]

                            RemoteData.Failure e ->
                                [ H.p [ HA.class "err" ] [ H.text "Success" ] ]
                       )
                )
            ]
        ]



-- Register


validateRegisterDbPlayer : Model -> Result.Result (List String) BE.DbPlayer
validateRegisterDbPlayer model =
    let
        trimmedPlayerId =
            String.trim model.registerPlayerId

        playerIdError =
            if trimmedPlayerId == "" then
                [ "PlayerID cannot be blank" ]

            else
                []

        passwordError =
            if model.registerPassword == "" then
                [ "Password cannot be blank" ]

            else
                []

        mismatchError =
            if model.registerPassword /= model.registerPasswordAgain then
                [ "Passwords do not match" ]

            else
                []

        allErrs =
            List.concat [ playerIdError, passwordError, mismatchError ]
    in
    if allErrs == [] then
        Result.Ok { dbPlayerId = trimmedPlayerId, dbPlayerPassword = model.registerPassword }

    else
        Result.Err allErrs
