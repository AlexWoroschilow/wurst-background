#!/usr/bin/env python3
import os, re, glob
import os.path
from subprocess import call

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
        return "%s/START" % self._path

    @property
    def status(self):
        return "%s/STATUS" % self._path

    @property
    def stop(self):
        return "%s/STOP" % self._path

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
        pass

    @property
    def tasks(self):
        for task in glob.glob("%s/salami.d/*" % os.getcwd()):
            yield Task(task)
        pass


    def queue(self):
        collection = [task for task in self.tasks]
        collection.sort(reverse=False)
        for task in collection:
            print(task)


    def start(self, name=None):
        if name is not None:
            return self._start_by_name(name)

        collection = [task for task in self.tasks]
        collection.sort(reverse=False)
        for task in collection:
            process = TaskRunner(task)

            if not process.done and process.ready:
                if not process.wait:
                    return process.start()
            
    def _start_by_name(self, name=None):
        for task in self.tasks:
            if task.name == name:
                return (TaskRunner(task)).start()
            
class TaskRunner(object):
    def __init__(self, task):
        self._task = task
        self._status = os.popen(task.status).read();
        print(self._status)
        pass
    
    def start(self):
        print(os.popen(self._task.start).read())
        pass

    @property
    def status(self):
        return self._status;
    
    @property
    def done(self):
        return (self.status.find('done') is not -1)
    
    @property
    def ready(self):
        return (self.status.find('ready') is not -1)

    @property
    def wait(self):
        return (self.status.find('wait') is not -1)
