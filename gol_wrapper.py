#!/usr/bin/python2
import gol
import sys;

###############################################################################

FIMG = sys.argv[1];
ODIR = sys.argv[2];
ITER = int(sys.argv[3]);

###############################################################################

print "Reading IMG.RAW";
sys.stdout.flush();

dim0, dim1, IMG = gol.readIMG(FIMG);

print "Preparing machine";
sys.stdout.flush();

G = gol.gol(dim0, dim1, IMG);

###############################################################################

for i in xrange(ITER):
  print '\rRunning %010d/%d' % (i+1, ITER),
  sys.stdout.flush();
  G.step();
#efor
print "";

G.draw(ODIR, 'png');

###############################################################################
