#!/bin/bash
for file in */*.pdf
    do convert -density 200  $file  ${file%%.*}.jpg
done
