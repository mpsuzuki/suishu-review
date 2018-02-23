all:
	for f in ../png-n4922/*.png ; do convert -verbose -resize "12.5%" -colors 8 +repage $${f} `basename $${f} .png`.gif ; done

clean:
	rm -f *.gif
