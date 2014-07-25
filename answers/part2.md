First off, I would check the existing tests for this controller. If there were not any, I would start at least a controller spec and then continue on reading the rest of the code.
My first step would be to rename the controller. Is there a reason we can't call it CandidatesController? That seems to be what the point is and I like to keep
things as resource-focused (and RESTful) as possible. Once the controller is renamed, we could rename the show_candidates method too. I'm thinking just "def index"
would be fine since what we seem to be wanting to do here is present a list of candidates.

Next, I would remove the comments. The "has_permission?" method seems to have rendered the code in the comments moot so they are no longer
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

Next is the jobs.each code block where we query the database with CandidateJob.where(:job_id => job.id) for each job. That isn't necessary.
We can just use the jobs off of the JobContracts we just found, something like this:

```ruby
    job_ids = current_user.job_contacts.eager_load(:job).where("jobs.is_deleted = ?", false).pluck(:job_id)
```

Now this method chain is getting a bit long and it's quite hard to parse, but it's more performant than
what we had so we want to keep it around. For the sake of clarity, I would stick this line of code
behind a descriptively-named method on User. Perhaps something like "job_contact_ids" and it would look like this:

```ruby
    class User
      def job_contacts_ids
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

Now that we've gotten rid of lines 34-47, we can look at the next chunk, the if statement. This code is re-sorting
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
":candidates", which would allow us to use that variable name in the partial. Also, do we really want a partial here? Perhaps
if this method is only being called by some javascript on the frontend that is only expecting a small chunk of html, which may
be the case here. If so, I would wrap this in a respond_to do |format| block so we can make sure that this render is
only happening for xhr requests. I would also see if we could rename the partial. Ideally, we could just rename it to 'index'. If we could
just use 'def index', that would let us get rid of the whole render line. The "layout: false" could be moved to the top of the controller now.
We just have to make sure we add our .js extenstion to our index.html file so it gets served up for js requests.

There's a few more things left I would address. The line where s_key is set. I would move that into the class_methods on Candidate that
use it. The controller doesn't need to concern itself with worrying about what the default value for s_key should be. Now we're
left with a pretty simple looking if..else statement which we could probably move off into a method on candidate, something
like Candidate.for_user or something similar. Depending on how this extra code on candidate was making it look we could look into
moving all of the code we added to candidate into some other service class but I think this is good for now.

You can view the *.rb files in this directory to see what a finished product based on my above comments might look like.
