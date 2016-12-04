#!/bin/bash

# execute in the directory where the epub is with the epub filename in the command line like this:
# ./ConvertEpubChapter2ICML.sh charles-dickens-weihnachtsgeschichten_2016-11-28_12-06-08.epub

# read file from input
fileepub=$1
echo "Converting file: " $fileepub

# new file name without epub ending
filename=$(echo $fileepub | cut -f 1 -d '.')

# create temporary working directory
if [ ! -d temp ]; then
  mkdir -p temp;
fi

# create ICML directory
if [ ! -d $filename"-ICML/Chapters" ]; then
  mkdir -p $filename"-ICML/Chapters";
fi

# create a ICML version of the entire book
pandoc -s --from epub --to icml -o "COMPLETE_"$filename.icml $fileepub
# move the file to the Text directory
mv "COMPLETE_"$filename.icml $filename"-ICML"

# create a copy for processing
cp $fileepub ./temp/book.epub

# unzip epub
cd ./temp
unzip ./book.epub

# copy fonts, css and images to ICML folder
cp -R ./OEBPS/Fonts ../$filename"-ICML/"
cp -R ./OEBPS/Images ../$filename"-ICML/"
cp -R ./OEBPS/Styles ../$filename"-ICML/"

# move to where the HTML files are
cd ./OEBPS/Text/

for chapterxhtml in *.xhtml; do
    # new chapter name without xhtml ending
    chaptername=$(echo $chapterxhtml | cut -f 1 -d '.')
    pandoc -s --from html --to icml -o $chaptername.icml $chapterxhtml
    mv $chaptername.icml ../../../$filename"-ICML/Chapters/"
done

# move back up outside temp directory
cd ../../../

# delete everything in temp folder
rm -rf ./temp

# create zip for ICML files and remove folder
zip -0r $filename-ICML.zip ./$filename"-ICML/"
rm -rf ./$filename"-ICML/"