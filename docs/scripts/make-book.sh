#!/usr/bin/env bash

# execute this in docs/

for f in `find . -name \*.md`
do
    t=${f%%.md}.tex
    pandoc $f --output $t
    sed --in-place 's/\.md//g' $t
done

rm -f book.tex ; ./scripts/make-book.pl > .book.tex; mv .book.tex book.tex

pdflatex book.tex; pdflatex book.tex; pdflatex book.tex
