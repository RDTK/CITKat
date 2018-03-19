from flask import Blueprint, Markup, render_template, abort, current_app, safe_join
from markdown import Markdown
# from markdown_blockdiag import BlockdiagExtension

markdown_content_blueprint = Blueprint(
    name='markdown_content', import_name=__name__, url_prefix='/content')
# TODO: add custom template to include all meta informations


@markdown_content_blueprint.route('/<path:fullpath>/')
def markdown_content(fullpath):
    if 'content-directory' not in current_app.config:
        warning = "<code>citkat.config['content-directory']</code> is not set!"
        if fullpath == 'Home':
            title = 'Home'
            content = Markup("<h1>Welcome!</h1>")
            return render_template('layout.html', **locals())
        return abort(500, warning)

    extensions = [
        'markdown.extensions.extra',
        'markdown.extensions.toc',
        'markdown.extensions.meta',
        # BlockdiagExtension(format='svg')
    ]
    md = Markdown(extensions=extensions, output_format='html5')

    try:
        f = open(
            safe_join(current_app.config['content-directory'], fullpath) +
            '.md', 'rb')
    except IOError:
        abort(404)

    raw_md = f.read().decode("UTF-8")

    html = md.convert(raw_md)
    title = 'Untitled Page'
    if 'title' in md.Meta:
        title = md.Meta['title'][0]
    content = Markup(html)
    return render_template(
        'layout.html', content=content, title=title, meta=md.Meta)
