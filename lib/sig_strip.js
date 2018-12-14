#!/usr/bin/env node

const planer = require('planer')
const jsdom = require('jsdom')
jsdom.env('<html></html>', function (_, window) {
  console.log(planer.extractFrom(process.argv[2], 'text/html', window.document))
})
