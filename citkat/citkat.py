#!/usr/bin/env python2
# -*- coding: utf-8 -*-

from os import path
from flask import Flask, send_from_directory
from flask_autoindex import AutoIndex

app = Flask(__name__)
AutoIndex(app, browse_root=path.curdir)


def main():
    app.run(debug=True)


# @app.route('/<string:directory>/<string:filename>')
# def serve_static(directory, filename):
#     return send_from_directory(directory, filename)
