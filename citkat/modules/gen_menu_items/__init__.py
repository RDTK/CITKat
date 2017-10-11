from flask import Blueprint

gen_menu_items_blueprint = Blueprint(name='gen_menu_items', import_name=__name__, url_prefix='/menu')


# TODO: scrape available menuItems
@gen_menu_items_blueprint.route('/additionalMenuItems.xml')
def gen_menu_items():
    """
    generate menu items, including dropdowns from file listing.
    :return: XML file with additional menu items.
    """
    return '<div />'  # TODO, for now return nothing