#!/bin/bash

# execute in the directory where the epub is with the epub filename in the command line like this:
# ./ConvertEpubChapter2DOCX.sh charles-dickens-weihnachtsgeschichten_2016-11-28_12-06-08.epub

# read file from input
fileepub=$1
echo "Converting file: " $fileepub

# create temporary working directory
if [ ! -d temp ]; then
  mkdir -p temp;
fi

# create DOCX directory
if [ ! -d $fileepub".DOCX/Chapters" ]; then
  mkdir -p $fileepub".DOCX/Chapters";
fi

# create a DOCX version of the entire book
pandoc -s --from epub --to docx -o "COMPLETE_"$fileepub.docx $fileepub
# move the file to the Text directory
mv "COMPLETE_"$fileepub.docx $fileepub".DOCX"

# create a copy for processing
cp $fileepub ./temp/book.epub

# unzip epub
cd ./temp
unzip ./book.epub

# copy fonts, css and images to DOCX folder
cp -R ./OEBPS/Fonts ../$fileepub".DOCX/"
cp -R ./OEBPS/Images ../$fileepub".DOCX/"
cp -R ./OEBPS/Styles ../$fileepub".DOCX/"

# move to where the HTML files are
cd ./OEBPS/Text/

for filename in ./*.xhtml; do
    ls -l $filename
    pandoc -s --from html --to docx -o $filename.docx $filename
    mv $filename.docx ../../../$fileepub".DOCX/Chapters/"
done

# move back up outside temp directory
cd ../../../

# delete everything in temp folder
rm -rf ./temp

# create zip for DOCX files
zip -0r $fileepub.docx.zip ./$fileepub".DOCX/"
rm -rf ./$fileepub".DOCX/"