module Generated.Api exposing(..)

import Json.Decode
import Json.Encode exposing (Value)
-- The following module comes from bartavelle/json-helpers
import Json.Helpers exposing (..)
import Dict exposing (Dict)
import Set
import Http
import String
import Url.Builder
import Time exposing (Posix, posixToMillis, millisToPosix)

maybeBoolToIntStr : Maybe Bool -> String
maybeBoolToIntStr mx =
  case mx of
    Nothing -> ""
    Just True -> "1"
    Just False -> "0"

jsonDecBool : Json.Decode.Decoder Bool
jsonDecBool = Json.Decode.bool
jsonEncBool : Bool -> Value
jsonEncBool = Json.Encode.bool

jsonDecPosix : Json.Decode.Decoder Posix
jsonDecPosix = Json.Decode.map Time.millisToPosix Json.Decode.int
jsonEncPosix : Posix -> Value
jsonEncPosix = posixToMillis >> Json.Encode.int

type alias PlayersMap a = Dict PlayerId a
jsonDecPlayersMap : Json.Decode.Decoder a -> Json.Decode.Decoder (PlayersMap a)
jsonDecPlayersMap = Json.Decode.dict
jsonEncPlayersMap : (a -> Value) -> PlayersMap a -> Value
jsonEncPlayersMap aEnc = Dict.map (always aEnc) >> Dict.toList >> Json.Encode.object

type alias GameId  = Int

jsonDecGameId : Json.Decode.Decoder ( GameId )
jsonDecGameId =
    Json.Decode.int

jsonEncGameId : GameId -> Value
jsonEncGameId  val = Json.Encode.int val



type alias JoinableGame  =
   { joinableGameId: GameId
   , playerCount: Int
   }

jsonDecJoinableGame : Json.Decode.Decoder ( JoinableGame )
jsonDecJoinableGame =
   Json.Decode.succeed (\pjoinableGameId pplayerCount -> {joinableGameId = pjoinableGameId, playerCount = pplayerCount})
   |> required "joinableGameId" (jsonDecGameId)
   |> required "playerCount" (Json.Decode.int)

jsonEncJoinableGame : JoinableGame -> Value
jsonEncJoinableGame  val =
   Json.Encode.object
   [ ("joinableGameId", jsonEncGameId val.joinableGameId)
   , ("playerCount", Json.Encode.int val.playerCount)
   ]



type alias Token  = String

jsonDecToken : Json.Decode.Decoder ( Token )
jsonDecToken =
    Json.Decode.string

jsonEncToken : Token -> Value
jsonEncToken  val = Json.Encode.string val



type alias ChatLine  =
   { chatLineTime: Posix
   , chatLineGameId: (Maybe GameId)
   , chatLinePlayerId: PlayerId
   , chatLineText: String
   }

jsonDecChatLine : Json.Decode.Decoder ( ChatLine )
jsonDecChatLine =
   Json.Decode.succeed (\pchatLineTime pchatLineGameId pchatLinePlayerId pchatLineText -> {chatLineTime = pchatLineTime, chatLineGameId = pchatLineGameId, chatLinePlayerId = pchatLinePlayerId, chatLineText = pchatLineText})
   |> required "chatLineTime" (jsonDecPosix)
   |> fnullable "chatLineGameId" (jsonDecGameId)
   |> required "chatLinePlayerId" (jsonDecPlayerId)
   |> required "chatLineText" (Json.Decode.string)

jsonEncChatLine : ChatLine -> Value
jsonEncChatLine  val =
   Json.Encode.object
   [ ("chatLineTime", jsonEncPosix val.chatLineTime)
   , ("chatLineGameId", (maybeEncode (jsonEncGameId)) val.chatLineGameId)
   , ("chatLinePlayerId", jsonEncPlayerId val.chatLinePlayerId)
   , ("chatLineText", Json.Encode.string val.chatLineText)
   ]



type alias NewChatLine  =
   { newChatGameId: (Maybe GameId)
   , newChatLinePlayerId: PlayerId
   , newChatLineText: String
   }

jsonDecNewChatLine : Json.Decode.Decoder ( NewChatLine )
jsonDecNewChatLine =
   Json.Decode.succeed (\pnewChatGameId pnewChatLinePlayerId pnewChatLineText -> {newChatGameId = pnewChatGameId, newChatLinePlayerId = pnewChatLinePlayerId, newChatLineText = pnewChatLineText})
   |> fnullable "newChatGameId" (jsonDecGameId)
   |> required "newChatLinePlayerId" (jsonDecPlayerId)
   |> required "newChatLineText" (Json.Decode.string)

jsonEncNewChatLine : NewChatLine -> Value
jsonEncNewChatLine  val =
   Json.Encode.object
   [ ("newChatGameId", (maybeEncode (jsonEncGameId)) val.newChatGameId)
   , ("newChatLinePlayerId", jsonEncPlayerId val.newChatLinePlayerId)
   , ("newChatLineText", Json.Encode.string val.newChatLineText)
   ]



type alias PlayerId  = String

jsonDecPlayerId : Json.Decode.Decoder ( PlayerId )
jsonDecPlayerId =
    Json.Decode.string

jsonEncPlayerId : PlayerId -> Value
jsonEncPlayerId  val = Json.Encode.string val



type Role  =
    CompositionalCrusaders Bool
    | SneakySideEffects Bool

