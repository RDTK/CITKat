<?xml version="1.0"?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:c="https://toolkit.cit-ec.uni-bielefeld.de/CITKat" xmlns:arr="array:variable"
                exclude-result-prefixes="c arr">
    <xsl:output method="html" indent="no" media-type="text/html" version="5.0"
                encoding="UTF-8" doctype-system="about:legacy-compat"
                cdata-section-elements="script" />
    <!--root template-->
    <xsl:template match="/">
        <html>
            <head>
                <xsl:apply-templates mode="head"/>
            </head>
            <body>
                <xsl:apply-templates/>
                <xsl:call-template name="footer"/>
            </body>
        </html>
    </xsl:template>

    <!--suppress all unwanted output:-->
    <xsl:template match="text()"/>
    <xsl:template match="text()" mode="head"/>
    <xsl:template match="text()" mode="catalog"/>
    <xsl:template match="text()" mode="dependency"/>
    <xsl:template match="text()" mode="gendist"/>

    <!--variables section-->
    <xsl:variable name="redmineRecipesRepository"><!--/wo trailing slash-->
        <xsl:value-of select="'https://opensource.cit-ec.de/projects/citk/repository/revisions/master'"/>
    </xsl:variable>
    <arr:array name="mediaQueries"><!--Bootstrap v4 values-->
        <arr:item name="sm">(min-width: 576px)</arr:item>
        <arr:item name="md">(min-width: 768px)</arr:item>
        <arr:item name="lg">(min-width: 992px)</arr:item>
        <arr:item name="xl">(min-width: 1200px)</arr:item>
    </arr:array>
    <xsl:variable name="mediaQueries" select="document('')/*/arr:array[@name = 'mediaQueries']/*"/>
    <xsl:variable name="includeHead">
        <xsl:copy-of select="document('/static/templates/head.xml')/child::node()/*"/>
    </xsl:variable>
    <xsl:variable name="includefooter">
        <xsl:copy-of select="document('/static/templates/footer.xml')/child::node()/*"/>
    </xsl:variable>
    <xsl:variable name="includeNavbar-head">
        <xsl:copy-of select="document('/static/templates/navbar-head.xml')/child::node()/*"/>
    </xsl:variable>
    <xsl:variable name="addMenuItems">
        <xsl:copy-of select="document('/menu/additionalMenuItems.xml')/child::node()/*"/>
    </xsl:variable>

    <!--logging helper-->
    <xsl:template name="log_template_info">
        <xsl:message>
            <xsl:text disable-output-escaping="yes">INFO: Calling '</xsl:text>
            <xsl:value-of select="local-name()"/>
            <xsl:text disable-output-escaping="yes">' template</xsl:text>
            <xsl:if test="@*">
                <xsl:text disable-output-escaping="yes"> with: </xsl:text>
                <xsl:for-each select="@*">
                    <xsl:text disable-output-escaping="yes">@</xsl:text>
                    <xsl:value-of select="local-name()"/>
                    <xsl:text disable-output-escaping="yes">="</xsl:text>
                    <xsl:value-of select="."/>
                    <xsl:text disable-output-escaping="yes">" </xsl:text>
                </xsl:for-each>
            </xsl:if>
        </xsl:message>
    </xsl:template>

    <!--capitalization helper-->
    <xsl:template name="capitalizeFirstLetter">
        <xsl:param name="in"/>
        <xsl:message>INFO: Calling 'capitalizeFirstLetter' template</xsl:message>
        <xsl:value-of
                select="concat(
                          translate(
                            substring($in, 1, 1), 'abcdefghijklmnopqrstuvwxyz', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
                          ),
                          substring(
                            $in, 2, string-length($in)-1
                          )
                        )"/>
    </xsl:template>

    <!--head-->
    <xsl:template match="/c:catalog" mode="head">
        <xsl:call-template name="log_template_info"/>
        <xsl:copy-of select="$includeHead"/>
        <title>
            <xsl:call-template name="capitalizeFirstLetter">
                <xsl:with-param name="in" select="name(*[1])"/>
            </xsl:call-template>
            <xsl:choose>
                <xsl:when test="not(c:publication) and not(c:person)">
                    <xsl:text disable-output-escaping="yes">: </xsl:text>
                    <xsl:value-of select="child::node()/@name"/>
                    <xsl:if test="child::node()/@version">
                        <xsl:text disable-output-escaping="yes"> (</xsl:text>
                        <xsl:value-of select="child::node()/@version"/>
                        <xsl:text disable-output-escaping="yes">)</xsl:text>
                    </xsl:if>
                </xsl:when>
                <xsl:when test="c:publication">
                    <xsl:text disable-output-escaping="yes">: </xsl:text>
                    <xsl:value-of select="child::node()/@title"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text> Details</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:text disable-output-escaping="yes"> // CITKat</xsl:text>
        </title>
    </xsl:template>

    <!--footer-->
    <xsl:template name="footer">
        <xsl:copy-of select="$includefooter"/>
        <script src="/static/js/linkParams.js"/>
        <script src="/static/js/oldAndroid.js"/>
        <!--TODO: include recipe url-->
        <div style="font-size: .5rem;" class="container text-muted">
            <samp>build-gen</samp>
            <xsl:text> </xsl:text>
            <xsl:value-of select="/c:catalog/@generatorVersion"/>
            <xsl:text>, </xsl:text>
            <span class="date">
                <xsl:value-of select="/c:catalog/@creationTime"/>
            </span>
            <xsl:text> || </xsl:text>
            <a href="#" class="text-muted">Recipe-Url</a>
        </div>
    </xsl:template>

    <!--catalog content-->
    <xsl:template match="c:catalog">
        <xsl:call-template name="log_template_info"/>
        <div class="container" style="padding-left: 0; padding-right: 0;"><!--first container doesn't need padding!-->
            <!--import navbar-->
            <xsl:call-template name="navbar">
                <xsl:with-param name="type">
                    <xsl:value-of select="name(*[1])"/>
                </xsl:with-param>
            </xsl:call-template>
            <!--main catalog container, set important attributes-->
            <xsl:element name="div">
                <xsl:attribute name="id">
                    <xsl:text disable-output-escaping="yes">catalog</xsl:text>
                </xsl:attribute>
                <xsl:attribute name="class">
                    <xsl:text disable-output-escaping="yes">container</xsl:text>
                </xsl:attribute>
                <xsl:attribute name="type">
                    <xsl:value-of select="name(*[1])"/>
                </xsl:attribute>
                <xsl:attribute name="data-filename">
                    <xsl:value-of select="child::node()/c:filename"/>
                </xsl:attribute>
                <xsl:if test="c:distribution">
                    <xsl:attribute name="build-generator-template">
                        <xsl:value-of select="c:distribution/@build-generator-template"/>
                    </xsl:attribute>
                    <xsl:attribute name="buildserverbaseurl">
                        <xsl:value-of select="c:distribution/@buildServerBaseURL"/>
                    </xsl:attribute>
                </xsl:if>
                <!--recipes name and version as headline-->
                <div class="h2 clearfix">
                    <!--<xsl:call-template name="includeOcticon">-->
                    <!--<xsl:with-param name="name" select="'star'"/>-->
                    <!--</xsl:call-template>-->
                    <xsl:call-template name="capitalizeFirstLetter">
                        <xsl:with-param name="in" select="name(*[1])"/>
                    </xsl:call-template>
                    <xsl:text disable-output-escaping="yes"> Details: </xsl:text>
                    <xsl:choose>
                        <xsl:when test="child::node()/@name">
                            <xsl:value-of select="child::node()/@name"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="child::node()/c:filename"/>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:if test="child::node()/@version and not(c:person)">
                        <span>
                            <xsl:text disable-output-escaping="yes"> </xsl:text>
                            <button class="btn btn-light dropdown-toggle" type="button" id="versionsDropdown"
                                    data-toggle="dropdown" aria-haspopup="true" aria-expanded="false"
                                    style="font-size: 1.5rem; line-height: 1.2rem; vertical-align: bottom;"
                                    title="Show other versions">
                                <xsl:call-template name="includeOcticon">
                                    <xsl:with-param name="name" select="'versions'"/>
                                </xsl:call-template>
                                <xsl:value-of select="child::node()/@version"/>
                            </button>
                            <div class="dropdown-menu dropdown-menu-right" aria-labelledby="versionsDropdown">
                                <a class="dropdown-item  active" title="Selected version">
                                    <xsl:attribute name="href">
                                        <xsl:text disable-output-escaping="yes">#</xsl:text>
                                    </xsl:attribute>
                                    <xsl:value-of select="child::node()/@version"/>
                                </a>
                            </div>
                        </span>
                        <!--Doing the load-other-versions-part as AJAX request in order to reduce server load-->
                        <script src="/api/versions/static/js/getVersions.js"/>
                        </xsl:if>
                    </div>

                <!--general information for all but persons and publications-->
                <div class="card">
                    <xsl:choose>
                        <xsl:when test="c:distribution | c:project | c:experiment | c:hardware | c:dataset">
                            <div class="card-header">
                                <h3>
                                    <xsl:call-template name="includeOcticon">
                                        <xsl:with-param name="name" select="'file'"/>
                                    </xsl:call-template>
                                    <xsl:text disable-output-escaping="yes">General Information</xsl:text>
                                </h3>
                            </div>
                            <div class="card-body hideContent">
                                <div class="description card-text">
                                    <xsl:choose>
                                        <xsl:when test="child::node()/c:description">
                                            <xsl:apply-templates select="child::node()/c:description" mode="catalog"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <p>
                                                <xsl:text disable-output-escaping="yes">No description provided yet.</xsl:text>
                                            </p>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </div>
                            </div>
                            <div class="card-footer">
                                <dl class="row">
                                    <!--access type-->
                                    <xsl:apply-templates select="child::node()/@access" mode="catalog"/>
                                    <!--languages-->
                                    <xsl:apply-templates select="child::node()/c:programmingLanguages" mode="catalog"/>
                                    <!--license-->
                                    <xsl:apply-templates select="child::node()/c:license" mode="catalog"/>
                                    <!--natures-->
                                    <xsl:apply-templates select="child::node()/c:natures" mode="catalog"/>
                                    <!--keywords-->
                                    <xsl:apply-templates select="child::node()/c:keywords" mode="catalog"/>
                                    <!--scm-->
                                    <xsl:apply-templates select="child::node()/c:scm" mode="catalog"/>
                                </dl>
                            </div>
                        </xsl:when>
                        <xsl:otherwise>
                            <div class="card-header">
                                <!--person -->
                                <xsl:apply-templates select="c:person" mode="catalog"/>
                            </div>
                            <xsl:if test="child::node()/c:description">
                                <div class="card-body">
                                    <xsl:apply-templates select="child::node()/c:description" mode="catalog"/>
                                </div>
                            </xsl:if>
                        </xsl:otherwise>
                    </xsl:choose>
                </div>

                <!--image carousel-->
                <xsl:if test="child::node()/c:resource[@type = 'img']">
                    <xsl:call-template name="imgCarousel"/>
                </xsl:if>
                <!--embed video-->
                <xsl:apply-templates select="child::node()/c:resource[@type = 'video']" mode="catalog"/>

                <!--other resources-->
                <div class="card-columns" id="resources">
                    <xsl:if test="c:project">
                        <xsl:choose>
                            <xsl:when test="not(child::node()/c:resource[not(@type = 'img') and not(@type = 'video')])">
                                <div class="card ">
                                    <div class="card-header">
                                        <h5>
                                            <xsl:call-template name="includeOcticon">
                                                <xsl:with-param name="name" select="'link-external'"/>
                                            </xsl:call-template>
                                            <xsl:text>Resources</xsl:text>
                                        </h5>
                                    </div>
                                    <div class="card-body">
                                        <dl>
                                            <dt>
                                                <xsl:call-template name="includeOcticon">
                                                    <xsl:with-param name="name" select="'alert'"/>
                                                </xsl:call-template>
                                                <xsl:text>No additional resources available in this recipe.</xsl:text>
                                            </dt>
                                        </dl>
                                    </div>
                                </div>
                            </xsl:when>
                            <xsl:when test="child::node()/c:resource[not(@type = 'img') and not(@type = 'video')]">
                                <div class="card ">
                                    <div class="card-header">
                                        <h5>
                                            <xsl:call-template name="includeOcticon">
                                                <xsl:with-param name="name" select="'link-external'"/>
                                            </xsl:call-template>
                                            <xsl:text>Resources</xsl:text>
                                        </h5>
                                    </div>
                                    <div class="card-body">
                                        <dl>
                                            <xsl:apply-templates 
                                                select="child::node()/c:resource[not(@type = 'img') and not(@type = 'video')]" 
                                                mode="catalog"/>
                                        </dl>
                                    </div>
                                </div>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:if>
                    <!--extends-->
                    <xsl:apply-templates select="child::node()/c:extends" mode="catalog"/>
                    <!--Related Persons-->
                    <xsl:if test="child::node()/c:relation[@type = 'person'] or /c:catalog/@gdpr">
                            <div class="card">
                                <div class="card-header">
                                    <h5>
                                        <xsl:call-template name="includeOcticon">
                                            <xsl:with-param name="name" select="'person'"/>
                                        </xsl:call-template>
                                        <xsl:text disable-output-escaping="yes">Involved </xsl:text>
                                        <xsl:call-template name="capitalizeFirstLetter">
                                            <xsl:with-param name="in" select="child::node()/c:relation[@type = 'person']/@type"/>
                                        </xsl:call-template>
                                        <xsl:if test="count(child::node()/c:relation[@type = 'person']) > 1">
                                            <xsl:text>s</xsl:text>
                                        </xsl:if>
                                        <xsl:text disable-output-escaping="yes">:</xsl:text>
                                        <xsl:if test="/c:catalog/@gdpr">
                                            
                                            <a href="#" class="badge badge-pill badge-info text-light" style="float:right;">
                                                <small>
                                                    <xsl:call-template name="includeOcticon">
                                                        <xsl:with-param name="name" select="'shield'"/>
                                                    </xsl:call-template>
                                                    <xsl:text>GDPR compliant</xsl:text>
                                                </small>
                                            </a>
                                        </xsl:if>
                                    </h5>
                                </div>
                                <div class="card-body">
                                    <xsl:choose>
                                        <xsl:when test="child::node()/c:relation[@type = 'person']">
                                            <xsl:if test="/c:catalog/@gdpr">
                                                <xsl:text>This list may incomplete in order to be compliant to the EU's GDPR.</xsl:text>
                                            </xsl:if>
                                    <ul class="persons">
                                        <xsl:apply-templates select="child::node()/c:relation[@type = 'person']" mode="person"/>
                                    </ul>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <text>Either there are currently no involved persons known or they did not aggree to the GDPR Opt-In.</text>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </div>
                            </div>
                    </xsl:if>
                    <!--Related Publications-->
                    <xsl:if test="child::node()/c:relation[@type = 'publication']">
                        <h5>
                            <xsl:text disable-output-escaping="yes">Linked </xsl:text>
                            <xsl:call-template name="capitalizeFirstLetter">
                                <xsl:with-param name="in" select="child::node()/c:relation[@type = 'publication']/@type"/>
                            </xsl:call-template>
                            <xsl:if test="count(child::node()/c:relation[@type = 'publication']) > 1">
                                <xsl:text>s</xsl:text>
                            </xsl:if>
                            <xsl:text disable-output-escaping="yes">:</xsl:text>
                        </h5>
                        <ul class="publications">
                            <xsl:apply-templates select="child::node()/c:relation[@type = 'publication']" mode="catalog"/>
                        </ul>
                    </xsl:if>
                    <!--Related Hardware-->
                    <xsl:if test="child::node()/c:relation[@type = 'hardware']">
                        <h5>
                            <xsl:call-template name="includeOcticon">
                                <xsl:with-param name="name" select="'server'"/>
                            </xsl:call-template>
                            <xsl:call-template name="capitalizeFirstLetter">
                                <xsl:with-param name="in" select="child::node()/c:relation[@type = 'hardware']/@type"/>
                            </xsl:call-template>
                            <xsl:text disable-output-escaping="yes">:</xsl:text>
                        </h5>
                        <ul class="hardware">
                            <xsl:apply-templates select="child::node()/c:relation[@type = 'hardware']" mode="catalog"/>
                        </ul>
                    </xsl:if>
                    <!--apply all dependency stuff-->
                    <xsl:apply-templates mode="dependency"/>
                    <!--additional experiment info-->
                    <xsl:if test="c:experiment">
                        <xsl:call-template name="experimentMetrics"/>
                    </xsl:if>
                    <!--getBacklinks block-->
                    <xsl:call-template name="getBacklink"/>
                    <!--jenkins block-->
                    <xsl:if test="c:distribution | c:project | c:experiment">
                        <xsl:call-template name="jenkinsApi"/>
                    </xsl:if>
                </div>
            </xsl:element>
        </div>
    </xsl:template>

    <!--include octicon-->
    <xsl:template name="includeOcticon">
        <xsl:param name="name"/>
        <xsl:message>INFO: Calling 'includeOcticon' template</xsl:message>
        <svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
            <xsl:attribute name="version">1.1</xsl:attribute>
            <xsl:attribute name="class">
                <xsl:text disable-output-escaping="yes">octicon octicon-</xsl:text>
                <xsl:value-of select="$name"/>
            </xsl:attribute>
            <use>
                <xsl:attribute name="xlink:href">
                    <xsl:text disable-output-escaping="yes">#</xsl:text>
                    <xsl:value-of select="$name"/>
                </xsl:attribute>
            </use>
        </svg>
    </xsl:template>

    <!--navbar creation-->
    <xsl:template name="navbar">
        <xsl:param name="type"/>
        <xsl:message>INFO: Calling 'navbar' template</xsl:message>
        <nav class="navbar sticky-top navbar-expand-lg navbar-light bg-light">
            <xsl:copy-of select="$includeNavbar-head"/>

            <div class="collapse navbar-collapse" id="navbarSupportedContent">
                <ul class="navbar-nav mr-auto">
                    <xsl:copy-of select="$addMenuItems"/>
                </ul>
                <form class="form-inline my-2 my-lg-0" method="get" action="/search">
                    <input class="form-control mr-sm-2" type="text" placeholder="Search" aria-label="Search" name="s"/>
                    <button class="btn btn-outline-success my-2 my-sm-0" type="submit" hidden="true">Search</button>
                </form>
            </div>
        </nav>
    </xsl:template>

    <!--navbar browsed-dropdown-->
    <xsl:template name="navbar-browseDropdown">
        <xsl:param name="type"/>
        <li class="nav-item dropdown active">
            <a class="nav-link dropdown-toggle" href="/browse/" id="BrowseDropdown"
               data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                <xsl:text>Browse</xsl:text>
                <span class="sr-only">
                    <xsl:text> (current)</xsl:text>
                </span>
            </a>
            <div class="dropdown-menu" aria-labelledby="BrowseDropdown">
                <!--System Versions-->
                <xsl:element name="a">
                    <xsl:attribute name="class">
                        <xsl:text>dropdown-item</xsl:text>
                        <xsl:if test="$type = 'distribution'">
                            <xsl:text> active</xsl:text>
                        </xsl:if>
                    </xsl:attribute>
                    <xsl:attribute name="href">
                        <xsl:text disable-output-escaping="yes">/browse/distribution/</xsl:text>
                    </xsl:attribute>
                    <xsl:text disable-output-escaping="yes">System Versions</xsl:text>
                    <xsl:if test="$type = 'distribution'">
                        <span class="sr-only">
                            <xsl:text> (current)</xsl:text>
                        </span>
                    </xsl:if>
                </xsl:element>
                <!--Component Versions-->
                <xsl:element name="a">
                    <xsl:attribute name="class">
                        <xsl:text>dropdown-item</xsl:text>
                        <xsl:if test="$type = 'project'">
                            <xsl:text> active</xsl:text>
                        </xsl:if>
                    </xsl:attribute>
                    <xsl:attribute name="href">
                        <xsl:text disable-output-escaping="yes">/browse/project/</xsl:text>
                    </xsl:attribute>
                    <xsl:text disable-output-escaping="yes">Component Versions</xsl:text>
                    <xsl:if test="$type = 'distribution'">
                        <span class="sr-only">
                            <xsl:text> (current)</xsl:text>
                        </span>
                    </xsl:if>
                </xsl:element>
                <!--Experiments-->
                <xsl:element name="a">
                    <xsl:attribute name="class">
                        <xsl:text>dropdown-item</xsl:text>
                        <xsl:if test="$type = 'experiment'">
                            <xsl:text> active</xsl:text>
                        </xsl:if>
                    </xsl:attribute>
                    <xsl:attribute name="href">
                        <xsl:text disable-output-escaping="yes">/browse/experiment/</xsl:text>
                    </xsl:attribute>
                    <xsl:text disable-output-escaping="yes">Experiments</xsl:text>
                    <xsl:if test="$type = 'distribution'">
                        <span class="sr-only">
                            <xsl:text> (current)</xsl:text>
                        </span>
                    </xsl:if>
                </xsl:element>
                <!--Datasets-->
                <xsl:element name="a">
                    <xsl:attribute name="class">
                        <xsl:text>dropdown-item</xsl:text>
                        <xsl:if test="$type = 'dataset'">
                            <xsl:text> active</xsl:text>
                        </xsl:if>
                    </xsl:attribute>
                    <xsl:attribute name="href">
                        <xsl:text disable-output-escaping="yes">/browse/dataset/</xsl:text>
                    </xsl:attribute>
                    <xsl:text disable-output-escaping="yes">Datasets</xsl:text>
                    <xsl:if test="$type = 'distribution'">
                        <span class="sr-only">
                            <xsl:text> (current)</xsl:text>
                        </span>
                    </xsl:if>
                </xsl:element>
                <!--Hardware Versions-->
                <xsl:element name="a">
                    <xsl:attribute name="class">
                        <xsl:text>dropdown-item</xsl:text>
                        <xsl:if test="$type = 'hardware'">
                            <xsl:text> active</xsl:text>
                        </xsl:if>
                    </xsl:attribute>
                    <xsl:attribute name="href">
                        <xsl:text disable-output-escaping="yes">/browse/hardware/</xsl:text>
                    </xsl:attribute>
                    <xsl:text disable-output-escaping="yes">Hardware Versions</xsl:text>
                    <xsl:if test="$type = 'distribution'">
                        <span class="sr-only">
                            <xsl:text> (current)</xsl:text>
                        </span>
                    </xsl:if>
                </xsl:element>
            </div>
        </li>
    </xsl:template>


    <!--create backlinks-->
    <xsl:template name="getBacklink">
        <xsl:message>INFO: Calling 'getBacklink' template</xsl:message>
        <!--<xsl:copy-of-->
                <!--select="document(-->
                                 <!--concat('/api/backlinks/',-->
                                        <!--name(*[1]),-->
                                        <!--'/',-->
                                        <!--child::node()/c:filename)-->
                                 <!--)/child::node()"/>-->
        <script src="/api/backlinks/static/js/backlink.js"/>
    </xsl:template>

    <!--resource type image, display in a carousel-->
    <xsl:template name="imgCarousel">
        <xsl:message>INFO: Calling 'imgCaroussel' template</xsl:message>
        <div id="carouselImgs" class="carousel slide card" data-ride="carousel" style="border: none;">
            <xsl:if test="count(child::node()/c:resource[@type = 'img']) > 1">
                <ol class="carousel-indicators">
                    <xsl:for-each select="child::node()/c:resource[@type = 'img']">
                        <xsl:element name="li">
                            <xsl:attribute name="data-target">
                                <xsl:text disable-output-escaping="yes">#carouselImgs</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="data-slide-to">
                                <xsl:value-of select="position() - 1"/>
                            </xsl:attribute>
                            <xsl:if test="position() = 1">
                                <xsl:attribute name="class">
                                    <xsl:text disable-output-escaping="yes">active</xsl:text>
                                </xsl:attribute>
                            </xsl:if>
                        </xsl:element>
                    </xsl:for-each>
                </ol>
            </xsl:if>
            <div class="carousel-inner">
                <xsl:apply-templates select="child::node()/c:resource[@type = 'img']"/>
                <xsl:for-each select="child::node()/c:resource[@type = 'img']">
                    <xsl:element name="div">
                        <xsl:attribute name="class">
                            <xsl:text disable-output-escaping="yes">carousel-item</xsl:text>
                            <xsl:if test="position() = 1">
                                <xsl:text disable-output-escaping="yes"> active</xsl:text>
                            </xsl:if>
                        </xsl:attribute>
                        <picture>
                            <xsl:call-template name="pictureSource">
                                <xsl:with-param name="href">
                                    <xsl:value-of select="@href"/>
                                </xsl:with-param>
                            </xsl:call-template>
                            <img class="d-block img-fluid" src="{@href}" alt="{@alt}"/>
                        </picture>
                        <xsl:if test="@name">
                            <div class="carousel-caption ">
                                <h3>
                                    <xsl:value-of select="@name"/>
                                </h3>
                            </div>
                        </xsl:if>
                    </xsl:element>
                </xsl:for-each>
            </div>
            <xsl:if test="count(child::node()/c:resource[@type = 'img']) > 1">
                <a class="carousel-control-prev" href="#carouselImgs" role="button" data-slide="prev">
                    <span class="carousel-control-prev-icon" aria-hidden="true"/>
                    <span class="sr-only">Previous</span>
                </a>
                <a class="carousel-control-next" href="#carouselImgs" role="button" data-slide="next">
                    <span class="carousel-control-next-icon" aria-hidden="true"/>
                    <span class="sr-only">Next</span>
                </a>
            </xsl:if>
        </div>
    </xsl:template>

    <!--generate picture source tag-->
    <xsl:template name="pictureSource">
        <xsl:param name="href"/>
        <xsl:message>INFO: Calling 'pictureSource' template</xsl:message>
        <xsl:for-each select="$mediaQueries">
            <xsl:element name="source">
                <!--TODO: manipulate href>: "/foo/image.png" -> "/foo.image-{@name}.png, /foo.image-{@name}@2X.png 2x"-->
                <xsl:attribute name="srcset">
                    <xsl:value-of select="$href"/>
                </xsl:attribute>
                <xsl:attribute name="media">
                    <xsl:value-of select="."/>
                </xsl:attribute>
            </xsl:element>
        </xsl:for-each>
    </xsl:template>

    <!--person -->
    <xsl:template match="c:person" mode="catalog">
        <xsl:call-template name="log_template_info"/>
        <xsl:if test="c:gravatar">
            <div id="gravatar" style="float: right">
                <img title="Gravatar" style="filter: brightness(97%)">
                    <xsl:attribute name="src">
                        <xsl:text>https://www.gravatar.com/avatar/</xsl:text>
                        <xsl:value-of select="c:gravatar/text()"/>
                        <xsl:text>?s=120&amp;d=identicon</xsl:text>
                    </xsl:attribute>
                </img>
            </div>
        </xsl:if>

        <h4>
            <xsl:call-template name="includeOcticon">
                <xsl:with-param name="name" select="'person'"/>
            </xsl:call-template>
            <xsl:value-of select="c:name"/>
        </h4>
        <xsl:if test="c:email">
            <ul>
                <xsl:apply-templates select="c:email" mode="catalog"/>
            </ul>
        </xsl:if>
    </xsl:template>

    <!--email-->
    <xsl:template match="c:email" mode="catalog">
        <xsl:call-template name="log_template_info"/>
        <li>
            <xsl:call-template name="includeOcticon">
                <xsl:with-param name="name" select="'mail'"/>
            </xsl:call-template>
            <a>
                <xsl:attribute name="href">
                    <xsl:choose>
                        <xsl:when test="contains(., 'mailto:')">
                            <xsl:value-of select="."/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text>mailto:</xsl:text>
                            <xsl:value-of select="."/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
                <xsl:choose>
                    <xsl:when test="contains(., 'mailto:')">
                        <xsl:value-of select="substring-after(., 'mailto:')"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="."/>
                    </xsl:otherwise>
                </xsl:choose>
            </a>
        </li>
    </xsl:template>

    <!--video resources-->
    <xsl:template match="c:resource[@type = 'video']" mode="catalog">
        <xsl:call-template name="log_template_info"/>
        <div class="video card" style="boder:none; ">
            <xsl:choose>
                <xsl:when test="contains(@href, 'vimeo')">
                    <div id="vimeo-embed" data-href="{@href}" class="videoWrapper">Loading video...</div>
                    <script src="/static/js/embedVimeo.js"/>
                </xsl:when>
                <xsl:when test="contains(@href, 'youtube.com') and contains(@href, '/embed/')">
                    <div class="videoWrapper">
                        <xsl:element name="iframe">
                            <xsl:attribute name="id">
                                <xsl:text disable-output-escaping="yes">ytplayer</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="type">
                                <xsl:text disable-output-escaping="yes">text/html</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="width">
                                <xsl:text disable-output-escaping="yes">640</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="height">
                                <xsl:text disable-output-escaping="yes">360</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="src">
                                <xsl:value-of select="@href"/>
                            </xsl:attribute>
                            <xsl:attribute name="frameborder">
                                <xsl:text disable-output-escaping="yes">0</xsl:text>
                            </xsl:attribute>
                        </xsl:element>
                    </div>
                </xsl:when>
                <xsl:otherwise>
                    <span>
                        <xsl:text disable-output-escaping="yes">Linked Video: </xsl:text>
                    </span>
                    <a href="{@href}">
                        <xsl:choose>
                            <xsl:when test="@name">
                                <xsl:value-of select="@name"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="@href"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </a>
                </xsl:otherwise>
            </xsl:choose>
        </div>
    </xsl:template>

    <!--other resource types-->
    <xsl:template match="c:resource[not(@type = 'img') and not(@type = 'video')]" mode="catalog">
        <xsl:call-template name="log_template_info"/>
        <dt>
            <xsl:choose>
                <xsl:when test="@type = 'bugtracker'">
                    <xsl:text disable-output-escaping="yes">Bug Tracker</xsl:text>
                </xsl:when>
                <xsl:when test="@type = 'scmbrowser'">
                    <xsl:text disable-output-escaping="yes">SCM</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="capitalizeFirstLetter">
                        <xsl:with-param name="in" select="@type"/>
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:text disable-output-escaping="yes">: </xsl:text>
        </dt>
        <dd>
            <a href="{@href}">
                <!--<xsl:call-template name="includeOcticon">-->
                    <!--<xsl:with-param name="name" select="'link-external'"/>-->
                <!--</xsl:call-template>-->
                <xsl:choose>
                    <xsl:when test="@name">
                        <xsl:value-of select="@name"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="@href"/>
                    </xsl:otherwise>
                </xsl:choose>
            </a>
        </dd>
    </xsl:template>

    <!--jenkins api-->
    <xsl:template name="jenkinsApi">
        <xsl:message>INFO: Calling 'jenkinsApi' template</xsl:message>
        <!--<xsl:element name="div">-->
            <!--<xsl:attribute name="id">-->
                <!--<xsl:text disable-output-escaping="yes">jenkinsState</xsl:text>-->
            <!--</xsl:attribute>-->
            <!--<xsl:attribute name="type">-->
                <!--<xsl:value-of select="name(*[1])"/>-->
            <!--</xsl:attribute>-->
            <!--<xsl:attribute name="name">-->
                <!--<xsl:value-of select="/c:catalog/child::node()/c:filename"/>-->
            <!--</xsl:attribute>-->
        <!--</xsl:element>-->
        <xsl:element name="script">
            <xsl:attribute name="src">
                <xsl:text disable-output-escaping="yes">/static/js/jenkins-api.js</xsl:text>
            </xsl:attribute>
        </xsl:element>
    </xsl:template>

    <!--description-->
    <xsl:template match="c:description" mode="catalog">
        <xsl:choose>
            <xsl:when test="@format='text/markdown'">
                <div style="white-space: pre-line;" data-markdown="true">
                    <xsl:value-of select="." disable-output-escaping="yes"/>
                </div>
                <script src="/static/node_modules/marked/marked.min.js"></script>
                <script><![CDATA[
// add +3 to the heading level of Markdown text
var renderer = new marked.Renderer();
renderer.heading = function(text, level, raw) {
    return '<h'
    + (level + 3)
    + ' id="'
    + this.options.headerPrefix
    + raw.toLowerCase().replace(/[^\w]+/g, '-')
    + '">'
    + text
    + '</h'
    + (level + 3)
    + '>\n';
};

document.body.querySelector('[data-markdown=true]').innerHTML = marked(document.body.querySelector('[data-markdown=true]').textContent, { renderer: renderer });
document.body.querySelector('[data-markdown=true]').removeAttribute('style');
]]>
                </script>
            </xsl:when> 
            <xsl:otherwise>
                <div style="white-space: pre-line;">
                    <xsl:value-of select="." disable-output-escaping="yes"/>
                </div>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!--access type-->
    <xsl:template match="@access" mode="catalog">
        <xsl:call-template name="log_template_info"/>
        <dt class="col-6 col-lg-3">
            <xsl:call-template name="includeOcticon">
                <xsl:with-param name="name" select="'lock'"/>
            </xsl:call-template>
            <xsl:text disable-output-escaping="yes">Access: </xsl:text>
        </dt>
        <dd class="col-6 col-lg-3">
            <a>
                <xsl:choose>
                    <xsl:when test=". = 'public'">
                        <xsl:attribute name="class">
                            <xsl:text>badge badge-success text-light</xsl:text>
                        </xsl:attribute>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="class">
                            <xsl:text>badge badge-secondary text-light</xsl:text>
                        </xsl:attribute>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:attribute name="href">
                    <xsl:text>/search/access/</xsl:text>
                    <xsl:value-of select="."/>
                </xsl:attribute>
                <xsl:attribute name="title">
                    <xsl:text disable-output-escaping="yes">Search for other &lt;strong></xsl:text>
                    <xsl:value-of select="."/>
                    <xsl:text disable-output-escaping="yes">&lt;/strong> recipes</xsl:text>
                </xsl:attribute>
                <xsl:attribute name="data-toggle">
                    <xsl:text>tooltip</xsl:text>
                </xsl:attribute>
                <xsl:attribute name="data-placement">
                    <xsl:text>bottom</xsl:text>
                </xsl:attribute>
                <small>
                    <xsl:call-template name="includeOcticon">
                        <xsl:with-param name="name" select="'tag'"/>
                    </xsl:call-template>
                </small>
                <xsl:value-of select="."/>
            </a>
        </dd>
    </xsl:template>

    <!--licenses-->
    <xsl:template match="c:license" mode="catalog">
        <xsl:call-template name="log_template_info"/>
        <dt class="col-6 col-lg-3">
            <xsl:call-template name="includeOcticon">
                <xsl:with-param name="name" select="'law'"/>
            </xsl:call-template>
            <xsl:text disable-output-escaping="yes">License: </xsl:text>
        </dt>
        <dd class="col-6 col-lg-3">
            <a>
                <xsl:attribute name="href">
                    <xsl:text>/search/license/</xsl:text>
                    <xsl:value-of select="."/>
                </xsl:attribute>
                <xsl:attribute name="title">
                    <xsl:text disable-output-escaping="yes">Search for other &lt;strong></xsl:text>
                    <xsl:value-of select="."/>
                    <xsl:text disable-output-escaping="yes">&lt;/strong> recipes</xsl:text>
                </xsl:attribute>
                <xsl:attribute name="data-toggle">
                    <xsl:text>tooltip</xsl:text>
                </xsl:attribute>
                <xsl:attribute name="data-placement">
                    <xsl:text>bottom</xsl:text>
                </xsl:attribute>
                <xsl:choose>
                    <xsl:when test=". = '-unknown-' or . = 'unknown'">
                        <xsl:attribute name="class">
                            <xsl:text>badge badge-danger text-light</xsl:text>
                        </xsl:attribute>
                        <small>
                            <xsl:call-template name="includeOcticon">
                                <xsl:with-param name="name" select="'alert'"/>
                            </xsl:call-template>
                        </small>
                        <xsl:value-of select="."/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="class">
                            <xsl:text>badge badge-info text-light</xsl:text>
                        </xsl:attribute>
                        <small>
                            <xsl:call-template name="includeOcticon">
                                <xsl:with-param name="name" select="'tag'"/>
                            </xsl:call-template>
                        </small>
                        <xsl:value-of select="."/>
                    </xsl:otherwise>
                </xsl:choose>
            </a>
        </dd>
    </xsl:template>

    <!--keywords-->
    <xsl:template match="c:keywords" mode="catalog">
        <xsl:call-template name="log_template_info"/>
        <dt class="col-6 col-lg-3 text-truncate">
            <xsl:call-template name="includeOcticon">
                <xsl:with-param name="name" select="'tag'"/>
            </xsl:call-template>
            <xsl:text disable-output-escaping="yes">Keyword</xsl:text>
            <xsl:if test="count(c:keyword) > 1">s</xsl:if>
            <xsl:text disable-output-escaping="yes">: </xsl:text>
        </dt>
        <dd class="col-6 col-lg-3">
            <xsl:for-each select="c:keyword">
                <a>
                    <xsl:attribute name="href">
                        <xsl:text>/search/keyword/</xsl:text>
                        <xsl:value-of select="."/>
                    </xsl:attribute>
                    <xsl:attribute name="title">
                        <xsl:text disable-output-escaping="yes">Search for other recipes with keyword &lt;strong></xsl:text>
                        <xsl:value-of select="."/>
                        <xsl:text disable-output-escaping="yes">&lt;/strong></xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="data-toggle">
                        <xsl:text>tooltip</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="data-placement">
                        <xsl:text>bottom</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="class">
                        <xsl:text>badge badge-info text-light</xsl:text>
                    </xsl:attribute>
                    <small>
                        <xsl:call-template name="includeOcticon">
                            <xsl:with-param name="name" select="'tag'"/>
                        </xsl:call-template>
                    </small>
                    <xsl:value-of select="."/>
                </a>
                <xsl:if test="position() != last()">
                    <xsl:text> </xsl:text>
                </xsl:if>
            </xsl:for-each>
        </dd>
    </xsl:template>

    <!--scm-->
    <xsl:template match="c:scm" mode="catalog">
        <xsl:call-template name="log_template_info"/>
        <dt class="w-100">
            <hr/>
        </dt>
        <dt class="col-6 col-lg-3 text-truncate">
            <xsl:call-template name="includeOcticon">
                <xsl:with-param name="name" select="'repo'"/>
            </xsl:call-template>
            <xsl:text disable-output-escaping="yes">Source control: </xsl:text>
        </dt>
        <dd class="col-6 col-lg-3">
            <xsl:choose>
                <xsl:when test="c:kind">
                    <a>
                        <xsl:attribute name="href">
                            <xsl:text>/search/scm/</xsl:text>
                            <xsl:value-of select="c:kind"/>
                        </xsl:attribute>
                        <xsl:attribute name="title">
                            <xsl:text disable-output-escaping="yes">Search for other &lt;strong></xsl:text>
                            <xsl:value-of select="c:kind"/>
                            <xsl:text disable-output-escaping="yes">&lt;/strong> recipes</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="data-toggle">
                            <xsl:text>tooltip</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="data-placement">
                            <xsl:text>bottom</xsl:text>
                        </xsl:attribute>
                        <xsl:choose>
                            <xsl:when test="c:kind = 'archive' or c:kind = 'svn'">
                                <xsl:attribute name="class">
                                    <xsl:text>badge badge-warning text-light</xsl:text>
                                </xsl:attribute>
                                <small>
                                    <xsl:call-template name="includeOcticon">
                                        <xsl:with-param name="name" select="'alert'"/>
                                    </xsl:call-template>
                                </small>
                                <xsl:value-of select="c:kind"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:attribute name="class">
                                    <xsl:text>badge badge-info text-light</xsl:text>
                                </xsl:attribute>
                                <small>
                                    <xsl:call-template name="includeOcticon">
                                        <xsl:with-param name="name" select="'tag'"/>
                                    </xsl:call-template>
                                </small>
                                <xsl:value-of select="c:kind"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </a>
                </xsl:when>
                <xsl:otherwise>
                    <span class="badge badge-warning text-light">
                        <small>
                            <xsl:call-template name="includeOcticon">
                                <xsl:with-param name="name" select="'alert'"/>
                            </xsl:call-template>
                        </small>
                        <xsl:text>none</xsl:text>
                    </span>
                </xsl:otherwise>
            </xsl:choose>
        </dd>

        <xsl:if test="c:revision">
            <dt class="col-6 col-lg-3 text-truncate">
                <xsl:call-template name="includeOcticon">
                    <xsl:with-param name="name" select="'clock'"/>
                </xsl:call-template>
                <xsl:text disable-output-escaping="yes">Most recent activity: </xsl:text>
            </dt>
            <dd class="col-6 col-lg-3">
                <span class="date">
                    <xsl:value-of select="c:revision/c:date"/>
                </span>
            </dd>
        </xsl:if>
        <xsl:if test="c:repository">
            <dt class="col-6 col-lg-3 text-truncate">
                <xsl:call-template name="includeOcticon">
                    <xsl:with-param name="name" select="'desktop-download'"/>
                </xsl:call-template>
                <xsl:text>Download Sourcecode:</xsl:text>
            </dt>
            <dd class="col-6 col-lg-3">
                <a href="javascript:void(0);" class="text-light badge badge-success" data-toggle="popover">
                    <xsl:attribute name="data-content">
                        <xsl:choose>
                            <xsl:when test="c:kind = 'git'">
                                <xsl:text disable-output-escaping="yes">&lt;div class="clone-popover"></xsl:text>
                                    <!--first step-->
                                    <xsl:text>Clone the content:</xsl:text>
                                    <xsl:text disable-output-escaping="yes">&lt;div class="input-group"></xsl:text>
                                        <xsl:text disable-output-escaping="yes">&lt;input type="text" id="git-clone" class="form-control" readonly="true" style='font-family: "SFMono-Regular", Consolas, "Liberation Mono", Menlo, Courier, monospace;' value="git clone </xsl:text>
                                            <xsl:value-of select="c:repository"/>
                                            <xsl:text disable-output-escaping="yes"> </xsl:text>
                                            <xsl:value-of select="/c:catalog/child::node()/c:filename"/>
                                            <xsl:text disable-output-escaping="yes">" aria-label="Clone this repository at </xsl:text>
                                            <xsl:value-of select="c:repository"/>
                                            <xsl:text disable-output-escaping="yes">"/></xsl:text>
                                        <xsl:text disable-output-escaping="yes">&lt;span class="input-group-btn"></xsl:text>
                                            <xsl:text disable-output-escaping="yes">&lt;button title="Copy to clipboard" aria-label="Copy to clipboard" class="btn btn-secondary" data-copied-hint="Copied!" type="button" onclick="copyToClipboard('input#git-clone')"></xsl:text>
                                                <xsl:text disable-output-escaping="yes">&lt;svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" version="1.1" class="octicon octicon-clippy"></xsl:text>
                                                    <xsl:text disable-output-escaping="yes">&lt;use xlink:href="#clippy">&lt;/use></xsl:text>
                                                <xsl:text disable-output-escaping="yes">&lt;/svg></xsl:text>
                                            <xsl:text disable-output-escaping="yes">&lt;/button></xsl:text>
                                        <xsl:text disable-output-escaping="yes">&lt;/span></xsl:text>
                                    <xsl:text disable-output-escaping="yes">&lt;/div></xsl:text>
                                    <!--second step-->
                                    <xsl:choose>
                                        <xsl:when test="c:revision/c:id">
                                            <xsl:text>Then checkout the specific revision:</xsl:text>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:text>Then change directory:</xsl:text>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                    <xsl:text disable-output-escaping="yes">&lt;div class="input-group"></xsl:text>
                                        <xsl:text disable-output-escaping="yes">&lt;input type="text" id="git-checkout" class="form-control" readonly="true" style='font-family: "SFMono-Regular", Consolas, "Liberation Mono", Menlo, Courier, monospace;' value="cd </xsl:text>
                                            <xsl:value-of select="/c:catalog/child::node()/c:filename"/>
                                            <xsl:if test="c:revision/c:id">
                                                <xsl:text disable-output-escaping="yes">; git checkout </xsl:text>
                                                <xsl:value-of select="substring(c:revision/c:id, 1, 8)"/>
                                            </xsl:if>
                                            <xsl:if test="c:sub-directory">
                                                <xsl:text disable-output-escaping="yes">; cd </xsl:text>
                                                <xsl:value-of select="c:sub-directory"/>
                                            </xsl:if>
                                            <xsl:text disable-output-escaping="yes">" aria-label="Clone this repository at </xsl:text>
                                            <xsl:value-of select="c:repository"/>
                                            <xsl:text disable-output-escaping="yes">"/></xsl:text>
                                        <xsl:text disable-output-escaping="yes">&lt;span class="input-group-btn"></xsl:text>
                                            <xsl:text disable-output-escaping="yes">&lt;button title="Copy to clipboard" aria-label="Copy to clipboard" class="btn btn-secondary" data-copied-hint="Copied!" type="button" onclick="copyToClipboard('input#git-checkout')"></xsl:text>
                                                <xsl:text disable-output-escaping="yes">&lt;svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" version="1.1" class="octicon octicon-clippy"></xsl:text>
                                                    <xsl:text disable-output-escaping="yes">&lt;use xlink:href="#clippy">&lt;/use></xsl:text>
                                                <xsl:text disable-output-escaping="yes">&lt;/svg></xsl:text>
                                            <xsl:text disable-output-escaping="yes">&lt;/button></xsl:text>
                                        <xsl:text disable-output-escaping="yes">&lt;/span></xsl:text>
                                    <xsl:text disable-output-escaping="yes">&lt;/div></xsl:text>
                                <xsl:text disable-output-escaping="yes">&lt;/div></xsl:text>
                            </xsl:when>
                            <xsl:when test="c:kind = 'hg'">
                                <xsl:text disable-output-escaping="yes">&lt;div class="clone-popover"></xsl:text>
                                    <!--first step-->
                                    <xsl:text>Clone the content:</xsl:text>
                                    <xsl:text disable-output-escaping="yes">&lt;div class="input-group"></xsl:text>
                                        <xsl:text disable-output-escaping="yes">&lt;input type="text" id="hg-clone" class="form-control" readonly="true" style='font-family: "SFMono-Regular", Consolas, "Liberation Mono", Menlo, Courier, monospace;' value="hg clone </xsl:text>
                                            <xsl:value-of select="c:repository"/>
                                            <xsl:text disable-output-escaping="yes"> </xsl:text>
                                            <xsl:value-of select="/c:catalog/child::node()/c:filename"/>
                                            <xsl:text disable-output-escaping="yes">" aria-label="Clone this repository at </xsl:text>
                                            <xsl:value-of select="c:repository"/>
                                            <xsl:text disable-output-escaping="yes">"/></xsl:text>
                                        <xsl:text disable-output-escaping="yes">&lt;span class="input-group-btn"></xsl:text>
                                            <xsl:text disable-output-escaping="yes">&lt;button title="Copy to clipboard" aria-label="Copy to clipboard" class="btn btn-secondary" data-copied-hint="Copied!" type="button" onclick="copyToClipboard('input#hg-clone')"></xsl:text>
                                                <xsl:text disable-output-escaping="yes">&lt;svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" version="1.1" class="octicon octicon-clippy"></xsl:text>
                                                    <xsl:text disable-output-escaping="yes">&lt;use xlink:href="#clippy">&lt;/use></xsl:text>
                                                <xsl:text disable-output-escaping="yes">&lt;/svg></xsl:text>
                                            <xsl:text disable-output-escaping="yes">&lt;/button></xsl:text>
                                        <xsl:text disable-output-escaping="yes">&lt;/span></xsl:text>
                                    <xsl:text disable-output-escaping="yes">&lt;/div></xsl:text>
                                    <!--second step-->
                                    <xsl:choose>
                                        <xsl:when test="c:revision/c:id">
                                            <xsl:text>Then revert to the specific revision:</xsl:text>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:text>Then change directory:</xsl:text>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                    <xsl:text disable-output-escaping="yes">&lt;div class="input-group"></xsl:text>
                                        <xsl:text disable-output-escaping="yes">&lt;input type="text" id="hg-revert" class="form-control" readonly="true" style='font-family: "SFMono-Regular", Consolas, "Liberation Mono", Menlo, Courier, monospace;' value="cd </xsl:text>
                                            <xsl:value-of select="/c:catalog/child::node()/c:filename"/>
                                            <xsl:if test="c:revision/c:id">
                                                <xsl:text disable-output-escaping="yes">; hg revert -r </xsl:text>
                                                <xsl:value-of select="c:revision/c:id"/>
                                            </xsl:if>
                                            <xsl:if test="c:sub-directory">
                                                <xsl:text disable-output-escaping="yes">; cd </xsl:text>
                                                <xsl:value-of select="c:sub-directory"/>
                                            </xsl:if>
                                            <xsl:text disable-output-escaping="yes">" aria-label="Clone this repository at </xsl:text>
                                            <xsl:value-of select="c:repository"/>
                                            <xsl:text disable-output-escaping="yes">"/></xsl:text>
                                        <xsl:text disable-output-escaping="yes">&lt;span class="input-group-btn"></xsl:text>
                                            <xsl:text disable-output-escaping="yes">&lt;button title="Copy to clipboard" aria-label="Copy to clipboard" class="btn btn-secondary" data-copied-hint="Copied!" type="button" onclick="copyToClipboard('input#hg-revert')"></xsl:text>
                                                <xsl:text disable-output-escaping="yes">&lt;svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" version="1.1" class="octicon octicon-clippy"></xsl:text>
                                                    <xsl:text disable-output-escaping="yes">&lt;use xlink:href="#clippy">&lt;/use></xsl:text>
                                                <xsl:text disable-output-escaping="yes">&lt;/svg></xsl:text>
                                            <xsl:text disable-output-escaping="yes">&lt;/button></xsl:text>
                                        <xsl:text disable-output-escaping="yes">&lt;/span></xsl:text>
                                    <xsl:text disable-output-escaping="yes">&lt;/div></xsl:text>
                                <xsl:text disable-output-escaping="yes">&lt;/div></xsl:text>
                            </xsl:when>
                            <xsl:when test="c:kind = 'svn'">
                                <xsl:text disable-output-escaping="yes">&lt;div class="clone-popover"></xsl:text>
                                    <!--first step-->
                                    <xsl:text>Clone the content:</xsl:text>
                                    <xsl:text disable-output-escaping="yes">&lt;div class="input-group"></xsl:text>
                                        <xsl:text disable-output-escaping="yes">&lt;input type="text" id="svn-checkout" class="form-control" readonly="true" style='font-family: "SFMono-Regular", Consolas, "Liberation Mono", Menlo, Courier, monospace;' value="svn checkout </xsl:text>
                                            <xsl:value-of select="c:repository"/>
                                            <xsl:text disable-output-escaping="yes"> </xsl:text>
                                            <xsl:value-of select="/c:catalog/child::node()/c:filename"/>
                                            <xsl:text disable-output-escaping="yes">" aria-label="Clone this repository at </xsl:text>
                                            <xsl:value-of select="c:repository"/>
                                            <xsl:text disable-output-escaping="yes">"/></xsl:text>
                                        <xsl:text disable-output-escaping="yes">&lt;span class="input-group-btn"></xsl:text>
                                            <xsl:text disable-output-escaping="yes">&lt;button title="Copy to clipboard" aria-label="Copy to clipboard" class="btn btn-secondary" data-copied-hint="Copied!" type="button" onclick="copyToClipboard('input#svn-checkout')"></xsl:text>
                                                <xsl:text disable-output-escaping="yes">&lt;svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" version="1.1" class="octicon octicon-clippy"></xsl:text>
                                                    <xsl:text disable-output-escaping="yes">&lt;use xlink:href="#clippy">&lt;/use></xsl:text>
                                                <xsl:text disable-output-escaping="yes">&lt;/svg></xsl:text>
                                            <xsl:text disable-output-escaping="yes">&lt;/button></xsl:text>
                                        <xsl:text disable-output-escaping="yes">&lt;/span></xsl:text>
                                    <xsl:text disable-output-escaping="yes">&lt;/div></xsl:text>
                                    <!--second step-->
                                    <xsl:choose>
                                        <xsl:when test="c:revision/c:id">
                                            <xsl:text>Then revert to the specific revision:</xsl:text>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:text>Then change directory:</xsl:text>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                    <xsl:text disable-output-escaping="yes">&lt;div class="input-group"></xsl:text>
                                        <xsl:text disable-output-escaping="yes">&lt;input type="text" id="hg-revert" class="form-control" readonly="true" style='font-family: "SFMono-Regular", Consolas, "Liberation Mono", Menlo, Courier, monospace;' value="cd </xsl:text>
                                            <xsl:value-of select="/c:catalog/child::node()/c:filename"/>
                                            <xsl:if test="c:revision/c:id">
                                                <xsl:text disable-output-escaping="yes">; svn update -r </xsl:text>
                                                <xsl:value-of select="c:revision/c:id"/>
                                            </xsl:if>
                                            <xsl:if test="c:sub-directory">
                                                <xsl:text disable-output-escaping="yes">; cd </xsl:text>
                                                <xsl:value-of select="c:sub-directory"/>
                                            </xsl:if>
                                            <xsl:text disable-output-escaping="yes">" aria-label="Clone this repository at </xsl:text>
                                            <xsl:value-of select="c:repository"/>
                                            <xsl:text disable-output-escaping="yes">"/></xsl:text>
                                        <xsl:text disable-output-escaping="yes">&lt;span class="input-group-btn"></xsl:text>
                                            <xsl:text disable-output-escaping="yes">&lt;button title="Copy to clipboard" aria-label="Copy to clipboard" class="btn btn-secondary" data-copied-hint="Copied!" type="button" onclick="copyToClipboard('input#hg-revert')"></xsl:text>
                                                <xsl:text disable-output-escaping="yes">&lt;svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" version="1.1" class="octicon octicon-clippy"></xsl:text>
                                                    <xsl:text disable-output-escaping="yes">&lt;use xlink:href="#clippy">&lt;/use></xsl:text>
                                                <xsl:text disable-output-escaping="yes">&lt;/svg></xsl:text>
                                            <xsl:text disable-output-escaping="yes">&lt;/button></xsl:text>
                                        <xsl:text disable-output-escaping="yes">&lt;/span></xsl:text>
                                    <xsl:text disable-output-escaping="yes">&lt;/div></xsl:text>
                                <xsl:text disable-output-escaping="yes">&lt;/div></xsl:text>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text disable-output-escaping="yes">&lt;div class="clone-popover"></xsl:text>
                                    <!--first step-->
                                    <xsl:text disable-output-escaping="yes">Download the archive: &lt;br/> &lt;a href="</xsl:text>
                                    <xsl:value-of select="c:repository"/>
                                    <xsl:text disable-output-escaping="yes">" title="Download archive"></xsl:text>
                                    <xsl:text disable-output-escaping="yes">&lt;svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" version="1.1" class="octicon octicon-desktop-download" style="margin-right: 0.1rem; height: 0.7rem;"></xsl:text>
                                        <xsl:text disable-output-escaping="yes">&lt;use xlink:href="#desktop-download">&lt;/use></xsl:text>
                                    <xsl:text disable-output-escaping="yes">&lt;/svg></xsl:text>
                                    <xsl:value-of select="c:repository"/>
                                    <xsl:text disable-output-escaping="yes">&lt;/a></xsl:text>
                                    <xsl:text disable-output-escaping="yes">&lt;/a></xsl:text>
                                <xsl:text disable-output-escaping="yes">&lt;/div></xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:attribute>
                    <small>
                        <xsl:call-template name="includeOcticon">
                            <xsl:with-param name="name" select="'arrow-down'"/>
                        </xsl:call-template>
                    </small>
                    <xsl:text>get the code</xsl:text>
                </a>
            </dd>
        </xsl:if>
    </xsl:template>

    <!--natures-->
    <xsl:template match="c:natures" mode="catalog">
        <xsl:call-template name="log_template_info"/>
        <dt class="col-6 col-lg-3">
            <xsl:call-template name="includeOcticon">
                <xsl:with-param name="name" select="'gear'"/>
            </xsl:call-template>
            <xsl:text disable-output-escaping="yes">Nature</xsl:text>
            <xsl:if test="count(c:nature) > 1">s</xsl:if>
            <xsl:text disable-output-escaping="yes">: </xsl:text>
        </dt>
        <dd class="col-6 col-lg-3">
            <xsl:for-each select="c:nature">
                <a>
                    <xsl:attribute name="href">
                        <xsl:text>/search/nature/</xsl:text>
                        <xsl:value-of select="."/>
                    </xsl:attribute>
                    <xsl:attribute name="title">
                        <xsl:text disable-output-escaping="yes">Search for other &lt;strong></xsl:text>
                        <xsl:value-of select="."/>
                        <xsl:text disable-output-escaping="yes">&lt;/strong> recipes</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="data-toggle">
                        <xsl:text>tooltip</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="data-placement">
                        <xsl:text>bottom</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="class">
                        <xsl:text>badge badge-info text-light</xsl:text>
                    </xsl:attribute>
                    <small>
                        <xsl:call-template name="includeOcticon">
                            <xsl:with-param name="name" select="'tag'"/>
                        </xsl:call-template>
                    </small>
                    <xsl:value-of select="."/>
                </a>
                <xsl:if test="position() != last()">
                    <xsl:text> </xsl:text>
                </xsl:if>
            </xsl:for-each>
        </dd>
    </xsl:template>

    <!--programming languages-->
    <xsl:template match="c:programmingLanguages" mode="catalog">
        <xsl:call-template name="log_template_info"/>
        <dt class="col-6 col-lg-3 text-truncate">
            <xsl:call-template name="includeOcticon">
                <xsl:with-param name="name" select="'code'"/>
            </xsl:call-template>
            <xsl:text disable-output-escaping="yes">Programming Language</xsl:text>
            <xsl:if test="count(c:language) > 1">s</xsl:if>
            <xsl:text disable-output-escaping="yes">: </xsl:text>
        </dt>
        <dd class="col-6 col-lg-3">
            <xsl:for-each select="c:language">
                <a>
                    <xsl:attribute name="href">
                        <xsl:text>/search/lang/</xsl:text>
                        <xsl:value-of select="."/>
                    </xsl:attribute>
                    <xsl:attribute name="title">
                        <xsl:text disable-output-escaping="yes">Search for other &lt;strong></xsl:text>
                        <xsl:value-of select="."/>
                        <xsl:text disable-output-escaping="yes">&lt;/strong> recipes</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="data-toggle">
                        <xsl:text>tooltip</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="data-placement">
                        <xsl:text>bottom</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="class">
                        <xsl:text>badge badge-info text-light</xsl:text>
                    </xsl:attribute>
                    <small>
                        <xsl:call-template name="includeOcticon">
                            <xsl:with-param name="name" select="'tag'"/>
                        </xsl:call-template>
                    </small>
                    <xsl:value-of select="."/>
                </a>
                <xsl:if test="position() != last()">
                    <xsl:text> </xsl:text>
                </xsl:if>
            </xsl:for-each>
        </dd>
    </xsl:template>

    <!--linked fragments-->
    <xsl:template match="c:relation" mode="catalog">
        <xsl:call-template name="log_template_info"/>
        <li>
            <xsl:element name="a">
                <xsl:attribute name="href">
                    <xsl:text>../</xsl:text>
                    <xsl:value-of select="@type"/>
                    <xsl:text disable-output-escaping="yes">/</xsl:text>
                    <xsl:value-of select="normalize-space(.)"/>
                    <xsl:text>.xml</xsl:text>
                </xsl:attribute>
                <xsl:if test="@type = 'experiment'">
                    <xsl:attribute name="class">
                        <xsl:text disable-output-escaping="yes">ref</xsl:text>
                    </xsl:attribute>
                </xsl:if>
                <xsl:choose>
                    <xsl:when test="@name">
                        <xsl:value-of select="@name"/>
                        <xsl:if test="@version">
                            <xsl:text disable-output-escaping="yes"> - </xsl:text>
                            <xsl:value-of select="@version"/>
                        </xsl:if>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="."/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:element>
            <xsl:if test="@type = 'experiment' or @type = 'dataset'">
                <span class="capitalize">
                    <xsl:text disable-output-escaping="yes"> (</xsl:text>
                    <xsl:value-of select="@type"/>
                    <xsl:text disable-output-escaping="yes">)</xsl:text>
                </span>
            </xsl:if>
        </li>
    </xsl:template>

    <!--linked person-->
    <xsl:template match="c:relation" mode="person">
        <xsl:call-template name="log_template_info"/>
        <xsl:variable name="actualNode">
			<xsl:value-of select="."/>
		</xsl:variable>
        <xsl:if test="not(preceding-sibling::*[. = $actualNode])">
            <li>
                <a class="badge badge-secondary text-light" href="javascript:void(0);"
                   data-toggle="tooltip" data-placement="bottom" style='font-family: "SFMono-Regular", Consolas, "Liberation Mono", Menlo, Courier, monospace;'>
                    <xsl:attribute name="title">
                        <xsl:value-of select="@role"/>
                    </xsl:attribute>
                    <xsl:value-of select="substring(@role, 1, 1)"/>
                </a>
                <xsl:for-each select="following-sibling::*[. = $actualNode]">
                    <xsl:text disable-output-escaping="yes"> </xsl:text>
                    <a class="badge badge-secondary text-light" href="javascript:void(0);"
                       data-toggle="tooltip" data-placement="bottom" style='font-family: "SFMono-Regular", Consolas, "Liberation Mono", Menlo, Courier, monospace;'>
                        <xsl:attribute name="title">
                            <xsl:value-of select="@role"/>
                        </xsl:attribute>
                        <xsl:value-of select="substring(@role, 1, 1)"/>
                    </a>
                </xsl:for-each>
                <xsl:text disable-output-escaping="yes"> </xsl:text>
                <xsl:element name="a">
                    <xsl:attribute name="href">
                        <xsl:text>../</xsl:text>
                        <xsl:value-of select="@type"/>
                        <xsl:text disable-output-escaping="yes">/</xsl:text>
                        <xsl:value-of select="normalize-space(.)"/>
                        <xsl:text>.xml</xsl:text>
                    </xsl:attribute>
                    <xsl:choose>
                        <xsl:when test="@name">
                            <xsl:value-of select="@name"/>
                            <xsl:if test="@version">
                                <xsl:text disable-output-escaping="yes"> - </xsl:text>
                                <xsl:value-of select="@version"/>
                            </xsl:if>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="."/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:element>
            </li>
        </xsl:if>
    </xsl:template>

    <!--extends other recipes-->
    <xsl:template match="c:extends" mode="catalog">
        <xsl:call-template name="log_template_info"/>
        <div>
            <h5>
                <xsl:text disable-output-escaping="yes">Inherits from:</xsl:text>
            </h5>
            <xsl:element name="a">
                <xsl:attribute name="href">
                    <xsl:value-of select="."/>
                    <xsl:text disable-output-escaping="yes">.xml</xsl:text>
                </xsl:attribute>
                <xsl:attribute name="class">
                    <xsl:text disable-output-escaping="yes">extends</xsl:text>
                </xsl:attribute>
                <xsl:value-of select="@name"/>
                <xsl:text disable-output-escaping="yes">-</xsl:text>
                <xsl:value-of select="@version"/>
            </xsl:element>
        </div>
    </xsl:template>

    <!--system os dependencies-->
    <xsl:template match="c:distribution | c:project | c:experiment | c:dataset" mode="dependency">
        <xsl:call-template name="log_template_info"/>
        <xsl:if test="c:dependencies/c:directDependency">
                <div class="card">
                    <div id="directDependencies">
                        <div class="card-header">
                            <h5>
                                <xsl:call-template name="includeOcticon">
                                    <xsl:with-param name="name" select="'package'"/>
                                </xsl:call-template>
                                <xsl:text disable-output-escaping="yes">Direct dependencies:</xsl:text>
                                <small>
                                    <span class="badge badge-pill badge-info text-light" style="float:right;">
                                        <xsl:value-of select="count(c:dependencies/c:directDependency)"/>
                                    </span>
                                </small>
                            </h5>
                        </div>
                        <div class="card-body hideContent">
                            <ul>
                                <xsl:apply-templates select="c:dependencies/c:directDependency" mode="dependency">
                                    <xsl:sort/>
                                </xsl:apply-templates>
                                <xsl:apply-templates
                                        select="c:relation[@type = 'experiment'] | c:relation[@type = 'dataset']"
                                        mode="catalog"/>
                            </ul>
                        </div>
                    </div>
                </div>
        </xsl:if>
        <xsl:if test="local-name() = 'distribution'">
            <div class="card">
                <div class="card-header">
                    <h5>
                        <xsl:call-template name="includeOcticon">
                            <xsl:with-param name="name" select="'repo-clone'"/>
                        </xsl:call-template>
                        <xsl:text disable-output-escaping="yes">Replication</xsl:text>
                    </h5>
                </div>
                <div class="card-body hideContent">
                    <xsl:if test="c:dependencies/c:system/c:dependency">
                        <h5>
                            <xsl:call-template name="includeOcticon">
                                <xsl:with-param name="name" select="'desktop-download'"/>
                            </xsl:call-template>
                            <xsl:text disable-output-escaping="yes">Install Required OS Packages:</xsl:text>
                        </h5>
                        <div id="systemDependencies" data-children=".system">
                            <xsl:apply-templates select="c:dependencies/c:system" mode="dependency"/>
                        </div>
                        <xsl:apply-templates select="." mode="gendist"/>
                    </xsl:if>
                </div>
            </div>
        </xsl:if>
    </xsl:template>

    <!--os specific packages-->
    <xsl:template match="c:system" mode="dependency">
        <xsl:call-template name="log_template_info"/>
        <div class="system">
            <xsl:element name="a">
                <xsl:attribute name="data-toggle">collapse</xsl:attribute>
                <xsl:attribute name="data-parent">#systemDependencies</xsl:attribute>
                <xsl:attribute name="aria-expanded">
                    <xsl:choose>
                        <xsl:when test="@version = '16.04'">
                            <xsl:text>true</xsl:text>
                        </xsl:when>
                        <xsl:when test="@version = 'xenial'">true</xsl:when>
                        <xsl:otherwise>false</xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
                <xsl:attribute name="href">
                    <xsl:text disable-output-escaping="yes">#</xsl:text>
                    <xsl:value-of select="@name"/>
                    <xsl:value-of select="position()"/>
                </xsl:attribute>
                <xsl:attribute name="aria-expand">true</xsl:attribute>
                <xsl:attribute name="aria-controls">
                    <xsl:text disable-output-escaping="yes">#</xsl:text>
                    <xsl:value-of select="@name"/>
                    <xsl:value-of select="position()"/>
                </xsl:attribute>
                <xsl:call-template name="capitalizeFirstLetter">
                    <xsl:with-param name="in" select="@name"/>
                </xsl:call-template>
                <xsl:text disable-output-escaping="yes"> (</xsl:text>
                <xsl:value-of select="@version"/>
                <xsl:text disable-output-escaping="yes">)</xsl:text>
            </xsl:element>
            <xsl:element name="div">
                <xsl:attribute name="id">
                    <xsl:value-of select="@name"/>
                    <xsl:value-of select="position()"/>
                </xsl:attribute>
                <xsl:attribute name="class">
                    <xsl:text>collapse</xsl:text>
                    <xsl:if test="(@version = '16.04') or (@version = 'xenial') or (count(../c:system) = 1)">
                        <xsl:text disable-output-escaping="yes"> show</xsl:text>
                    </xsl:if>
                </xsl:attribute>
                <xsl:attribute name="role">tabpanel</xsl:attribute>
                <pre>
                    <code class="shell">
                        <xsl:choose>
                            <xsl:when test="@name = 'ubuntu'">
                                <xsl:if test="c:repository">
                                    <xsl:choose>
                                        <xsl:when test="(@version = '14.04') or (@version = 'trusty')">
                                            <xsl:text disable-output-escaping="yes">$ sudo apt-get update&#xa;</xsl:text>
                                            <xsl:text disable-output-escaping="yes">$ sudo apt-get install --no-install-recommends \&#xa;    software-properties-common&#xa;</xsl:text>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:text disable-output-escaping="yes">$ sudo apt update&#xa;</xsl:text>
                                            <xsl:text disable-output-escaping="yes">$ sudo apt install --no-install-recommends \&#xa;    software-properties-common&#xa;</xsl:text>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:if>
                                <xsl:for-each select="c:repository">
                                    <xsl:text disable-output-escaping="yes">$ sudo add-apt-repository "</xsl:text>
                                    <xsl:value-of select="normalize-space(.)"/>
                                    <xsl:text disable-output-escaping="yes">"&#xa;</xsl:text>
                                    <xsl:if test="@gpgkey">
                                        <xsl:text disable-output-escaping="yes">$ sudo apt-key adv --recv-keys --keyserver keyserver.ubuntu.com </xsl:text>
                                        <xsl:value-of select="@gpgkey"/>
                                        <xsl:text disable-output-escaping="yes">&#xa;</xsl:text>
                                    </xsl:if>
                                </xsl:for-each>
                                <xsl:choose>
                                    <xsl:when test="(@version = '14.04') or (@version = 'trusty')">
                                        <xsl:text disable-output-escaping="yes">$ sudo apt-get update&#xa;</xsl:text>
                                        <xsl:text disable-output-escaping="yes">$ sudo apt-get install --no-install-recommends \&#xa;    </xsl:text>
                                        <!--<xsl:text disable-output-escaping="yes">$ sudo apt-get install &#45;&#45;no-install-recommends \&#xa;</xsl:text>-->
                                        <xsl:for-each select="c:dependency">
                                            <xsl:sort/>
                                            <!--<xsl:text disable-output-escaping="yes">    </xsl:text>-->
                                            <xsl:value-of select="."/>
                                            <xsl:if test="position() != last()">
                                                <xsl:text disable-output-escaping="yes"> \&#xa;    </xsl:text>
                                            </xsl:if>
                                            <!--<xsl:if test="position() != last()">-->
                                                <!--<xsl:text disable-output-escaping="yes"> \&#xa;</xsl:text>-->
                                            <!--</xsl:if>-->
                                        </xsl:for-each>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:text disable-output-escaping="yes">$ sudo apt update&#xa;</xsl:text>
                                        <xsl:text disable-output-escaping="yes">$ sudo apt install --no-install-recommends \&#xa;    </xsl:text>
                                        <!--<xsl:text disable-output-escaping="yes">$ sudo apt-get install &#45;&#45;no-install-recommends \&#xa;</xsl:text>-->
                                        <xsl:for-each select="c:dependency">
                                            <xsl:sort/>
                                            <!--<xsl:text disable-output-escaping="yes">    </xsl:text>-->
                                            <xsl:value-of select="."/>
                                            <xsl:if test="position() != last()">
                                                <xsl:text disable-output-escaping="yes"> \&#xa;    </xsl:text>
                                            </xsl:if>
                                            <!--<xsl:if test="position() != last()">-->
                                            <!--<xsl:text disable-output-escaping="yes"> \&#xa;</xsl:text>-->
                                            <!--</xsl:if>-->
                                        </xsl:for-each>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:when>
                            <xsl:otherwise>
                                <strong>
                                    <xsl:text>Not implemented yet.</xsl:text>
                                </strong>
                            </xsl:otherwise>
                        </xsl:choose>
                    </code>
                </pre>
            </xsl:element>
        </div>
    </xsl:template>

    <!--directDependencies-->
    <xsl:template match="c:directDependency" mode="dependency">
        <xsl:call-template name="log_template_info"/>
        <li>
            <xsl:element name="a">
                <xsl:attribute name="href">
                    <xsl:text disable-output-escaping="yes">../project/</xsl:text>
                    <xsl:value-of select="normalize-space(.)"/>
                    <xsl:text>.xml</xsl:text>
                </xsl:attribute>
                <xsl:attribute name="class">
                    <xsl:text disable-output-escaping="yes">ref</xsl:text>
                </xsl:attribute>
                <xsl:choose>
                    <xsl:when test="@name">
                        <xsl:value-of select="@name"/>
                        <xsl:if test="@version">
                            <xsl:text disable-output-escaping="yes"> (</xsl:text>
                            <xsl:value-of select="@version"/>
                            <xsl:text>)</xsl:text>
                        </xsl:if>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="."/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:element>
        </li>
    </xsl:template>

    <!--generate distribution-->
    <xsl:template match="c:distribution" mode="gendist">
        <xsl:call-template name="log_template_info"/>
        <h5>
            <xsl:call-template name="includeOcticon">
                <xsl:with-param name="name" select="'terminal'"/>
            </xsl:call-template>
            <xsl:text disable-output-escaping="yes">Generate Distribution</xsl:text>
        </h5>
        <p>
            <xsl:text>Now, please use our distribution tool chain as explained in the tutorials section Bootstrapping
                and Installing. Read and execute these instructions carefully. You will need to bootstrap the
            </xsl:text>
            <xsl:element name="a">
                <xsl:attribute name="href">
                    <xsl:value-of select="$redmineRecipesRepository"/>
                    <xsl:text disable-output-escaping="yes">/entry/</xsl:text>
                    <xsl:value-of select="name(.)"/>
                    <xsl:if test="not(name(.) = 'hardware')">
                        <xsl:text disable-output-escaping="yes">s</xsl:text>
                    </xsl:if>
                    <xsl:text disable-output-escaping="yes">/</xsl:text>
                    <xsl:value-of select="c:filename"/>
                    <xsl:text>.distribution</xsl:text>
                </xsl:attribute>
                <code>
                    <xsl:value-of select="c:filename"/>
                    <xsl:text>.distribution</xsl:text>
                </code>
            </xsl:element>
            <xsl:text>. If you changed your prefix from </xsl:text>
            <code>$HOME/citk</code>
            <xsl:text> to something else, please keep that in mind.</xsl:text>
        </p>
        <pre>
            <code class="shell">
                <xsl:text disable-output-escaping="yes">$ $HOME/citk/jenkins/job-configurator \&#xa;    --on-error=continue \&#xa;    -d $HOME/citk/dist/distributions/</xsl:text>
                <xsl:value-of select="c:filename"/>
                <xsl:text disable-output-escaping="yes">.distribution \&#xa;    -m toolkit \&#xa;    -u YOUR_USERNAME \&#xa;    -p YOUR_PASSWORD \&#xa;    -D toolkit.volume=$HOME/citk/systems</xsl:text>
            </code>
        </pre>
    </xsl:template>

    <!--additional experiment info-->
    <!--TODO: replace iCub stuff by actual val: $prefix/etc/fsmt-experiments/icub-nightly/icub-nightly-balltracking.scxml-->
    <xsl:template name="experimentMetrics">
        <h3>
            <xsl:text disable-output-escaping="yes">Experiment Metrics</xsl:text>
        </h3>
        <div>
            <xsl:text disable-output-escaping="yes">
                In general, successful execution is automatically reported by
            </xsl:text>
            <strong>
                <xsl:text>FSMT</xsl:text>
            </strong>
            <xsl:text disable-output-escaping="yes"> indicating the following on the command line:</xsl:text>
            <pre>
                <code class="shell">> FSMT RUN WAS SUCCESSFUL</code>
            </pre>
            <xsl:text disable-output-escaping="yes">In case an experiment fails, i.e., evaluation criteria are not met,
                FSMT reports:</xsl:text>
            <pre>
                <code class="shell">> FSMT RUN FAILED</code>
            </pre>
            <xsl:text disable-output-escaping="yes">This result is based on evaluation scripts and methods that are
                usually distributed alongside an associated system distribution. Thus, the applied metrics are </xsl:text>
            <strong>
                <xsl:text>highly system</xsl:text>
            </strong>
            <xsl:text disable-output-escaping="yes"> specific and are typically explained in detail in a corresponding
                publication. You can always inspect the FSMT experiment definition (*.ini file) for further details
                and/or compare the reference data which is attached to this experiment.</xsl:text>
        </div>
        <h3>
            <xsl:text disable-output-escaping="yes">Replication Information</xsl:text>
        </h3>
        <div>
            <p>Please replicate the associated system iCub Ball Tracking-s1 as described in the Replicate System
                Section, see Linked System Version. After installing the system, run the following CI Job on your local
                Jenkins instance in order to execute the experiment:
                <code id="">
                    <xsl:value-of select="/c:catalog/child::node()/c:filename"/>
                    <xsl:text disable-output-escaping="yes">-*</xsl:text>
                </code>
            </p>
            <p>Please also compare your results to the Linked CI Job.</p>
            <p>
                <strong>
                    <xsl:text disable-output-escaping="yes">Alternatively </xsl:text>
                </strong>
                <xsl:text disable-output-escaping="yes">you may execute the following script in order to run the
                    experiment manually. Remember, if you changed your prefix from </xsl:text>
                <code>$HOME/citk</code>
                <xsl:text> to something else, change the code accordingly.</xsl:text>
            </p>
            <pre>
                <code class="bash">
                    <xsl:text disable-output-escaping="yes">#!/bin/bash&#xa;</xsl:text>
                    <xsl:text disable-output-escaping="yes">export DISPLAY=:0.0&#xa;</xsl:text>
                    <xsl:text disable-output-escaping="yes">export prefix="$HOME/citk"  # you may have to change this!&#xa;</xsl:text>
                    <xsl:text disable-output-escaping="yes">export PYTHONPATH=$prefix/lib/python2.7/site-packages/&#xa;</xsl:text>
                    <xsl:text disable-output-escaping="yes">export PATH=$prefix/bin/:$PATH&#xa;</xsl:text>
                    <xsl:text disable-output-escaping="yes">fsmt $prefix/etc/fsmt-experiments/icub-nightly/icub-nightly-balltracking.scxml  # TODO: must be replaced by xsl val&#xa;</xsl:text>
                </code>
            </pre>
            <h5>
                <xsl:text disable-output-escaping="yes">Make the Experiment Fail:</xsl:text>
            </h5>
            <p>
                <xsl:text disable-output-escaping="yes">In order to prove the simplicity of the FSMT approach you may again start the experiment by executing the last command. </xsl:text>
                <strong>
                    <xsl:text>This </xsl:text>
                </strong>
                <xsl:text disable-output-escaping="yes">time please close one of the camera images, the experiment will be
                instantaneously stopped and marked as failed.</xsl:text>
            </p>
        </div>
    </xsl:template>
</xsl:stylesheet>
