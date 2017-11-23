from glob import glob
from flask import Blueprint
from flask_restful import Resource, Api
from flask_restful.inputs import regex
from lxml.etree import XPath, XMLParser, parse, XMLSyntaxError

backlinks_blueprint = Blueprint(name='backlinks', import_name=__name__, url_prefix='/api/backlinks', static_folder='static')


class Backlinks(Resource):
    def __init__(self):
        from re import UNICODE
        expr_recipe_type = '^(distribution|project|experiment|hardware|publication|person|dataset){1}$'
        expr_filename = '^[^\.][\w\-\.@:]+(?<!.xml)(?<!.html)(?<!.htm)$'
        self.valType = regex(expr_recipe_type, UNICODE)
        self.valFilename = regex(expr_filename, UNICODE)
        ns = {'c': 'https://toolkit.cit-ec.uni-bielefeld.de/CITKat'}
        self.xpath_relation_contains = XPath('//c:relation/text() = $filename_wo_suffix', namespaces=ns)
        self.xpath_directDependency_contains = XPath('//c:directDependency/text() = $filename_wo_suffix', namespaces=ns)
        self.xpath_extends_contains = XPath('//c:extends/text() = $filename_wo_suffix', namespaces=ns)
        self.xpath_catalog_children = XPath('/c:catalog/child::node()', namespaces=ns)

    def get(self, filename_wo_suffix, recipe_type):
        """
        Find backlinks.
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
            doc = parse(file_path, parser=parser)
            try:
                if self.xpath_relation_contains(doc, filename_wo_suffix=filename_wo_suffix) \
                        or self.xpath_directDependency_contains(doc, filename_wo_suffix=filename_wo_suffix) \
                        or self.xpath_extends_contains(doc, filename_wo_suffix=filename_wo_suffix):
                    return_dict = dict(self.xpath_catalog_children(doc)[0].attrib)
                    if 'keywords' in return_dict:
                        del return_dict['keywords']
                    return_dict['path'] = file_path
                    return_dict['type'] = file_path.split('/')[0]
                    return_list.append(return_dict)
            except XMLSyntaxError:
                pass
        return return_list


api = Api(backlinks_blueprint)
api.add_resource(Backlinks, '/<string:recipe_type>/<string:filename_wo_suffix>')