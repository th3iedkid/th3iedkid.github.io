---
layout: post
title:  "Building Stream-Analytic Ecosystems via Metaprogramming"
author: "Ganesh"
date:   2017-05-27 19:44:08 +0530
categories: metaprogramming talks
---

Back in Feb, i had a unqiue opportunity to talk on using meta-programming to build stream-analytic ecosystems for enterprises.
The talk itself is available here :  [Video](https://www.youtube.com/watch?v=1OTdhWhNJVw) [Slides](https://www.slideshare.net/DataTorrent/lightning-talks-integrations-track-building-streamanalytic-ecosystems-for-enterprises-abdw17-pune?qid=19b15b6a-fd6b-490e-a799-ec5063fa97a7&v=&b=&from_search=5)

### Idea ###

Let me briefly describe the idea.

Agile analytics with streaming capabilities requires different teams to coordinate and execute across a range of tools and platforms. Building a process that facilitates iterative execution with increasing productivity under such environments requires, not only a guiding process but a platform to facilitate the same.
The Hadoop ecosystem with streaming analytic engines such Apache Apex, empowers enterprises build sophisticated data pipelines. When augmented with an agile analytics process, it facilitates the Enterprise towards a complete ecosystem.
One such platform capability, facilitating process is via Metaprogramming. Metaprogramming is a programming technique in which computer programs can treat programs as their data. It means that a program could be designed to read, generate, analyse or transform other programs, and even modify itself while running.
Building domain driven Domain Specific Language , converging productivity benefits of stock  language platforms(like Java) for analytics, covering different stages right from ideation to Realization  for analytic stream processing needs, enabling formal systems to verify via domain’s characteristics to verify the pipeline even before materializing, helping manage the usual iterative productivity requirements of multi-versioned pipelines, security, facilitating domains to refactor pipeline itself with possible autosuggestion ,deriving domain driven type-systems for pre-materialization verification and finally bringing all the usual engineering features of  a programming language ecosystem , directly to the domain , in its own friendly language.

### Agile analytic ecosystems ###

Agile analytic ecosystems usually involve more than fast moving data.They are all driven by fast moving demands for value generation from data.The demand could drive different approaches based on its own constraints ,during different times.
This could lead to a demand in requests for not only fast changing data but code too.In an enterprise with common capability models, it usually so happens that realizing such high rates of demands puts tremendous pressure on engineering execution latencies.
Scaling towards such demands can sometimes prove difficult under enterprise specific constraints where process drive results rather than individuals.
These processes tend to orchestrate the evolution of an idea to a realizable unit in so many steps that latencies accumlate downwards and sometimes makes the realization itself time-inefficient.
 ![Process](/img/processsblock.png ){:height="200px" width="36px"}

There are many strategies within the gamut of an Enterprise strategy to address the same.However one low-level design strategy is to piggy back on platforms to translate the idea from one common semantic form to another.
Platforms can help derive the results ensuring the nature of substantiated quality guarantees an Enterprise might expect.One such platform strategy is via Metaprogramming.

### What is Meta-programming ###

[Wikipedia](https://en.wikipedia.org/wiki/Metaprogramming) :
> Metaprogramming is a programming technique in which computer programs have the ability to treat programs as their data. It means that a program can be designed to read, generate, analyse or transform other programs, and even modify itself while running

For those familiar with Java , Reflective abilities of the language does enable some degree of meta-programming.Most languages provide some-degree of abilities to perform metaprogramming.

The video of the talk is as below
<div><iframe width="854" height="480" src="https://www.youtube.com/watch?v=1OTdhWhNJVw" frameborder="0" allowfullscreen></iframe></div>
