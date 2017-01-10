// http://stackoverflow.com/a/7409789/3592846
$.fn.changeVal = function (v) {
    return $(this).val(v).trigger("change");
}
