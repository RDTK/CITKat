# -*- coding: utf-8 -*-
from os import path
from flask import Flask
from flask_autoindex import AutoIndex
from flask_restful import Resource, Api
from flask_restful.inputs import regex
from mmap import mmap, ACCESS_READ
from glob import glob
from lxml import etree
from StringIO import StringIO


app = Flask(__name__)
api = Api(app)
AutoIndex(app, browse_root=path.curdir)


class Backlink(Resource):
    def __init__(self):
        from re import UNICODE
        expr_recipe_type = '^(distribution|project|experiment|hardware|publication|person|dataset){1}$'
        expr_filename = '^[^\.][\w\-\.@]+(?<!.xml)(?<!.html)(?<!.htm)$'
        self.valType = regex(expr_recipe_type, UNICODE)
        self.valFilename = regex(expr_filename, UNICODE)

    def get(self, filename_wo_suffix, recipe_type):
        """
        find backlinks
        TODO: speed up things
        :param filename_wo_suffix:
        :param recipe_type:
        :return:
        """
        try:
            self.valFilename(filename_wo_suffix)
            self.valType(recipe_type)
        except ValueError:
            return 406
        return_list = []
        for file_path in glob('*/*.xml'):
            with open(file_path, 'ro') as f:
                # s = mmap(f.fileno(), 0, access=ACCESS_READ)
                # HTML workaround for faulty lxml parser:
                s = f.read()
                # print(type(s))
                doc = etree.HTML(s)
                # doc = etree.parse(file)
                for elem in doc.xpath("/html/body/catalog//text()[. = '" + filename_wo_suffix + "']/.."):
                    return_dict = dict(elem.attrib)
                    if not 'type' in return_dict:
                        return_dict['type'] = 'directDependency'
                    return_dict['path'] = file_path
                    return_list.append(return_dict)
                # # print s
                # lines = findall('>' + filename_wo_suffix + '</(directDependency|linkedFragment)>', s, MULTILINE)
                # if lines:
                #     return [file_path, lines], 200
                # # if (s.find('<directDependency>' + filename_wo_suffix + '</directDependency>') != -1) or (
                # #     s.find('>' + filename_wo_suffix + '</linkedFragment>') != -1):
                # #     return_list.append(file_path)
        return return_list, 200


api.add_resource(Backlink, '/api/backlinks/<string:recipe_type>/<string:filename_wo_suffix>')


# TODO: replace AutoIndex by well-styled templates
# TODO: implement search


def main():
    app.run(debug=True, host='::')

# TODO: implement ReST API for backlinks
