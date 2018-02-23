PDF_TEXT = ShuishuLogogramNameList.txt ShuishuRadicalNameList.txt

all: ShuishuLogogramNameList.json

ShuishuLogogramNameList.json: ShuishuLogogramNameList.txt
	./tokenizeUcsCharName.rb --charname-list=$< --sounds=sounds_wg2n4696.txt > $@

ShuishuLogogramNameList.txt: srcPDF/17366r-n4922-5th-ed-pdam2-2-chart.pdf
	pdftotext -raw -f 87 -l 92 srcPDF/17366r-n4922-5th-ed-pdam2-2-chart.pdf ${@:.txt=.dat}
	./makeCharNameList.rb < ${@:.txt=.dat} > $@

ShuishuRadicalNameList.txt: srcPDF/17366r-n4922-5th-ed-pdam2-2-chart.pdf
	pdftotext -raw -f 93 -l 93 srcPDF/17366r-n4922-5th-ed-pdam2-2-chart.pdf ${@:.txt=.dat}
	./makeCharNameList.rb < ${@:.txt=.dat} > $@

clean:
	rm -f $(PDF_TEXT)
