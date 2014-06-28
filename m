#! /usr/bin/env python3
# -*- coding: utf-8 -*-
''' This program converts a manpage to HTML with Arch Linux Wiki's CSS style.
    It uses mandoc (aka mdocml) for HTML convertion.
    The resulting file is then opened in a $BROWSER.

    Required arguments are section number and manpage name, for exmaple:
        ./<this script> 8 pacman

    Section number is required because I can't figure out how to specify
    2 poisitional arguments in argparse, with one of them non-required.
'''

import re, argparse, gzip, subprocess, os

CSS_CONTENT = '''
.head, .foot {
	display: none;
}

body {
	background: none repeat scroll 0% 0% #F6F9FC;
	color: #F9F9F9;
	direction: ltr;
	float: right;
	font-family: sans-serif;
	font-size: 12.7px;
	font-size-adjust: none;
	font-stretch: normal;
	font-style: normal;
	font-variant: normal;
	font-weight: 400;
	line-height: 16px;
	margin-bottom: 7.61667px;
	margin-left: -154.933px;
	margin-right: 0px;
	margin-top: 0px;
	padding-bottom: 0px;
	padding-left: 0px;
	padding-right: 0px;
	padding-top: 0px;
	width: 1588px;
}

.mandoc {
	background-attachment: scroll;
	background-clip: border-box;
	background-color: #FFF;
	background-image: none;
	background-origin: padding-box;
	background-position: 0% 0%;
	background-repeat: repeat;
	background-size: auto auto;
	border-bottom-color: #CCC;
	border-bottom-style: solid;
	border-bottom-width: 1px;
	border-image-outset: 0 0 0 0;
	border-image-repeat: stretch stretch;
	border-image-slice: 100% 100% 100% 100%;
	border-image-source: none;
	border-image-width: 1 1 1 1;
	border-left-color: #CCC;
	border-left-style: solid;
	border-left-width: 1px;
	border-right-color: #CCC;
	border-right-style: solid;
	border-right-width: 1px;
	border-top-color: #CCC;
	border-top-style: solid;
	border-top-width: 1px;
	color: #000;
	direction: ltr;
	font-family: sans-serif;
	font-size: 12.7px;
	font-size-adjust: none;
	font-stretch: normal;
	font-style: normal;
	font-variant: normal;
	font-weight: 400;
	line-height: 19.05px;
	margin-bottom: 50px;
	margin-left: 25.4px;
	margin-right: 25.4px;
	margin-top: 25.4px;
	padding-bottom: 12.7px;
	padding-left: 12.7px;
	padding-right: 12.7px;
	padding-top: 12.7px;
	position: relative;
	top: 10px;
	z-index: 2;
}

h1 {
	background-attachment: scroll;
	background-clip: border-box;
	background-color: transparent;
	background-image: none;
	background-origin: padding-box;
	background-position: 0% 0%;
	background-repeat: repeat;
	background-size: auto auto;
	border-bottom-color: #AAA;
	border-bottom-style: solid;
	border-bottom-width: 1px;
	color: #222;
	direction: ltr;
	font-family: sans-serif;
	font-size: 19.05px;
	font-size-adjust: none;
	font-stretch: normal;
	font-style: normal;
	font-variant: normal;
	font-weight: 400;
	line-height: 19.05px;
	margin-bottom: 11.4333px;
	margin-left: 0px;
	margin-right: 0px;
	margin-top: 0px;
	overflow: hidden;
	overflow-x: hidden;
	overflow-y: hidden;
	padding-bottom: 3.23333px;
	padding-top: 9.53333px;
}

b, i {
	background-color: #EBF1F5;
	color: #222;
	direction: ltr;
	display: inline-block;
	font-family: monospace;
	font-size: 12.7px;
	font-size-adjust: none;
	font-stretch: normal;
	font-style: normal;
	font-variant: normal;
	line-height: 19.05px;
	padding-bottom: 1.26667px;
	padding-left: 3.81667px;
	padding-right: 3.81667px;
	padding-top: 1.26667px;
}

b {
	font-weight: 400;
}

i {
	font-style: italic;
}

dt {
	background-color: #EBF1F5;
	color: #222;
	direction: ltr;
	display: inline-block;
	font-family: monospace;
	font-size: 12.7px;
	font-size-adjust: none;
	font-stretch: normal;
	font-style: normal;
	font-variant: normal;
	line-height: 19.05px;
	padding-bottom: 1.26667px;
	padding-left: 3.81667px;
	padding-right: 3.81667px;
	padding-top: 1.26667px;
	margin-bottom: 0.1em;
}

dt b, dt i {
	background-color: #EBF1F5;
	display: inline;
	padding: 0 0 0 0;
	color: #000;
	direction: ltr;
	font-family: monospace;
	font-size: 12.7px;
	font-size-adjust: none;
	font-stretch: normal;
	font-style: normal;
	font-variant: normal;
	font-weight: 400;
	line-height: 19.05px;
}

dt b {
	font-weight: 400;
}

dt i {
	font-style: italic;
}

dl {
	margin-top: 0.2em;
	margin-bottom: 0.5em;
	line-height: 1.5em;
}

p {
	color: #000;
	direction: ltr;
	font-family: sans-serif;
	font-size: 12.7px;
	font-size-adjust: none;
	font-stretch: normal;
	font-style: normal;
	font-variant: normal;
	font-weight: 400;
	line-height: 19.05px;
	margin-bottom: 6.35px;
	margin-left: 0px;
	margin-right: 0px;
	margin-top: 5.08333px;
}

dd {
	margin-bottom: 0.1em;
	line-height: 1.5em;
	margin-left: 2.0em;
	margin-right: 0px;
}

i.link-sec, a b {
	background-color: #FFF;
	display: inline;
	padding: 0 0 0 0;
	color: #000;
	direction: ltr;
	font-family: sans-serif;
	font-size: 12.7px;
	font-size-adjust: none;
	font-stretch: normal;
	font-style: normal;
	font-variant: normal;
	font-weight: 400;
	line-height: 19.05px;
}

.link-man, .link-sec, .link-ext, a.link-ext > b {
        background-attachment: scroll;
        background-clip: border-box;
        background-color: transparent;
        background-image: none;
        background-origin: padding-box;
        background-position: 0% 0%;
        background-repeat: repeat;
        background-size: auto auto;
        color: #07B;
        direction: ltr;
        font-family: sans-serif;
        font-size: 12.7px;
        font-size-adjust: none;
        font-stretch: normal;
        font-style: normal;
        font-variant: normal;
        font-weight: 700;
        line-height: 19.05px;
        outline-color: #07B;
        outline-style: none;
        outline-width: 0px;
        text-decoration: none;
}

.link-man:hover, .link-sec:hover, .link-ext:hover, a.link-ext > b:hover {
        background-attachment: scroll;
        background-clip: border-box;
        background-color: transparent;
        background-image: none;
        background-origin: padding-box;
        background-position: 0% 0%;
        background-repeat: repeat;
        background-size: auto auto;
        color: #999;
        direction: ltr;
        font-family: sans-serif;
        font-size: 12.7px;
        font-size-adjust: none;
        font-stretch: normal;
        font-style: normal;
        font-variant: normal;
        font-weight: 700;
        line-height: 19.05px;
        outline-color: #999;
        outline-style: none;
        outline-width: 0px;
        text-decoration: underline;
}
'''

