#!/bin/bash

coproc STOCKFISH { stdbuf -oL stockfish; }

send_command() {
    echo "$1" >&${STOCKFISH[1]}
}

read_output() {
    local cmd="$1"
    local timeout=0.1

    while read -t "$timeout" -u ${STOCKFISH[0]} line; do
        echo "$line"
    done
    
    # Deals with problem of not receving 'bestmove' after go command
    if [[ "$cmd" == "go"* ]]; then
        while read -t 5 -u ${STOCKFISH[0]} line; do
            echo "$line"
            if [[ "$line" == "bestmove"* ]]; then
                break
            fi
        done
    fi
}

send_command "uci"
sleep 1
read_output "uci"

echo "Stockfish Interactive Interface"
echo "Type 'quit' to exit."

while true; do
    read -e -p "> " cmd
    history -s "$cmd"
    
    if [[ "$cmd" == "quit" ]]; then
        break
    fi
    
    send_command "$cmd"
    read_output "$cmd"
done

kill $STOCKFISH_PID
