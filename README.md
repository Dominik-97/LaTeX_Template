# A basic LaTeX template I got and slightly changed which I decided to use for some of my lower scale projects

### Required software
1. some TeX distribution, I use MacTeX which comes with pdflatex compiler which I use to compile
2. Make
3. Python, version 3 or newer
3. bibtex
4. qpdf

### Not required but nice to have software
1. evince, you can always use Adobe or Preview

## Struktura repozitáře

**project.tex** - basic definitions - edit your paper info here <br>
**project1.tex** - write your paper in this file <br>
**project2.tex** - you can write another part of your paper in this file, or you can use only project1.tex

> edit this in project.tex - remove/add include files starting from line 109

**seznamZkratek.tex** - list of abbreviations used in your paper, add them here <br>
**titulniStrana.tex** - title page definition - you can create your desired design here, or you can keep the default setting, you can edit variables for title page in project.tex

> edit this in project.tex - edit variables starting from line 29

**Makefile** - use this to compile your paper <br>
**pics/** - directory for images <br>
**aux.py** - using some regex magic, it makes your final output look better

## How to compile

Run `Make help` to display help. <br>
If you want to compile your paper run `Make build` <br>
If you then want to delete generated `bin` directory, run `Make clean` - your output will still be in your root and it will not be deleted, do not worry about that.
