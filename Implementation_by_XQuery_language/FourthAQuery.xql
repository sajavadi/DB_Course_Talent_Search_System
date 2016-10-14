(: Find all pairs of contestants such that the rst contestants has performed all the pieces of the second contestant (possibly in different shows) :)

xquery version "3.0";

for $C1 in doc("/db/Javadi_Talent_Sys.xml")/Talent_Sys/Contestants/Contestant,
    $C2 in doc("/db/Javadi_Talent_Sys.xml")/Talent_Sys/Contestants/Contestant
where 
    $C1/ConID != $C2/ConID and
    not (
            for $A2 in $C2/AuditionList/Audition
                where
                    not (some 
                            $A1 in $C1/AuditionList/Audition 
                            satisfies 
                                $A1/AWID = $A2/AWID
                        )
                return $A2
        )
    
return
    <Result>
        <FirstContestantName>{$C1/Name/text()}</FirstContestantName>
        <SecondContestantName>{$C2/Name/text()}</SecondContestantName>
    </Result>