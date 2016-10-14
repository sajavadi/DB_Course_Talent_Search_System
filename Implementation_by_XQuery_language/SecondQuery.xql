(: Find all pairs of contestants who happened to audition the same piece (in possibly different shows) and got the same average score for that piece. :)

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
            avg($C1Audition/ScoreList/JudgeScore/Score) = avg($C2Audition/ScoreList/JudgeScore/Score)
    )
return
    <Result>
        <FirstContestantName>{$C1/Name/text()}</FirstContestantName>
        <SecondContestantName>{$C2/Name/text()}</SecondContestantName>
    </Result>
