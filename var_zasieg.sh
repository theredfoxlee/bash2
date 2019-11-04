#!/bin/bash
function zmienne() {
    local var_local=4096
    var_global=128
    echo "  var_local => ${var_local}"
    echo "  var_global => ${var_global}"
}
echo "| Zmienne w funkcji:"
zmienne
echo "| Zmienne poza funkcją:"
echo "  var_local => ${var_local}"
echo "  var_global => ${var_global}"
