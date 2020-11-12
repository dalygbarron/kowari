(import pingo)

(defn- load-named-pic
  "Loads a picture and saves it's file name as well. It should be fine in
  practice since pingo only changes image data in a destructive way"
  [path]
  (def pic (pingo/read-file path))
  {:name path
   :data (pic :data)
   :width (pic :width)
   :heigh (pic :height)})

(defn- make-bin-node
  "Makes a node in the bin packing tree"
  [pic lower-bound right-bound]
  @{:pic pic
    :lower-bound lower-bound
    :right-bound right-bound
    :lower nil
    :right nil})

(defn- right-size
  "Gives you the space of a tree node's right area as a 2d tuple"
  [tree]
  [(tree :right-bound)
   ((tree :pic) :height)])

(defn- lower-size
  "Gives you the space of a tree node's lower area as a 2d tuple"
  [tree]
  [(+ (tree :right-bound) ((tree :pic) :width))
   (tree :lower-bound)])

(defn- pic-size
  "Gives you the size of a pic as a 2d tuple of numbers"
  [pic]
  [(pic :width) (pic :height)])

(defn- fit
  "Takes two 2d tuples of numbers as points and checks the first is lesser than
  the second in each dimension"
  [point bound]
  (and (<= (point 0) (bound 0)) (<= (point 1) (bound 1))))

(defn- add-to-bin
  "Tries to fit an item into the tree recursively. Returns true on success and
  false on failure"
  [tree pic]
  (def size (pic-size pic))
  (if (fit size (right-size tree))
    (if (nil? (tree :right))
      (do
        (set (tree :right) (make-bin-node pic
                                          (tree :lower-bound)
                                          (- (tree :right-bound) (pic :width))))
        true)
      (if (add-to-bin (tree :right) pic)
        true
        (if (fit size (lower-size tree))
          (if (nil? (tree :lower))
            (do
              (set (tree :lower) (make-bin-node pic
                                                (- (tree :lower-bound)
                                                   (pic :height))
                                                (- (+ (tree :right-bound)
                                                      ((tree :pic) :width))
                                                   (pic :width))))
              true)
            (add-to-bin (tree :lower) pic))
          false)))
    false))

(defn- draw-node
  "Draws a bin tree recursively"
  [pic tree x y]
  (pingo/superimpose pic (tree :pic) x y)
  (if (not (nil? (tree :right))) (draw-node pic
                                            (tree :right)
                                            (+ ((tree :pic) :width) x)
                                            y))
  (if (not (nil? (tree :lower))) (draw-node pic
                                            (tree :lower)
                                            x
                                            (+ ((tree :pic) :height) y))))

(defn make-json-writer
  "Returns a closure for writing an atlas to a file in json format"
  [filename]
  (def file (file/open filename :w))
  (if (nil? file) (errorf "Could not open %s for writing" filename))
  (file/write file "[")
  (fn [node x y]
    (if (nil? node)
      (do 
        (file/write file "]")
        (file/close file))
      (file/write (string/format "{\"name\":\"%s\",\"x\":%d\"y\":%d,\"w\":%d,\"h\":%d},"
                                 ((node :pic) :name)
                                 x
                                 y
                                 ((node :pic) :width)
                                 ((node :pic) :height))))))

(defn make-atlas
  "Creates a texture atlas representation which contains tree of placements,
  but it lets you choose what to do with it all. width and height are the
  bounds of the atlas, passive is whether to crash on errors, and files are the
  string names of png files to get images from"
  [width height passive & files]
  (def sorted-files
    (sort-by (fn [pic] (- 0 (max (pic :width) (pic :height))))
             (map (fn [file] (pingo/read-file file)) files)))
  (def atlas-pic (pingo/make-blank-image width height))
  (def bin-tree (make-bin-node (sorted-files 0)
                               (- width ((sorted-files 0) :width))
                               (- height ((sorted-files 0) :height))))
  (for i 1 (length sorted-files) (add-to-bin bin-tree (sorted-files i)))
  bin-tree)

(defn map-atlas
  "Iterates over atlas nodes recursively, calling a function with intended
  arguments of [x y pic]. Whatever this function evaluates to is added to a

(defn draw-atlas
  "Takes an atlas and draws it plainly to a png file of your choosing"
  [tree file]
  (def width (+ (tree :right-bound) ((tree :pic) :width)))
  (def height (+ (tree :lower-bound) ((tree :pic) :height)))
  (def pic (pingo/make-blank-image width height))
  (draw-node pic tree 0 0)
  (pingo/write-file pic file))
