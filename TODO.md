## until 1.0
* ~~replace all CDN content by /static/...~~ done.
* integrate Flask-Bootstrap v.4, https://github.com/mbr/flask-bootstrap/pull/164
* ~~make Flask serve /static~~ done.
* ~~make Flask serve working dir~~ done.
* implement linkedFragments in XSL
* ~~implement ReST interface for backlinks~~ mostly done.
* make templates use static/stylesheet/*.xml files, therefor use _content_ of the root tag, not the root tag itself
* automate XSD to HTML documentation
* ~~implement search interface (naive solution)~~ done.
* ~~attribute buildServerBaseURL: for distributions only!~~ no. attribute for all.  
  * ~~rework xsd~~ done. made attribute mandatory
  * ~~add url param to all ankers in a distribution~~ done. added url param to all artifacts, that are build with jenkins 
  * ~~clone url param to all other types via js~~ done.  
* hardware and dataset: remove description doublet
* create better (real world) sample data, integrate with real jenkins
* (mockup build-generator output for user study)
* Person|Puclication|dataset|experiment|hardware details



## after 1.0:
* Use Flask-script and  for running incremental build-generator updates on changed files or one specific file:
  `python manage.py update [file]`
* optimize search interface (using cache or database)
* make Flask serve working dir files, add config param
* minify all css and js, merge into one file?
* replace URL params by cookies or (better) by Window.sessionStorage (which store data per tab/window) (however: it might be a better solution, to just keep GET params)
* ReST API for file creation date and file modified date, eventually additional HTTP header?