jsonDecRole : Json.Decode.Decoder ( Role )
jsonDecRole =
    let jsonDecDictRole = Dict.fromList
            [ ("CompositionalCrusaders", Json.Decode.lazy (\_ -> Json.Decode.map CompositionalCrusaders (Json.Decode.bool)))
            , ("SneakySideEffects", Json.Decode.lazy (\_ -> Json.Decode.map SneakySideEffects (Json.Decode.bool)))
            ]
    in  decodeSumTwoElemArray  "Role" jsonDecDictRole

jsonEncRole : Role -> Value
jsonEncRole  val =
    let keyval v = case v of
                    CompositionalCrusaders v1 -> ("CompositionalCrusaders", encodeValue (Json.Encode.bool v1))
                    SneakySideEffects v1 -> ("SneakySideEffects", encodeValue (Json.Encode.bool v1))
    in encodeSumTwoElementArray keyval val



type alias LeadershipQueue  = (List String)

jsonDecLeadershipQueue : Json.Decode.Decoder ( LeadershipQueue )
jsonDecLeadershipQueue =
    Json.Decode.list (Json.Decode.string)

jsonEncLeadershipQueue : LeadershipQueue -> Value
jsonEncLeadershipQueue  val = (Json.Encode.list Json.Encode.string) val



type SideEffectWinCondition  =
    FPExpertFired 
    | ThreeFailedProjects 
    | FiveTeamsVetoed 

jsonDecSideEffectWinCondition : Json.Decode.Decoder ( SideEffectWinCondition )
jsonDecSideEffectWinCondition = 
    let jsonDecDictSideEffectWinCondition = Dict.fromList [("FPExpertFired", FPExpertFired), ("ThreeFailedProjects", ThreeFailedProjects), ("FiveTeamsVetoed", FiveTeamsVetoed)]
    in  decodeSumUnaries "SideEffectWinCondition" jsonDecDictSideEffectWinCondition

jsonEncSideEffectWinCondition : SideEffectWinCondition -> Value
jsonEncSideEffectWinCondition  val =
    case val of
        FPExpertFired -> Json.Encode.string "FPExpertFired"
        ThreeFailedProjects -> Json.Encode.string "ThreeFailedProjects"
        FiveTeamsVetoed -> Json.Encode.string "FiveTeamsVetoed"



type EndCondition  =
    CrusadersWin 
    | SideEffectsWin SideEffectWinCondition
    | GameCancelled 

jsonDecEndCondition : Json.Decode.Decoder ( EndCondition )
jsonDecEndCondition =
    let jsonDecDictEndCondition = Dict.fromList
            [ ("CrusadersWin", Json.Decode.lazy (\_ -> Json.Decode.succeed CrusadersWin))
            , ("SideEffectsWin", Json.Decode.lazy (\_ -> Json.Decode.map SideEffectsWin (jsonDecSideEffectWinCondition)))
            , ("GameCancelled", Json.Decode.lazy (\_ -> Json.Decode.succeed GameCancelled))
            ]
    in  decodeSumTwoElemArray  "EndCondition" jsonDecDictEndCondition

jsonEncEndCondition : EndCondition -> Value
jsonEncEndCondition  val =
    let keyval v = case v of
                    CrusadersWin  -> ("CrusadersWin", encodeValue (Json.Encode.list identity []))
                    SideEffectsWin v1 -> ("SideEffectsWin", encodeValue (jsonEncSideEffectWinCondition v1))
                    GameCancelled  -> ("GameCancelled", encodeValue (Json.Encode.list identity []))
    in encodeSumTwoElementArray keyval val



type alias RoundShape  =
   { roundShapeTeamSize: Int
   , roundShapeTwoFails: Bool
   }

jsonDecRoundShape : Json.Decode.Decoder ( RoundShape )
jsonDecRoundShape =
   Json.Decode.succeed (\proundShapeTeamSize proundShapeTwoFails -> {roundShapeTeamSize = proundShapeTeamSize, roundShapeTwoFails = proundShapeTwoFails})
   |> required "roundShapeTeamSize" (Json.Decode.int)
   |> required "roundShapeTwoFails" (Json.Decode.bool)

jsonEncRoundShape : RoundShape -> Value
jsonEncRoundShape  val =
   Json.Encode.object
   [ ("roundShapeTeamSize", Json.Encode.int val.roundShapeTeamSize)
   , ("roundShapeTwoFails", Json.Encode.bool val.roundShapeTwoFails)
   ]



type ViewStateProposalState  =
    NoProposal 
    | Proposed (List PlayerId) (List PlayerId)
    | Approved (List PlayerId) (List PlayerId)

jsonDecViewStateProposalState : Json.Decode.Decoder ( ViewStateProposalState )
jsonDecViewStateProposalState =
    let jsonDecDictViewStateProposalState = Dict.fromList
            [ ("NoProposal", Json.Decode.lazy (\_ -> Json.Decode.succeed NoProposal))
            , ("Proposed", Json.Decode.lazy (\_ -> Json.Decode.map2 Proposed (Json.Decode.index 0 (Json.Decode.list (jsonDecPlayerId))) (Json.Decode.index 1 (Json.Decode.list (jsonDecPlayerId)))))
            , ("Approved", Json.Decode.lazy (\_ -> Json.Decode.map2 Approved (Json.Decode.index 0 (Json.Decode.list (jsonDecPlayerId))) (Json.Decode.index 1 (Json.Decode.list (jsonDecPlayerId)))))
            ]
    in  decodeSumTwoElemArray  "ViewStateProposalState" jsonDecDictViewStateProposalState

