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
import Time
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
    = HandleLoginResp BE.PlayerId (Result Http.Error String)
    | SetLoginPlayerId String
    | SetLoginPassword String
    | SubmitLogin
    | HandleRegisterResp BE.PlayerId (Result Http.Error String)
    | SetRegisterPlayerId String
    | SetRegisterPassword String
    | SetRegisterPasswordAgain String
    | SubmitRegister
    | Tick Session.Player Time.Posix
    | HandleGetChatResp Session.Player (Result Http.Error (List BE.ChatLine))
    | SetNewChatLine String
    | SubmitNewChatLine Session.Player
    | HandleNewChatLineResp (Result Http.Error ())


type alias Model =
    { player : Maybe Session.Player
    , loginToken : RemoteData String String
    , loginPlayerId : String
    , loginPassword : String
    , registerToken : RemoteData String String
    , registerValidationIssues : List String
    , registerPlayerId : String
    , registerPassword : String
    , registerPasswordAgain : String
    , chatLines : List BE.ChatLine
    , newChatLine : String
    }


init : flags -> ( Model, Cmd Msg )
init _ =
    ( { player = Nothing
      , loginToken = RemoteData.NotAsked
      , loginPlayerId = ""
      , loginPassword = ""
      , registerToken = RemoteData.NotAsked
      , registerValidationIssues = []
      , registerPlayerId = ""
      , registerPassword = ""
      , registerPasswordAgain = ""
      , chatLines = []
      , newChatLine = ""
      }
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update action model =
    case action of
        HandleLoginResp playerId r ->
            ( { model
                | loginToken = RemoteData.fromResult r |> RemoteData.mapError Utils.httpErrorToStr
                , player = Result.toMaybe r |> Maybe.map (Session.Player playerId)
              }
            , Cmd.none
            )

        SetLoginPlayerId p ->
            ( { model | loginPlayerId = p }, Cmd.none )

        SetLoginPassword p ->
            ( { model | loginPassword = p }, Cmd.none )

        SubmitLogin ->
            ( { model | loginToken = RemoteData.Loading }
            , BE.postApiLogin (BE.DbPlayer model.loginPlayerId model.loginPassword) (HandleLoginResp model.loginPlayerId)
            )

        HandleRegisterResp playerId r ->
            ( { model
                | registerToken = RemoteData.fromResult r |> RemoteData.mapError Utils.httpErrorToStr
                , player = Result.toMaybe r |> Maybe.map (Session.Player playerId)
              }
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
                    , BE.postApiPlayers dbPlayer (HandleRegisterResp dbPlayer.dbPlayerId)
                    )

                Err problems ->
                    ( { model
                        | registerToken = RemoteData.NotAsked
                        , registerValidationIssues = problems
                      }
                    , Cmd.none
                    )

        Tick player _ ->
            ( model, BE.getApiLobby player.token Nothing (HandleGetChatResp player) )

        HandleGetChatResp player chatLines ->
            ( { model | chatLines = Result.withDefault [] chatLines }, Cmd.none )

        SetNewChatLine s ->
            ( { model | newChatLine = s }, Cmd.none )

        SubmitNewChatLine player ->
            ( model, BE.postApiLobby player.token model.newChatLine HandleNewChatLineResp )

        HandleNewChatLineResp r ->
            ( { model | newChatLine = "" }, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    case model.player of
        Nothing ->
            Sub.none

        Just p ->
            Time.every 2000 (Tick p)


view : Model -> H.Html Msg
view model =
    case model.player of
        Nothing ->
            loggedOutView model

        Just p ->
            loggedInView p model


loggedInView : Session.Player -> Model -> H.Html Msg
loggedInView player model =
    H.div [ HA.class "lobby" ]
        [ H.div [ HA.class "lobby-games" ]
            [ H.h1 [] [ H.text "Lobby" ]
            ]
        , H.div [ HA.class "chatbox-container" ]
            [ H.h2 [] [ H.text "Chat Lobby" ]
            , H.div [ HA.id "chatbox", HA.class "chatbox" ] (List.map chatLineView model.chatLines)
            , H.form [ HE.onSubmit (SubmitNewChatLine player) ]
                [ H.ul []
                    [ H.li [ HA.class "chat-message" ]
                        [ H.input
                            [ HA.placeholder "type a chat message"
                            , HE.onInput SetNewChatLine
                            , HA.value model.newChatLine
                            , HA.class "chat-message-input"
                            , HAA.ariaLabel "Enter Chat Message"
                            ]
                            []
                        ]
                    , H.li []
                        [ H.button
                            [ HA.class "btn primary" ]
                            [ H.text "send" ]
                        ]
                    ]
                ]
            ]
        ]


chatLineView : BE.ChatLine -> H.Html Msg
chatLineView cl =
    H.p []
        [ H.b [] [ H.text cl.chatLinePlayerId, H.text "> " ]
        , H.text cl.chatLineText
        ]


loggedOutView : Model -> H.Html Msg
loggedOutView model =
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
