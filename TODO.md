## until 1.0
* ~~replace all CDN content by /static/...~~ done.
* integrate Flask-Bootstrap v.4, https://github.com/mbr/flask-bootstrap/pull/164
* ~~make Flask serve /static~~ done.
* ~~make Flask serve working dir~~ done.
* implement ReST interface for backlinks
* make templates use static/stylesheet/*.xml files, therefor use _content_ of the root tag, not the root tag itself
* automate XSD to HTML documentation
* implement search interface (naive solution)
* attribute buildServerBaseURL: for distributions only!s
  * rework xsd
  * add url param to all ankers in a distribution
  * clone url param to all other types via js  


## after 1.0:
* Use Flask-script and  for running incremental build-generator updates on changed files or one specific file:
  `python manage.py update [file]`
* optimize search interface (using cache or database)
* make Flask serve working dir files, add config param
* minify all css and js, merge into one file?