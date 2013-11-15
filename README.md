gameoflife
==========

A simple game of life machine written in python.

Additional tools create a slideshow with a starting point generated from an image.

![An example of the slideshow](/montage.gif)

Dependencies
=============

For core functionality:

  * Matplotlib: http://matplotlib.org/
  * Numpy: http://www.numpy.org/

For exhibition functionality:

  * Imagemagick: http://www.imagemagick.org/
  * Feh: http://feh.finalrewind.org/

Usage
======

Make sure that each dependency (and their dependencies) is installed.

gol.py usage
-------------

The gol class is a very, very simple, bare-bones implementation of the Game of Life in python.

```python
import gol;                     # Import the library
IMG  = [ (3,3), (3,4), (3,5) ]; # A list of co-ordinates which are alive
dim0 = 10;                      # The first dimension
dim1 = 10;                      # The second dimension
iter = 10;                      # The number of iterations to perform
odir = 'oscillator';             # The output directory for the images
G = gol.gol(dim0, dim1, IMG);   # Create the GOL object
for i in xrange(iter):          # Perform the iterations
  G.step();
G.draw(odir, 'png');            # Export the images to 'odir'
```

Exhibition Usage
-----------------

```
Usage: ./show.sh <task> [arguments]

Tasks
  add <image> <title> [iter] [msize] [exhibit_dir]
    image:       The image you wish to add
    title:       The title of the exhibit
    exhibit_dir: The output directory (DEFAULT = exhibits)
    iter:        The number of iterations to perform (DEFAULT = 100)
    msize:       The maximum size of the image (DEFAULT = 250)

  start [exhibit_dir] [time]
    exhibit_dir: The input directory (DEFAULT = exhibits)
    time:        The seconds delay between images in slideshow (DEFAULT = 0.05)

  loop [exhibit_dir] [time]
    exhibit_dir: The input directory (DEFAULT = exhibits)
    time:        The seconds delay between images in slideshow (DEFAULT = 0.05)

  montage <title> [outf] [exhibit_dir]
    title:       The title of the exhibit
    outf:        The output file (DEFAULT = montage.png)
    exhibit_dir: The input directory (DEFAULT = exhibits)

  effect <title> <effects> [exhibit_dir]
    title:      The exhibit you wish to apply it to
    effects:    The effects you with to apply (DEFAULT=reset,multiply,overlay,fade)
    exhbit_dir: The input directory (DEFAULT = exhibits)

Example usage
  $ ./show.sh add lena.jpg lena # To add an image
  $ ./show.sh start             # To display all images once
  $ ./show.sh loop              # To display all images, forever
```

Exhibition functionality
-------------------------
```bash
./show.sh add lena.jpg lena 100    # To add an image, 100 iterations
./show.sh effect lena overlay,fade # To add effects to an exhibition
./show.sh start                    # To display all images once
./show.sh loop                     # To display all images, forever
```
