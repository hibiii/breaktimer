#!/bin/sh
case "$1" in
"test")
    pkill -SIGALRM bktimer
    ;;
"ack")
    pkill -SIGUSR1 bktimer
    ;;
"stand")
    pkill -SIGUSR2 bktimer
    ;;
"sit")
    pkill -50 bktimer
    ;;
*)
    echo "use \"test\", \"ack\", \"stand\", or \"sit\" for the first argument."
    ;;
esac
