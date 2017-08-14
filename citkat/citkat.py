# -*- coding: utf-8 -*-

from os import path
from flask import Flask
from flask_autoindex import AutoIndex

app = Flask(__name__)
AutoIndex(app, browse_root=path.curdir)


def main():
    app.run(debug=True)
