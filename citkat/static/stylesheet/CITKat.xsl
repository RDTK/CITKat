<?xml version="1.0"?>
<!--TODO: replace alle absolute URIs, move to github pages-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:c="https://toolkit.cit-ec.uni-bielefeld.de/CITKat" exclude-result-prefixes="c">
    <xsl:output method="html" cdata-section-elements="script" indent="no" media-type="text/html" version="5.0"
                encoding="UTF-8" doctype-system="about:legacy-compat"/>

    <xsl:variable name="lowerCaseLetter" select="'abcdefghijklmnopqrstuvwxyz'"/>

    <xsl:variable name="upperCaseLetter" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'"/>

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

    <xsl:template name="capitalizeFirstLetter">
        <xsl:param name="in"/>
        <xsl:message>INFO: Calling 'capitalizeFirstLetter' template</xsl:message>
        <xsl:value-of
                select="concat(
                          translate(
                            substring($in, 1, 1), $lowerCaseLetter, $upperCaseLetter
                          ),
                          substring(
                            $in, 2, string-length($in)-1
                          )
                        )"/>
    </xsl:template>

    <xsl:template name="getBacklink">
        <xsl:message>INFO: Calling 'getBacklink' template</xsl:message>
        <xsl:element name="div">
            <xsl:attribute name="id">
                <xsl:text disable-output-escaping="yes">backlinks</xsl:text>
            </xsl:attribute>
            <xsl:for-each select="/c:catalog/child::node()/@*">
                <xsl:attribute name="{local-name()}">
                    <xsl:value-of select="."/>
                </xsl:attribute>
            </xsl:for-each>
            <xsl:attribute name="type">
                <xsl:value-of select="name(*[1])"/>
            </xsl:attribute>
            <xsl:attribute name="data-backlinks">
                <xsl:value-of select="/c:catalog/child::node()/c:filename/text()"/>
            </xsl:attribute>
        </xsl:element>
        <xsl:element name="script">
            <xsl:attribute name="src">
                <xsl:text disable-output-escaping="yes">/static/js/backlink.js</xsl:text>
            </xsl:attribute>
        </xsl:element>
    </xsl:template>

    <xsl:template name="makeTitle">
        <xsl:message>INFO: Calling 'makeTitle' template</xsl:message>
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
            <xsl:when test="child::node()/@title">
                <xsl:text disable-output-escaping="yes">: "</xsl:text>
                <xsl:value-of select="child::node()/@title"/>
                <xsl:text disable-output-escaping="yes">"</xsl:text>
            </xsl:when>
        </xsl:choose>
        <xsl:text disable-output-escaping="yes"> // CITKat</xsl:text>
    </xsl:template>

    <xsl:template match="/c:catalog">
        <xsl:call-template name="log_template_info"/>
        <html lang="en">
            <head>
                <xsl:copy-of select="document('/static/templates/head.xml')/head/*"/>
                <title>
                    <xsl:call-template name="makeTitle"/>
                </title>
            </head>
            <body>
                <div class="container" style="padding-left: 0; padding-right: 0; "><!--first container doesn't need padding!-->
                    <xsl:copy-of select="document('/static/templates/nav.xml')/body/*"/>
                    <xsl:copy-of select="document('/static/templates/header.xml')/body/*"/>
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
                        <xsl:if test="c:distribution 
                                    | c:project
                                    | c:experiment">
                            <xsl:attribute name="build-generator-template">
                                <xsl:value-of select="/c:catalog/@build-generator-template"/>
                            </xsl:attribute>
                            <xsl:attribute name="buildserverbaseurl">
                                <xsl:value-of select="/c:catalog/@buildServerBaseURL"/>
                            </xsl:attribute>
                            <xsl:attribute name="name">
                                <xsl:value-of select="child::node()/@name"/>
                            </xsl:attribute>
                            <xsl:attribute name="version">
                                <xsl:value-of select="child::node()/@version"/>
                            </xsl:attribute>
                        </xsl:if>
                        <h1>
                            <xsl:call-template name="capitalizeFirstLetter">
                                <xsl:with-param name="in" select="name(*[1])"/>
                            </xsl:call-template>
                            <xsl:text disable-output-escaping="yes"> Details </xsl:text>
                        </h1>
                        <h2>
                            <xsl:choose>
                                <xsl:when test="child::node()/@name and child::node()/@version">
                                    <xsl:value-of select="child::node()/@name"/>
                                    <xsl:text disable-output-escaping="yes"> (</xsl:text>
                                    <xsl:value-of select="child::node()/@version"/>
                                    <xsl:text disable-output-escaping="yes">)</xsl:text>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="child::node()/c:filename/text()"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </h2>
                        <xsl:apply-templates select="child::node()/c:description"/>

                        <xsl:if test="child::node()/c:resource[not(@type = 'img') and not(@type = 'video')]">
                            <xsl:apply-templates select="child::node()/c:resource[not(@type = 'img') and not(@type = 'video')]"/>
                        </xsl:if>


                        <xsl:if test="child::node()/c:resource[@type = 'img']">
                            <div id="carouselImgs" class="carousel slide" data-ride="carousel">
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
                                <div class="carousel-inner">
                                    <xsl:apply-templates select="child::node()/c:resource[@type = 'img']"/>
                                </div>
                                <a class="carousel-control-prev" href="#carouselImgs" role="button" data-slide="prev">
                                    <span class="carousel-control-prev-icon" aria-hidden="true"/>
                                    <span class="sr-only">Previous</span>
                                </a>
                                <a class="carousel-control-next" href="#carouselImgs" role="button" data-slide="next">
                                    <span class="carousel-control-next-icon" aria-hidden="true"/>
                                    <span class="sr-only">Next</span>
                                </a>
                            </div>
                        </xsl:if>

                        <xsl:apply-templates select="child::node()/c:resource[@type = 'video']"/>

                        <xsl:apply-templates select="/c:catalog/c:distribution/@access"/>
                        <!--Persons-->
                        <xsl:if test="//c:linkedFragment[@type = 'person']">
                            <h5>
                                <xsl:text disable-output-escaping="yes">Involved </xsl:text>
                                <xsl:call-template name="capitalizeFirstLetter">
                                    <xsl:with-param name="in" select="//c:linkedFragment[@type = 'person']/@type"/>
                                </xsl:call-template>
                                <xsl:if test="count(//c:linkedFragment[@type = 'person']) > 1">
                                    <xsl:text>s</xsl:text>
                                </xsl:if>
                                <xsl:text disable-output-escaping="yes">:</xsl:text>
                            </h5>
                            <ul class="persons">
                                <xsl:apply-templates select="//c:linkedFragment[@type = 'person']"/>
                            </ul>
                        </xsl:if>
                        <!--Publications-->
                        <xsl:if test="//c:linkedFragment[@type = 'publication']">
                            <h5>
                                <xsl:text disable-output-escaping="yes">Linked </xsl:text>
                                <xsl:call-template name="capitalizeFirstLetter">
                                    <xsl:with-param name="in" select="//c:linkedFragment[@type = 'publication']/@type"/>
                                </xsl:call-template>
                                <xsl:if test="count(//c:linkedFragment[@type = 'publication']) > 1">
                                    <xsl:text>s</xsl:text>
                                </xsl:if>
                                <xsl:text disable-output-escaping="yes">:</xsl:text>
                            </h5>
                            <ul class="publications">
                                <xsl:apply-templates select="//c:linkedFragment[@type = 'publication']"/>
                            </ul>
                        </xsl:if>
                        <!--Hardware-->
                        <xsl:if test="//c:linkedFragment[@type = 'hardware']">
                            <h5>
                                <xsl:call-template name="capitalizeFirstLetter">
                                    <xsl:with-param name="in" select="//c:linkedFragment[@type = 'hardware']/@type"/>
                                </xsl:call-template>
                                <xsl:text disable-output-escaping="yes">:</xsl:text>
                            </h5>
                            <ul class="hardware">
                                <xsl:apply-templates select="//c:linkedFragment[@type = 'hardware']"/>
                            </ul>
                        </xsl:if>
                        <xsl:apply-templates select="child::node()"/>
                        <xsl:call-template name="getBacklink"/>
                        <xsl:if test="c:distribution
                                     | c:project
                                     | c:experiment">
                            <xsl:call-template name="jenkinsApi"/>
                        </xsl:if>
                    </xsl:element>
                    <xsl:copy-of select="document('/static/templates/linkParams.xml')/body/*"/>
                    <xsl:copy-of select="document('/static/templates/footer.xml')/body/*"/>
                </div>
            </body>
        </html>
    </xsl:template>

    <xsl:template match="c:description">
        <xsl:call-template name="log_template_info"/>
        <!-- workaround for doublet description in dataset and hardware-->
        <xsl:if test="position() = 1">
            <h3>
                <xsl:text disable-output-escaping="yes">General Information</xsl:text>
            </h3>
            <xsl:element name="p">
                <xsl:value-of select="text()"/>
            </xsl:element>
        </xsl:if>
    </xsl:template>

    <xsl:template match="c:resource[@type = 'img']">
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
    </xsl:template>

    <xsl:template match="c:resource[not(@type = 'img') and not(@type = 'video')]">
        <xsl:call-template name="log_template_info"/>
        <xsl:choose>
            <xsl:when test="bugtracker">
                <xsl:text disable-output-escaping="yes">Bug Tracker</xsl:text>
            </xsl:when>
            <xsl:when test="scmbrowser">
                <xsl:text disable-output-escaping="yes">SCM</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="capitalizeFirstLetter">
                    <xsl:with-param name="in" select="@type"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:text disable-output-escaping="yes">: </xsl:text>
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
    </xsl:template>
    
    <xsl:template match="c:resource[@type = 'video']">
        <xsl:call-template name="log_template_info"/>
        <xsl:choose>
            <xsl:when test="contains(@href, 'vimeo')">
                <div id="vimeo-embed" data-href="{@href}" class="videoWrapper">Loading video...</div>
                <script><![CDATA[
var videoUrl = document.querySelector('#vimeo-embed').getAttribute('data-href');
var endpoint = 'http://www.vimeo.com/api/oembed.json';
function embedVideo(video) {
    document.querySelector('#vimeo-embed').innerHTML = unescape(video.html);
}
var callback = 'embedVideo';
var url = endpoint + '?url=' + encodeURIComponent(videoUrl) + '&callback=' + callback + '&width=640';
(function() {
    var js = document.createElement('script');
    js.setAttribute('type', 'text/javascript');
    js.setAttribute('src', url);
    document.querySelector('#vimeo-embed').appendChild(js);
})();
]]>
                </script>
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
                <xsl:text disable-output-escaping="yes">Linked Video: </xsl:text>
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
    </xsl:template>

    <xsl:template match="c:linkedFragment">
        <xsl:call-template name="log_template_info"/>
        <li>
            <xsl:if test="@role">
                <xsl:call-template name="capitalizeFirstLetter">
                    <xsl:with-param name="in" select="@role"/>
                </xsl:call-template>
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

    <xsl:template match="c:extends">
        <xsl:call-template name="log_template_info"/>
        <div>
            <h5>
                <xsl:text disable-output-escaping="yes">Inherits from:</xsl:text>
            </h5>
            <xsl:element name="a">
                <xsl:attribute name="href">
                    <xsl:call-template name="firstWordOnly">
                        <xsl:with-param name="sequence" select="text()"/>
                    </xsl:call-template>
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

    <xsl:template match="c:distribution
                       | c:project
                       | c:experiment">
        <xsl:call-template name="log_template_info"/>
        <xsl:apply-templates select="c:extends"/>
        <xsl:if test="c:dependencies//c:dependency">
            <h5>
                <xsl:text disable-output-escaping="yes">Install Required OS Packages:</xsl:text>
            </h5>
            <div id="systemDependencies" data-children=".system">
                <xsl:apply-templates select="c:dependencies/c:system"/>
            </div>

            <xsl:if test="local-name() = 'distribution'">
                <h3>
                    <xsl:text disable-output-escaping="yes">Replication</xsl:text>
                </h3>
                <xsl:call-template name="generateDistribution"/>
            </xsl:if>
        </xsl:if>
        <xsl:if test="c:dependencies/c:directDependency">
            <div id="directDependencies">
                <h5>
                    <xsl:text disable-output-escaping="yes">Direct dependencies:</xsl:text>
                </h5>
                <ul>
                    <xsl:apply-templates select="c:dependencies/c:directDependency"/>
                    <xsl:apply-templates select="c:linkedFragment[@type = 'experiment']
                                               | c:linkedFragment[@type = 'dataset']"/>
                </ul>
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template match="c:directDependency">
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

    <xsl:template match="c:system">
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

    <xsl:template name="generateDistribution">
        <xsl:message>INFO: Calling 'generateDistribution' template</xsl:message>
        <h5>
            <xsl:text disable-output-escaping="yes">Generate Distribution</xsl:text>
        </h5>
        <p>
            <xsl:text>Now, please use our distribution tool chain as explained in the tutorials section Bootstrapping
                and Installing. Read and execute these instructions carefully. You will need to bootstrap the
            </xsl:text>
            <code>
                <xsl:value-of select="/c:catalog/c:distribution/c:filename/text()"/>
                <xsl:text>.distribution</xsl:text>
            </code>
            <xsl:text>. If you changed your prefix from </xsl:text>
            <code>$HOME/citk</code>
            <xsl:text> to something else, please keep that in mind.</xsl:text>
        </p>
        <pre>
            <code class="shell">
                <xsl:text disable-output-escaping="yes">$ $HOME/citk/jenkins/job-configurator --on-error=continue -d $HOME/citk/dist/distributions/</xsl:text>
                <xsl:value-of select="//c:distribution/c:filename/text()"/>
                <xsl:text disable-output-escaping="yes">.distribution -m toolkit -u YOUR_USERNAME -p YOUR_PASSWORD -D toolkit.volume=$HOME/citk/systems</xsl:text>
            </code>
        </pre>
    </xsl:template>

    <xsl:template name="firstWordOnly">
        <xsl:param name="sequence"/>
        <xsl:choose>
            <xsl:when
                    test="(
                           string-length(normalize-space($sequence)) -
                           string-length(translate(normalize-space($sequence),' ','')) + 1
                          ) > 1">
                <xsl:value-of select="substring-before(normalize-space($sequence), ' ')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="normalize-space($sequence)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

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
                <xsl:value-of select="/c:catalog/child::node()/@name"/>
            </xsl:attribute>
            <xsl:attribute name="version">
                <xsl:value-of select="/c:catalog/child::node()/@version"/>
            </xsl:attribute>
        </xsl:element>
        <xsl:element name="script">
            <xsl:attribute name="src">
                <xsl:text disable-output-escaping="yes">/static/js/jenkins-api.js</xsl:text>
            </xsl:attribute>
        </xsl:element>
    </xsl:template>

    <xsl:template match="/c:catalog/c:distribution/@access">
        <xsl:call-template name="log_template_info"/>
        <h5>
            <xsl:text disable-output-escaping="yes">Access: </xsl:text>
            <xsl:value-of select="."/>
        </h5>
    </xsl:template>
</xsl:stylesheet>