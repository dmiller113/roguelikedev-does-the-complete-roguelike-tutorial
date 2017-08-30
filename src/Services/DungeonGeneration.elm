module Services.DungeonGeneration exposing (DungeonGenerator(..), generatorToCharList)

import Constants.Map exposing (defaultMap, bigRoom)
import Array exposing (Array)
import Dict exposing (Dict)
import Random exposing (Generator, Seed, pair, bool, int)
import Lib.Utils exposing (mapWithRandom)


type DungeonGenerator
    = ConstantGenerator Seed
    | RogueGenerator Int Int Seed


type CorridorOrientation
    = Left
    | Right
    | Up
    | Down


type alias RoomInfo =
    { tX : Int
    , tY : Int
    , section : Int
    , width : Int
    , height : Int
    }


type alias Coord =
    { x : Int
    , y : Int
    }


type alias CorridorInfo =
    { beginSection : Int
    , endSection : Int
    , startEnd : ( Coord, Coord )
    }


rogueRoomCoords =
    pair (int 1 20) (int 1 8)


rogueRoomGenerator =
    Random.map2 generateRoom rogueRoomCoords rogueRoomCoords


rogueConnectionGenerator =
    Random.pair (Random.bool) (Random.bool)


generatorToCharList : DungeonGenerator -> ( List Char, Seed )
generatorToCharList generator =
    case generator of
        ConstantGenerator seed ->
            ( String.toList defaultMap, seed )

        RogueGenerator width height seed ->
            generateRooms width height 12 seed


generateRooms : Int -> Int -> Int -> Seed -> ( List Char, Seed )
generateRooms width height sections seed =
    let
        ( roomInfos, middleSeed ) =
            List.range 0 (sections - 1)
                |> mapWithRandom finishRogueRoom rogueRoomGenerator seed
    in
        createMap width height middleSeed roomInfos


generateRoom : ( Int, Int ) -> ( Int, Int ) -> RoomInfo
generateRoom coords1 coords2 =
    let
        tx =
            min (Tuple.first coords1) (Tuple.first coords2) |> min 15

        ty =
            min (Tuple.second coords1) (Tuple.second coords2) |> min 3

        bx =
            max (Tuple.first coords1) (Tuple.first coords2) |> min 18

        by =
            max (Tuple.second coords1) (Tuple.second coords2) |> min 6
    in
        { tX = max 1 tx
        , tY = max 1 ty
        , width = bx - tx |> max 3
        , height = by - ty |> max 4
        , section = 0
        }


finishRogueRoom : RoomInfo -> Int -> RoomInfo
finishRogueRoom ri section =
    { ri | section = section }


createMap : Int -> Int -> Seed -> List RoomInfo -> ( List Char, Seed )
createMap width height seed roomInfos =
    let
        initMap =
            Array.repeat (width * height) '#'

        rough =
            List.map (\i -> ( i.section, i )) roomInfos

        rooms =
            List.map .section roomInfos |> Array.fromList

        roomDict =
            Dict.fromList rough

        ( corridorInfos, newSeed ) =
            joinSections seed roomDict rooms [] [] []

        corridorIndex =
            List.concatMap corridorInfoToIndexes corridorInfos

        roomMap =
            (List.foldl changeMapWithRi initMap roomInfos) |> (addPlayerSpawn <| List.head roomInfos)

        map =
            List.foldl (\i accum -> Array.set i ':' accum) roomMap corridorIndex
    in
        ( Array.toList map, newSeed )


addPlayerSpawn : Maybe RoomInfo -> Array Char -> Array Char
addPlayerSpawn ri acc =
    case ri of
        Nothing ->
            acc

        Just info ->
            let
                playerIndex =
                    rogueTranslateSCoordToCoord info.section info
            in
                Array.set playerIndex '@' acc


