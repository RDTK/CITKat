/**
 * Hide long content.
 */
function hideLongContent() {
  var rem = parseFloat(getComputedStyle(document.documentElement).fontSize);
  var content = document.querySelectorAll('.hideContent');
  for (var i = 0, len = content.length; i < len; i++) {
    if (content[i].offsetHeight > 18 * rem) {
      content[i].classList.remove('hideContent');
      var innerNodes = content[i].innerHTML;
      var inputCheckbox = document.createElement('input');
      inputCheckbox.setAttribute('type', 'checkbox');
      inputCheckbox.setAttribute('id', 'readmore-' + i);

      var innerDiv = document.createElement('div');
      innerDiv.className = 'inner';
      innerDiv.innerHTML = innerNodes;

      content[i].innerHTML = '';
      content[i].appendChild(inputCheckbox);
      content[i].appendChild(innerDiv);

      var label = document.createElement('label');
      label.className = 'btn btn-link';
      label.setAttribute('for', 'readmore-' + i);

      content[i].appendChild(label);
    }
  }
}
