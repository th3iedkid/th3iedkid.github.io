---
layout: post
title:  "Functional Patterns in Effectful Computations and Values"
author: "Ganesh"
date:   2017-08-05 18:38:08 +0530
categories: functional-programming FP effects
---
While this is continuing on the theme of functional languages and referential transparency, it slightly digresses further onto effectful computation.

Its often a common pattern that one would like to execute a series commands or sequence of commands on a series of values.These commands could themselves be effectful, like say inserting into an external database.There are many patterns for such a sequence , one of which is `seqeuence` or `tranverse` pattern in Haskell as well as Scala.

The Haskell variant looks like this :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

sequence :: [IO a] -> IO[a]
sequence [] = return []
sequence (c:cs) = do
        x <- x
        xs <- sequence cs
        return(x:xs)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~   

To brief , it would read like a list of effectful IO (input/output) computations on values, would be translated to an effectful computation of list of values.Sequence , can thus transform your bunch of effects , to ordered execution of effects.     


In scala for e.g. with traverse on future displays a similar pattern

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

import scala.concurrent.{ExecutionContext, Future}

def traverseFuture[A, B](as: List[A])(f: A => Future[B])(implicit ec: ExecutionContext): Future[List[B]] =
  Future.traverse(as)(f)

//example usage under a thread execution context , assumed implicit

traverseFuture(List(1,2,3,4))(x=>Future.sucessful(x.toString))
//would return a future containing list of strings 
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

However,lets say we would like to abstract away the container , which happens to be a list in this case, to something else , which in its own way dictates , how it would compose the effects. The container list for e.g. is an instance of such an abstraction , stating that it would effect on the values ,one after the other , in order.

Before we dvelve into such containers, there are certain things ,that when introduced makes understanding those palpable.

First of those is Functors.Functors are containers which help warp a single-effectful-computation.
Lets talk about Lists, lists are effectively sequences which help wrap a single effect , which could be just about wrapping a value returning effect.Functors are about lifting a pure function , which can be referentially transpared indpendent of external contexts, to be wrapped in an effectfull computational context.

In scala , this could be viewed as :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
trait Functor[F[_]] {
  def map[A, B](fa: F[A])(f: A => B): F[B]

  def lift[A, B](f: A => B): F[A] => F[B] =
    fa => map(fa)(f)
}
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The F in Functor is often referred to as an “effect” or “computational context.” Different effects will abstract away different behaviors with respect to fundamental functions like map. For instance, Option’s effect abstracts away potentially missing values, where map applies the function only in the Some case but otherwise `threads` the None through.

The concept of thread is about effecting these effectful computations.

Functors actually contextualize only one effect at a time , if closely observed.There are other patterns to help compose more than one effect across more than a few values , in a semantically comprehensive form.One of them is Applicatives .

Applicative extends Functor with an ap and pure method.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

trait Applicative[F[_]] extends Functor[F] {
  def product[A, B](fa: F[A], fb: F[B]): F[(A, B)]
  def ap[A, B](ff: F[A => B])(fa: F[A]): F[B]
  def pure[A](a: A): F[A]

  def map[A, B](fa: F[A])(f: A => B): F[B] = ap(pure(f))(fa)
}
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 

Pure . helps wrap a value onto an effectful context.

Applicative is about applying a transformation from one effect to another ,over a value. 
One of the underlying assumption is the fact that, this higher order transformation is in-itself
a functor.This is the apply prespective of the fact.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

val transformation:Option[Int=>String]=Some(_.toString)

Applicative[Option[Int]].ap(transformation)(Some(2))

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 


Applicative encodes working with multiple independent effects. Between product and map, we can take two separate effectful values and compose them

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Applicative[Option[Int]].product(Some(1),None) == None
Applicative[Option[Int]].product(Some(1),Some(4)) == Some(1,4)

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

From there we can generalize to working with any N number of independent effects.

F[A => B] is about transforming an effect of one form to another, e.g. 
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
def product3[F[_]: Applicative, A, B, C](fa: F[A], fb: F[B], fc: F[C]): F[(A, B, C)] = {
  val F = Applicative[F]
  val fabc = F.product(F.product(fa, fb), fc)
  F.map(fabc) { case ((a, b), c) => (a, b, c) }
}

//continuing ....

val username: Option[String] = Some("username")
val password: Option[String] = Some("password")
val url: Option[String] = Some("some.login.url.here")

def attemptConnect(username: String, password: String, url: String): Option[Connection] = None

Applicative[Option].map3(username, password, url)(attemptConnect)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

