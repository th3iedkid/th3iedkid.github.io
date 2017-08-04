---
layout: post
title:  "Functional programming and referential transparency"
author: "Ganesh"
date:   2017-08-04 19:44:08 +0530
categories: functional-programming FP
---

Functional programming is a programming paradigm .A programming paradigm is actually more of a semantic style for the structures and elements of a computer program.

Before dwelving into the details of functional programming ,some more details on different semantic models might be of great help.So lets get them first.

### Formal Semantics of a programming language ###
In programming language theory, semantics is the field concerned with the rigorous mathematical study of the meaning of programming languages.It does so by evaluating the meaning of syntactically legal strings defined by a specific programming language, showing the computation involved.In such a case that the evaluation would be of syntactically illegal strings, the result would be non-computation. Semantics describes the processes a computer follows when executing a program in that specific language.

Formal semantics of interest for compiler writers,interpreter writers and complex program analysis in say distributed settings.

Formal semantics, for instance, helps better understand what a program is doing and to prove, e.g., that the following if statement, is as good as evaluating S1 alone.

`if 1 = 1 then S1 else S2`

The field of formal semantics encompasses all of the following:

    The definition of semantic models
    The relations between different semantic models
    The relations between different approaches to meaning
    The relation between computation and the underlying mathematical structures from fields such as logic, set theory, model theory, category theory, etc.

It has close links with other areas of computer science such as programming language design, type theory, compilers and interpreters, program verification and model checking.

There are different approaches to formal semantics , namely denotational semantics, operational semantics,axomatic semantics.

Denotational semantics is about attaching a conceptual meaning , abstractly to each phrase of a language.While such notations are usually mathematical for mathematical objects occupying some mathematical space,it isn't a requirement either.A loose e.g. for those used to Object Relational Mapping,in ORM , you could build your own language layer that denotationally translates (or maps) objects to relational tuples(and hence they give different abstractions of the space of relational algebra vis object oriented schemes).Another strict and rigourous example is of functional languages translated to a mathematical space called Domain theory.

Operational semantics is about execution semantics.E.g. for those used to JVMs (or CLRs or assemblers etc), its often the case that, while you write programs in Java/Scala/Clojure/Ruby/Python etc , your code is eventually compiled to something called a byte-code and evaluated in something called an interpreter.Operational semantics then details on the mappings between say Java and the eventual bye-code instructions.These are generally of use in code-generators, dynamic optimizers etc.

Axiomatic semantics is the process by which one gives meaning to phrases by describing the logical axioms that apply to them. Axiomatic semantics makes no distinction between a phrase's meaning and the logical formulas that describe it; its meaning is exactly what can be proven about it in some logic.       

There are many variations to the above, however.

### Referential Transparency ###

There is one other major concept called referential transparency .Its a property, which makes it easier to reason about a given program written in a given lanugage.Its a property that is very similar to mathematical equations.In a long drawn equation , if there are a number of variables , while these variables can take in a constrained set of values, the variables make the logical assertion drawn out by the equation rather directly.

A more formal definition that is easier to understand is :

` "The phrase 'referentially transparent' is used to describe notations where only the meaning (value) of immediate component expressions (sentences/phrases) is significant in determining the meaning of a compound expression (sentence/phrase). Since expressions are equal if and only if they have the same meaning, referential transparency means that substitutivity of equality holds (i.e. equal subexpressions can be interchanged in the context of a larger expression to give equal results)." Reade, Chris; Elements of Functional Programming, p. 10; Addison-Wesley, 1989. `   

Another one ,

` "The fundamental property of mathematical functions which enables us to plug together block boxes [he is referring here to 'built-in functions or primitives' described in a previous paragraph] in this way is the property of 'referential transparency.' There are a number of intuitive reading of the term, but essentially it means that each expression denotes a single value which cannot be changed by evaluating the expression or by allowing different parts of a program to share the expression. Evaluation of the expression simply changes the form of the expression but never its value. All references to the value are therefore equivalent to the value itself and the fact that the expression may be referred to from other parts of the program is of no concern." Field, Anthony, and Harrison, Peter G.; Functional Programming, p. 10; Addison-Wesley, 1988. `

### Functional Purity ###

Referntial transparency has direct associativity to funtionally pure languages.

Lets say our language is made up of expressions which form statements which compose a given program.

An expression e is referentially transparent if for all programs p, every occurrence of e in p can be replaced with the result of evaluating e without changing the result of evaluating p.

A function f is pure if the expression f(x) is referentially transparent for all referentially transparent x.

Denotationally , however clear this may be , its however, its operational semantics that does effect its context .The context has to clarify, in no-uncertain terms,what makes `evaluation` of the function transparent in itself.It also needs to define `occurence` , `program` and `replace`.  

Thus one can see how purity is a contextual abstraction around a given context.Sometimes this is an execution context, other times , it might be a different denotational context.

The denotational context is what is captured by property based testing .
In scala , for e.g. 

~~~~~~~~~~~~~~~~~~~~~~~~~
class Fraction(n: Int, d: Int) {

  require(d != 0)
  require(d != Integer.MIN_VALUE)
  require(n != Integer.MIN_VALUE)

  val numer = if (d < 0) -1 * n else n
  val denom = d.abs

  override def toString = numer + " / " + denom
}


forAll { (n: Int, d: Int) =>

  whenever (d != 0 && d != Integer.MIN_VALUE
      && n != Integer.MIN_VALUE) {

    val f = new Fraction(n, d)

    if (n < 0 && d < 0 || n > 0 && d > 0)
      f.numer should be > 0
    else if (n != 0)
      f.numer should be < 0
    else
      f.numer should be === 0

    f.denom should be > 0
  }
}
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The forAll based property tests illustrate the fact that , Fractional has a property for numer and denom , which always follow the constraints , and they are also referentially transparent across different values of the inputs.

While referential transparency is not a necessary condition for property tests to be evaluated to success, they however do offer a good illustration of transparency.

Coming back to the question of functional purity,

### What is impure ###

There are many different divergent understanding of the what impure really constitutes.

Impurity is not about not doing state transitions, not about not side-effecting , its rather about containing and qulafying those aspects in discrete contextual ways , so that referential gaurentees can be held in different ways.

The leak in abstraction offered by usage of context in referential transparency does offer more scope for defining purity differently , however, conventions dominate it differently.

### Further readings ###

[What is Purely Functional Language ](https://www.cs.indiana.edu/~sabry/papers/purelyFunctional.ps)
[Fundamental Concepts in Programming languages](https://www.itu.dk/courses/BPRD/E2009/fundamental-1967.pdf)

## More ##

There shall be more articles continuing this topic.