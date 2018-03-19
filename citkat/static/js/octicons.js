(function () {
  var xhttp = new XMLHttpRequest();
  xhttp.onreadystatechange = function () {
    if (this.readyState == 4 && this.status == 200) {
      var div = document.createElement('div');
      div.setAttribute('hidden', 'true');
      div.setAttribute('id', 'octicons');
      div.innerHTML = xhttp.responseText;
      document.getElementsByTagName('body')[0].appendChild(div);
    }
  };
  xhttp.open(
    'GET',
    '/static/node_modules/octicons/build/sprite.octicons.svg',
    true
  );
  xhttp.send();
})();
