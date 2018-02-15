from glob import glob
from collections import OrderedDict

from flask import Blueprint, render_template, safe_join, current_app
from lxml.etree import XPath, XMLParser, parse, XMLSyntaxError
from os import getcwd

browse_blueprint = Blueprint(name='browse', import_name=__name__, url_prefix='/browse', template_folder='templates')


class Browse(object):
    def __init__(self):
        ns = {'c': 'https://toolkit.cit-ec.uni-bielefeld.de/CITKat'}
        self.xpath_entity_name = XPath('/c:catalog/child::node()/@name', namespaces=ns)
        self.xpath_entity_version = XPath('/c:catalog/child::node()/@version', namespaces=ns)

    def get_name(self, entity, file):
        parser = XMLParser(remove_blank_text=True)
        doc = parse(safe_join(entity, file), parser=parser)
        name = self.xpath_entity_name(doc)
        if not name:
            name = file[:-4]
        else:
            name = name[0]
            version = self.xpath_entity_version(doc)
            if version:
                return {'name': name, 'version': version[0]}
        return {'name': name, 'version': ''}


titles = {'project': 'Project Versions',
          'distribution': 'System Versions',
          'experiment': 'Experiments',
          'dataset': 'Datasets',
          'hardware': 'Hardware Versions',
          'person': 'Persons'}


# TODO: pagenation, images?
@browse_blueprint.route('/<path:entity>')
def browse(entity):
    title = 'Browse ' + titles[entity[:-1]]
    listing = dict()
    b = Browse()
    for itm in glob(safe_join(getcwd(), entity, '*.xml')):
        try:
            res = b.get_name(entity, itm.split('/')[-1])
            if not res['name'] in listing:
                listing[res['name']] = dict()
            listing[res['name']][res['version']] = '/'.join(itm.split('/')[-2:])
        except XMLSyntaxError as e:
            current_app.logger.warning('Syntax error in catalog file "%s": \n%s', itm, e)
    print(listing)
    return render_template('browse.html', **locals())
