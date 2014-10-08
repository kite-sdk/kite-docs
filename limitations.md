---
layout: page
title: 'Limitations'
---

# Known Limitations

The Kite Data module has the following known limitations as well as the intended
course of action, if available. Users are encouraged to participate in the
discussion of any feature addition or improvements by way of the mailing lists
or the indicated JIRA, if it exists.

* It's not currently possible to rename datasets.
* There's no inter-process coordination or locking when operating on datasets.
  As a result, races can occur if two processes each try and create the same
  dataset.
