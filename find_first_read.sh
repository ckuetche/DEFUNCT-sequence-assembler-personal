#!/bin/bash

declare -A reads

# Load reads into associative array
while read id seq; do
    reads["$id"]="$seq"
done < preprocessed_reads.txt

detect_overlap() {
    local test_id=$1
    local test_seq=${reads[$test_id]}
    local len_test=${#test_seq}

    for other_id in "${!reads[@]}"; do
        [[ "$other_id" == "$test_id" ]] && continue
        local other_seq=${reads[$other_id]}
        local len_other=${#other_seq}

        # maximum possible overlap is the shorter of the two
        local max_overlap=$(( len_test < len_other ? len_test : len_other ))

        for ((k=1; k<=max_overlap; k++)); do
            local suffix=${other_seq: -$k}
            local prefix=${test_seq:0:$k}
            if [[ "$suffix" == "$prefix" ]]; then
                return 0  # found a read that overlaps on the left
            fi
        done
    done

    return 1  #match not found
}

# Find the first read
for id in "${!reads[@]}"; do
    if ! detect_overlap "$id"; then
        echo "$id"
        break
    fi
done
