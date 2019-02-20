# Cyclescape

Cyclescape is a Ruby on Rails web application created to facilitate cycle campaigning.

The software has been developed to power the [Cyclescape](http://www.cyclescape.org)
campaigning website, and you can help improve it or take the software and customise
it for your own needs.

It is split into two main sections:

* Reporting a problem: a section open to anyone
* Managing and solving problems: for campaigners and groups

Cyclescape aims to have the following outcomes:

* Fundamentally, increased resolution of problems on the street/path network and therefore an improved cycling environment
* Improved and better-organised working practices by local groups around the country through access to a new tool to help them manage the deluge of cycling problems that they get told about or wish to see resolved
* Increased reporting of network deficiencies, i.e. increased involvement of local people
* Increased awareness of problems faced by cyclists
* Improved working relationships between campaign groups and Local Authorities (a common problem)
* Increased ability for Local Authorities to justify central government investment
* Increased demonstration of partnership working between Local Authorities and local people
* Potentially, consolidation of existing web-based systems, reducing the need for groups to maintain custom-written and highly-specific systems.

Cyclescape is being created by CycleStreets, who run the UK-wide cycle journey planner (at [cyclestreets.net](http://www.cyclestreets.net)), run ‘for cyclists, by cyclists’. As well as the cycle journey planner, which has planned almost a million routes in the UK, the CycleStreets website includes a Photomap campaigning tool used by cyclists to report problems and good practice, by locating photographs on a map.

# Project Development

We use [Github](https://github.com/cyclestreets/cyclescape) for managing development, you can clone the repository, or report bugs there.

Pull requests are *very* welcome! Additional developer notes are available on the github wiki.

# Translations

Translations are managed using the [Transifex](https://www.transifex.com) platform. After signing up, you can go to the [Cyclescape project page](https://www.transifex.com/cyclestreets/cyclescape/), select a language and click Translate now to start translating.

The words in braces preceded by a percent, for example %{name}, should not be translated into a new language: it's replaced with the group name when rails presents the text. So a German translation of `Request membership of %{group_name}` would look like `Mitgliedsantrag aus %{group_name}`

At the moment, the translations are not used by the application, but are useful for custom deployments.

 * https://www.cyclescape.org/
 * http://www.cyklistesobe.cz/