changeMapWithRi : RoomInfo -> Array Char -> Array Char
changeMapWithRi ri acc =
    let
        h =
            List.range 0 (ri.height - 1)

        sectionX =
            (ri.section % 4)

        sectionY =
            (ri.section // 4)

        indexes =
            (List.concatMap (rogueFormCoords sectionX sectionY ri) h)
    in
        List.foldl (\i accum -> Array.set i '.' accum) acc indexes


joinSections : Seed -> Dict Int RoomInfo -> Array Int -> List Int -> List Int -> List CorridorInfo -> ( List CorridorInfo, Seed )
joinSections currentSeed rooms unlinkedSections linkedSections currentSections acc =
    case Array.get 0 unlinkedSections of
        Maybe.Nothing ->
            ( acc, currentSeed )

        Maybe.Just section ->
            let
                ( index, midSeed ) =
                    Random.step (int 0 ((Array.length unlinkedSections) - 1)) currentSeed

                usection =
                    case List.head currentSections of
                        Nothing ->
                            Maybe.withDefault 0 <| Array.get index unlinkedSections

                        Just i ->
                            i

                ( connection, newSeed ) =
                    Random.step rogueConnectionGenerator midSeed

                curSectionX =
                    (usection % 4)

                curSectionY =
                    (usection // 4)

                posSectionX =
                    case connection of
                        ( True, True ) ->
                            if (curSectionX + 1) > 3 then
                                2
                            else
                                (curSectionX + 1)

                        ( True, False ) ->
                            if (curSectionX - 1) < 0 then
                                1
                            else
                                (curSectionX - 1)

                        _ ->
                            curSectionX

                posSectionY =
                    case connection of
                        ( False, True ) ->
                            if (curSectionY + 1) > 2 then
                                1
                            else
                                (curSectionY + 1)

                        ( False, False ) ->
                            if (curSectionY - 1) < 0 then
                                1
                            else
                                (curSectionY - 1)

                        _ ->
                            curSectionY

                posSection =
                    posSectionY * 4 + posSectionX

                posRi =
                    Dict.get posSection rooms

                ri =
                    flip Dict.get rooms usection

                ci =
                    createCorridorInfo ri posRi

                newAcc =
                    case ci of
                        Nothing ->
                            acc

                        Just corridor ->
                            corridor :: acc

                workingSections =
                    if List.isEmpty currentSections then
                        posSection :: usection :: currentSections
                    else
                        posSection :: currentSections
            in
                if List.member posSection linkedSections || List.isEmpty linkedSections then
                    let
                        unlinked =
                            Array.filter (\i -> not <| (flip List.member) workingSections i) unlinkedSections
                    in
                        joinSections newSeed rooms unlinked (workingSections ++ linkedSections) [] newAcc
                else
                    joinSections newSeed rooms unlinkedSections linkedSections workingSections newAcc


createCorridorInfo : Maybe RoomInfo -> Maybe RoomInfo -> Maybe CorridorInfo
createCorridorInfo startRoom endRoom =
    case ( startRoom, endRoom ) of
        ( Nothing, _ ) ->
            Nothing

        ( _, Nothing ) ->
            Nothing

        ( Just s, Just e ) ->
            let
                begin =
                    if s.section <= e.section then
                        s
                    else
                        e

                end =
                    if s.section > e.section then
                        s
                    else
                        e

                orientation =
                    getOrientation <| compareRooms begin end
            in
                case orientation of
                    Down ->
                        Just
                            { beginSection = begin.section
                            , endSection = end.section
                            , startEnd =
                                ( { x = (begin.tX + begin.width // 2), y = (begin.tY + begin.height) }
                                , { x = (end.tX + end.width // 2), y = (end.tY - 1) }
                                )
                            }

                    Right ->
                        Just
                            { beginSection = begin.section
                            , endSection = end.section
                            , startEnd =
                                ( { x = (begin.tX + begin.width + 1), y = (begin.tY + begin.height // 2) }
                                , { x = (end.tX - 1), y = (end.tY + end.height // 2) }
                                )
                            }

                    _ ->
                        Just
                            { beginSection = begin.section
                            , endSection = end.section
                            , startEnd =
                                ( { x = (begin.tX + begin.width // 2), y = (begin.tY + begin.height // 2) }
                                , { x = (end.tX + end.width // 2), y = (end.tY + end.height // 2) }
                                )
                            }


compareRooms : RoomInfo -> RoomInfo -> ( Order, Order )
compareRooms begin end =
    ( (compare (begin.section % 4) (end.section % 4)), (compare (begin.section // 4) (end.section // 4)) )


createRogueCorridor : Array RoomInfo -> ( Bool, Bool ) -> RoomInfo -> CorridorInfo
createRogueCorridor roomArray ( isX, sign ) ri =
    let
        amount =
            if sign then
                1
            else
                -1

        elSection =
            ri.section

        sectionX =
            ri.section % 4

        sectionY =
            ri.section // 4

        newSectionX =
            if isX then
                if sectionX + amount > 3 then
                    2
                else if sectionX + amount < 0 then
                    1
                else
                    sectionX + amount
            else
                sectionX

        newSectionY =
            if not isX then
                if sectionY + amount > 2 then
                    1
                else if sectionY + amount < 0 then
                    1
                else
                    sectionY + amount
            else
                sectionY

        newSection =
            newSectionX + (newSectionY * 4)

        endRi =
            Maybe.withDefault ri <| Array.get newSection roomArray
    in
        { beginSection = ri.section
        , endSection = newSection
        , startEnd =
            ( { x = (ri.tX + ri.width // 2), y = (ri.tY + ri.height // 2) }
            , { x = (endRi.tX + endRi.width // 2), y = (endRi.tY + endRi.height // 2) }
            )
        }


corridorInfoToIndexes : CorridorInfo -> List Int
corridorInfoToIndexes { beginSection, endSection, startEnd } =
    List.concat
        [ (sectionCorridor beginSection ( compare (beginSection % 4) (endSection % 4), compare (beginSection // 4) (endSection // 4) ) (Tuple.first startEnd))
        , (sectionCorridor endSection ( compare (endSection % 4) (beginSection % 4), compare (endSection // 4) (beginSection // 4) ) (Tuple.second startEnd))
        , (joinVertically beginSection endSection startEnd)
        , (joinHorizontally beginSection endSection startEnd)
        ]


sectionCorridor : Int -> ( Order, Order ) -> Coord -> List Int
sectionCorridor section order { x, y } =
    let
        orientation =
            getOrientation order

        ( rStart, rEnd ) =
            properCorridorOrder orientation { x = x, y = y }

        start =
            rogueTranslateSCoordToCoord section rStart

        end =
            rogueTranslateSCoordToCoord section rEnd
    in
        if orientation == Left || orientation == Right then
            List.range
                (start)
                (end)
        else
            List.map callTranslateWithSection <|
                verticalLink (abs (rStart.tY - rEnd.tY)) section { x = rStart.tX, y = rStart.tY }


callTranslateWithSection : { a | tX : Int, tY : Int, section : Int } -> Int
callTranslateWithSection a =
    rogueTranslateSCoordToCoord a.section a


joinHorizontally : Int -> Int -> ( Coord, Coord ) -> List Int
joinHorizontally beginSection endSection ( start, end ) =
    let
        orientation =
            getOrientation
                ( compare (beginSection % 4) (endSection % 4)
                , compare (beginSection // 4) (endSection // 4)
                )

        ( startCoord, endCoord ) =
            case orientation of
                Down ->
                    ( { tX = (min start.x end.x), tY = 8 }, { tX = (max start.x end.x), tY = 8 } )

                Up ->
                    ( { tX = (min start.x end.x), tY = 0 }, { tX = (max start.x end.x), tY = 0 } )

                _ ->
                    ( { tX = start.x, tY = start.y }, { tX = end.x, tY = end.y } )

        startIndex =
            rogueTranslateSCoordToCoord beginSection startCoord

        endIndex =
            rogueTranslateSCoordToCoord beginSection endCoord
    in
        if orientation == Up || orientation == Down then
            List.range startIndex endIndex
        else
            []


joinVertically : Int -> Int -> ( Coord, Coord ) -> List Int
joinVertically beginSection endSection ( start, end ) =
    let
        orientation =
            getOrientation
                ( compare (beginSection % 4) (endSection % 4)
                , compare (beginSection // 4) (endSection // 4)
                )

        startCoord =
            case orientation of
                Right ->
                    { start | x = 20, y = (min start.y end.y) }

                Left ->
                    { start | x = 0, y = (min start.y end.y) }

                _ ->
                    start
    in
        if orientation == Right || orientation == Left then
            List.map callTranslateWithSection <|
                verticalLink (abs (start.y - end.y)) beginSection startCoord
        else
            []


verticalLink : Int -> Int -> { a | x : Int, y : Int } -> List { tX : Int, tY : Int, section : Int }
verticalLink height section start =
    -- let
    -- h = Debug.log "Height" height
    -- s = Debug.log "Section" section
    -- in
    List.range start.y (start.y + height)
        |> List.map (constructVCoord section start)



-- |> Debug.log "v's"


constructVCoord : Int -> { a | x : Int, y : Int } -> Int -> { tX : Int, tY : Int, section : Int }
constructVCoord section { x, y } hl =
    let
        -- aset = Debug.log "x, y, hl, section" (x, y, hl, section)
        newSection =
            section + (hl // 8)

        -- |> Debug.log "New Section"
    in
        { tX = x, tY = hl % 8, section = newSection }


getOrientation : ( Order, Order ) -> CorridorOrientation
getOrientation ( horizontal, verticle ) =
    case ( horizontal, verticle ) of
        ( GT, EQ ) ->
            Left

        ( LT, EQ ) ->
            Right

        ( EQ, GT ) ->
            Up

        ( EQ, LT ) ->
            Down

        _ ->
            Left |> Debug.log "wat"


properCorridorOrder : CorridorOrientation -> Coord -> ( { tX : Int, tY : Int }, { tX : Int, tY : Int } )
properCorridorOrder orientation { x, y } =
    case orientation of
        Left ->
            -- Going left, to zero
            ( { tX = 0, tY = y }, { tX = x, tY = y } )

        Right ->
            -- Going right to 19
            ( { tX = x, tY = y }, { tX = 19, tY = y } )

        Up ->
            -- Going up to 0
            ( { tX = x, tY = 0 }, { tX = x, tY = y } )

        Down ->
            -- Going down to 7
            ( { tX = x, tY = y }, { tX = x, tY = 7 } )


formCoords : Int -> Int -> Int -> Int -> RoomInfo -> Int -> List Int
formCoords sectionWidth sectionHeight sectionX sectionY ri hi =
    List.range (translateSCoordToCoord sectionWidth sectionHeight 80 hi sectionX sectionY ri)
        (translateSCoordToCoord sectionWidth sectionHeight 80 hi sectionX sectionY { ri | tX = ri.tX + ri.width })


rogueFormCoords : Int -> Int -> RoomInfo -> Int -> List Int
rogueFormCoords =
    formCoords (80 // 4) (24 // 3)


translateSCoordToCoord : Int -> Int -> Int -> Int -> Int -> Int -> { a | tX : Int, tY : Int } -> Int
translateSCoordToCoord sectionWidth sectionHeight mapHeight heightLine sectionX sectionY { tX, tY } =
    (tX + (sectionX * sectionWidth)) + ((heightLine + (tY + (sectionY * sectionHeight))) * mapHeight)


rogueTranslateSCoordToCoord : Int -> { a | tX : Int, tY : Int } -> Int
rogueTranslateSCoordToCoord section ri =
    translateSCoordToCoord (80 // 4) (24 // 3) 80 0 (section % 4) (section // 4) ri