jsonEncViewStateProposalState : ViewStateProposalState -> Value
jsonEncViewStateProposalState  val =
    let keyval v = case v of
                    NoProposal  -> ("NoProposal", encodeValue (Json.Encode.list identity []))
                    Proposed v1 v2 -> ("Proposed", encodeValue (Json.Encode.list identity [(Json.Encode.list jsonEncPlayerId) v1, (Json.Encode.list jsonEncPlayerId) v2]))
                    Approved v1 v2 -> ("Approved", encodeValue (Json.Encode.list identity [(Json.Encode.list jsonEncPlayerId) v1, (Json.Encode.list jsonEncPlayerId) v2]))
    in encodeSumTwoElementArray keyval val



type alias TeamVotingResult  =
   { votingTeamLeader: PlayerId
   , votingResultTeam: (List PlayerId)
   , votingResult: (PlayersMap Bool)
   }

jsonDecTeamVotingResult : Json.Decode.Decoder ( TeamVotingResult )
jsonDecTeamVotingResult =
   Json.Decode.succeed (\pvotingTeamLeader pvotingResultTeam pvotingResult -> {votingTeamLeader = pvotingTeamLeader, votingResultTeam = pvotingResultTeam, votingResult = pvotingResult})
   |> required "votingTeamLeader" (jsonDecPlayerId)
   |> required "votingResultTeam" (Json.Decode.list (jsonDecPlayerId))
   |> required "votingResult" (jsonDecPlayersMap (Json.Decode.bool))

jsonEncTeamVotingResult : TeamVotingResult -> Value
jsonEncTeamVotingResult  val =
   Json.Encode.object
   [ ("votingTeamLeader", jsonEncPlayerId val.votingTeamLeader)
   , ("votingResultTeam", (Json.Encode.list jsonEncPlayerId) val.votingResultTeam)
   , ("votingResult", (jsonEncPlayersMap (Json.Encode.bool)) val.votingResult)
   ]



type RoundResult  =
    RoundSuccess Int
    | RoundFailure Int
    | RoundNoConsensus 

jsonDecRoundResult : Json.Decode.Decoder ( RoundResult )
jsonDecRoundResult =
    let jsonDecDictRoundResult = Dict.fromList
            [ ("RoundSuccess", Json.Decode.lazy (\_ -> Json.Decode.map RoundSuccess (Json.Decode.int)))
            , ("RoundFailure", Json.Decode.lazy (\_ -> Json.Decode.map RoundFailure (Json.Decode.int)))
            , ("RoundNoConsensus", Json.Decode.lazy (\_ -> Json.Decode.succeed RoundNoConsensus))
            ]
    in  decodeSumTwoElemArray  "RoundResult" jsonDecDictRoundResult

jsonEncRoundResult : RoundResult -> Value
jsonEncRoundResult  val =
    let keyval v = case v of
                    RoundSuccess v1 -> ("RoundSuccess", encodeValue (Json.Encode.int v1))
                    RoundFailure v1 -> ("RoundFailure", encodeValue (Json.Encode.int v1))
                    RoundNoConsensus  -> ("RoundNoConsensus", encodeValue (Json.Encode.list identity []))
    in encodeSumTwoElementArray keyval val



type alias ViewStateCurrentRoundState  =
   { currentRoundShape: RoundShape
   , currentRoundProposal: ViewStateProposalState
   , currentRoundVotes: (List TeamVotingResult)
   }

jsonDecViewStateCurrentRoundState : Json.Decode.Decoder ( ViewStateCurrentRoundState )
jsonDecViewStateCurrentRoundState =
   Json.Decode.succeed (\pcurrentRoundShape pcurrentRoundProposal pcurrentRoundVotes -> {currentRoundShape = pcurrentRoundShape, currentRoundProposal = pcurrentRoundProposal, currentRoundVotes = pcurrentRoundVotes})
   |> required "currentRoundShape" (jsonDecRoundShape)
   |> required "currentRoundProposal" (jsonDecViewStateProposalState)
   |> required "currentRoundVotes" (Json.Decode.list (jsonDecTeamVotingResult))

jsonEncViewStateCurrentRoundState : ViewStateCurrentRoundState -> Value
jsonEncViewStateCurrentRoundState  val =
   Json.Encode.object
   [ ("currentRoundShape", jsonEncRoundShape val.currentRoundShape)
   , ("currentRoundProposal", jsonEncViewStateProposalState val.currentRoundProposal)
   , ("currentRoundVotes", (Json.Encode.list jsonEncTeamVotingResult) val.currentRoundVotes)
   ]



type GameStateInputEvent  =
    AddPlayer 
    | RemovePlayer 
    | StartGame 
    | ConfirmOk 
    | ProposeTeam (List PlayerId)
    | VoteOnTeam Bool
    | VoteOnProject Bool
    | FirePlayer PlayerId
    | AbortGame 

jsonDecGameStateInputEvent : Json.Decode.Decoder ( GameStateInputEvent )
jsonDecGameStateInputEvent =
    let jsonDecDictGameStateInputEvent = Dict.fromList
            [ ("AddPlayer", Json.Decode.lazy (\_ -> Json.Decode.succeed AddPlayer))
            , ("RemovePlayer", Json.Decode.lazy (\_ -> Json.Decode.succeed RemovePlayer))
            , ("StartGame", Json.Decode.lazy (\_ -> Json.Decode.succeed StartGame))
            , ("ConfirmOk", Json.Decode.lazy (\_ -> Json.Decode.succeed ConfirmOk))
            , ("ProposeTeam", Json.Decode.lazy (\_ -> Json.Decode.map ProposeTeam (Json.Decode.list (jsonDecPlayerId))))
            , ("VoteOnTeam", Json.Decode.lazy (\_ -> Json.Decode.map VoteOnTeam (Json.Decode.bool)))
            , ("VoteOnProject", Json.Decode.lazy (\_ -> Json.Decode.map VoteOnProject (Json.Decode.bool)))
            , ("FirePlayer", Json.Decode.lazy (\_ -> Json.Decode.map FirePlayer (jsonDecPlayerId)))
            , ("AbortGame", Json.Decode.lazy (\_ -> Json.Decode.succeed AbortGame))
            ]
    in  decodeSumTwoElemArray  "GameStateInputEvent" jsonDecDictGameStateInputEvent

