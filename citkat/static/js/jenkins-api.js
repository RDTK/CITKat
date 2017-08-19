(function () {
    function loadJSON(url, callback) {
        var request = new XMLHttpRequest();
        request.overrideMimeType('application/json');
        request.open('GET', url, true);
        request.onreadystatechange = function () {
            if (request.readyState === 4 && request.status === 200) {
                callback(request.responseText)
            }
        };
        request.send(null)
    }

    var jenkinsDiv = document.querySelector('#jenkinsState');
    var catalog = document.querySelector('#catalog');
    var url = catalog.querySelector('distribution').getAttribute('buildserverbaseurl');
    var urlParam =
        '/api/json?&tree=' +
        'healthReport[' +
            'score' +
        '],' +
            'lastSuccessfulBuild[' +
            'timestamp' +
        '],' +
        'lastFailedBuild[' +
            'timestamp' +
        ']';

    if (url[-1] !== '/') {
        url += '/';
    }
    url = url + 'job/';
    if (catalog.getAttribute('type') === 'distribution') {
        url = url
            + catalog.getAttribute('name')
            + '-'
            + catalog.getAttribute('version')
            + '-'
            + catalog.querySelector('distribution').getAttribute('build-generator-template')
            + '-orchestration'
            + urlParam;
    } else {
        function getQueryParams(qs) {
            qs = qs.split('+').join(' ');
            var params = {},
                tokens,
                re = /[?&]?([^=]+)=([^&]*)/g;
            while (tokens = re.exec(qs)) {
                params[decodeURIComponent(tokens[1])] = decodeURIComponent(tokens[2]);
            }
            return params;
        }

        var params = getQueryParams(document.location.search);
        if (params && 'jobs' in params) {
            url = url
                + catalog.getAttribute('name')
                + '-'
                + catalog.getAttribute('version')
                + '-'
                + catalog.querySelector('distribution').getAttribute('build-generator-template')
                + '-'
                + params['jobs']
                + urlParam;
        }
    }
    console.log(url)
    // TODO: load json from jenkins server, build corresponding domFragment, TEST!
})();