import numpy as np;
import matplotlib.pyplot as plt;
import sys;
import os;

###############################################################################

class gol:

  dim0 = 0;
  dim1 = 0;
  iter = 0;

  C        = None; # Current state
  P        = None; # Past states
  neighmap = None; # Neighborhood map for each cell, precomputed.

  #############################################################################

  def __init__(self, dim0, dim1, IMG):

    self.dim0     = dim0;
    self.dim1     = dim1;
    self.C        = set(IMG);
    self.P        = [ IMG ];
    self.iter     = 0;
    self.neighmap = {};

    for i in xrange(dim0):
      for j in xrange(dim1):
        self.neighmap[(i,j)] = neighborhood(i, j, dim0, dim1);
      #efor
    #efor

  #edef

  #############################################################################

  def state(self, k):

    n = self.neighmap[k];

    c = len(self.C & n);

    if k in self.C:
      if c in (2,3):
        return True;
      elif c < 2 or c >= 4:
        return False;
      else:
        return True;
      #fi
    else:
      if c == 3:
        return True;
      else:
        return False;
   #fi
  #edef

  #############################################################################

  def step(self):
    N = [];
    V = set([]);
    for cell in self.C:
      V = V | self.neighmap[cell];
    #efor

    for cell in V:
      if self.state(cell):
        N.append(cell);
      #fi
    #efor

    self.C    = set(N);
    self.iter = self.iter + 1;
    self.P.append(self.C);
  #edef

  #############################################################################

  def draw(self, loc, ftype):

    if not(os.path.isdir(loc)):
      os.mkdir(loc);
    #fi

    dpi   = 150;
    fac   = 5;
    size1 = fac * float(self.dim0) / float(self.dim1)
    size2 = fac * float(self.dim1) / float(self.dim0)
    for (k, C) in enumerate(self.P):

      IMG = np.zeros((self.dim0, self.dim1));
      for (i,j) in C:
        IMG[i][j] = 1;
      #efor

      print "\rDrawing %010d/%d" % (k+1, len(self.P)),
      sys.stdout.flush();
      fig = plt.imshow(IMG, interpolation='nearest');
      plt.axis('off');
      plt.savefig('%s/%010d.%s' % (loc, k, ftype), bbox_inches='tight', figsize=(size1, size2), dpi=dpi);
      plt.cls();
    #efor
  #edef

#eclass

###############################################################################

nb = lambda i,j : [ (i-1, j-1), (i, j-1), (i+1,j-1), \
                    (i-1, j),             (i+1, j),  \
                    (i-1, j+1), (i, j+1), (i+1, j+1) ];
def neighborhood(i, j, dim0, dim1):
  return set([ mm(a,b, dim0, dim1) for (a,b) in nb(i, j) ]);
#edef

###############################################################################

def mm(i, j, dim0, dim1):
  if i >= dim0:
    i = dim0-1;
  elif i < 0:
    i = 0;
  #fi

  if j >= dim1:
    j = dim1-1;
  elif j < 0:
    j = 0;

  return (i, j);

###############################################################################

def readIMG(fname):
  """ (dim0, dim1, IMG) = readIMG(fname);

  fname = a filename which contains:
    dim0,dim1
    x1,y1
    x2,y2
    ...

  dim0 = dimension 0;
  dim1 = dimension 1;
  IMG  = a set of coordinates which are alive
  """

  fd = open(fname, 'r');

  dim0, dim1 = [ int(x) for x in fd.readline()[:-1].rsplit(',', 2) ];

  C = [];

  while True:
    l = fd.readline();
    s = l.rstrip('\n');

    if len(s) > 0:
      k = tuple([ int(x) for x in l.rsplit(',', 2) ]);
    else:
      break;
    #fi

    C.append(k);
  #ewhile

  return (dim0, dim1, C);

#edef

###############################################################################
