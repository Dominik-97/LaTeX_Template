import re
import textwrap
import sys

def url_worker(fname):
    f = open(fname, "r")
    out = ""

    for line in f:
        if (line.find('url = {') != -1):
            out += "  url = {"

            url = (re.search('{(.*)}', line)).group(1)
            leng = len(url)

            url = url.replace("_", "\\_")
            url = url.replace("#", "\\#")

            if leng > 55:
                url = textwrap.fill(url, 55)
        #    url = url.replace("\n", "\\newline")

            out += url
            out += "},\n"
        else:
            out += line

    return out

def nonbreaking_space(fname):
    f = open(fname, "r")

    text = f.read()

    text = re.sub(r' ([a-zA-Z0-9ěščřžýáíéňťďĚŠČŘŽÝÁÍÉŇŤĎ]{1}) ', r' \1~', text)
    text = re.sub(r' ([a-zA-Z0-9ěščřžýáíéňťďĚŠČŘŽÝÁÍÉŇŤĎ]{2}) ', r' \1~', text)
    text = re.sub(r'~([a-zA-Z0-9ěščřžýáíéňťďĚŠČŘŽÝÁÍÉŇŤĎ]{1}) ', r'~\1~', text)
    text = re.sub(r'~([a-zA-Z0-9ěščřžýáíéňťďĚŠČŘŽÝÁÍÉŇŤĎ]{2}) ', r'~\1~', text)
    text = re.sub(r'\n([a-zA-Z0-9ěščřžýáíéňťďĚŠČŘŽÝÁÍÉŇŤĎ]{1}) ', r'\n\1~', text)
    text = re.sub(r'\n([a-zA-Z0-9ěščřžýáíéňťďĚŠČŘŽÝÁÍÉŇŤĎ]{2}) ', r'\n\1~', text)

    return text

if sys.argv[1] == "1":
    print(url_worker(sys.argv[2]))
else:
    print(nonbreaking_space(sys.argv[2]))
