#!/bin/bash

# execute in the directory where the epub is with the epub filename in the command line like this:
# ./ConvertEpubChapter2DOCX.sh charles-dickens-weihnachtsgeschichten_2016-11-28_12-06-08.epub

# read file from input
fileepub=$1
echo "Converting file: " $fileepub

# new file name without epub ending
filename=$(echo $fileepub | cut -f 1 -d '.')

# create temporary working directory
if [ ! -d temp ]; then
  mkdir -p temp;
fi

# create DOCX directory
if [ ! -d $filename"-DOCX/Chapters" ]; then
  mkdir -p $filename"-DOCX/Chapters";
fi

# create a DOCX version of the entire book
pandoc -s --from epub --to docx -o "COMPLETE_"$filename.docx $fileepub
# move the file to the Text directory
mv "COMPLETE_"$filename.docx $filename"-DOCX"

# create a copy for processing
cp $fileepub ./temp/book.epub

# unzip epub
cd ./temp
unzip ./book.epub

# copy fonts, css and images to DOCX folder
cp -R ./OEBPS/Fonts ../$filename"-DOCX/"
cp -R ./OEBPS/Images ../$filename"-DOCX/"
cp -R ./OEBPS/Styles ../$filename"-DOCX/"

# move to where the HTML files are
cd ./OEBPS/Text/

for chapterxhtml in *.xhtml; do
    # new chapter name without xhtml ending
    chaptername=$(echo $chapterxhtml | cut -f 1 -d '.')
    pandoc -s --from html --to docx -o $chaptername.docx $chapterxhtml
    mv $chaptername.docx ../../../$filename"-DOCX/Chapters/"
done

# move back up outside temp directory
cd ../../../

# delete everything in temp folder
rm -rf ./temp

# create zip for DOCX files
zip -0r $filename-DOCX.zip ./$filename"-DOCX/"
rm -rf ./$filename"-DOCX/"