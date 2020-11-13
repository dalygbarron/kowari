(import kowari)

# I am too lazy to make a genius complicated test so it is just a regression
# test that makes sure it's still outputting the same stuff it used to output,
# and that it can read it's own output accurately.

(defn fwritef
  "write to file with format string"
  [file format & bits]
  (file/write file (string/format format ;bits)))

(def pngs (mapcat (fn [item] (if (string/has-suffix? ".png" item)
                               (string "test-images/" item)
                               []))
                  (os/dir "test-images")))
(def atlas (kowari/make-atlas 321 295 ;pngs))
(kowari/render-atlas-to-file atlas "out.png")
(with [file (file/open "test.csv" :w)]
  (file/write file "name,x,y,w,h\n")
  (kowari/each-atlas atlas
                     (fn [x y pic]
                       (fwritef file
                                "%s,%d,%d,%d,%d\n"
                                (pic :name)
                                x
                                y
                                (pic :width)
                                (pic :height)))))
