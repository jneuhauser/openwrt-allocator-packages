#!/bin/sh

# config
RESULT_FILE="malloc-benchmarks/$(date +%Y%m%d%H%M%S)_malloc_benchmark.result"
MALLOC_LIBS="libc.so libmimalloc.so libjemalloc.so librpmallocwrap.so"
ENABLED_TESTS="
alloc-test
barnes
cache-scratch
cache-thrash
cfrac
espresso
larson
malloc-test
malloc-large
mstress
rptest
sh6bench
sh8bench
xmalloc-test
"
LD_PATHS="/lib /usr/lib /usr/local/lib"
BARNES_INPUT_FILE="/usr/share/barnes/input"
ESPRESSO_INPUT_FILE="/usr/share/espresso/largest.espresso"

# auto cfg
NPROC=$( grep -c processor /proc/cpuinfo )

# args
[ "$1" = DEBUG ] && set -x && shift
[ $# -gt 0 ] && ENABLED_TESTS="$*"

echo "Searching for available malloc libraries..."
LD_PATHS_TMP=
for d in $LD_PATHS ; do
    [ -d "$d" ] && LD_PATHS_TMP="$LD_PATHS_TMP $d"
done
LD_PATHS=$LD_PATHS_TMP
AVAILABLE_MALLOC_LIBS=""
for name in $MALLOC_LIBS ; do
    # We need word splitting for LD_PATHS, so no double quotes here!
    so=$( find $LD_PATHS -type f -iname "${name}*" | sort | tail -n 1 )
    if [ -f "$so" ] ; then
        echo " Found: $so"
        AVAILABLE_MALLOC_LIBS="$AVAILABLE_MALLOC_LIBS $so"
    fi
done

echo "Searching for available benchmarks..."
AVAILABLE_BENCHMARKS=""
for bench in $ENABLED_TESTS ; do
    if command -v "$bench" >/dev/null 2>&1 ; then
        echo " Found: $bench"
        AVAILABLE_BENCHMARKS="$AVAILABLE_BENCHMARKS $bench"
    fi
done

run_with_time() {
    [ $# -lt 4 ] && echo "run_with_time: missing args" && return 1
    local input=$1
    shift
    local output=$1
    shift
    local name=$1
    shift
    local cmd=$1
    shift
    local args
    [ $# -gt 0 ] && args=$*
    local lib=${LD_PRELOAD##*/}
    lib=${lib%%.so*}
    GNU_TIME=$( type -P time )
    echo "Running $name with $lib"
    # We need word splitting for args, so no double quotes here!
    $GNU_TIME --format "%U\\t%S\\t%E\\t%X\\t%D\\t%M\\t%F\\t%R\\t%W\\t$lib\\t$name\\t$cmd\\t$args" \
        --quiet --append --output "$RESULT_FILE" \
        "$cmd" $args < "$input" > "$output" 2>&1
    tail -n 1 "$RESULT_FILE"
}

run_benchmark() {
    local bench=$1

    case "$bench" in
        alloc-test|\
        sh6bench|\
        sh8bench)
            run_with_time /dev/null /dev/null "$bench" "$bench" 1
            if [ "$NPROC" -gt 1 ] ; then
                run_with_time /dev/null /dev/null "$bench$NPROC" "$bench" "$NPROC"
            fi
            ;;
        barnes)
            run_with_time "$BARNES_INPUT_FILE" /dev/null "$bench" "$bench"
            ;;
        cache-scratch|\
        cache-thrash)
            run_with_time /dev/null /dev/null "$bench" "$bench" 1 1000 1 2000000 1
            if [ "$NPROC" -gt 1 ] ; then
                run_with_time /dev/null /dev/null "$bench$NPROC" "$bench" "$NPROC" 1000 1 2000000 "$NPROC"
            fi
            ;;
        cfrac)
            run_with_time /dev/null /dev/null "$bench" "$bench" 175451865205073170563711388363274837927895
            ;;
        espresso)
            run_with_time /dev/null /dev/null "$bench" "$bench" -s "$ESPRESSO_INPUT_FILE"
            ;;
        larson)
            run_with_time /dev/null /dev/null "$bench" "$bench" 2.5 7 8 1000 10000 42 100
            ;;
        malloc-test)
            case "$(uname -m)" in
                x86*|i?86) ITERATIONS="1000000000" ;;
                aarch64|arm*) ITERATIONS="100000000" ;;
                *) ITERATIONS="10000000" ;;
            esac
            run_with_time /dev/null /dev/null "${bench}1k" "$bench" 1024 $ITERATIONS "$NPROC"
            run_with_time /dev/null /dev/null "${bench}10k" "$bench" 10240 $ITERATIONS "$NPROC"
            ;;
        malloc-large)
            run_with_time /dev/null /dev/null "$bench" "$bench"
            ;;
        mstress)
            run_with_time /dev/null /dev/null "$bench" "$bench" 1
            if [ "$NPROC" -gt 1 ] ; then
                run_with_time /dev/null /dev/null "$bench$NPROC" "$bench" "$NPROC"
            fi
            ;;
        rptest)
            run_with_time /dev/null /dev/null "$bench$NPROC" "$bench" "$NPROC" 0 2 2 500 1000 200 8 32000
            #run_with_time /dev/null /dev/null $bench$NPROC $bench $NPROC 0 1 2 1000 1000 500 8 64000
            #run_with_time /dev/null /dev/null $bench$NPROC $bench $NPROC 0 2 2 500 1000 200 16 1600000
            threads=$((4*NPROC))
            run_with_time /dev/null /dev/null "$bench$threads" "$bench" "$threads" 0 2 2 500 1000 200 8 32000
            ;;
        xmalloc-test)
            case "$(uname -m)" in
                x86*|i?86|aarch64|arm*) COUNT="100000000" ;;
                *) COUNT="10000000" ;;
            esac
            threads=$((4*NPROC))
            #run_with_time /dev/null /dev/null "$bench" "$bench" -w $threads -t 5 -s '-1'
            run_with_time /dev/null /dev/null "$bench$NPROC" "$bench" -w "$NPROC" -c "$COUNT" -s '-1'
            run_with_time /dev/null /dev/null "$bench$threads" "$bench" -w "$threads" -c "$COUNT" -s '-1'
            ;;
        *)
            echo "ERROR: unknown benchmark: $bench"
            ;;
    esac
}

run_available_benchmarks_with_available_malloc_libs() {
    for lib in $AVAILABLE_MALLOC_LIBS ; do
        LD_PRELOAD="/lib/libatomic.so.1 $lib"
        export LD_PRELOAD
        for bench in $AVAILABLE_BENCHMARKS ; do
            run_benchmark "$bench"
            sleep 5
        done
    done
}

mkdir -p "$(dirname "$RESULT_FILE")"

run_available_benchmarks_with_available_malloc_libs
