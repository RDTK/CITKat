(function () {
    function getQueryParams(qs) {
        qs = qs.split('+').join(' ');
        var p = {},
            tokens,
            re = /[?&]?([^=]+)=([^&]*)/g;
        while (tokens = re.exec(qs)) {
            p[decodeURIComponent(tokens[1])] = decodeURIComponent(tokens[2]);
        }
        return p;
    }

    var params = getQueryParams(document.location.search);

    if (Object.keys(params).length !== 0) {
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
        var url = '';
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
        if (catalog.getAttribute('type') === 'distribution') {
            url = catalog.getAttribute('buildserverbaseurl');

            if (url[-1] !== '/') {
                url += '/';
            }
            url = url + 'job/';
            url = url
                + catalog.getAttribute('data-filename')
                + '-'
                + catalog.getAttribute('build-generator-template')
                + '-orchestration'
                + urlParam;
        } else {


            url = params['jenkins'];
            url = url + '/job/';
            url = url
                + catalog.getAttribute('data-filename')
                + '-'
                + params['tpl']
                + '-'
                + params['dist']
                + urlParam;
        }
        console.log(url)
    } else {
        console.log('jenkins-api: no params found in url')
    }
    // TODO: load json from jenkins server, build corresponding domFragment, TEST!
})();