all:
	../genCssSprite.rb  < ../png-n4922/geometry.txt > cssSprite.css
	for f in ../png-n4922/n4922*-08[56].png ../png-n4922/n4922*-093.png ; do \
		echo convert -verbose -resize "12.5%" -colors 8 +repage $${f} `basename $${f} .png | sed "s/-r600/-r075/g"`.gif ; \
	done

cropped:
	for f in ../png-n4922/*.png ; do convert -verbose -resize "12.5%" -colors 8 +repage $${f} `basename $${f} .png`.gif ; done

clean:
	rm -f *.gif
