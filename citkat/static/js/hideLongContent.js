function hideLongContent() {
  var rem = parseFloat(getComputedStyle(document.documentElement).fontSize);
  content = document.querySelectorAll('.hideContent');
  for (var i = 0, len = content.length; i < len; i++) {
    if (content[i].offsetHeight > 18 * rem) {
      content[i].classList.remove('hideContent');
      var inner = content[i].firstChild;
      inner.setAttribute('class', inner.getAttribute('class') + ' inner');
      content[i].innerHTML = '<input type="checkbox">';
      content[i].firstChild.setAttribute('id', 'readmore-' + i)
      content[i].appendChild(inner);
      var label = document.createElement('label');
      label.setAttribute('for', 'readmore-' + i);
      label.setAttribute('class', 'btn btn-link');
      content[i].appendChild(label);
    }
  }
}