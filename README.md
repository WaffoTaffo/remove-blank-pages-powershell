This is a Powershell script adapted off of nklb's [remove-blank-pages](https://github.com/nklb/remove-blank-pages) bash script that serves the same purpose and can be run on windows. I have also added a third argument that results in a file containing the pages identified as blank for cross-checking purposes.

To run it `ghostscript` and `pdftk` are needed. Both programs can be easily installed on Windows.

The script can be run on powershell
```
./remove-blank-pages input-with-blank-pages.pdf output-without-blank-pages.pdf extracted-blank-pages.pdf
```
...or on cmd
```
powershell ./remove-blank-pages input-with-blank-pages.pdf output-without-blank-pages.pdf extracted-blank-pages.pdf
```
The ink coverage threshold (CMYK values) determining if a page is considered blank or not is defined in line 7 of the script. Feel free to adjust it to the sensitivity of the scanner if the results are not satisfactorily.