TMP_PREFIX = '/tmp/'
CSS_LOCATION = TMP_PREFIX + 'archwiki.css'
CSS_FILE = open(CSS_LOCATION, 'w+')
CSS_FILE.write(CSS_CONTENT)
CSS_FILE.close()


def capitalize_func(match):
    ''' Callback function for regex match.
        This function receives regex text enclosed in HTML header tag(s) and
        returns the same string, but with capitalized title.
    '''
    return match.group(1) + match.group(2).capitalize() + match.group(3)

PARSER = argparse.ArgumentParser(description='Convert manpage to HTML and'
                                 'open in browser')
PARSER.add_argument('manpage_section',
                    help='the section number of manpage')
PARSER.add_argument('manpage_name', help='manpage file to parse')
ARGS = PARSER.parse_args()

try:
    MANPAGE_LOCATIONS = subprocess.check_output(['man',
                                                 '--where',
                                                 '--all',
                                                 ARGS.manpage_section,
                                                 ARGS.manpage_name])
except subprocess.CalledProcessError:
    print('No such manpage found.')
    exit(1)

MANPAGE_LOCATION = MANPAGE_LOCATIONS.split()[0]

UNCOMPRESSED_FILE = gzip.open(MANPAGE_LOCATION, mode='rt')
UNCOMPRESSED_DATA = UNCOMPRESSED_FILE.read()
UNCOMPRESSED_FILE.close()