jsonEncGameStateInputEvent : GameStateInputEvent -> Value
jsonEncGameStateInputEvent  val =
    let keyval v = case v of
                    AddPlayer  -> ("AddPlayer", encodeValue (Json.Encode.list identity []))
                    RemovePlayer  -> ("RemovePlayer", encodeValue (Json.Encode.list identity []))
                    StartGame  -> ("StartGame", encodeValue (Json.Encode.list identity []))
                    ConfirmOk  -> ("ConfirmOk", encodeValue (Json.Encode.list identity []))
                    ProposeTeam v1 -> ("ProposeTeam", encodeValue ((Json.Encode.list jsonEncPlayerId) v1))
                    VoteOnTeam v1 -> ("VoteOnTeam", encodeValue (Json.Encode.bool v1))
                    VoteOnProject v1 -> ("VoteOnProject", encodeValue (Json.Encode.bool v1))
                    FirePlayer v1 -> ("FirePlayer", encodeValue (jsonEncPlayerId v1))
                    AbortGame  -> ("AbortGame", encodeValue (Json.Encode.list identity []))
    in encodeSumTwoElementArray keyval val



type alias HistoricRoundState  =
   { historicRoundShape: RoundShape
   , historicRoundTeam: (Maybe (List PlayerId))
   , historicRoundVotes: (List TeamVotingResult)
   , historicRoundResult: RoundResult
   }

jsonDecHistoricRoundState : Json.Decode.Decoder ( HistoricRoundState )
jsonDecHistoricRoundState =
   Json.Decode.succeed (\phistoricRoundShape phistoricRoundTeam phistoricRoundVotes phistoricRoundResult -> {historicRoundShape = phistoricRoundShape, historicRoundTeam = phistoricRoundTeam, historicRoundVotes = phistoricRoundVotes, historicRoundResult = phistoricRoundResult})
   |> required "historicRoundShape" (jsonDecRoundShape)
   |> fnullable "historicRoundTeam" (Json.Decode.list (jsonDecPlayerId))
   |> required "historicRoundVotes" (Json.Decode.list (jsonDecTeamVotingResult))
   |> required "historicRoundResult" (jsonDecRoundResult)

jsonEncHistoricRoundState : HistoricRoundState -> Value
jsonEncHistoricRoundState  val =
   Json.Encode.object
   [ ("historicRoundShape", jsonEncRoundShape val.historicRoundShape)
   , ("historicRoundTeam", (maybeEncode ((Json.Encode.list jsonEncPlayerId))) val.historicRoundTeam)
   , ("historicRoundVotes", (Json.Encode.list jsonEncTeamVotingResult) val.historicRoundVotes)
   , ("historicRoundResult", jsonEncRoundResult val.historicRoundResult)
   ]



type alias ViewRoundsState  =
   { roundsMyRole: Role
   , roundsRoles: (PlayersMap CensoredRole)
   , roundsCurrentLeader: PlayerId
   , roundsLeadershipQueue: LeadershipQueue
   , roundsCurrent: ViewStateCurrentRoundState
   , roundsFuture: (List RoundShape)
   , roundsHistoric: (List HistoricRoundState)
   }

jsonDecViewRoundsState : Json.Decode.Decoder ( ViewRoundsState )
jsonDecViewRoundsState =
   Json.Decode.succeed (\proundsMyRole proundsRoles proundsCurrentLeader proundsLeadershipQueue proundsCurrent proundsFuture proundsHistoric -> {roundsMyRole = proundsMyRole, roundsRoles = proundsRoles, roundsCurrentLeader = proundsCurrentLeader, roundsLeadershipQueue = proundsLeadershipQueue, roundsCurrent = proundsCurrent, roundsFuture = proundsFuture, roundsHistoric = proundsHistoric})
   |> required "roundsMyRole" (jsonDecRole)
   |> required "roundsRoles" (jsonDecPlayersMap (jsonDecCensoredRole))
   |> required "roundsCurrentLeader" (jsonDecPlayerId)
   |> required "roundsLeadershipQueue" (jsonDecLeadershipQueue)
   |> required "roundsCurrent" (jsonDecViewStateCurrentRoundState)
   |> required "roundsFuture" (Json.Decode.list (jsonDecRoundShape))
   |> required "roundsHistoric" (Json.Decode.list (jsonDecHistoricRoundState))

jsonEncViewRoundsState : ViewRoundsState -> Value
jsonEncViewRoundsState  val =
   Json.Encode.object
   [ ("roundsMyRole", jsonEncRole val.roundsMyRole)
   , ("roundsRoles", (jsonEncPlayersMap (jsonEncCensoredRole)) val.roundsRoles)
   , ("roundsCurrentLeader", jsonEncPlayerId val.roundsCurrentLeader)
   , ("roundsLeadershipQueue", jsonEncLeadershipQueue val.roundsLeadershipQueue)
   , ("roundsCurrent", jsonEncViewStateCurrentRoundState val.roundsCurrent)
   , ("roundsFuture", (Json.Encode.list jsonEncRoundShape) val.roundsFuture)
   , ("roundsHistoric", (Json.Encode.list jsonEncHistoricRoundState) val.roundsHistoric)
   ]



