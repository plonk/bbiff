install:
	install -m 755 bbiff /usr/local/bin
	mkdir -p /usr/local/lib/bbiff
	install -m 644 bbiff.rb res_format.rb bbs_reader.rb /usr/local/lib/bbiff
