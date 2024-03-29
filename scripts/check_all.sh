#!/usr/bin/env bash

ENGINE=${ENGINE:-podman}

function yc {
    $ENGINE run --rm -t -v $PWD:/workdir docker.io/chevdor/yamlcheck $@
}

echo "Using yamlcheck $(yc --version)"

overall_tmp=$(mktemp)

echo 0 > $overall_tmp
find chain_info -name "*.yaml" | sort | while read -r f; do
    yc check -s ./schemas/pnd_chain-schema.json --file "$f" > /dev/null
    res=$?
    if (( res == 0 )); then
        status="OK "
    else
        status="ERR"
        echo 1 > $overall_tmp
    fi
    short_name=$(basename "$f" | cut -d "." -f1)

    echo "$status : $short_name"
done

overall=$(cat $overall_tmp)
exit $overall