type CensoredRole  =
    Censored 
    | CensoredSideEffect 

jsonDecCensoredRole : Json.Decode.Decoder ( CensoredRole )
jsonDecCensoredRole = 
    let jsonDecDictCensoredRole = Dict.fromList [("Censored", Censored), ("CensoredSideEffect", CensoredSideEffect)]
    in  decodeSumUnaries "CensoredRole" jsonDecDictCensoredRole

jsonEncCensoredRole : CensoredRole -> Value
jsonEncCensoredRole  val =
    case val of
        Censored -> Json.Encode.string "Censored"
        CensoredSideEffect -> Json.Encode.string "CensoredSideEffect"



type ViewState  =
    WaitingForPlayers PlayerId (List PlayerId)
    | Pregame Role (PlayersMap CensoredRole) (PlayersMap Bool)
    | Rounds ViewRoundsState
    | FiringRound Role (PlayersMap CensoredRole) (List HistoricRoundState)
    | Complete (PlayersMap Role) EndCondition (List HistoricRoundState)
    | Aborted PlayerId

jsonDecViewState : Json.Decode.Decoder ( ViewState )
jsonDecViewState =
    let jsonDecDictViewState = Dict.fromList
            [ ("WaitingForPlayers", Json.Decode.lazy (\_ -> Json.Decode.map2 WaitingForPlayers (Json.Decode.index 0 (jsonDecPlayerId)) (Json.Decode.index 1 (Json.Decode.list (jsonDecPlayerId)))))
            , ("Pregame", Json.Decode.lazy (\_ -> Json.Decode.map3 Pregame (Json.Decode.index 0 (jsonDecRole)) (Json.Decode.index 1 (jsonDecPlayersMap (jsonDecCensoredRole))) (Json.Decode.index 2 (jsonDecPlayersMap (Json.Decode.bool)))))
            , ("Rounds", Json.Decode.lazy (\_ -> Json.Decode.map Rounds (jsonDecViewRoundsState)))
            , ("FiringRound", Json.Decode.lazy (\_ -> Json.Decode.map3 FiringRound (Json.Decode.index 0 (jsonDecRole)) (Json.Decode.index 1 (jsonDecPlayersMap (jsonDecCensoredRole))) (Json.Decode.index 2 (Json.Decode.list (jsonDecHistoricRoundState)))))
            , ("Complete", Json.Decode.lazy (\_ -> Json.Decode.map3 Complete (Json.Decode.index 0 (jsonDecPlayersMap (jsonDecRole))) (Json.Decode.index 1 (jsonDecEndCondition)) (Json.Decode.index 2 (Json.Decode.list (jsonDecHistoricRoundState)))))
            , ("Aborted", Json.Decode.lazy (\_ -> Json.Decode.map Aborted (jsonDecPlayerId)))
            ]
    in  decodeSumTwoElemArray  "ViewState" jsonDecDictViewState

jsonEncViewState : ViewState -> Value
jsonEncViewState  val =
    let keyval v = case v of
                    WaitingForPlayers v1 v2 -> ("WaitingForPlayers", encodeValue (Json.Encode.list identity [jsonEncPlayerId v1, (Json.Encode.list jsonEncPlayerId) v2]))
                    Pregame v1 v2 v3 -> ("Pregame", encodeValue (Json.Encode.list identity [jsonEncRole v1, (jsonEncPlayersMap (jsonEncCensoredRole)) v2, (jsonEncPlayersMap (Json.Encode.bool)) v3]))
                    Rounds v1 -> ("Rounds", encodeValue (jsonEncViewRoundsState v1))
                    FiringRound v1 v2 v3 -> ("FiringRound", encodeValue (Json.Encode.list identity [jsonEncRole v1, (jsonEncPlayersMap (jsonEncCensoredRole)) v2, (Json.Encode.list jsonEncHistoricRoundState) v3]))
                    Complete v1 v2 v3 -> ("Complete", encodeValue (Json.Encode.list identity [(jsonEncPlayersMap (jsonEncRole)) v1, jsonEncEndCondition v2, (Json.Encode.list jsonEncHistoricRoundState) v3]))
                    Aborted v1 -> ("Aborted", encodeValue (jsonEncPlayerId v1))
    in encodeSumTwoElementArray keyval val



type alias DbViewState  =
   { dbViewStateGameId: GameId
   , dbViewState: ViewState
   }

jsonDecDbViewState : Json.Decode.Decoder ( DbViewState )
jsonDecDbViewState =
   Json.Decode.succeed (\pdbViewStateGameId pdbViewState -> {dbViewStateGameId = pdbViewStateGameId, dbViewState = pdbViewState})
   |> required "dbViewStateGameId" (jsonDecGameId)
   |> required "dbViewState" (jsonDecViewState)

jsonEncDbViewState : DbViewState -> Value
jsonEncDbViewState  val =
   Json.Encode.object
   [ ("dbViewStateGameId", jsonEncGameId val.dbViewStateGameId)
   , ("dbViewState", jsonEncViewState val.dbViewState)
   ]



type ViewStateEventData  =
    ViewStateEventChat ChatLine
    | ViewStateEventOutput ViewStateOutputEvent

