Blockage
========

Neo4j.rb somehow blocks itself in the `Node.wrapper` methods. Here are a couple of screenshots of a profiling session with [YourKit](http://www.yourkit.com). To begin with, two threads were started that both loaded a Neo4j node with `Neo4j::Node.load` (each thread it's own node).

![YourKit profiler output](http://dl.dropbox.com/u/1953503/Screenshots/2_qan1dzj_1f.png)

Things go relatively fine while there are only two threads read nodes. As soon as there's 4 threads, blocking starts and throughput goes down heavily.

This repo contains an `.rvmrc` and a Gemfile, so all you need to do is `source .rvmrc` and `bundle`. Then you can start the test runner console with `./test_runner.rb`.

Examples
========

Loading nodes using the `Node._load` method with concurrency 10 looks like this in the profiler. ~8M loads per minute on my laptop: 

    @node = Neo4j::Transaction.run{ Neo4j::Node.new(:name => 'Fred') }
    Runner.new(10).do!{ Neo4j::Node._load(1) }
    

![concurrency 10 without wrapper](http://dl.dropbox.com/u/1953503/Screenshots/j-r792_50k8p.png)

    ....................................................................................    Concurrency 10, actions total: 11131166, actions/min: 8294563

-----------------------------------

To see things break, let's use the `Node.load` method (without the `_`, hence loading the wrapper). Around 50k loads per minute on my laptop.

![concurrency 10 with wrapper](http://dl.dropbox.com/u/1953503/Screenshots/q24xwqqkq_18.png)

    ....................................................................................    Concurrency 10, actions total: 84412, actions/min: 50517

The screenshots were not made exactly as shown - each Thread accessed it's own node, not all threads the same one.