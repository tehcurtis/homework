class CandidatesController < ApplicationController
  layout: false

  def index
    @open_jobs = Job.all_open_new(current_user.organization)

   if current_user.has_permission?('view_candidates')
     @candidates = Candidate.for_organization(current_user.organization, params[:sort])
   else
     job_ids = current_user.job_contacts_ids
     @candidate = if job_ids.blank?
                    # no need to run the other queries
                    @candidates = []
                  else
                    candidate_ids = CandidateJob.jobs_for_active_candidates(job_ids).pluck(:candidate_id)
                    @candidates = Candidate.for_ids(candidate_ids, params[:sort])
                  end
   end

    respond_to do |format|
      format.js do

      end
    end
  end
end