jsonDecViewStateEventData : Json.Decode.Decoder ( ViewStateEventData )
jsonDecViewStateEventData =
    let jsonDecDictViewStateEventData = Dict.fromList
            [ ("ViewStateEventChat", Json.Decode.lazy (\_ -> Json.Decode.map ViewStateEventChat (jsonDecChatLine)))
            , ("ViewStateEventOutput", Json.Decode.lazy (\_ -> Json.Decode.map ViewStateEventOutput (jsonDecViewStateOutputEvent)))
            ]
    in  decodeSumTwoElemArray  "ViewStateEventData" jsonDecDictViewStateEventData

jsonEncViewStateEventData : ViewStateEventData -> Value
jsonEncViewStateEventData  val =
    let keyval v = case v of
                    ViewStateEventChat v1 -> ("ViewStateEventChat", encodeValue (jsonEncChatLine v1))
                    ViewStateEventOutput v1 -> ("ViewStateEventOutput", encodeValue (jsonEncViewStateOutputEvent v1))
    in encodeSumTwoElementArray keyval val



type ViewStateOutputEvent  =
    PlayerAdded PlayerId
    | PlayerRemoved PlayerId
    | PregameStarted (PlayersMap CensoredRole)
    | PlayerConfirmed PlayerId
    | RoundsCommenced ViewRoundsState
    | TeamProposed (List PlayerId)
    | TeamApproved Int
    | TeamRejected Int PlayerId
    | NextRound Bool Int
    | ThreeSuccessfulProjects 
    | PlayerFired PlayerId
    | GameEnded (PlayersMap Role) EndCondition
    | GameAborted PlayerId
    | GameCrashed 

jsonDecViewStateOutputEvent : Json.Decode.Decoder ( ViewStateOutputEvent )
jsonDecViewStateOutputEvent =
    let jsonDecDictViewStateOutputEvent = Dict.fromList
            [ ("PlayerAdded", Json.Decode.lazy (\_ -> Json.Decode.map PlayerAdded (jsonDecPlayerId)))
            , ("PlayerRemoved", Json.Decode.lazy (\_ -> Json.Decode.map PlayerRemoved (jsonDecPlayerId)))
            , ("PregameStarted", Json.Decode.lazy (\_ -> Json.Decode.map PregameStarted (jsonDecPlayersMap (jsonDecCensoredRole))))
            , ("PlayerConfirmed", Json.Decode.lazy (\_ -> Json.Decode.map PlayerConfirmed (jsonDecPlayerId)))
            , ("RoundsCommenced", Json.Decode.lazy (\_ -> Json.Decode.map RoundsCommenced (jsonDecViewRoundsState)))
            , ("TeamProposed", Json.Decode.lazy (\_ -> Json.Decode.map TeamProposed (Json.Decode.list (jsonDecPlayerId))))
            , ("TeamApproved", Json.Decode.lazy (\_ -> Json.Decode.map TeamApproved (Json.Decode.int)))
            , ("TeamRejected", Json.Decode.lazy (\_ -> Json.Decode.map2 TeamRejected (Json.Decode.index 0 (Json.Decode.int)) (Json.Decode.index 1 (jsonDecPlayerId))))
            , ("NextRound", Json.Decode.lazy (\_ -> Json.Decode.map2 NextRound (Json.Decode.index 0 (Json.Decode.bool)) (Json.Decode.index 1 (Json.Decode.int))))
            , ("ThreeSuccessfulProjects", Json.Decode.lazy (\_ -> Json.Decode.succeed ThreeSuccessfulProjects))
            , ("PlayerFired", Json.Decode.lazy (\_ -> Json.Decode.map PlayerFired (jsonDecPlayerId)))
            , ("GameEnded", Json.Decode.lazy (\_ -> Json.Decode.map2 GameEnded (Json.Decode.index 0 (jsonDecPlayersMap (jsonDecRole))) (Json.Decode.index 1 (jsonDecEndCondition))))
            , ("GameAborted", Json.Decode.lazy (\_ -> Json.Decode.map GameAborted (jsonDecPlayerId)))
            , ("GameCrashed", Json.Decode.lazy (\_ -> Json.Decode.succeed GameCrashed))
            ]
    in  decodeSumTwoElemArray  "ViewStateOutputEvent" jsonDecDictViewStateOutputEvent

jsonEncViewStateOutputEvent : ViewStateOutputEvent -> Value
jsonEncViewStateOutputEvent  val =
    let keyval v = case v of
                    PlayerAdded v1 -> ("PlayerAdded", encodeValue (jsonEncPlayerId v1))
                    PlayerRemoved v1 -> ("PlayerRemoved", encodeValue (jsonEncPlayerId v1))
                    PregameStarted v1 -> ("PregameStarted", encodeValue ((jsonEncPlayersMap (jsonEncCensoredRole)) v1))
                    PlayerConfirmed v1 -> ("PlayerConfirmed", encodeValue (jsonEncPlayerId v1))
                    RoundsCommenced v1 -> ("RoundsCommenced", encodeValue (jsonEncViewRoundsState v1))
                    TeamProposed v1 -> ("TeamProposed", encodeValue ((Json.Encode.list jsonEncPlayerId) v1))
                    TeamApproved v1 -> ("TeamApproved", encodeValue (Json.Encode.int v1))
                    TeamRejected v1 v2 -> ("TeamRejected", encodeValue (Json.Encode.list identity [Json.Encode.int v1, jsonEncPlayerId v2]))
                    NextRound v1 v2 -> ("NextRound", encodeValue (Json.Encode.list identity [Json.Encode.bool v1, Json.Encode.int v2]))
                    ThreeSuccessfulProjects  -> ("ThreeSuccessfulProjects", encodeValue (Json.Encode.list identity []))
                    PlayerFired v1 -> ("PlayerFired", encodeValue (jsonEncPlayerId v1))
                    GameEnded v1 v2 -> ("GameEnded", encodeValue (Json.Encode.list identity [(jsonEncPlayersMap (jsonEncRole)) v1, jsonEncEndCondition v2]))
                    GameAborted v1 -> ("GameAborted", encodeValue (jsonEncPlayerId v1))
                    GameCrashed  -> ("GameCrashed", encodeValue (Json.Encode.list identity []))
    in encodeSumTwoElementArray keyval val



