##Hireology Software Engineer Homework

### Instructions

There are two parts to the Software Engineer Homework set. Part 1 is written answer, and Part 2 is a set of programmable problems. Please fork this repo to your GitHub account, add your work to the forked repo, and send a pull request when your work is complete.

###Part 1 - Written Questions

1. How can Memcache improve a site’s performance? Include a description about how data is stored and retrieved in a multi-node configuration.

Memcache is basically a key-value datastore that completely runs in memory (RAM) and is typically used to stored chunks of data. It does not store any data on disk like a traditional database
so you can store and retrieve data quite a bit faster. In a multi-node configuration, where the nodes are application servers for example,
each node would be configured to point to that main memcached server. The process of storing and retrieving data in memcached looks something like this:

  1. An app needs to make an expensive query (expensive in terms of time, how long it takes to run) to a database.

  2. It checks to see if we have stored the results of that expensive query in memcached yet.

  3. The app sees that there is not anything stored in memcached for this query, so it run the query against the database.

  4. The app takes the results of that expensive call and stores it in memcached.

  5. The next time the app goes to make that expensive call, it again checks memcached first. This time the app sees that the results are in memcached so memcahced returns the results to the app and the app can carry on with the results, without having to run the query agaist the database.

2. Please take a look at [this controller action](https://github.com/Hireology/homework/blob/master/some_controller.rb). Please tell us what you think of this code and how you would make it better.

  First off, I would check the existing tests for this controller. If there were not any, I would start one and then continue on reading the rest of the code.
  My first step would be to remove the comments. The "has_permission?" method seems to have rendered the code in the comments moot so they are no longer
  relevant. If we need to get them back or reference them for whatever reason, we can just look through the git commit history. Also, I don't believe
  you can use .all() like that in vanilla Rails 4 so anywhere in this file where there is an ".all", I would replace it with a where. Unless the "all" gave us something
  the "where" does not.

  Next I would take the code under the
  ```ruby
    if current_user.has_permission?('view_candidates')
  ```
   branch and move it off into a class method on Candidate. That method could take the organization and the sort_key and return the proper collection of
  candidates. Something like
  ```ruby
    @candidates = Candidate.for_organization(organization, sort_by)
  ```

  Next I would look into the relationship between JobContact and User to see if we could just do
  ```ruby
    current_user.job_contacts
  ```
  instead of

  ```ruby
    JobContact.where(:user_id => current_user.id)
  ```
  Now since we collect the jobs off of the job_contacts next, we could
  handle that when we load the JobContacts, with something like
  ```ruby
    current_user.job_contacts.eager_load(:job).where("jobs.is_deleted = ?", false)
  ```
  That would allow us to remove the "job_contacts.each" chunk of code since we already have the job_contracts and their related (and non-deleted) jobs.

  Next is the jobs.each code block where we query the database with CandidateJob.where(:job_id => job.id) for each job. This isn't necessary.
  We can just use the jobs off of the JobContracts we just found, something like this:

  ```ruby
    job_ids = current_user.job_contacts.eager_load(:job).where("jobs.is_deleted = ?", false).pluck(:job_id)
  ```

  Now this method chain is getting a bit long and it's quite hard to parse, but it's more performant than
  what we had so we want to keep it around. For the sake of clarity, I would stick this line of code
  behind a descriptively-named method on User. Perhaps something like "job_contact_ids" and it would look like this:

  ```ruby
  class User
    def job_contact_ids
      job_contacts.eager_load(:job).where("jobs.is_deleted = ?", false).pluck(:job_id)
    end
  end
  ```

  That would allow us to change up how we query CandidateJob.

  ```ruby
    job_ids = current_user.job_contact_ids
    candidate_jobs = CandidateJob.where(:job_id => job_ids).eager_load(:candidate)
  ```

  We eagerly load the candidates since we are going to use them later.

  Next we remove the "unless candidate_jobs.blank?" and related "end" since it's not necessary and start iterating through the candidate_jobs. However,
  one of the first things we do is run a few boolean checks on the candidate. We can move those checks into our initial query, making the database do the heavy lifting
  since it's more optimized for it. So we can use something like

  ```ruby
    candidate_jobs = CandidateJob.where(:job_id => job_ids).
                       eager_load(:candidate).
                       where("#{Candidate.table_name}.is_deleted = ? AND #{Candidate.table_name}.is_completed = ? AND #{Candidate.table_name}.organization_id = ?",  false, true, current_user.organization_id)
  ```
  Now again, this query is getting a little long so we could also move it to a method on CandidateJob. Something like

  ```ruby
  class CandidateJob
    def self.jobs_for_active_candidates(job_ids)
      where(:job_id => job_ids).
        eager_load(:candidate).
        where("#{Candidate.table_name}.is_deleted = ? AND #{Candidate.table_name}.is_completed = ? AND #{Candidate.table_name}.organization_id = ?",  false, true, current_user.organization_id)
    end
  end
  ```

  Which would turn our above code into:
  ```ruby
    candidate_jobs = CandidateJob.jobs_for_active_candidates(job_ids)
  ```

  Now that we've gotten rid of lines 34-47, we can look at the next chunk, the if statement. This code is resorting
  @candidates for each candidate_job we look at. Now that we don't need to go through each candidate_job, we can just remove it. Lines
  48-56 can be trashed but we still need to set @candidates, which we can. We can get the candidate_ids off of
  the method we just added to CandidateJob and query for candidates based on those ids. Something like
  ```ruby
    candidate_ids = candidate_jobs.pluck(:candidate_id)
    @candidates = Candidate.for_ids(candidate_ids, sort_by)
  ```
  I like the idea of adding another class method on Candidate to handle this since that would allow us to use
  the sorting logic we would have used in Candidate.for_organization above. Code reuse where possible is always good.

  So now we are just down to the render statement. I would not use ":@candidates" as a key in locals. I would just use
  ":candidates", which would allow us to use that variable name in the partial.

  I think that covers most of the fixes I would make on my first pass. If I liked the way the tests looked
  and everything interacted. I would move on.

  Actually, there's one more thing. Line 3 where s_key is set. I would move that into the class_methods on Candidate that
  use it. The controller doesn't need to concern itself with worrying about what the default value for s_key should
  be.

###Part 2 - Programming Problems

1) Write a program using regular expressions to parse a file where each line is of the following format:

`$4.99 TXT MESSAGING – 250 09/29 – 10/28 4.99`

For each line in the input file, the program should output three pieces of information parsed from the line in the following JSON format (using the above example line):

```
{
  “feature” : “TXT MESSAGING – 250”,
  “date_range” : “09/29 – 10/28”,
  “price” : 4.99 // use the last dollar amount in the line
}
```

2) Please complete a set of classes for the problem described in [this blog post](http://www.adomokos.com/2012/10/the-organizations-users-roles-kata.html). Please do not create a database backend for this. Test doubles should work fine.
