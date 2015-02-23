---
layout: page
title: Kite Community Information
---

## Logistics

### Project Format

This project is an open source project, released under the [Apache Software License, version 2.0](http://www.apache.org/licenses/LICENSE-2.0). This project is hosted and managed on Github. Community contributions are welcome and encouraged! See [How to Contribute](https://github.com/kite-sdk/kite/wiki/How-to-contribute).

All feature requests and bugs are tracked in the CDK JIRA project at [https://issues.cloudera.org/browse/CDK](https://issues.cloudera.org/browse/CDK). Users are encouraged to use the cdh-user@cloudera.org mailing list to discuss CDK-related topics.

## Releases

We distribute releases through Maven Central. Release frequency is undefined at this time. Some versions of Kite are also included in Hadoop distributions such as CDH.

## Compatibility Statement

As a library, users must be able to reliably determine the intended compatibility of this project. We take API stability and compatibility seriously; any deviation from the stated guarantees is a bug. This project follows the guidelines set forth by the 

## Semantic Versioning

This project makes the following compatibility guarantees:

1. The patch version is incremented if only backward-compatible bug fixes are introduced.
1. The minor version is incremented when backward-compatible features are added to the public API, parts of the public API are deprecated, or when changes are made to private code. Patch level changes might also be included.
1. The major version is incremented when backward-incompatible changes are made. Minor and patch level changes might also be included.
1. Prior to version 1.0.0, no backward-compatibility is guaranteed.
1. Version 1.0.0 releases when there is a stable API and the Kite team is ready to commit to these compatibility guarantees.

See the Semantic Versioning Specification for more information. 

Additionally, this project makes the following statements:
* The public API is defined by the Javadoc.
* Some classes might be annotated with @Beta. These classes are evolving or experimental, and are not subject to the stated compatibility guarantees. They might change incompatibly in any release.
* Deprecated elements of the public API are retained for two releases and then removed. Since this breaks backward compatibility, the major version must also be incremented.