type NewViewStateEvent  =
    NewViewStateEventChat String
    | NewViewStateEventInput GameStateInputEvent

jsonDecNewViewStateEvent : Json.Decode.Decoder ( NewViewStateEvent )
jsonDecNewViewStateEvent =
    let jsonDecDictNewViewStateEvent = Dict.fromList
            [ ("NewViewStateEventChat", Json.Decode.lazy (\_ -> Json.Decode.map NewViewStateEventChat (Json.Decode.string)))
            , ("NewViewStateEventInput", Json.Decode.lazy (\_ -> Json.Decode.map NewViewStateEventInput (jsonDecGameStateInputEvent)))
            ]
    in  decodeSumTwoElemArray  "NewViewStateEvent" jsonDecDictNewViewStateEvent

jsonEncNewViewStateEvent : NewViewStateEvent -> Value
jsonEncNewViewStateEvent  val =
    let keyval v = case v of
                    NewViewStateEventChat v1 -> ("NewViewStateEventChat", encodeValue (Json.Encode.string v1))
                    NewViewStateEventInput v1 -> ("NewViewStateEventInput", encodeValue (jsonEncGameStateInputEvent v1))
    in encodeSumTwoElementArray keyval val



type alias ViewStateEvent  =
   { viewStateEventTime: Posix
   , viewStateEventPlayer: PlayerId
   , viewStateEventData: ViewStateEventData
   }

jsonDecViewStateEvent : Json.Decode.Decoder ( ViewStateEvent )
jsonDecViewStateEvent =
   Json.Decode.succeed (\pviewStateEventTime pviewStateEventPlayer pviewStateEventData -> {viewStateEventTime = pviewStateEventTime, viewStateEventPlayer = pviewStateEventPlayer, viewStateEventData = pviewStateEventData})
   |> required "viewStateEventTime" (jsonDecPosix)
   |> required "viewStateEventPlayer" (jsonDecPlayerId)
   |> required "viewStateEventData" (jsonDecViewStateEventData)

jsonEncViewStateEvent : ViewStateEvent -> Value
jsonEncViewStateEvent  val =
   Json.Encode.object
   [ ("viewStateEventTime", jsonEncPosix val.viewStateEventTime)
   , ("viewStateEventPlayer", jsonEncPlayerId val.viewStateEventPlayer)
   , ("viewStateEventData", jsonEncViewStateEventData val.viewStateEventData)
   ]



type alias DbPlayer  =
   { dbPlayerId: PlayerId
   , dbPlayerPassword: String
   }

jsonDecDbPlayer : Json.Decode.Decoder ( DbPlayer )
jsonDecDbPlayer =
   Json.Decode.succeed (\pdbPlayerId pdbPlayerPassword -> {dbPlayerId = pdbPlayerId, dbPlayerPassword = pdbPlayerPassword})
   |> required "dbPlayerId" (jsonDecPlayerId)
   |> required "dbPlayerPassword" (Json.Decode.string)

jsonEncDbPlayer : DbPlayer -> Value
jsonEncDbPlayer  val =
   Json.Encode.object
   [ ("dbPlayerId", jsonEncPlayerId val.dbPlayerId)
   , ("dbPlayerPassword", Json.Encode.string val.dbPlayerPassword)
   ]


getApiLobby : Token -> (Maybe Int) -> (Result Http.Error  ((List ChatLine))  -> msg) -> Cmd msg
getApiLobby header_Authorization query_since toMsg =
    let
        params =
            List.filterMap identity
            (List.concat
                [ [ query_since
                    |> Maybe.map (String.fromInt >> Url.Builder.string "since") ]
                ])
    in
        Http.request
            { method =
                "GET"
            , headers =
                List.filterMap identity
                    [ Maybe.map (Http.header "Authorization") (Just header_Authorization)
                    ]
            , url =
                Url.Builder.crossOrigin "http://localhost:8001"
                    [ "api"
                    , "lobby"
                    ]
                    params
            , body =
                Http.emptyBody
            , expect =
                Http.expectJson toMsg (Json.Decode.list (jsonDecChatLine))
            , timeout =
                Nothing
            , tracker =
                Nothing
            }

postApiLobby : Token -> String -> (Result Http.Error  (())  -> msg) -> Cmd msg
postApiLobby header_Authorization body toMsg =
    let
        params =
            List.filterMap identity
            (List.concat
                [])
    in
        Http.request
            { method =
                "POST"
            , headers =
                List.filterMap identity
                    [ Maybe.map (Http.header "Authorization") (Just header_Authorization)
                    ]
            , url =
                Url.Builder.crossOrigin "http://localhost:8001"
                    [ "api"
                    , "lobby"
                    ]
                    params
            , body =
                Http.jsonBody (Json.Encode.string body)
            , expect =
                Http.expectString 
                     (\x -> case x of
                     Err e -> toMsg (Err e)
                     Ok _ -> toMsg (Ok ()))
            , timeout =
                Nothing
            , tracker =
                Nothing
            }

