#!/bin/bash
# Copyright 2015 Alex Woroschilow (alex.woroschilow@gmail.com)
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#$ -clear
#$ -q stud.q
#$ -S /bin/bash
set -e
ROOT=$(pwd)
LIBRARY="${ROOT}/lib:${LD_LIBRARY_PATH}"
CONFIG=$1
OUTPUT=$2

# there are no zlog library in 
# zbh system, so we have to add
# custom library path to be able
# to use our logging subsystem
export LD_LIBRARY_PATH=${LIBRARY}

# Start work  
BINARY="${ROOT}/wurstimbiss.x"
${BINARY} -c ${CONFIG} > ${OUTPUT}