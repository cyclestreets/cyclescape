#!/usr/bin/env node

const planer = require('planer')
const jsdom = require('jsdom')
jsdom.defaultDocumentFeatures = {
  FetchExternalResources: false,
  ProcessExternalResources: false
}
const dom = new jsdom.JSDOM().window.document
console.log(planer.extractFromHtml(process.argv[2], dom))
