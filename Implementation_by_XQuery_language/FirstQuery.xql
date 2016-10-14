(: Find all pairs of contestants who happened to audition the same piece during the same show and got the same score from at least one judge. :)

xquery version "3.0";

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
        <FirstContestantName>{$C1/Name/text()}</FirstContestantName>
        <SecondContestantName>{$C2/Name/text()}</SecondContestantName>
    </Result>