getApiGamesByGameId : Token -> GameId -> (Result Http.Error  (DbViewState)  -> msg) -> Cmd msg
getApiGamesByGameId header_Authorization capture_gameId toMsg =
    let
        params =
            List.filterMap identity
            (List.concat
                [])
    in
        Http.request
            { method =
                "GET"
            , headers =
                List.filterMap identity
                    [ Maybe.map (Http.header "Authorization") (Just header_Authorization)
                    ]
            , url =
                Url.Builder.crossOrigin "http://localhost:8001"
                    [ "api"
                    , "games"
                    , capture_gameId |> String.fromInt
                    ]
                    params
            , body =
                Http.emptyBody
            , expect =
                Http.expectJson toMsg jsonDecDbViewState
            , timeout =
                Nothing
            , tracker =
                Nothing
            }

getApiGamesByGameIdEvents : Token -> GameId -> (Maybe Int) -> (Result Http.Error  ((List ViewStateEvent))  -> msg) -> Cmd msg
getApiGamesByGameIdEvents header_Authorization capture_gameId query_since toMsg =
    let
        params =
            List.filterMap identity
            (List.concat
                [ [ query_since
                    |> Maybe.map (String.fromInt >> Url.Builder.string "since") ]
                ])
    in
        Http.request
            { method =
                "GET"
            , headers =
                List.filterMap identity
                    [ Maybe.map (Http.header "Authorization") (Just header_Authorization)
                    ]
            , url =
                Url.Builder.crossOrigin "http://localhost:8001"
                    [ "api"
                    , "games"
                    , capture_gameId |> String.fromInt
                    , "events"
                    ]
                    params
            , body =
                Http.emptyBody
            , expect =
                Http.expectJson toMsg (Json.Decode.list (jsonDecViewStateEvent))
            , timeout =
                Nothing
            , tracker =
                Nothing
            }

postApiGamesByGameIdEvents : Token -> GameId -> NewViewStateEvent -> (Result Http.Error  (())  -> msg) -> Cmd msg
postApiGamesByGameIdEvents header_Authorization capture_gameId body toMsg =
    let
        params =
            List.filterMap identity
            (List.concat
                [])
    in
        Http.request
            { method =
                "POST"
            , headers =
                List.filterMap identity
                    [ Maybe.map (Http.header "Authorization") (Just header_Authorization)
                    ]
            , url =
                Url.Builder.crossOrigin "http://localhost:8001"
                    [ "api"
                    , "games"
                    , capture_gameId |> String.fromInt
                    , "events"
                    ]
                    params
            , body =
                Http.jsonBody (jsonEncNewViewStateEvent body)
            , expect =
                Http.expectString 
                     (\x -> case x of
                     Err e -> toMsg (Err e)
                     Ok _ -> toMsg (Ok ()))
            , timeout =
                Nothing
            , tracker =
                Nothing
            }

postApiGames : Token -> (Result Http.Error  (GameId)  -> msg) -> Cmd msg
postApiGames header_Authorization toMsg =
    let
        params =
            List.filterMap identity
            (List.concat
                [])
    in
        Http.request
            { method =
                "POST"
            , headers =
                List.filterMap identity
                    [ Maybe.map (Http.header "Authorization") (Just header_Authorization)
                    ]
            , url =
                Url.Builder.crossOrigin "http://localhost:8001"
                    [ "api"
                    , "games"
                    ]
                    params
            , body =
                Http.emptyBody
            , expect =
                Http.expectJson toMsg jsonDecGameId
            , timeout =
                Nothing
            , tracker =
                Nothing
            }

getApiGamesJoinable : Token -> (Result Http.Error  ((List JoinableGame))  -> msg) -> Cmd msg
getApiGamesJoinable header_Authorization toMsg =
    let
        params =
            List.filterMap identity
            (List.concat
                [])
    in
        Http.request
            { method =
                "GET"
            , headers =
                List.filterMap identity
                    [ Maybe.map (Http.header "Authorization") (Just header_Authorization)
                    ]
            , url =
                Url.Builder.crossOrigin "http://localhost:8001"
                    [ "api"
                    , "games"
                    , "joinable"
                    ]
                    params
            , body =
                Http.emptyBody
            , expect =
                Http.expectJson toMsg (Json.Decode.list (jsonDecJoinableGame))
            , timeout =
                Nothing
            , tracker =
                Nothing
            }

postApiPlayers : DbPlayer -> (Result Http.Error  (String)  -> msg) -> Cmd msg
postApiPlayers body toMsg =
    let
        params =
            List.filterMap identity
            (List.concat
                [])
    in
        Http.request
            { method =
                "POST"
            , headers =
                []
            , url =
                Url.Builder.crossOrigin "http://localhost:8001"
                    [ "api"
                    , "players"
                    ]
                    params
            , body =
                Http.jsonBody (jsonEncDbPlayer body)
            , expect =
                Http.expectJson toMsg Json.Decode.string
            , timeout =
                Nothing
            , tracker =
                Nothing
            }

postApiLogin : DbPlayer -> (Result Http.Error  (String)  -> msg) -> Cmd msg
postApiLogin body toMsg =
    let
        params =
            List.filterMap identity
            (List.concat
                [])
    in
        Http.request
            { method =
                "POST"
            , headers =
                []
            , url =
                Url.Builder.crossOrigin "http://localhost:8001"
                    [ "api"
                    , "login"
                    ]
                    params
            , body =
                Http.jsonBody (jsonEncDbPlayer body)
            , expect =
                Http.expectJson toMsg Json.Decode.string
            , timeout =
                Nothing
            , tracker =
                Nothing
            }
