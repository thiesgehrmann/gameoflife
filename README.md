gameoflife
==========

A simple game of life machine written in python.

Additional tools create a slideshow with a starting point generated from an image.

![An example of the slideshow](/montage.png)

Dependencies
=============

  * Imagemagick: http://www.imagemagick.org/
  * Feh: http://feh.finalrewind.org/
  * Matplotlib: http://matplotlib.org/
  * Numpy: http://www.numpy.org/

Usage
======

Make sure that each dependency (and their dependencies) is installed.

gol.py usage
-------------

The gol class is a very, very simple, bare-bones implementation of the Game of Life in python.

```
> import gol;                     # Import the library
> IMG  = [ (3,3), (3,4), (3,5) ]; # The initial conditions (a list of co-ordinates which are alive)
> dim0 = 10;                      # The first dimension
> dim1 = 10;                      # The second dimension
> iter = 10;                      # The number of iterations to perform
> odir = 'oscilator';             # The output directory for the images
> G = gol.gol(dim0, dim1, IMG);   # Create the GOL object
> for i in xrange(iter):          # Perform the iterations
    G.step();
> G.draw(odir, 'png');            # Export the images to 'odir'
```

Exhibition functionality
-------------------------
```
$ ./show.sh add lena.jpg lena # To add an image
$ ./show.sh start             # To display all images once
$ ./show.sh loop              # To display all images, forever
```
