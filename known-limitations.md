---
layout: page
title: Known Limitations
---

Kite datasets have the following known limitations:

* It's not currently possible to rename datasets.
* There's no inter-process coordination or locking when operating on datasets. As a result, races can occur if two processes each try and create the same dataset.
