var videoUrl = document.querySelector('#vimeo-embed').getAttribute('data-href');
var endpoint = 'http://www.vimeo.com/api/oembed.json';

function embedVideo(video) {
    document.querySelector('#vimeo-embed').innerHTML = unescape(video.html); // TODO: use shadowDom
}

var callback = 'embedVideo';
var url = endpoint + '?url=' + encodeURIComponent(videoUrl) + '&callback=' + callback + '&width=640';
(function () {
    var js = document.createElement('script');
    js.setAttribute('type', 'text/javascript');
    js.setAttribute('src', url);
    document.querySelector('#vimeo-embed').appendChild(js);
})();