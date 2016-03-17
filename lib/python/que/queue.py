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
import re
import glob
import sys
import subprocess
import logging

from time import sleep

class Task(object):
    def __init__(self, path):
        self._logger = logging.getLogger('task')
        self._logger.debug(path)        
        self._path = path
        pass

    @property
    def priority(self):
        priorities = re.findall(r'\d+', self.name)
        if priorities is not None:
            return priorities.pop()
        return None
    
    @property
    def path(self):
        return self._path

    @property
    def start(self):
        return "%s/start" % self._path

    @property
    def status(self):
        return "%s/status" % self._path

    @property
    def name(self):
        return self.path[self.path.rfind('/') + 1:]
    
    def __eq__(self, other):
        return not self.priority < other.priority and not other.priority < self.priority

    def __ne__(self, other):
        return self.priority < other.priority or other.priority < self.priority

    def __gt__(self, other):
        return other.priority < self.priority

    def __ge__(self, other):
        return not self.priority < other.priority

    def __le__(self, other):
        return not other.priority < self.priority    
    
    def __str__(self):
            return self.name


class TaskRunner(object):
    def __init__(self, task):
        self._logger = logging.getLogger('task-runner')
        self._logger.debug(task.name)        
        self._status = None
        self._task = task
        pass

    @property
    def status(self):
        return self._status;

    @status.setter
    def status(self, value):
        self._status = value.decode('utf-8')

    @property
    def is_done(self):
        return self.status == 'done'
    
    @property
    def is_ready(self):
        return self.status == 'ready'

    @property
    def is_wait(self):
        return self.status == 'wait'

    @property
    def is_failure(self):
        return self.status == 'failure'

    def _start(self, script):
        with subprocess.Popen([script], stdout=subprocess.PIPE) as process:
            self._logger.debug("start - %s" % script)        
            self.status, stderrdata = process.communicate()
            self._logger.debug("%s - %s" % (self.status, script))
            return True
        self._logger.error("can not start script: %s " % script)
        return False
    
    def start(self):
        for script in [self._task.status, self._task.start]:
            if not self._start(script):
                return False            
            if self.is_failure or self.is_wait:
                return False
            if self.is_done:
                return True
        return True


class Queue(object):
    def __init__(self, path):
        self._path = path        
        self._logger = logging.getLogger('queue')
        self._logger.debug("folder with tasks: %s" % path)
        pass

    @property
    def tasks(self):
        for task in glob.glob(self._path):
            yield Task(task)

    def queue(self):
        collection = [task for task in self.tasks]
        collection.sort(reverse=False)
        for task in collection:
            print(task)
            
    def start(self, name=None):
        if name is not None:
            return self.start_task(name)

        collection = [task for task in self.tasks]
        collection.sort(reverse=False)
        for task in collection:
            self._logger.debug("%s - start" % task.name)
            process = TaskRunner(task)
            status = process.start()
            self._logger.info("%s - %s" % (task.name, process.status))
            if not status :
                break

            
    def start_task(self, name=None):
        for task in self.tasks:
            if task.name == name:
                self._logger.info(name)
                process = TaskRunner(task)
                return process.start()

