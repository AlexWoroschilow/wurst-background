#!/usr/bin/python3
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
import os
from queue import Queue
from optparse import OptionParser

if __name__ == "__main__":
    parser = OptionParser()
    parser.add_option("-t", "--task", default=False, dest="task", help="enable debug mode")
    parser.add_option("-q", "--queue", action="store_true", default=False, dest="queue", help="show devices")


    (options, args) = parser.parse_args()

    queue = Queue("%s/salami.d/*" % os.getcwd())
    queue.queue() \
        if options.queue \
        else queue.start(options.task)
