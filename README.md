# From-EPUB-To-Conversion

A bundle of scripts to convert from EPUB to other formats. The results will be in a ZIP file.

This set of scripts is using the valid EPUB structure from Booktype.pro (or Omnibook.pro). 
Using other EPUB structures will require to alter the scripts.

## Requirements

For the conversion I am using pandoc Version 1.16.0.2

## How to use

`./ConvertEpubChapter2ICML.sh -i ../test-booktype.epub -o ../tests/test-booktype-ICML.zip`

`./ConvertEpubChapter2DOCX.sh -i ../test-booktype.epub -o ../tests/test-booktype-DOCX.zip`

## Run tests

`cd tests`

`./tests.sh`