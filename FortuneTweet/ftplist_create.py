# -*- mode: python; coding: utf-8 -*-
#
# Time-stamp: <2012-09-06 22:37:37 NorimasaNabeta>
#
# Fortune Data to pList converter
#
#
import plistlib
import datetime
import time
import re
import codecs
import hashlib

import sys
import os.path


"""
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>date</key><date>2012-09-03T02:18:29Z</date>
	<key>playId</key><string>d232c6c498283da7cb5b433a82e2b2bb9d5b39a9</string>
	<key>playName</key><string>startrek</string>
	<key>quotations</key><array>
		<dict>
			<key>act</key><string>stardate 3468.1.</string>
			<key>character</key><string>Lt. Carolyn Palamas</string>
			<key>qid</key><string>52bdb9fed0362e86d1e8aa12f8759c04b92faafe</string>
			<key>quotation</key><string>A father doesn't destroy his children.</string>
			<key>scene</key><string>"Who Mourns for Adonais?"</string>
		</dict>
                ...
		<dict>
			<key>act</key><string>stardate 5928.5.</string>
			<key>character</key><string>Dr. Janice Lester (in Kirk's body)</string>
			<key>qid</key><string>ca4d568959a46a5fefe7b8ec562ca4af4851441c</string>
			<key>quotation</key><string>Youth doesn't excuse everything.</string>
			<key>scene</key><string>"Turnabout Intruder"</string>
		</dict>
	</array>
	<key>version</key><integer>1</integer>
</dict>
</plist>


"""
#
#
#
def readFortuneDataAux( arrayList, content, author ):
    tags = [ 'character', 'scene', 'act', 'quotation', 'qid', '' ]
    debug_flag=1
    tmp = {}
    if ((debug_flag>=1) and ((len(content) >= 80) or (len(author) >=80))):
        print
        print ">>>", len(content), content
        print ">>>", len(author), author

    if ((len(content) < 80) and (len(content)>0) and (author != '') and (len(author) < 80)):
        cont = author.split(',')
        if debug_flag:
            print
            print ">>", len(content), content
            if (len(cont)<2):
                print ">> -- ", len(cont), author
            elif (len(cont)==2):
                print ">> -s- ", len(cont), cont[1].strip()
                print ">> -c- ", len(cont), cont[0].strip()
            else:
                print ">> -a- ", len(cont), cont[2].strip()
                print ">> -s- ", len(cont), cont[1].strip()
                print ">> -c- ", len(cont), cont[0].strip()
        
        if (len(cont) > 3):
            print "ERR", len(cont), content
            return

        for idx in range(0, 4):
            tmp[ tags[idx] ] = ""
        tmp[ tags[3] ] = content
        if (len(cont)<2):
            tmp[ tags[0] ] = author
        else:
            for idx in range(0, len(cont)):
                tmp[ tags[idx] ] = cont[idx].strip()

        # qid for character,scene,act
        m = hashlib.sha1()
        for idx in range(0, 3):
            m.update(tmp[ tags[idx] ])
            # print ">> ", idx, m.hexdigest(), tmp[ tags[idx] ]

        tmp[ tags[4] ] = m.hexdigest()
        arrayList.append(tmp)

    return

#
#
#
def readFortuneData( filename ):
    f = open(inputTextDatafile)
    data = f.read()
    f.close()

    lines = data.split('\n')
    sz = len(lines)
    idx=0
    author=''
    content=''
    ctclass = []
    tmp = {}
    for line in lines:
        if (line == '%'):
            #print ">>>>", line
            readFortuneDataAux( ctclass, content, author )
            author=''
            content=''
        if (len(line) > 1):
            #print line
            startp=line.find("-- ")
            if (startp > 1):
                author=line[startp+3:]
            else:
                if (len(author) > 0):
                    author = author + line.strip()
                else:
                    content = content + line

    readFortuneDataAux( ctclass, content, author )

    return ctclass

#
#
#
if __name__ == '__main__':
    if len(sys.argv) > 1 :
        inputTextDatafile = sys.argv[1]
        outputPlistfile   = sys.argv[2]
    else:
        inputTextDatafile = 'startrek.txt'
        outputPlistfile   = 'startrek.plist'

    titleFortune       = os.path.splitext(os.path.basename(inputTextDatafile))[0]
    descriptionFortune = 'fortune database'
    editorFortune      = 'FortuneTweet'
    m = hashlib.sha1()
    m.update(titleFortune)
    m.update(editorFortune)
    output_pl = [
        dict(
            playName        = titleFortune,
            playDescription = descriptionFortune,
            playEditor      = editorFortune,
            playId          = m.hexdigest(),
            date            = datetime.datetime.fromtimestamp(time.mktime(time.gmtime())),
            formatVersion   = 2,
            quotations      = readFortuneData(inputTextDatafile)
            )
        ]
    plistlib.writePlist(output_pl, outputPlistfile)

    # convert into the binary plist form
    # https://developer.apple.com/library/mac/#documentation/Darwin/Reference/ManPages/man1/plutil.1.html
    # plutil -convert binary1 outputPlistfile
    os.system(('plutil -convert binary1 %s' % outputPlistfile))


# 
# http://www.doughellmann.com/PyMOTW-ja/plistlib/
#output_file = tempfile.NamedTemporaryFile()
#try:
#    plistlib.writePlist(d, output_file)
#    output_file.seek(0)
#    print output_file.read()
#finally:
#    output_file.close()
 

# binary case
# d = { 'binary_data':plistlib.Data('This data has an embedded null. \0'),}
# print plistlib.writePlistToString(d)   
