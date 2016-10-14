(: Find all chained co-auditions. A chained co-auditions is the transitive closure of the following binary relation: X and Y (directly) co-auditioned iff they both performed the same piece in the same show and got the same score from at least one (same) judge. Thus, a chained co-audition can be either a direct or an indirect co-audition. :)

xquery version "3.0";
declare namespace ex="http://exist-db.org/xquery/ex";

declare function ex:DirectCoAuditioned() as element()*
{
    for $C1 in doc("/db/Javadi_Talent_Sys.xml")/Talent_Sys/Contestants/Contestant,
    $C2 in doc("/db/Javadi_Talent_Sys.xml")/Talent_Sys/Contestants/Contestant
	where 
    $C1/ConID < $C2/ConID and 
    (some 
        $C1Audition in $C1/AuditionList/Audition, 
        $C2Audition in $C2/AuditionList/Audition  
            satisfies 
                $C1Audition/ShowName = $C2Audition/ShowName and
                $C1Audition/AWID = $C2Audition/AWID and 
                (some 
                    $C1Score in $C1Audition/ScoreList/JudgeScore, 
                    $C2Score in $C2Audition/ScoreList/JudgeScore 
                        satisfies 
                            $C1Score/JID = $C2Score/JID and 
                            $C1Score/Score = $C2Score/Score
                )
    ) 
    return  
        <Result>
            <FirstContestant>
                <Name> {$C1/Name/text()}</Name>
                <ConID> {$C1/ConID/text()} </ConID>
            </FirstContestant>
            <SecondContestant>
                <Name> {$C2/Name/text()}</Name>
                <ConID> {$C2/ConID/text()} </ConID>    
            </SecondContestant>
        </Result>
} ;
declare function ex:JoinCoAuditons($allCoAuditioned)  as element()*
{
    let $directCoAuditioned := ex:DirectCoAuditioned()
    let $tmp := $allCoAuditioned 
  
    for $CA1 in $directCoAuditioned,
        $CA2 in $tmp
    where 
        $CA1/SecondContestant/ConID = $CA2/FirstContestant/ConID
    return  
            <Result>
                <FirstContestant>
                    <Name> {$CA1/FirstContestant/Name/text()}</Name>
                    <ConID> {$CA1/FirstContestant/ConID/text()} </ConID>
                </FirstContestant>
                <SecondContestant>
                    <Name> {$CA2/SecondContestant/Name/text()}</Name>
                    <ConID> {$CA2/SecondContestant/ConID/text()} </ConID>    
                </SecondContestant>
            </Result>
} ;

declare function ex:AllCoAuditioned($allCoAuditioned)  as element()*
{
  let $tmp := $allCoAuditioned | ex:JoinCoAuditons($allCoAuditioned)
  
  return 
        if 
        (every 
            $CA1 in $tmp 
                satisfies 
                    (some 
                        $CA2 in $allCoAuditioned 
                            satisfies 
                                $CA2/FirstContestant/ConID = $CA1/FirstContestant/ConID and 
                                $CA2/SecondContestant/ConID = $CA1/SecondContestant/ConID
                    )
        )
        
        then 
            $allCoAuditioned
        else 
            ex:AllCoAuditioned($tmp) 
  
} ;

let $allCoAuditioned := ex:AllCoAuditioned(ex:DirectCoAuditioned())
for $r in $allCoAuditioned
    return 
    <Result>
        <FirstContestantName>{$r/FirstContestant/Name/text()}</FirstContestantName>
        <SecondContestantName>{$r/SecondContestant/Name/text()}</SecondContestantName>
    </Result>
    
