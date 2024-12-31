
def register(params)

end

def filter(event)

    durations = event.get("[@metadata][checkpointDuration]").split(' ')
    checkpointDurationms = 0

    durations.each do |duration|
        if duration["ms"]
            checkpointDurationms += duration.delete("^0-9").to_i
        else 
            if duration["s"]
                checkpointDurationms += duration.delete("^0-9").to_i * 1000
            else
                if duration["m"]
                    checkpointDurationms += duration.delete("^0-9").to_i * 60000
                elsif duration["h"]
                    checkpointDurationms += duration.delete("^0-9").to_i * 3600000
                end
            end
        end
    end
    
    event.set("[neo4j][debug][checkpoint][durationms]", checkpointDurationms)
    return [event]
end
