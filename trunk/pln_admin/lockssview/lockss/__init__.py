import inspect

print ">> ", inspect.getfile(inspect.currentframe())
print "<< ", inspect.getfile(inspect.currentframe())
