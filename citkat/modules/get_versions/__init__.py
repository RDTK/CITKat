from glob import glob
from flask import Blueprint, current_app, safe_join
from flask_restful import Resource, Api
from lxml.etree import XPath, XMLParser, parse, XMLSyntaxError

get_versions_blueprint = Blueprint(name='get_versions', import_name=__name__, url_prefix='/api/versions',
                                   static_folder='static')


class GetVersions(Resource):
    def __init__(self):
        ns = {'c': 'https://toolkit.cit-ec.uni-bielefeld.de/CITKat'}
        self.xpath_has_other_versions = XPath(
            "/c:catalog/child::node()[not(@version = $version) and "
            "c:filename = concat($filename_wo_version, '-', translate(@version, '#', '_'))]",  # TODO: needs better escaping of all special uri-chars
            namespaces=ns)
        self.xpath_get_version = XPath('/c:catalog/child::node()/@version', namespaces=ns)

    def get(self, filename_wo_suffix, recipe_type):
        """
        Find other versions.
        :param filename_wo_suffix:
        :param recipe_type:
        :return: list of dicts with version as key and filepath as value
        """
        original_file_path_wo_suffix = safe_join(recipe_type, filename_wo_suffix)
        parser = XMLParser(remove_blank_text=True)
        try:
            actual_doc = parse(original_file_path_wo_suffix + '.xml', parser=parser)
        except IOError as e:
            current_app.logger.error(e)
            return []
        versions = self.xpath_get_version(actual_doc)
        actual_version = ''
        actual_version_len = 0
        if versions:
            actual_version = versions[0]
            actual_version_len = len(actual_version) + 1

        filename_wo_version = filename_wo_suffix[:-actual_version_len]

        return_list = []
        if actual_version:
            for file_path in glob(safe_join(recipe_type, filename_wo_version) + '-*.xml'):
                try:
                    doc = parse(file_path, parser=parser)
                    if self.xpath_has_other_versions(doc, version=actual_version,
                                                     filename_wo_version=filename_wo_version):
                        return_dict = {self.xpath_get_version(doc)[0]: '/' + file_path}
                        return_list.append(return_dict)
                except XMLSyntaxError as e:
                    current_app.logger.warning('Syntax error in catalog file "%s": \n%s', file_path, e)
            return return_list


api = Api(get_versions_blueprint)
api.add_resource(GetVersions, '/<string:recipe_type>/<string:filename_wo_suffix>')
