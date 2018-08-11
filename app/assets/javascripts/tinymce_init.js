$(window).ready(function () {
  tinyMCE.init({
    selector: 'textarea.tinymce',
    branding: false,
    menubar: false,
    plugins: [ 'table', 'link', 'lists' ],
    toolbar: 'undo redo | bold italic | bullist numlist | table link unlink | blockquote image',
    // keep updated with content.scss blockquote
    content_style: 'blockquote {padding: 0 1em; color: #61737d; border-left: 0.25em solid #dfe2e5; margin: 0}'
  })
})
