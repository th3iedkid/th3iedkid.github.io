---
layout: post
title:  "Building Akka streaming appication to stream from a RESTfull source to an Elasticsearch cluster"
author: "Ganesh"
date:   2017-05-26 19:44:08 +0530
categories: akka-streaming blog
---

I had to quickly build a data pipeline to index TeamCity's run data onto elasticsearch for anaytics.
This post is to briefly describe how large volumes of data were piped into elasticsearch using akka-streaming and how it was tuned.

### Basic Setup ###

While i wanted to do it in Scala with Akka-Streaming, i wanted to quickly generate scala models that would be required to read data from teamcity via REST.
I chose to first fetch TeamCity's REST spec via Swagger.I saw that there was one sbt plugin in github that appeared to do the Job.
I chose to move along with that, but discovered numerous bugs esp around reference specs of swagger where not implemented in the original project.
So i went ahead , forked it and fixed the bugs. The fixed one is available at : [sbt-swagger-codegen](https://github.com/ganesh47/sbt-swagger-codegen)
The plugin is also hosted in bintray , which can be accessed placing this in your plugins.sbt

> resolvers += Resolver.bintrayRepo("th3iedkid","sbt-plugins")

Then it was about adding the plugin into the plugins.sbt as :

> addSbtPlugin("in.thedatateam" % "sbt-swagger-codegen" % "0.0.14")

Once done with that , i fetched TeamCity's swagger def using its own API

> curl https://<your teamcity server>/app/rest/swagger.json  > teamcity.json

Then placing the file in src/main/swagger/ , i run the swaggerModelCodeGen sbt task which yielded the necessary models in target/scala-<version>/src_managed/main/Teamcity.scala and teamcityJson.scala.
The former contains the main models packaged in an object.The latter contains the code using Play-Json-lib for converting plaiin-string json to the model object and vice-versa.

Now it was upto building the pipe-line using Akka-streams!

TeamCity's REST API has an end-point to fetch all build-details paged by a given count.

> "/app/rest/builds?locator=affectedProject:pjkey,branch:default:any,count:<count>&fields=nextHref,build(id,number,status,buildType(id,name,projectName),triggered(details,date,user(username,email)),startDate,finishDate,revisions(revision(version,vcsBranchName)),lastChanges(href),statistics(property(name,value)))"

Am actually fetching loads of statistics along with the build data.

How am i fetching it ?I first prep a Akka-Http Host-Level connection pool and then re-use that throughout.

~~~~~~~~~~~~~~~~~~~~~~~~

val teamcityPool = Http().cachedHostConnectionPool[Int]("li1458-195.members.linode.com", 8111)

Source.single(HttpRequest(uri = url, headers = headers) -> port)
      .via(teamcityPool).runWith(Sink.head)

~~~~~~~~
{: .language-scala}

Using the nextHref element of this result the rest of the pages could be drawn.Then i use the DSL driven elastic4s library to index into ElasticSearch.The way i built the pipeline is to index mulitple details at the same time and also index and fetch and fetch at the same time.

The GraphDSL is roughly built this way :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

   Source.fromFuture[builds](resolvedValue) ~> merge ~> broadcast

        broadcast ~> buildDetailsFromBuilds.async ~> buildItemBroadcast
        merge.preferred <~ buildsFromNext.async <~ broadcast

        val indexItems = buildItemBroadcast ~> indexBuildDetails
        buildItemBroadcast ~> balancerForBuilds ~> buildItemBalancer

        for (i <- 1 to balancers)
          buildItemBalancer ~> indexTestDetails.async ~> Sink.ignore


        buildItemBroadcast ~> indexBuildStats.async ~> Sink.ignore


        SourceShape(indexItems.outlet)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
{: .language-scala}

Am using balancers to have a controlled degree of parallelism in some ways whle i index those results.


The balancers could be adjusted this way :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
val balancers = 40
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
{: .language-scala}


Besides this , i add a closeStage to close the pipeline when all entries from TeamCity have been fully processed :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def closeStage[T] = new GraphStage[FlowShape[Option[T], Option[T]]] {
    val in = Inlet[Option[T]]("closeStage.in")
    val out = Outlet[Option[T]]("closeStage.out")

    override val shape: FlowShape[Option[T], Option[T]] = FlowShape.of(in, out)

    override def createLogic(inheritedAttributes: Attributes) = new GraphStageLogic(shape) {
      setHandler(in, new InHandler {
        override def onPush(): Unit = grab(in) match {
          case None ⇒
            completeStage()
          case msg ⇒
            push(out, msg)
        }
      })
      setHandler(out, new OutHandler {
        override def onPull(): Unit = pull(in)
      })
    }
  }
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
{: .language-scala}


And it could be embedded this way :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Flow[builds].map(_.nextHref)
      .via(FlowUtils.closeStage)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
{: .language-scala}

... (in progress ...)