gameoflife
==========

A simple game of life machine written in python.

Additional tools create a slideshow with a starting point generated from an image.

![An example of the slideshow](/montage.png)

Dependencies
=============

  * Imagemagick: [http://www.imagemagick.org/]
  * Feh: [http://feh.finalrewind.org/]
  * Matplotlib: [http://matplotlib.org/]
  * Numpy: [http://www.numpy.org/]

Usage
======

Make sure that each dependency (and their dependencies) is installed.

```
$ ./show.sh add lena.jpg exhibits/lena # To add an image
$ ./show.sh start                      # To display all images once
$ ./show.sh loop                       # To display all images, forever
```
