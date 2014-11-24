---
layout: page
title: Kite Community Information
---

## Logistics

### Project Format

The intention is for this library to be released as an open source project, under the Apache Software License. The project will be hosted and managed on Github. Community contributions are welcome and are encouraged. Those who wish to contribute to the project must complete a contributor license agreement (CLA) and provide their changes to the project under the same license as the rest of the project. This must be done prior to accepting any changes (for example, a Github pull request).

A more detailed "How to Contribute" document, as well as individual and corporate CLAs, will be provided when with the initial publication of the project.

All feature requests and bugs are tracked in the CDK JIRA project at https://issues.cloudera.org/browse/CDK. Users are encouraged to use the cdh-user@cloudera.org mailing list to discuss CDK-related topics.

## Releases

Since this project ultimately produces a Java library, the natural way to disseminate releases by way of Cloudera's Maven repository. Direct downloads containing the combined source and binary artifacts will also be provided. 

Optionally, we might additionally publish artifacts to Maven Central. Release frequency is left undefined at this time. That said, since this project makes similar compatibility guarantees as CDH (see Compatibility Statement), quarterly releases seem likely.

## Compatibility Statement

As a library, users must be able to reliably determine the intended compatibility of this project. We take API stability and compatibility seriously; any deviation from the stated guarantees is a bug. This project follows the guidelines set forth by the 

## Semantic Versioning

Specification and uses the same nomenclature. Just as with CDH (and semver), this project makes the following compatibility guarantees:

1.	The patch version is incremented if only backward-compatible bug fixes are introduced.
2.	The minor version is incremented when backward-compatible features are added to the public API, parts of the public API are deprecated, or when changes are made to private code. Patch level changes may also be included.
3.	The major version is incremented when backward-incompatible changes are made. Minor and patch level changes may also be included.
4.	Prior to version 1.0.0, no backward-compatibility is guaranteed.

See the Semantic Versioning Specification for more information. 

Additionally, this project makes the following statements:
•	The public API is defined by the Javadoc.
•	Some classes may be annotated with @Beta. These classes are evolving or experimental, and are not subject to the stated compatibility guarantees. They might change incompatibly in any release.
•	Deprecated elements of the public API are retained for two releases and then removed. Since this breaks backward compatibility, the major version must also be incremented.
