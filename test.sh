#!/bin/bash
export JULIA_NUM_THREADS=7

echo "Running analysis for $1"

julia 4qubits_single_temperature.jl $1 0.8506

julia 4qubits_single_temperature.jl $1 0.846

echo "Done running for $1 !!!"
