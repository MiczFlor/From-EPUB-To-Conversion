#!/bin/bash

# execute in the directory where the epub is with the epub filename in the command line like this:
# ./ConvertEpubChapter2ICML.sh charles-dickens-weihnachtsgeschichten_2016-11-28_12-06-08.epub

# read file from input
fileepub=$1
echo "Converting file: " $fileepub

# create temporary working directory
if [ ! -d temp ]; then
  mkdir -p temp;
fi

# create ICML directory
if [ ! -d $fileepub".ICML/Chapters" ]; then
  mkdir -p $fileepub".ICML/Chapters";
fi

# create a ICML version of the entire book
pandoc -s --from epub --to icml -o "COMPLETE_"$fileepub.icml $fileepub
# move the file to the Text directory
mv "COMPLETE_"$fileepub.icml $fileepub".ICML"


# create a copy for processing
cp $fileepub ./temp/book.epub

# unzip epub
cd ./temp
unzip ./book.epub

# copy fonts, css and images to ICML folder
cp -R ./OEBPS/Fonts ../$fileepub".ICML/"
cp -R ./OEBPS/Images ../$fileepub".ICML/"
cp -R ./OEBPS/Styles ../$fileepub".ICML/"

# move to where the HTML files are
cd ./OEBPS/Text/

for filename in ./*.xhtml; do
    ls -l $filename
    pandoc -s --from html --to icml -o $filename.icml $filename
    mv $filename.icml ../../../$fileepub".ICML/Chapters/"
done

# move back up outside temp directory
cd ../../../

# delete everything in temp folder
rm -rf ./temp

# create zip for ICML files and remove folder
zip -0r $fileepub.icml.zip ./$fileepub".ICML/"
rm -rf ./$fileepub".ICML/"