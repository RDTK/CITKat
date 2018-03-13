/**
 * Hide long content.
 */
function hideLongContent() {
  let rem = parseFloat(getComputedStyle(document.documentElement).fontSize);
  let content = document.querySelectorAll('.hideContent');
  for (let i = 0, len = content.length; i < len; i++) {
    if (content[i].offsetHeight > 18 * rem) {
      content[i].classList.remove('hideContent');
      let innerNodes = content[i].innerHTML;
      let inputCheckbox = document.createElement('input');
      inputCheckbox.setAttribute('type', 'checkbox');
      inputCheckbox.setAttribute('id', 'readmore-' + i);

      let innerDiv = document.createElement('div');
      innerDiv.className = 'inner';
      innerDiv.innerHTML = innerNodes;

      content[i].innerHTML = '';
      content[i].appendChild(inputCheckbox);
      content[i].appendChild(innerDiv);

      let label = document.createElement('label');
      label.className = 'btn btn-link';
      label.setAttribute('for', 'readmore-' + i);

      content[i].appendChild(label);
    }
  }
}
