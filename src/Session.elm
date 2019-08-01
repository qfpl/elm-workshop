module Session exposing (Player, playerDecode, playerEncode)

import Generated.Api exposing (Token)
import Json.Decode as Decode
import Json.Decode.Pipeline exposing (custom)
import Json.Encode as Encode


type alias Player =
    { playerId : String
    , token : Token
    }


playerEncode : Player -> Encode.Value
playerEncode p =
    Encode.object [ ( "playerId", Encode.string p.playerId ), ( "token", Encode.string p.token ) ]


playerDecode : Decode.Decoder Player
playerDecode =
    Decode.map2 Player (Decode.field "playerId" Decode.string) (Decode.field "token" Decode.string)
