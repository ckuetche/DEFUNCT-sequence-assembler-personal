declare -A reads
while read id seq; do
    reads["$id"]="$seq"
done < preprocessed_reads.txt

first_id=$(./find_first_read.sh)

consensus+=${reads[$first_id]}
unset reads[$first_id]

while (( ${#reads[@]} > 0 )); do
    best_len=0
    best_read=""

    for read_id in "${!reads[@]}"; do
        read=${reads[$read_id]}
        len_consensus=${#consensus}
        len_read=${#read}

        #determine maximum possible overlap
        if (( len_consensus < len_read )); then
            max_overlap=$len_consensus
        else
            max_overlap=$len_read
        fi

        # Check all possible overlap lengths
        for (( overlap_len=1; overlap_len<=max_overlap; overlap_len++ )); do
            suffix=${consensus: -$overlap_len}
            prefix=${read:0:$overlap_len}

            if [[ "$suffix" == "$prefix" ]]; then
                if (( overlap_len > best_len )); then
                    best_len=$overlap_len
                    best_read_id=$read_id
                fi
            fi
        done
    done

    # If we found a read that overlaps, append it
    if (( best_len > 0 )); then
        consensus+=${reads[$best_read_id]:$best_len}
        unset reads[$best_read_id]
    else
        break  # no overlaps left
    fi
done

echo "Consensus sequence: $consensus"