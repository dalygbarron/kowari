(import kowari)

# I am too lazy to make a genius complicated test so it is just a regression
# test that makes sure it's still outputting the same stuff it used to output,
# and that it can read it's own output accurately.

(def pngs (mapcat (fn [item] (if (string/has-suffix? ".png" item)
                               (string "test-images/" item)
                               []))
                  (os/dir "test-images")))
(def atlas (kowari/make-atlas 321 295 ;pngs))
(kowari/draw-atlas atlas "out.png")
(kowari/write-atlas-json atlas "test.json")