TEMP_FILE = open(TMP_PREFIX + 'temp_uncompressed_manpage', 'w+')
TEMP_FILE.write(UNCOMPRESSED_DATA)
TEMP_FILE.close()

FILE_MANPAGE = open(TMP_PREFIX + 'temp_uncompressed_manpage')

FILE_HTML_NAME = TMP_PREFIX + \
                 os.path.basename(ARGS.manpage_name) + \
                 '.' + ARGS.manpage_section + \
                 '.html'
FILE_HTML = open(FILE_HTML_NAME, 'w')

HTML_OUTPUT = subprocess.check_output(['mandoc',
                                       '-Thtml',
                                       '-Ostyle=' + CSS_LOCATION,
                                       '-Oman=man://%N.%S_LINKSNOTWORKING.html'
                                      ],
                                      stdin=FILE_MANPAGE)
FILE_MANPAGE.close()

HTML_OUTPUT_DECODED = HTML_OUTPUT.decode()
HTML_OUTPUT_DECODED = re.sub('(<h[1-7][^>]*>)(.+)(</h[1-7]>)',
                             capitalize_func,
                             HTML_OUTPUT_DECODED)
HTML_OUTPUT_DECODED = re.sub('<div style="height: 1.00em;">',
                             '<div style="height: 0.40em;">',
                             HTML_OUTPUT_DECODED)
HTML_OUTPUT_DECODED = re.sub('<br>',
                             '',
                             HTML_OUTPUT_DECODED)
HTML_OUTPUT_DECODED = re.sub('<b>[\n]<p>[\n]</b>',
                             '<p>',
                             HTML_OUTPUT_DECODED)
HTML_OUTPUT_DECODED = re.sub('<b></b>',
                             '',
                             HTML_OUTPUT_DECODED)
HTML_OUTPUT_DECODED = re.sub('<dt>[\n]</dt>',
                             '',
                             HTML_OUTPUT_DECODED)
HTML_OUTPUT_DECODED = re.sub('<dt>[\n]<p>[\n]</dt>',
                             '<p>',
                             HTML_OUTPUT_DECODED)
HTML_OUTPUT_DECODED = re.sub('<p style="margin-left: 5.00ex;'\
                             'text-indent: -5.00ex;">',
                             '<p>',
                             HTML_OUTPUT_DECODED)
HTML_OUTPUT_DECODED = re.sub('&#8722;',
                             '-',
                             HTML_OUTPUT_DECODED)

for line in HTML_OUTPUT_DECODED.split('\n'):
    FILE_HTML.write(line + '\n')
FILE_HTML.close()

# Redirection to /dev/null is a workaround around
# https://bugzilla.mozilla.org/show_bug.cgi?id=833117
DEVNULL = open(os.devnull, 'wb')
subprocess.call([os.environ['BROWSER'], FILE_HTML_NAME], stderr=DEVNULL)
DEVNULL.close()

