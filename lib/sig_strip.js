#!/usr/bin/env node

const planer = require('planer')
const jsdom = require('jsdom')
const dom = new jsdom.JSDOM().window.document
console.log(planer.extractFrom(process.argv[2], 'text/html', dom))
