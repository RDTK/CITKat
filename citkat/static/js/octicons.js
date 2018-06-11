(function () {
  fetch('/static/node_modules/octicons/build/sprite.octicons.svg',
      {cache: 'force-cache'})
    .then(function (response) {
      return response.text();
    }).then(function (svg) {
      var div = document.createElement('div');
      div.setAttribute('hidden', 'true');
      div.setAttribute('id', 'octicons');
      div.innerHTML = svg;
      document.body.appendChild(div);
    });
})();
