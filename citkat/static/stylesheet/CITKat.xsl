<?xml version="1.0"?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:c="https://toolkit.cit-ec.uni-bielefeld.de/CITKat" exclude-result-prefixes="c">
    <xsl:output method="html" cdata-section-elements="script" indent="no" media-type="text/html" version="5.0"
                encoding="UTF-8" doctype-system="about:legacy-compat"/>
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

    <!--variables section-->

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
        <xsl:copy-of select="document('/static/templates/head.xml')/child::node()/*"/>
        <title>
            <xsl:call-template name="capitalizeFirstLetter">
                <xsl:with-param name="in" select="name(*[1])"/>
            </xsl:call-template>
            <xsl:choose>
                <xsl:when test="not(c:publication) and not(c:person)">
                    <xsl:text disable-output-escaping="yes">: </xsl:text>
                    <xsl:value-of select="child::node()/@name"/>
                    <xsl:text disable-output-escaping="yes"> (</xsl:text>
                    <xsl:value-of select="child::node()/@version"/>
                    <xsl:text disable-output-escaping="yes">)</xsl:text>
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
        <xsl:copy-of select="document('/static/templates/footer.xml')/child::node()/*"/>
        <script src="/static/js/linkParams.js"/>
        <script src="/static/js/oldAndroid.js"/>
    </xsl:template>

    <!--catalog content-->
    <xsl:template match="c:catalog">
        <xsl:call-template name="log_template_info"/>
        <div class="container" style="padding-left: 0; padding-right: 0;"><!--first container doesn't need padding!-->
            <!--import navbar-->
            <xsl:copy-of select="document('/static/templates/nav.xml')/child::node()/*"/>
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
                <h1>
                    <xsl:call-template name="capitalizeFirstLetter">
                        <xsl:with-param name="in" select="name(*[1])"/>
                    </xsl:call-template>
                    <xsl:text disable-output-escaping="yes"> Details </xsl:text>
                </h1>
                <!--recipes name and version as headline-->
                <h2>
                    <xsl:choose>
                        <xsl:when test="child::node()/@name and child::node()/@version">
                            <xsl:value-of select="child::node()/@name"/>
                            <xsl:text disable-output-escaping="yes"> (</xsl:text>
                            <xsl:value-of select="child::node()/@version"/>
                            <xsl:text disable-output-escaping="yes">)</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="child::node()/c:filename"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </h2>
                <!--general information for all but persons and publications-->
                <xsl:if test="c:distribution | c:project | c:experiment | c:hardware | c:dataset">
                    <h3>
                        <xsl:text disable-output-escaping="yes">General Information</xsl:text>
                    </h3>
                    <div class="description">
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
                </xsl:if>
                <!--image carousel-->
                <xsl:if test="child::node()/c:resource[@type = 'img']">
                    <xsl:call-template name="imgCarousel"/>
                </xsl:if>
                <!--embed video-->
                <xsl:apply-templates select="child::node()/c:resource[@type = 'video']" mode="catalog"/>
                <!--access type-->
                <xsl:apply-templates select="c:distribution/@access" mode="catalog"/>
                <!--other resources-->
                <xsl:apply-templates select="child::node()/c:resource[not(@type = 'img') and not(@type = 'video')]"
                                     mode="catalog"/>
                <!--extends-->
                <xsl:apply-templates select="child::node()/c:extends" mode="catalog"/>
                <!--Persons-->
                <xsl:if test="child::node()/c:linkedFragment[@type = 'person']">
                    <h5>
                        <xsl:text disable-output-escaping="yes">Involved </xsl:text>
                        <xsl:call-template name="capitalizeFirstLetter">
                            <xsl:with-param name="in" select="child::node()/c:linkedFragment[@type = 'person']/@type"/>
                        </xsl:call-template>
                        <xsl:if test="count(child::node()/c:linkedFragment[@type = 'person']) > 1">
                            <xsl:text>s</xsl:text>
                        </xsl:if>
                        <xsl:text disable-output-escaping="yes">:</xsl:text>
                    </h5>
                    <ul class="persons">
                        <xsl:apply-templates select="child::node()/c:linkedFragment[@type = 'person']" mode="catalog"/>
                    </ul>
                </xsl:if>
                <!--Publications-->
                <xsl:if test="child::node()/c:linkedFragment[@type = 'publication']">
                    <h5>
                        <xsl:text disable-output-escaping="yes">Linked </xsl:text>
                        <xsl:call-template name="capitalizeFirstLetter">
                            <xsl:with-param name="in" select="child::node()/c:linkedFragment[@type = 'publication']/@type"/>
                        </xsl:call-template>
                        <xsl:if test="count(child::node()/c:linkedFragment[@type = 'publication']) > 1">
                            <xsl:text>s</xsl:text>
                        </xsl:if>
                        <xsl:text disable-output-escaping="yes">:</xsl:text>
                    </h5>
                    <ul class="publications">
                        <xsl:apply-templates select="child::node()/c:linkedFragment[@type = 'publication']" mode="catalog"/>
                    </ul>
                </xsl:if>
                <!--Hardware-->
                <xsl:if test="child::node()/c:linkedFragment[@type = 'hardware']">
                    <h5>
                        <xsl:call-template name="capitalizeFirstLetter">
                            <xsl:with-param name="in" select="child::node()/c:linkedFragment[@type = 'hardware']/@type"/>
                        </xsl:call-template>
                        <xsl:text disable-output-escaping="yes">:</xsl:text>
                    </h5>
                    <ul class="hardware">
                        <xsl:apply-templates select="child::node()/c:linkedFragment[@type = 'hardware']" mode="catalog"/>
                    </ul>
                </xsl:if>
                <!--apply all dependency stuff-->
                <xsl:apply-templates mode="dependency"/>
                <!--getBacklinks block-->
                <xsl:call-template name="getBacklink"/>
                <!--jenkins block-->
                <xsl:if test="c:distribution | c:project | c:experiment">
                    <xsl:call-template name="jenkinsApi"/>
                </xsl:if>
            </xsl:element>
        </div>
    </xsl:template>

    <!--backlinks creating-->
    <xsl:template name="getBacklink">
        <xsl:message>INFO: Calling 'getBacklink' template</xsl:message>
        <xsl:element name="div">
            <xsl:attribute name="id">
                <xsl:text disable-output-escaping="yes">backlinks</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="type">
                <xsl:value-of select="name(*[1])"/>
            </xsl:attribute>
            <xsl:attribute name="data-backlinks">
                <xsl:value-of select="child::node()/c:filename"/>
            </xsl:attribute>
            <xsl:for-each select="child::node()/@*">
                <xsl:attribute name="{local-name()}">
                    <xsl:value-of select="."/>
                </xsl:attribute>
            </xsl:for-each>
        </xsl:element>
        <script src="/static/js/backlink.js"/>
    </xsl:template>

    <!--resource type image, display in a carousel-->
    <xsl:template name="imgCarousel">
        <xsl:message>INFO: Calling 'imgCaroussel' template</xsl:message>
        <div id="carouselImgs" class="carousel slide" data-ride="carousel">
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
                        <img class="d-block w-100" src="{@href}" alt="{@alt}"/>
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

    <!--video resources-->
    <xsl:template match="c:resource[@type = 'video']" mode="catalog">
        <xsl:call-template name="log_template_info"/>
        <div class="video">
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
        <div class="resource">
            <span>
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
        </div>
    </xsl:template>

    <!--jenkins api-->
    <xsl:template name="jenkinsApi">
        <xsl:message>INFO: Calling 'jenkinsApi' template</xsl:message>
        <xsl:element name="div">
            <xsl:attribute name="id">
                <xsl:text disable-output-escaping="yes">jenkinsState</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="type">
                <xsl:value-of select="name(*[1])"/>
            </xsl:attribute>
            <xsl:attribute name="name">
                <xsl:value-of select="/c:catalog/child::node()/c:filename"/>
            </xsl:attribute>
        </xsl:element>
        <xsl:element name="script">
            <xsl:attribute name="src">
                <xsl:text disable-output-escaping="yes">/static/js/jenkins-api.js</xsl:text>
            </xsl:attribute>
        </xsl:element>
    </xsl:template>

    <!--description-->
    <xsl:template match="c:description" mode="catalog">
        <p>
            <xsl:value-of select="."/>
        </p>
    </xsl:template>

    <!--distributions access type-->
    <xsl:template match="c:distribution/@access" mode="catalog">
        <xsl:call-template name="log_template_info"/>
        <h5>
            <xsl:text disable-output-escaping="yes">Access: </xsl:text>
            <xsl:value-of select="."/>
        </h5>
    </xsl:template>

    <!--linked fragments-->
    <xsl:template match="c:linkedFragment" mode="catalog">
        <xsl:call-template name="log_template_info"/>
        <li>
            <xsl:if test="@role">
                <span class="capitalize">
                    <xsl:value-of select="@role"/>
                </span>
                <xsl:text disable-output-escaping="yes">: </xsl:text>
            </xsl:if>
            <xsl:element name="a">
                <xsl:attribute name="href">
                    <xsl:text>../</xsl:text>
                    <xsl:value-of select="@type"/>
                    <xsl:text disable-output-escaping="yes">/</xsl:text>
                    <xsl:value-of select="."/>
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
        </li>
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
    <xsl:template match="c:distribution | c:project | c:experiment" mode="dependency">
        <xsl:call-template name="log_template_info"/>
        <xsl:if test="c:dependencies/c:directDependency">
            <div id="directDependencies">
                <h5>
                    <xsl:text disable-output-escaping="yes">Direct dependencies:</xsl:text>
                </h5>
                <ul>
                    <xsl:apply-templates select="c:dependencies/c:directDependency" mode="dependency"/>
                    <xsl:apply-templates
                            select="c:linkedFragment[@type = 'experiment'] | c:linkedFragment[@type = 'dataset']"
                            mode="catalog"/>
                </ul>
            </div>
        </xsl:if>
        <xsl:if test="c:dependencies/c:system/c:dependency">
            <xsl:if test="local-name() = 'distribution'">
                <h3>
                    <xsl:text disable-output-escaping="yes">Replication</xsl:text>
                </h3>
            </xsl:if>
            <h5>
                <xsl:text disable-output-escaping="yes">Install Required OS Packages:</xsl:text>
            </h5>
            <div id="systemDependencies" data-children=".system">
                <xsl:apply-templates select="c:dependencies/c:system" mode="dependency"/>
            </div>
            <xsl:apply-templates select="." mode="gendist"/>
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
                <xsl:if test="c:repositories/c:repository">
                    <pre>
                        <code class="shell">
                            <xsl:choose>
                                <xsl:when test="@name = 'ubuntu'">
                                    <xsl:if test="c:repositories/c:repository">
                                        <xsl:choose>
                                            <xsl:when test="(@version = '14.04') or (@version = 'trusty')">
                                                <xsl:text disable-output-escaping="yes">$ sudo apt-get update&#xa;</xsl:text>
                                                <xsl:text disable-output-escaping="yes">$ sudo apt-get install --no-install-recommends software-properties-common&#xa;</xsl:text>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:text disable-output-escaping="yes">$ sudo apt update&#xa;</xsl:text>
                                                <xsl:text disable-output-escaping="yes">$ sudo apt install --no-install-recommends software-properties-common&#xa;</xsl:text>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:if>
                                    <xsl:for-each select="c:repositories/c:repository">
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
                                            <xsl:text disable-output-escaping="yes">$ sudo apt-get install --no-install-recommends </xsl:text>
                                            <xsl:for-each select="c:dependency">
                                                <xsl:value-of select="."/>
                                                <xsl:text disable-output-escaping="yes"> </xsl:text>
                                            </xsl:for-each>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:text disable-output-escaping="yes">$ sudo apt update&#xa;</xsl:text>
                                            <xsl:text disable-output-escaping="yes">$ sudo apt install --no-install-recommends </xsl:text>
                                            <xsl:for-each select="c:dependency">
                                                <xsl:value-of select="."/>
                                                <xsl:text disable-output-escaping="yes"> </xsl:text>
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
                </xsl:if>
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
                    <xsl:value-of select="."/>
                    <xsl:text>.xml</xsl:text>
                </xsl:attribute>
                <xsl:attribute name="class">
                    <xsl:text disable-output-escaping="yes">ref</xsl:text>
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
    </xsl:template>

    <!--generate distribution-->
    <xsl:template match="c:distribution" mode="gendist">
        <xsl:call-template name="log_template_info"/>
        <h5>
            <xsl:text disable-output-escaping="yes">Generate Distribution</xsl:text>
        </h5>
        <p>
            <xsl:text>Now, please use our distribution tool chain as explained in the tutorials section Bootstrapping
                and Installing. Read and execute these instructions carefully. You will need to bootstrap the
            </xsl:text>
            <code>
                <xsl:value-of select="c:filename"/>
                <xsl:text>.distribution</xsl:text>
            </code>
            <xsl:text>. If you changed your prefix from </xsl:text>
            <code>$HOME/citk</code>
            <xsl:text> to something else, please keep that in mind.</xsl:text>
        </p>
        <pre>
            <code class="shell">
                <xsl:text disable-output-escaping="yes">$ $HOME/citk/jenkins/job-configurator --on-error=continue -d $HOME/citk/dist/distributions/</xsl:text>
                <xsl:value-of select="c:filename"/>
                <xsl:text disable-output-escaping="yes">.distribution -m toolkit -u YOUR_USERNAME -p YOUR_PASSWORD -D toolkit.volume=$HOME/citk/systems</xsl:text>
            </code>
        </pre>
    </xsl:template>
</xsl:stylesheet>