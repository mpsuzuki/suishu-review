PDF_TEXT = ShuishuLogogramNameList.txt ShuishuRadicalNameList.txt
DERIVED_JSON = ShuishuLogogramNameList.json SDYZSound.json

all:
	make -C srcPDF
	make -C png-n4922
	make -C gif-oe-n4922
	make $(DERIVED_JSON)

ShuishuLogogramNameList.json: $(PDF_TEXT)
	./tokenizeUcsCharName.rb --charname-list=$< --sounds=sounds_wg2n4758.txt > $@

SDYZSound.json: 
	./makeSoundTableJson.rb sounds_.txt < sounds_SDYZ2007.txt > $@

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
	1x1.gif \
	*.md \
	*.css \
	*/*.css \
	*.js \
	*.json \
	*/*.json

DIST_SOURCES_EXTRA = \
	gif-sdyz-ipa/*.gif \
	gif-oe-n4922/U+*.gif 

DIST_SOURCES_EXTRA_EXTRA = \
	gif-oe-n4922/n4922*.gif 

dist:
	tar cvpf - $(DIST_SOURCES) | xz -9v > lookup_U+1B300.tar.xz

dist-images:
	tar cvpf - $(DIST_SOURCES) $(DIST_SOURCES_EXTRA) | xz -9v > lookup_U+1B300.tar.xz

dist-whole:
	tar cvpf - $(DIST_SOURCES) $(DIST_SOURCES_EXTRA) $(DIST_SOURCES_EXTRA_EXTRA) | xz -9v > lookup_U+1B300.tar.xz

dist-zip:
	zip -vr lookup_U+1B300.zip $(DIST_SOURCES)
