PDF_TEXT = ShuishuLogogramNameList.txt ShuishuRadicalNameList.txt
DERIVED_JSON = ShuishuLogogramNameList.json

all: $(DERIVED_JSON) $(PDF_TEXT)

ShuishuLogogramNameList.json: ShuishuLogogramNameList.txt
	./tokenizeUcsCharName.rb --charname-list=$< --sounds=sounds_wg2n4696.txt > $@

ShuishuLogogramNameList.txt: srcPDF/17366r-n4922-5th-ed-pdam2-2-chart.pdf
	pdftotext -raw -f 87 -l 92 srcPDF/17366r-n4922-5th-ed-pdam2-2-chart.pdf ${@:.txt=.dat}
	./makeCharNameList.rb < ${@:.txt=.dat} > $@

ShuishuRadicalNameList.txt: srcPDF/17366r-n4922-5th-ed-pdam2-2-chart.pdf
	pdftotext -raw -f 93 -l 93 srcPDF/17366r-n4922-5th-ed-pdam2-2-chart.pdf ${@:.txt=.dat}
	./makeCharNameList.rb < ${@:.txt=.dat} > $@

clean:
	rm -f $(PDF_TEXT) $(DERIVED_JSON)

DIST_SOURCES = \
	lookup_U+1B300.html \
	*.js \
	*.json \
	gif-oe-n4922/*.gif 

dist:
	tar cvf - $(DIST_SOURCES) | xz -9v > lookup_U+1B300.tar.xz

dist-zip:
	zip -vr lookup_U+1B300.zip $(DIST_SOURCES)
