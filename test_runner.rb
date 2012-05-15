#!/usr/bin/env ruby
puts "Loading gems..."
require 'rubygems'
require 'irb'
require 'bundler'

Bundler.require

class Runner
  def initialize(num_threads, dot_every = 1000)
    @threads     = []
    @start       = Time.now
    @actions       = 0
    @run         = true
    @dot_every   = dot_every
    @num_threads = num_threads
    init_trap
    puts "Concurrency #{@num_threads}"
  end

  def init_trap
    trap("INT") do
      @run=false
      @threads.map{|t| Thread.kill(t)}
      duration = Time.now - @start
      puts "\nConcurrency #{@num_threads}, actions total: #{@actions}, actions/min: #{(((@actions)/duration)*60).floor}"
    end 
  end

  def do!(&block)
    @num_threads.times do |thread_num|
      t = Thread.new do
        my_block = block.clone
        while @run do
          my_block.call(thread_num)
          @actions+=1
          print "." if @actions % @dot_every == 0
        end 
      end.run
      @threads << t
      t.run
    end
  end
end

puts ""
puts "To load a node with 4 threads in parallel, copy & paste this"
puts "  @node = Neo4j::Transaction.run{ Neo4j::Node.create(:name => 'fred') }"
puts "  Runner.new(4).do!{ Neo4j::Node.load(@node.id) }\n"
puts ""
puts "- every 1000 actions, a '.' is printed"
puts "- press control-c to stop and see a summary"
puts "- press control-d to quit the irb"
puts ""

IRB.start
