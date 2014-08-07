---
layout: page
title: Parquet vs Avro Format
---

<a href="https://www.youtube.com/watch?v=AY1dEfyFeHc&list=PLGzsQf6UXBR-BJz5BGzJb2mMulWTfTu99&index=4">
<img src="https://raw.githubusercontent.com/DennisDawson/KiteImages/master/parquetVsAvro.png" 
alt="Parquet vs Avro Video" width="240" height="180" border="10" align="right" title="Link to Parquet vs Avro Video"/></a>


Avro is a row-based storage format for Hadoop.

Parquet is a column-based storage format for Hadoop.

If your use case typically scans or retrieves all of the fields in a row in each query, Avro is usually the best choice.

If your dataset has many columns, and your use case typically involves working with a subset of those columns rather than entire records, Parquet is optimized for that kind of work.
