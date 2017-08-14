#!/usr/bin/env python2
# -*- coding: utf-8 -*-

from flask import Flask
app = Flask(__name__)


def main():
    app.run(debug=True)


@app.route("/")
def hello():
    return "Hello Worlds!"
