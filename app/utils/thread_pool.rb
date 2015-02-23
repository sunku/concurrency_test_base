require 'thread'

class ThreadPool
  # ### initialization, or `Pool.new(size)`
  # Creating a new `Pool` involves a certain amount of work. First, however,
  # we need to define its’ `size`. It defines how many threads we will have
  # working internally.
  # 
  # Which size is best for you is hard to answer. You do not want it to be
  # too low, as then you won’t be able to do as many things concurrently.
  # However, if you make it too high Ruby will spend too much time switching
  # between threads, and that will also degrade performance!

  def initialize(size)
    # Before we do anything else, we need to store some information about
    # our pool. `@size` is useful later, when we want to shut our pool down,
    # and `@jobs` is the heart of our pool that allows us to schedule work.
    @size = size
    @jobs = Queue.new
    
    # #### Creating our pool of threads
    # Once preparation is done, it’s time to create our pool of threads.
    # Each thread store its’ index in a thread-local variable, in case we
    # need to know which thread a job is executing in later on.
    @pool = Array.new(@size) do |i|
      Thread.new do
        Thread.current[:id] = i

        # We start off by defining a `catch` around our worker loop. This
        # way we’ve provided a method for graceful shutdown of our threads.
        # Shutting down is merely a `#schedule { throw :exit }` away!
        catch(:exit) do
          # The worker thread life-cycle is very simple. We continuously wait
          # for tasks to be put into our job `Queue`. If the `Queue` is empty,
          # we will wait until it’s not.
          loop do
            # Once we have a piece of work to be done, we will pull out the
            # information we need and get to work.
            job, args = @jobs.pop
            job.call(*args)
          end
        end
      end
    end
  end
  
  # ### Work scheduling
  
  # To schedule a piece of work to be done is to say to the `Pool` that you
  # want something done.
  def schedule(*args, &block)
    # Your given task will not be run immediately; rather, it will be put
    # into the work `Queue` and executed once a thread is ready to work.
    @jobs << [block, args]
  end
  
  # ### Graceful shutdown
  
  # If you ever wish to close down your application, I took the liberty of
  # making it easy for you to wait for any currently executing jobs to finish
  # before you exit.
  def shutdown
    # A graceful shutdown involves threads exiting cleanly themselves, and
    # since we’ve defined a `catch`-handler around the threads’ worker loop
    # it is simply a matter of throwing `:exit`. Thus, if we throw one `:exit`
    # for each thread in our pool, they will all exit eventually!
    @size.times do
      schedule { throw :exit }
    end
    
    # And now one final thing: wait for our `throw :exit` jobs to be run on
    # all our worker threads. This call will not return until all worker threads
    # have exited.
    @pool.map(&:join)
  end

  def current_job_size
    @jobs.size
  end
end
######################################### Thread Pool Implementation Done