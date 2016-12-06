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

# write some additional ICML information to text file

echo "1. What is an ICML file?

ICML stands for InCopy Markup Language. It is a standard defined
by Adobe allowing the easy migration of content between InDesign
documents.

An ICML file is a text only file, similar to an HTML file, which
can be imported into and exported from InDesign. The ICML file
contains relevant information about the content and formatting
as well as relative links to media.

Using ICML file to migrate content to InDesign has the advantage
that the content can flow into an existing InDesign IDML document.
In other words: If you have a book layout in InDesign, you can
add content in chapters - or entire books - by placing ICML
content inside your project.

This is similar to placing DOCX files in InDesign with one major 
advantage: the images referenced in ICML are 'raw' whereas the 
DOCX images are embedded in the DOCX file - and depending on the
editor that was used to create the DOCX file, you never quite 
know what conversion has been applied to the image.

If you start from scratch, follow the below step to import an 
entire book into a new InDesign document.

2. Adding pages automatically when importing ICML

InDesign's 'Smart Text Reflow' functionality allows to automatically
create pages when importing a document, such as an ICML file. Here 
is a simple example, assuming you start a new document:

2.1. Create new document

Make sure 'Number of pages' is set to 1.
Activate 'Primary Text Frame'.
Create document by clicking 'OK'.

2.2. Edit preferences

* Select 'Preferences > Type...' from the dropdown menu.
* Activate the 'Smart Text Reflow' section.
* Select where you want pages to be added automatically.
* Select if you want to 'Limit to primary text frames' or also 
  reflow into other text frames.
* You can also select if empty pages should be deleted.
* Click 'OK' to close the preferences.

2.3. Place document

Place the ICML document in the first page of the new document.
Click 'Open' to import the content.

3. Linked ICML file

The ICML file is linked to InDesign. This means that changes made 
in the ICML file are reflected in InDesign. You can break this link, 
if you are sure that you don't want your InDesign document to be 
updated automatically as the content of the ICML file changes.

3.1. Unlink ICML file

* Select 'Links' to show all linked files.
* Locate the ICML file and simply 'unlink' it." >> $filename"-ICML/HOWTO.txt"

# create zip for ICML files and remove folder
zip -0r $filename-ICML.zip ./$filename"-ICML/"
rm -rf ./$filename"-ICML/"