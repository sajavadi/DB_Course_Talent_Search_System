(: Find all pairs of contestants who auditioned the same piece in (possibly different) shows that had at least 3 judges and the two contestants got the same highest score. :)

xquery version "3.0";

for $C1 in doc("/db/Javadi_Talent_Sys.xml")/Talent_Sys/Contestants/Contestant,
    $C2 in doc("/db/Javadi_Talent_Sys.xml")/Talent_Sys/Contestants/Contestant
where 
    $C1/ConID < $C2/ConID and 
    (some 
        $C1Audition in $C1/AuditionList/Audition, 
        $C2Audition in $C2/AuditionList/Audition  
            satisfies 
                $C1Audition/AWID = $C2Audition/AWID and 
                count($C1Audition/ScoreList/JudgeScore/JID)> 2 and 
                count($C2Audition/ScoreList/JudgeScore/JID) > 2 and
                max($C1Audition/ScoreList/JudgeScore/Score) = max($C2Audition/ScoreList/JudgeScore/Score)
    )
return
    <Result>
        <FirstContestantName>{$C1/Name/text()}</FirstContestantName>
        <SecondContestantName>{$C2/Name/text()}</SecondContestantName>
    </Result>