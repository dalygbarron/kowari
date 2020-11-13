# Kowari
This is a texture atlas generating module written in Janet. I gave it this name
because I had an old texture atlas generating program called Rat or RatPack and
Kowari is a cool rat type of thing native to Australia.

This is a module which could almost be a standalone program in a lot of ways,
since it is only really meant to perform a task when required. The reason it is
not a standalone program is that this way you can define your output format
yourself with ease, and call it from a build script or something.

## How to use
A texture atlas generally consists of two parts when output; an image file
which is the actual texture to use, and some kind of file that describes where
each individual image has been placed inside the larger image, so in general,
there are three steps when creating a texture atlas:
 - Determine picture placement inside atlas
 - render and save atlas picture
 - save placement of pictures inside atlas in whatever format

Now, since there are only four public functions in this module, I will just
describe them and you should get the idea of how this module is used.
If you want to see an example then look at `test/kowari.janet`.

### (kowari/make-atlas width height & files)
Creates kowari's representation of a texture atlas which is a tree btw. Width
and Height are the width and height that the images are being packed into and
the dimensions of the final output image, and files is an arbitrary number of
string filenames.

If the images don't all fit then an error will be thrown and you will be left
with nothing.

The atlas object you receive in return is a recursive tree sort of
datastructure. You don't need to worry about it a whole lot since you should be
able to do everything you need with kowari functions.

### (kowari/each-atlas tree func &opt x y)
Iterates over every picture in the atlas, calling `(func x y picture)` where
picture is a Pingo picture which has an added field called name which is the
filename it was loaded with. X and y are optional and only really needed
because the function is recursive, but if you feel like offsetting everthing
for some reason go ahead I guess.

### (kowari/render-atlas atlas)
Takes an atlas and renders it's pictures into the final texture atlas picture
which it returns.

### (kowari/render-atlas-to-file atlas filename)
Takes an atlas and renders it's pictures into the final texture atlas picture
then saves that picture to a given file. Also evaluates to the picture just in
case you want to do something with it after.

## Outputting picture locations
You may have noticed there is mention of outputting the final texture atlas,
but there is no mention of outputting the location data of each image inside
the atlas. This is because you have to implement it yourself. The reason for
this is that there are a million different formats in the world and I suspect
everybody has a different one so then, why support a few formats and leave
people lacking when instead I can just make it easy to support yourself?

You basically just use `kowari/each-atlas` and do whatever you want. Here is an
example:
```
(with [file (file/open "output.csv" :w)]
  (file/write file "name,x,y,w,h\n")
  (kowari/each-atlas atlas
                     (fn [x y pic]
                       (file/write file (string/format "%s,%d,%d,%d,%d\n"
                                                       (pic :name)
                                                       x
                                                       y
                                                       (pic :width)
                                                       (pic :height))))))
```
You can write it in binary if you want, and you can even include the texture
atlas and the position data together in some weird format if you want, you can
do anything.
