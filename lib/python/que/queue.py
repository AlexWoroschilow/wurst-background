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
from time import sleep

class Task(object):
    def __init__(self, path):
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


class Queue(object):
    def __init__(self, path):
        self._path = path
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
            process = TaskRunner(task)
            if not process.start() :
                break
            
            
    def start_task(self, name=None):
        for task in self.tasks:
            if task.name == name:
                process = TaskRunner(task)
                return process.start()
            
class TaskRunner(object):
    def __init__(self, task):
        self._status = None
        self._task = task
        pass

    @property
    def status(self):
        return self._status;

    @status.setter
    def status(self, value):
        self._status = value.decode('utf-8')
        print(self._task.name, "\t", self._status)
    
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
    
    
    def start(self):
        with subprocess.Popen([self._task.status], stdout=subprocess.PIPE) as process:
            self.status, stderrdata = process.communicate()
            if self.is_done:
                return True            
            if self.is_ready:
                with subprocess.Popen([self._task.start], stdout=subprocess.PIPE) as process:
                    self.status, stderrdata = process.communicate()
                    if self.is_done:
                        return True
        return False

