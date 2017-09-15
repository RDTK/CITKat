# -*- coding: utf-8 -*-
from lxml.etree import parse, XMLParser
from os import path
from flask import Flask, abort
from flask_autoindex import AutoIndex
from flask_restful import Resource, Api
from flask_restful.inputs import regex
from glob import glob

app = Flask(__name__)
api = Api(app)
AutoIndex(app, browse_root=path.curdir)


class Backlink(Resource):
    def __init__(self):
        from re import UNICODE
        expr_recipe_type = '^(distribution|project|experiment|hardware|publication|person|dataset){1}$'
        expr_filename = '^[^\.][\w\-\.@:]+(?<!.xml)(?<!.html)(?<!.htm)$'
        self.valType = regex(expr_recipe_type, UNICODE)
        self.valFilename = regex(expr_filename, UNICODE)

    def get(self, filename_wo_suffix, recipe_type):
        """
        find backlinks

        TODO: differentiate between distributions and (project|experiment)
        :param filename_wo_suffix:
        :param recipe_type:
        :return: json list with backlinks dict
        """
        try:
            self.valFilename(filename_wo_suffix)
            self.valType(recipe_type)
        except ValueError:
            return 406
        return_list = []
        for file_path in glob('*/*.xml'):
            parser = XMLParser(remove_blank_text=True)
            ns = {'c': 'https://toolkit.cit-ec.uni-bielefeld.de/CITKat'}
            doc = parse(file_path, parser=parser)
            elem_list = doc.xpath('//c:relation[contains(text(), "' + filename_wo_suffix + '")]', namespaces=ns)
            elem_list += doc.xpath('//c:directDependency[contains(text(), "' + filename_wo_suffix + '")]', namespaces=ns)
            elem_list += doc.xpath('//c:extends[contains(text(), "' + filename_wo_suffix + '")]', namespaces=ns)
            if elem_list:
                return_dict = dict(doc.xpath('/c:catalog/child::node()', namespaces=ns)[0].attrib)
                if 'keywords' in return_dict:
                    del return_dict['keywords']
                return_dict['path'] = file_path
                return_list.append(return_dict)
        if return_list:
            return return_list, 200
        else:
            return [], 404


api.add_resource(Backlink, '/api/backlinks/<string:recipe_type>/<string:filename_wo_suffix>')


# TODO: replace AutoIndex by well-styled templates
# TODO: implement search

@app.after_request
def add_header(r):
    """
    Add headers to both force latest IE rendering engine or Chrome Frame,
    and also to cache the rendered page for 10 minutes.
    """
    if app.debug:
        r.headers["Cache-Control"] = "no-cache, no-store, must-revalidate"
        r.headers["Pragma"] = "no-cache"
        r.headers["Expires"] = "0"
        r.headers['Cache-Control'] = 'public, max-age=0'
    return r


def main():
    app.run(debug=True, host='::')
