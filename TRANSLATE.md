# Translations

Translating Cyclescape is carried out using Transifex, which provides a nice user-interface for translators.

[https://www.transifex.com/cyclestreets/cyclescape/dashboard/](https://www.transifex.com/cyclestreets/cyclescape/dashboard/)

## Translating Cyclescape into your language

Please sign up for an account at Transifex and join our group there. If you want to start a new language please just ask!

## Developers

Please only make changes to the `*.en-GB.yml` files. The other files are generated automatically from Transifex.

When you have the transifex command line client installed, the en-GB source files can be uploaded to Transifex with:

`bundle exec rake transifex:push`

To fetch new translations from Transifex run:

`bundle exec rake transifex:pull`
