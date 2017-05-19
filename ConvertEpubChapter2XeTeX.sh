#!/bin/bash
#
# MIT license
# https://github.com/MiczFlor/From-EPUB-To-Conversion
#
# USAGE EXAMPLES:
# bash ConvertEpubChapter2XeTeX.sh -i {epub-file-path} -o {output-zip-file-path} -p {pandoc-executable-path} -t {temp-dir-path}
# bash ConvertEpubChapter2XeTeX.sh --in {epub-file-path} --out {output-zip-file-path} -p {pandoc-executable-path} -t {temp-dir-path}

# read parameters from input
while [[ $# -gt 1 ]]
do
key="$1"

case $key in
    -i|--in)
    SOURCE="$2"
    shift
    ;;
    -o|--out)
    TARGET="$2"
    shift
    ;;
    -p)
    PANDOC="$2"
    shift
    ;;
    -t)
    TEMPDIR="$2"
    shift
    ;;
    *)
esac
shift # past argument or value
done

filename=$(basename "$TARGET")
TARGETEXTENSION="${filename##*.}"
TARGETFILENAME="${filename%.*}"
PANDOC="${PANDOC:-"pandoc"}"
TEMPDIR="${TEMPDIR:-"/tmp"}"
TARGETFOLDER=$TEMPDIR"/"$TARGETFILENAME

printf '%s\n'
echo INITIAL VARIABLES
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
echo SOURCE === $SOURCE
echo TARGET === $TARGET
echo TARGET EXTENSION === $TARGETEXTENSION
echo TARGET FILENAME === $TARGETFILENAME
echo PANDOC EXECUTABLE === $PANDOC
echo TEMP DIR === $TEMPDIR
echo TARGETFOLDER === $TARGETFOLDER
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
printf '%s\n'

echo '-------'CREATE TEMP DIR
if [ ! -d $TEMPDIR ]; then
  mkdir -p $TEMPDIR;
fi
echo '-------'DONE
printf '%s\n'

echo '-------'CREATE TARGETFOLDER DIR
if [ ! -d $TARGETFOLDER"/Chapters" ]; then
  echo $TARGETFOLDER"/Chapters"
  mkdir -p $TARGETFOLDER"/Chapters";
fi
echo '-------'DONE
printf '%s\n'

echo '-------'RUN PANDOC
$PANDOC -s --from epub --to latex --variable documentclass=book --latex-engine=xelatex -o $TARGETFOLDER"/COMPLETE_"$TARGETFILENAME.tex $SOURCE
echo '-------'DONE
printf '%s\n'

echo '-------'COPY EPUB TO TEMP
if [ ! -d $TEMPDIR"/tempbook/" ]; then
  echo $TEMPDIR"/tempbook/"
  mkdir -p $TEMPDIR"/tempbook/";
fi
cp $SOURCE $TEMPDIR"/tempbook/"source.epub
echo '-------'DONE
printf '%s\n'

echo '-------'UNZIP SOURCE EPUB
cd $TEMPDIR"/tempbook/"
unzip ./source.epub
echo '-------'DONE
printf '%s\n'

echo '-------'COPY FONTS, CSS AND IMAGES TO TEX FOLDER
cp -R ./OEBPS/Fonts $TARGETFOLDER
cp -R ./OEBPS/Images $TARGETFOLDER
cp -R ./OEBPS/Styles $TARGETFOLDER
echo '-------'DONE
printf '%s\n'

echo '-------'RUN PANDOC FOR EACH CHAPTER
cd ./OEBPS/Text/
for chapterxhtml in *.xhtml; do
    # chapter name without xhtml ending
    chaptername=$(echo $chapterxhtml | cut -f 1 -d '.')
    $PANDOC -s --from html --to latex --variable documentclass=article --latex-engine=xelatex -o $TARGETFOLDER"/Chapters/"$chaptername.tex $chapterxhtml
done
echo '-------'DONE
printf '%s\n'

echo '-------'CREATE ZIP
echo '-------' $TARGET $TARGETFILENAME
cd $TEMPDIR
# make sure we start from scratch, delete old existing target file
rm $TARGET
zip -0r $TARGET $TARGETFILENAME
echo '-------'DONE
printf '%s\n'

echo '-------'DELETE TEMP $TARGETFILENAME DIR
cd $TEMPDIR
pwd
rm -rf ./tempbook/
rm -rf $TARGETFILENAME
echo '-------'DONE
printf '%s\n'